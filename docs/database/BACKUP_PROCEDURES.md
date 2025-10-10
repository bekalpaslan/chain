# Database Backup & Recovery Procedures

This document outlines the backup strategy, recovery procedures, and disaster recovery plan for the Ticketz PostgreSQL database.

## Table of Contents

1. [Backup Strategy](#backup-strategy)
2. [Backup Procedures](#backup-procedures)
3. [Recovery Procedures](#recovery-procedures)
4. [Disaster Recovery](#disaster-recovery)
5. [Testing and Validation](#testing-and-validation)
6. [Troubleshooting](#troubleshooting)

---

## Backup Strategy

### Objectives

- **RPO (Recovery Point Objective):** 15 minutes
  - Maximum acceptable data loss
  - Achieved through WAL archiving

- **RTO (Recovery Time Objective):** 1 hour
  - Maximum acceptable downtime
  - Achieved through automated restore procedures

### Backup Types

#### 1. Daily Full Backups

- **Frequency:** Daily at 2:00 AM UTC
- **Method:** pg_dump with custom format (-Fc)
- **Retention:** 30 days
- **Location:** Local storage + S3 bucket

#### 2. Weekly Full Backups

- **Frequency:** Sunday at 3:00 AM UTC
- **Method:** pg_dump with custom format (-Fc)
- **Retention:** 90 days
- **Location:** S3 bucket (glacier storage after 30 days)

#### 3. Monthly Full Backups

- **Frequency:** First Sunday of each month
- **Method:** pg_dump with custom format (-Fc)
- **Retention:** 1 year
- **Location:** S3 bucket (glacier storage immediately)

#### 4. Continuous WAL Archiving

- **Frequency:** Continuous (5-minute intervals)
- **Method:** PostgreSQL WAL archiving
- **Retention:** 30 days
- **Location:** Local storage + S3 bucket
- **Purpose:** Point-in-time recovery (PITR)

---

## Backup Procedures

### Automated Daily Backup

#### Setup

Create the backup script:

```bash
#!/bin/bash
# /scripts/backup-database.sh

set -e  # Exit on error
set -u  # Exit on undefined variable

# Configuration
BACKUP_DIR="/backups/postgresql"
S3_BUCKET="s3://chain-backups/postgresql"
DB_CONTAINER="chain-postgres"
DB_NAME="chaindb"
DB_USER="chain"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="chaindb_${DATE}.dump"
LOG_FILE="/var/log/backup-database.log"

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Start backup
log "Starting database backup: $BACKUP_FILE"

# Create backup directory if not exists
mkdir -p "$BACKUP_DIR"

# Create backup using pg_dump
if docker exec "$DB_CONTAINER" pg_dump -U "$DB_USER" -Fc "$DB_NAME" > "${BACKUP_DIR}/${BACKUP_FILE}"; then
    log "Backup created successfully: $BACKUP_FILE"
else
    log "ERROR: Backup failed"
    exit 1
fi

# Verify backup file is not empty
BACKUP_SIZE=$(stat -c%s "${BACKUP_DIR}/${BACKUP_FILE}")
if [ "$BACKUP_SIZE" -lt 1000 ]; then
    log "ERROR: Backup file is suspiciously small ($BACKUP_SIZE bytes)"
    exit 1
fi
log "Backup size: $BACKUP_SIZE bytes"

# Compress old backups (older than 7 days)
log "Compressing old backups"
find "$BACKUP_DIR" -name "*.dump" -mtime +7 -exec gzip {} \;

# Upload to S3
log "Uploading backup to S3"
if aws s3 cp "${BACKUP_DIR}/${BACKUP_FILE}" "${S3_BUCKET}/daily/${BACKUP_FILE}"; then
    log "Backup uploaded to S3 successfully"
else
    log "WARNING: S3 upload failed, backup is only available locally"
fi

# Delete local backups older than 30 days
log "Cleaning up old local backups"
find "$BACKUP_DIR" -name "*.dump.gz" -mtime +30 -delete
find "$BACKUP_DIR" -name "*.dump" -mtime +30 -delete

# Verify backup integrity
log "Verifying backup integrity"
if docker exec "$DB_CONTAINER" pg_restore -l "${BACKUP_DIR}/${BACKUP_FILE}" > /dev/null 2>&1; then
    log "Backup integrity verified successfully"
else
    log "ERROR: Backup integrity check failed"
    exit 1
fi

log "Backup completed successfully"
```

#### Make script executable:

```bash
chmod +x /scripts/backup-database.sh
```

#### Schedule with cron:

```bash
# Edit crontab
crontab -e

# Add daily backup at 2 AM
0 2 * * * /scripts/backup-database.sh

# Add weekly backup at 3 AM on Sundays
0 3 * * 0 /scripts/backup-database-weekly.sh

# Add monthly backup at 4 AM on first Sunday
0 4 1-7 * 0 /scripts/backup-database-monthly.sh
```

### Manual Backup

For one-off backups before major changes:

```bash
# Full database backup
docker exec chain-postgres pg_dump -U chain -Fc chaindb > backup_manual_$(date +%Y%m%d_%H%M%S).dump

# Schema-only backup (structure without data)
docker exec chain-postgres pg_dump -U chain -s chaindb > backup_schema_$(date +%Y%m%d_%H%M%S).sql

# Data-only backup (data without structure)
docker exec chain-postgres pg_dump -U chain -a chaindb > backup_data_$(date +%Y%m%d_%H%M%S).sql

# Specific table backup
docker exec chain-postgres pg_dump -U chain -t users chaindb > backup_users_$(date +%Y%m%d_%H%M%S).sql
```

### WAL Archiving Setup

#### Configure PostgreSQL for WAL archiving:

```bash
# Edit postgresql.conf
docker exec -it chain-postgres bash

# In the container:
cat >> /var/lib/postgresql/data/postgresql.conf <<EOF

# WAL archiving configuration
wal_level = replica
archive_mode = on
archive_command = 'test ! -f /backups/wal_archive/%f && cp %p /backups/wal_archive/%f'
archive_timeout = 300  # Force switch every 5 minutes
max_wal_senders = 3
wal_keep_size = 1GB
EOF

# Restart PostgreSQL
docker restart chain-postgres
```

#### Create WAL archive directory:

```bash
# Create directory
mkdir -p /backups/wal_archive

# Set permissions
chmod 750 /backups/wal_archive
chown postgres:postgres /backups/wal_archive
```

#### Archive WAL files to S3:

```bash
#!/bin/bash
# /scripts/archive-wal.sh

WAL_ARCHIVE_DIR="/backups/wal_archive"
S3_BUCKET="s3://chain-backups/wal_archive"

# Upload WAL files to S3
aws s3 sync "$WAL_ARCHIVE_DIR" "$S3_BUCKET" --delete

# Delete local WAL files older than 30 days
find "$WAL_ARCHIVE_DIR" -name "0*" -mtime +30 -delete
```

Schedule with cron:
```bash
# Run every 15 minutes
*/15 * * * * /scripts/archive-wal.sh
```

---

## Recovery Procedures

### Full Database Restore

Use this when you need to restore the entire database from a backup.

#### Prerequisites

- Backup file available (local or S3)
- Database credentials
- Sufficient disk space
- Application stopped (to prevent write conflicts)

#### Procedure

```bash
#!/bin/bash
# /scripts/restore-database.sh

set -e

# Configuration
BACKUP_FILE="$1"  # Pass backup file as argument
DB_CONTAINER="chain-postgres"
DB_NAME="chaindb"
DB_USER="chain"

if [ -z "$BACKUP_FILE" ]; then
    echo "Usage: $0 <backup_file>"
    exit 1
fi

if [ ! -f "$BACKUP_FILE" ]; then
    echo "ERROR: Backup file not found: $BACKUP_FILE"
    exit 1
fi

echo "=========================================="
echo "DATABASE RESTORE PROCEDURE"
echo "=========================================="
echo "Backup file: $BACKUP_FILE"
echo "Database: $DB_NAME"
echo "Container: $DB_CONTAINER"
echo ""
echo "WARNING: This will DROP and RECREATE the database!"
echo "Press Ctrl+C to cancel, or Enter to continue..."
read

# Step 1: Stop application
echo "[1/7] Stopping application..."
docker-compose stop backend

# Step 2: Drop and recreate database
echo "[2/7] Dropping existing database..."
docker exec "$DB_CONTAINER" psql -U "$DB_USER" -c "DROP DATABASE IF EXISTS ${DB_NAME};"

echo "[3/7] Creating fresh database..."
docker exec "$DB_CONTAINER" psql -U "$DB_USER" -c "CREATE DATABASE ${DB_NAME};"

# Step 3: Restore from backup
echo "[4/7] Restoring from backup..."
docker exec -i "$DB_CONTAINER" pg_restore -U "$DB_USER" -d "$DB_NAME" -v < "$BACKUP_FILE"

# Step 4: Verify data
echo "[5/7] Verifying restored data..."
USER_COUNT=$(docker exec "$DB_CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" -t -c "SELECT COUNT(*) FROM users;")
echo "Users in database: $USER_COUNT"

TICKET_COUNT=$(docker exec "$DB_CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" -t -c "SELECT COUNT(*) FROM tickets;")
echo "Tickets in database: $TICKET_COUNT"

# Step 5: Rebuild indexes (optional, for performance)
echo "[6/7] Rebuilding indexes..."
docker exec "$DB_CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" -c "REINDEX DATABASE ${DB_NAME};"

# Step 6: Analyze tables
echo "[7/7] Analyzing tables..."
docker exec "$DB_CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" -c "ANALYZE;"

# Restart application
echo "Restore completed successfully!"
echo "Starting application..."
docker-compose start backend

echo ""
echo "=========================================="
echo "RESTORE COMPLETE"
echo "=========================================="
echo "Please verify application functionality"
```

Make executable:
```bash
chmod +x /scripts/restore-database.sh
```

Usage:
```bash
# Restore from latest backup
./scripts/restore-database.sh /backups/postgresql/chaindb_20250110_020000.dump

# Or restore from S3
aws s3 cp s3://chain-backups/postgresql/daily/chaindb_20250110_020000.dump ./
./scripts/restore-database.sh ./chaindb_20250110_020000.dump
```

### Point-in-Time Recovery (PITR)

Use this when you need to restore to a specific timestamp (e.g., before an accidental deletion).

#### Procedure

```bash
#!/bin/bash
# /scripts/restore-pitr.sh

set -e

# Configuration
BASE_BACKUP="$1"        # Full backup file
RECOVERY_TARGET="$2"    # Target timestamp: '2025-01-10 15:30:00'
WAL_ARCHIVE_DIR="/backups/wal_archive"
DB_CONTAINER="chain-postgres"
DB_NAME="chaindb"
DB_USER="chain"

if [ -z "$BASE_BACKUP" ] || [ -z "$RECOVERY_TARGET" ]; then
    echo "Usage: $0 <base_backup_file> <recovery_target_timestamp>"
    echo "Example: $0 backup.dump '2025-01-10 15:30:00'"
    exit 1
fi

echo "=========================================="
echo "POINT-IN-TIME RECOVERY"
echo "=========================================="
echo "Base backup: $BASE_BACKUP"
echo "Recovery target: $RECOVERY_TARGET"
echo ""
echo "Press Ctrl+C to cancel, or Enter to continue..."
read

# Step 1: Stop application and database
echo "[1/6] Stopping services..."
docker-compose stop backend
docker-compose stop postgres

# Step 2: Restore base backup
echo "[2/6] Restoring base backup..."
docker-compose start postgres
sleep 5
docker exec "$DB_CONTAINER" psql -U "$DB_USER" -c "DROP DATABASE IF EXISTS ${DB_NAME};"
docker exec "$DB_CONTAINER" psql -U "$DB_USER" -c "CREATE DATABASE ${DB_NAME};"
docker exec -i "$DB_CONTAINER" pg_restore -U "$DB_USER" -d "$DB_NAME" < "$BASE_BACKUP"

# Step 3: Stop database to configure recovery
echo "[3/6] Configuring recovery..."
docker-compose stop postgres

# Step 4: Create recovery configuration
cat > /tmp/recovery.conf <<EOF
restore_command = 'cp ${WAL_ARCHIVE_DIR}/%f %p'
recovery_target_time = '${RECOVERY_TARGET}'
recovery_target_action = 'promote'
EOF

# Copy recovery.conf to PostgreSQL data directory
docker cp /tmp/recovery.conf "${DB_CONTAINER}:/var/lib/postgresql/data/recovery.conf"

# Step 5: Start PostgreSQL in recovery mode
echo "[4/6] Starting recovery process..."
docker-compose start postgres

# Monitor recovery
echo "[5/6] Monitoring recovery progress..."
echo "Waiting for recovery to complete (this may take several minutes)..."
sleep 10

# Check if recovery completed
while true; do
    RECOVERY_STATUS=$(docker exec "$DB_CONTAINER" psql -U "$DB_USER" -t -c "SELECT pg_is_in_recovery();")
    if [[ "$RECOVERY_STATUS" == *"f"* ]]; then
        echo "Recovery completed!"
        break
    fi
    echo "Still recovering... ($(date))"
    sleep 5
done

# Step 6: Verify data
echo "[6/6] Verifying restored data..."
docker exec "$DB_CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" -c "SELECT COUNT(*) FROM users;"

echo ""
echo "=========================================="
echo "PITR COMPLETE"
echo "=========================================="
echo "Database restored to: $RECOVERY_TARGET"
echo "Starting application..."
docker-compose start backend
```

Usage:
```bash
./scripts/restore-pitr.sh /backups/chaindb_20250110_020000.dump '2025-01-10 15:30:00'
```

### Table-Level Recovery

Use this to restore a single table without affecting the rest of the database.

```bash
#!/bin/bash
# Restore single table

BACKUP_FILE="$1"
TABLE_NAME="$2"

if [ -z "$BACKUP_FILE" ] || [ -z "$TABLE_NAME" ]; then
    echo "Usage: $0 <backup_file> <table_name>"
    exit 1
fi

# Extract table from backup to temp database
docker exec chain-postgres psql -U chain -c "CREATE DATABASE temp_restore;"
docker exec -i chain-postgres pg_restore -U chain -d temp_restore -t "$TABLE_NAME" < "$BACKUP_FILE"

# Dump restored table
docker exec chain-postgres pg_dump -U chain -t "$TABLE_NAME" temp_restore > "/tmp/${TABLE_NAME}_restored.sql"

# Drop temp database
docker exec chain-postgres psql -U chain -c "DROP DATABASE temp_restore;"

echo "Table $TABLE_NAME extracted to /tmp/${TABLE_NAME}_restored.sql"
echo "Review the file and manually apply changes to production database"
```

---

## Disaster Recovery

### Disaster Scenarios

#### 1. Database Corruption

**Symptoms:**
- PostgreSQL won't start
- Data inconsistency errors
- Index corruption

**Recovery:**
1. Stop application
2. Restore from latest backup
3. Apply WAL files for PITR (if needed)
4. Verify data integrity
5. Restart application

#### 2. Accidental Data Deletion

**Symptoms:**
- User reports missing data
- Unintended DELETE or UPDATE operations

**Recovery:**
1. Identify the timestamp before deletion
2. Use PITR to restore to that timestamp
3. Export affected data
4. Restore current database
5. Import recovered data

#### 3. Server Failure

**Symptoms:**
- Server unresponsive
- Hardware failure
- Network issues

**Recovery:**
1. Provision new server
2. Install PostgreSQL and dependencies
3. Download latest backup from S3
4. Download WAL files from S3
5. Restore database with PITR
6. Update DNS/load balancer
7. Start application

#### 4. Ransomware Attack

**Symptoms:**
- Files encrypted
- Database inaccessible
- Ransom demand

**Recovery:**
1. DO NOT pay ransom
2. Isolate affected systems
3. Provision clean server
4. Restore from offsite backup (S3)
5. Verify no corruption in backup
6. Update all credentials
7. Implement security improvements

### Disaster Recovery Runbook

```bash
#!/bin/bash
# /scripts/disaster-recovery.sh

echo "=========================================="
echo "DISASTER RECOVERY PROCEDURE"
echo "=========================================="
echo ""
echo "This script guides you through disaster recovery"
echo ""

# Step 1: Assess the situation
echo "Step 1: Assess the Situation"
echo "----------------------------"
echo "What is the nature of the disaster?"
echo "1) Database corruption"
echo "2) Accidental data deletion"
echo "3) Server failure"
echo "4) Security incident"
read -p "Select option (1-4): " DISASTER_TYPE

# Step 2: Retrieve backup
echo ""
echo "Step 2: Retrieve Latest Backup"
echo "-------------------------------"
echo "Downloading latest backup from S3..."
LATEST_BACKUP=$(aws s3 ls s3://chain-backups/postgresql/daily/ | sort | tail -1 | awk '{print $4}')
echo "Latest backup: $LATEST_BACKUP"
aws s3 cp "s3://chain-backups/postgresql/daily/${LATEST_BACKUP}" ./

# Step 3: Retrieve WAL files (if PITR needed)
if [ "$DISASTER_TYPE" == "2" ]; then
    echo ""
    echo "Step 3: Retrieve WAL Archive"
    echo "----------------------------"
    echo "Downloading WAL files for PITR..."
    aws s3 sync s3://chain-backups/wal_archive/ /backups/wal_archive/
fi

# Step 4: Perform restore
echo ""
echo "Step 4: Restore Database"
echo "------------------------"
case $DISASTER_TYPE in
    1|3)
        echo "Performing full restore..."
        ./restore-database.sh "$LATEST_BACKUP"
        ;;
    2)
        read -p "Enter recovery timestamp (YYYY-MM-DD HH:MM:SS): " RECOVERY_TIME
        echo "Performing PITR to $RECOVERY_TIME..."
        ./restore-pitr.sh "$LATEST_BACKUP" "$RECOVERY_TIME"
        ;;
    4)
        echo "Security incident - full restore and credential rotation required"
        ./restore-database.sh "$LATEST_BACKUP"
        echo "IMPORTANT: Rotate all credentials immediately!"
        ;;
esac

# Step 5: Verification
echo ""
echo "Step 5: Verification"
echo "-------------------"
echo "Please verify the following:"
echo "- [ ] Database is accessible"
echo "- [ ] Critical data is present"
echo "- [ ] Application starts successfully"
echo "- [ ] Users can login"
echo "- [ ] Recent transactions are visible"
echo ""
read -p "Press Enter after verification..."

# Step 6: Post-recovery
echo ""
echo "Step 6: Post-Recovery Actions"
echo "------------------------------"
echo "- [ ] Update documentation"
echo "- [ ] Notify stakeholders"
echo "- [ ] Perform root cause analysis"
echo "- [ ] Update disaster recovery plan"
echo "- [ ] Schedule post-mortem meeting"
echo ""
echo "Disaster recovery completed"
```

---

## Testing and Validation

### Weekly Restore Test

Automate restore testing to staging environment:

```bash
#!/bin/bash
# /scripts/test-restore.sh

# Download latest backup
LATEST_BACKUP=$(aws s3 ls s3://chain-backups/postgresql/daily/ | sort | tail -1 | awk '{print $4}')
aws s3 cp "s3://chain-backups/postgresql/daily/${LATEST_BACKUP}" /tmp/

# Restore to staging database
export DB_CONTAINER=chain-postgres-staging
export DB_NAME=chaindb_staging

./restore-database.sh "/tmp/${LATEST_BACKUP}"

# Run verification queries
docker exec $DB_CONTAINER psql -U chain -d $DB_NAME -c "SELECT COUNT(*) FROM users;" > /tmp/restore-test.log
docker exec $DB_CONTAINER psql -U chain -d $DB_NAME -c "SELECT COUNT(*) FROM tickets;" >> /tmp/restore-test.log

# Compare with production counts
echo "Restore test completed - check /tmp/restore-test.log"

# Send notification
if [ $? -eq 0 ]; then
    echo "Weekly restore test: SUCCESS" | mail -s "Backup Test Success" ops@example.com
else
    echo "Weekly restore test: FAILED" | mail -s "Backup Test FAILURE" ops@example.com
fi
```

Schedule weekly:
```bash
# Run every Sunday at 5 AM
0 5 * * 0 /scripts/test-restore.sh
```

### Backup Verification

Verify backup integrity after creation:

```bash
# Check backup file is not corrupt
pg_restore -l backup.dump > /dev/null

# Check backup file size
ls -lh backup.dump

# Test restore to temp database
createdb temp_test
pg_restore -d temp_test backup.dump
psql -d temp_test -c "SELECT COUNT(*) FROM users;"
dropdb temp_test
```

---

## Troubleshooting

### Backup Issues

#### Issue: Backup file is empty or too small

```bash
# Check PostgreSQL logs
docker logs chain-postgres

# Check disk space
df -h

# Check permissions
ls -la /backups/postgresql

# Manual backup with verbose output
docker exec chain-postgres pg_dump -U chain -Fc -v chaindb > backup_test.dump
```

#### Issue: S3 upload fails

```bash
# Check AWS credentials
aws sts get-caller-identity

# Check S3 bucket permissions
aws s3 ls s3://chain-backups/

# Test upload manually
echo "test" > /tmp/test.txt
aws s3 cp /tmp/test.txt s3://chain-backups/test.txt
```

### Restore Issues

#### Issue: Restore fails with errors

```bash
# Check backup file integrity
pg_restore -l backup.dump

# Restore with --clean --if-exists
pg_restore --clean --if-exists -d chaindb backup.dump

# Restore without errors (ignore errors)
pg_restore --no-acl --no-owner -d chaindb backup.dump
```

#### Issue: Data mismatch after restore

```bash
# Check Flyway version
SELECT * FROM flyway_schema_history ORDER BY installed_rank DESC LIMIT 5;

# Re-run Flyway migrations
./gradlew flywayRepair
./gradlew flywayMigrate

# Rebuild indexes
REINDEX DATABASE chaindb;

# Update statistics
ANALYZE;
```

---

## Monitoring and Alerts

### Metrics to Monitor

- Backup success/failure rate
- Backup duration
- Backup file size
- Time since last successful backup
- WAL archive lag
- Restore test success rate

### Alert Conditions

```yaml
# Example Prometheus alerts

- alert: BackupFailed
  expr: backup_last_success_timestamp < (time() - 86400)  # 24 hours
  severity: critical
  annotations:
    summary: "Database backup has not succeeded in 24 hours"

- alert: BackupFileTooSmall
  expr: backup_file_size_bytes < 1000000  # 1 MB
  severity: warning
  annotations:
    summary: "Backup file is suspiciously small"

- alert: WALArchiveLag
  expr: pg_wal_archive_lag_seconds > 600  # 10 minutes
  severity: warning
  annotations:
    summary: "WAL archiving is lagging"
```

---

## Compliance and Retention

### Retention Policy

| Backup Type | Retention Period | Storage Location |
|-------------|------------------|------------------|
| Daily | 30 days | Local + S3 Standard |
| Weekly | 90 days | S3 Standard → Glacier |
| Monthly | 1 year | S3 Glacier |
| WAL Archive | 30 days | Local + S3 Standard |

### Compliance Requirements

- **GDPR:** Backups must be encrypted at rest
- **SOC 2:** Backup procedures must be documented and tested
- **PCI DSS:** Backups must be stored securely with access controls
- **Data Retention:** Comply with data retention policies for your jurisdiction

---

## References

- [PostgreSQL Backup Documentation](https://www.postgresql.org/docs/current/backup.html)
- [Database Consolidation Plan](DATABASE_CONSOLIDATION_PLAN.md)
- [Migration Guide](MIGRATION_GUIDE.md)

---

**Last Updated:** 2025-01-10
**Version:** 1.0
**Next Review:** 2025-04-10
