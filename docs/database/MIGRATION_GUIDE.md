# Database Migration Guide

This guide explains how to create, test, and deploy database migrations for the Ticketz project.

## Overview

Ticketz uses **Flyway** for database schema versioning and migrations. Flyway automatically applies SQL migration scripts in version order and tracks which migrations have been applied.

## Migration Naming Convention

All migration files must follow this naming pattern:

```
V{VERSION}__{DESCRIPTION}.sql
```

**Rules:**
- `V` - Prefix (required, uppercase V)
- `{VERSION}` - Version number (required, integers like 1, 2, 3, or semantic like 1.1, 1.2)
- `__` - Double underscore separator (required)
- `{DESCRIPTION}` - Description using underscores for spaces (required)
- `.sql` - File extension (required)

**Examples:**
```
✅ V1__Initial_Schema.sql
✅ V2__Add_Performance_Indexes.sql
✅ V3__Add_Check_Constraints.sql
✅ V10__Add_User_Preferences_Table.sql
✅ V2.1__Hotfix_Ticket_Constraint.sql

❌ v1__initial_schema.sql           (lowercase v)
❌ V1_Initial_Schema.sql             (single underscore)
❌ V1__initial-schema.sql            (hyphens not allowed)
❌ InitialSchema.sql                 (no version number)
```

## Migration File Structure

Every migration should include:

```sql
-- V{N}__{Description}.sql
-- Purpose: [Brief description of what this migration does]
-- Author: [Your name or team]
-- Date: [YYYY-MM-DD]
-- Ticket: [JIRA-XXX or GitHub issue number]

-- Pre-migration validation (optional but recommended)
DO $$
BEGIN
    -- Validate preconditions
    IF (SELECT COUNT(*) FROM users WHERE email IS NULL) > 0 THEN
        RAISE EXCEPTION 'Cannot proceed: Users with NULL email exist';
    END IF;
END $$;

-- Main migration
CREATE TABLE IF NOT EXISTS new_table (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_new_table_name ON new_table (name);

-- Post-migration validation (optional but recommended)
DO $$
BEGIN
    -- Verify migration success
    IF NOT EXISTS (
        SELECT 1 FROM pg_tables
        WHERE schemaname = 'public' AND tablename = 'new_table'
    ) THEN
        RAISE EXCEPTION 'Migration failed: new_table was not created';
    END IF;
END $$;

-- Comments
COMMENT ON TABLE new_table IS 'Description of table purpose and usage';
COMMENT ON COLUMN new_table.name IS 'User-friendly name, must be unique';
```

## Creating a New Migration

### Step 1: Determine Version Number

Check the latest migration version:

```bash
# On Windows (PowerShell)
Get-ChildItem backend\src\main\resources\db\migration | Where-Object { $_.Name -match "^V" } | Sort-Object Name | Select-Object -Last 1

# On Linux/Mac
ls backend/src/main/resources/db/migration/ | grep "^V" | sort -V | tail -1
```

Use the next sequential number (e.g., if last is V4, use V5).

### Step 2: Create Migration File

Create a new file in `backend/src/main/resources/db/migration/`:

```bash
# Example: Creating V5
touch backend/src/main/resources/db/migration/V5__Add_User_Preferences.sql
```

### Step 3: Write SQL

**Best Practices:**

#### ✅ DO: Write Idempotent SQL

```sql
-- Use IF NOT EXISTS
CREATE TABLE IF NOT EXISTS user_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE
);

-- Use IF NOT EXISTS for columns
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'users' AND column_name = 'timezone'
    ) THEN
        ALTER TABLE users ADD COLUMN timezone VARCHAR(50);
    END IF;
END $$;

-- Use ON CONFLICT for data inserts
INSERT INTO config (key, value)
VALUES ('max_tickets_per_user', '5')
ON CONFLICT (key) DO NOTHING;
```

#### ✅ DO: Use CREATE INDEX CONCURRENTLY

```sql
-- Avoids locking the table during index creation
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_users_email
ON users (LOWER(email));
```

**Note:** `CONCURRENTLY` cannot be used inside a transaction block. If your migration script runs in a transaction, either:
1. Split index creation into a separate migration
2. Or configure Flyway to run that specific migration outside a transaction

#### ✅ DO: Add Foreign Key Constraints

```sql
-- Always name your constraints
ALTER TABLE user_preferences
ADD CONSTRAINT fk_user_preferences_user
FOREIGN KEY (user_id)
REFERENCES users(id)
ON DELETE CASCADE;
```

#### ✅ DO: Add Comments

```sql
COMMENT ON TABLE user_preferences IS
    'Stores user-specific preferences like theme, language, timezone';

COMMENT ON COLUMN user_preferences.user_id IS
    'Foreign key to users table, cascades on delete';
```

#### ❌ DON'T: Use DROP without IF EXISTS

```sql
-- ❌ Bad: Will fail if column doesn't exist
ALTER TABLE users DROP COLUMN old_field;

-- ✅ Good: Won't fail if column doesn't exist
ALTER TABLE users DROP COLUMN IF EXISTS old_field;
```

#### ❌ DON'T: Hardcode Values

```sql
-- ❌ Bad: Hardcoded date
UPDATE tickets SET expires_at = '2025-12-31' WHERE status = 'ACTIVE';

-- ✅ Good: Relative date
UPDATE tickets SET expires_at = CURRENT_TIMESTAMP + INTERVAL '7 days'
WHERE status = 'ACTIVE' AND expires_at IS NULL;
```

#### ❌ DON'T: Assume Data State

```sql
-- ❌ Bad: Assumes user with ID exists
UPDATE tickets SET owner_id = '00000000-0000-0000-0000-000000000001';

-- ✅ Good: Check if user exists first
UPDATE tickets SET owner_id = '00000000-0000-0000-0000-000000000001'
WHERE owner_id IS NULL
AND EXISTS (SELECT 1 FROM users WHERE id = '00000000-0000-0000-0000-000000000001');
```

### Step 4: Test Locally

#### Start Local Database

```bash
docker-compose up -d postgres
```

#### Run Migration

```bash
# Using Gradle
./gradlew flywayMigrate

# Or using Maven
./mvnw flyway:migrate
```

#### Verify Migration

```bash
# Connect to database
docker exec -it chain-postgres psql -U chain -d chaindb

# Check migration status
SELECT * FROM flyway_schema_history ORDER BY installed_rank;

# Verify table/column was created
\d+ new_table

# Exit psql
\q
```

#### Test Rollback (if needed)

Flyway doesn't support automatic rollbacks, so you need to create a compensating migration:

```sql
-- V6__Rollback_User_Preferences.sql
DROP TABLE IF EXISTS user_preferences;
```

### Step 5: Test with Application

```bash
# Start full application stack
docker-compose up

# Run integration tests
./gradlew test

# Verify application starts without errors
curl http://localhost:8080/actuator/health
```

## Common Migration Patterns

### Adding a Table

```sql
-- V{N}__Add_{TableName}_Table.sql
CREATE TABLE IF NOT EXISTS table_name (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- Indexes for foreign keys and common queries
CREATE INDEX idx_table_name_created_at ON table_name (created_at);

-- Soft delete support
CREATE INDEX idx_table_name_deleted_at ON table_name (deleted_at) WHERE deleted_at IS NULL;

-- Comments
COMMENT ON TABLE table_name IS 'Purpose and usage of this table';
```

### Adding a Column

```sql
-- V{N}__Add_{ColumnName}_To_{TableName}.sql
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public'
        AND table_name = 'users'
        AND column_name = 'phone_number'
    ) THEN
        ALTER TABLE users ADD COLUMN phone_number VARCHAR(20);
    END IF;
END $$;

-- Add index if needed
CREATE INDEX IF NOT EXISTS idx_users_phone_number ON users (phone_number);

-- Add comment
COMMENT ON COLUMN users.phone_number IS 'User phone number in E.164 format';
```

### Modifying a Column

```sql
-- V{N}__Modify_{ColumnName}_In_{TableName}.sql

-- Change column type
ALTER TABLE users ALTER COLUMN username TYPE VARCHAR(100);

-- Change column nullability
ALTER TABLE users ALTER COLUMN email SET NOT NULL;

-- Add default value
ALTER TABLE users ALTER COLUMN country_code SET DEFAULT 'US';

-- Remove default value
ALTER TABLE users ALTER COLUMN country_code DROP DEFAULT;
```

### Adding an Index

```sql
-- V{N}__Add_{IndexName}_Index.sql

-- Simple index
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_tickets_status
ON tickets (status);

-- Composite index
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_tickets_owner_status
ON tickets (owner_id, status);

-- Partial index (with WHERE clause)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_tickets_active
ON tickets (owner_id, expires_at)
WHERE status = 'ACTIVE' AND deleted_at IS NULL;

-- Unique index
CREATE UNIQUE INDEX CONCURRENTLY IF NOT EXISTS idx_users_email_unique
ON users (LOWER(email));

-- Covering index (with INCLUDE)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_users_username_covering
ON users (username)
INCLUDE (email, display_name);

-- GIN index for JSONB
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_metadata_gin
ON audit_log USING GIN (metadata);

-- BRIN index for time-series data
CREATE INDEX IF NOT EXISTS idx_audit_log_created_brin
ON audit_log USING BRIN (created_at);
```

### Adding a Foreign Key

```sql
-- V{N}__Add_FK_{ChildTable}_To_{ParentTable}.sql

-- Add foreign key constraint
ALTER TABLE tickets
ADD CONSTRAINT fk_tickets_owner
FOREIGN KEY (owner_id)
REFERENCES users(id)
ON DELETE CASCADE;

-- Add index on foreign key (if not already exists)
CREATE INDEX IF NOT EXISTS idx_tickets_owner_id ON tickets (owner_id);
```

### Adding a Check Constraint

```sql
-- V{N}__Add_Check_Constraints.sql

-- Simple check constraint
ALTER TABLE tickets
ADD CONSTRAINT check_ticket_dates
CHECK (expires_at > issued_at);

-- Enum validation
ALTER TABLE notifications
ADD CONSTRAINT check_notification_priority
CHECK (priority IN ('LOW', 'NORMAL', 'HIGH', 'URGENT'));

-- Range validation
ALTER TABLE tickets
ADD CONSTRAINT check_attempt_number
CHECK (attempt_number >= 0 AND attempt_number <= max_attempts);

-- Pattern validation
ALTER TABLE users
ADD CONSTRAINT check_username_format
CHECK (username ~ '^[a-zA-Z0-9_]{3,50}$');
```

### Populating Initial Data

```sql
-- V{N}__Populate_{TableName}_Initial_Data.sql

-- Use ON CONFLICT to make idempotent
INSERT INTO chain_rules (id, version, rule_content, is_active, created_at, updated_at)
VALUES (
    '00000000-0000-0000-0000-000000000001'::UUID,
    1,
    '{"max_tickets": 5, "expiry_days": 7}'::JSONB,
    true,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
)
ON CONFLICT (id) DO NOTHING;

-- Bulk insert with ON CONFLICT
INSERT INTO badges (id, name, description, icon_url, badge_type, created_at)
VALUES
    ('00000000-0000-0000-0000-000000000101'::UUID, 'First Invite', 'Invited your first user', 'badge1.png', 'ACHIEVEMENT', CURRENT_TIMESTAMP),
    ('00000000-0000-0000-0000-000000000102'::UUID, 'Chain Builder', 'Built a chain of 10 users', 'badge2.png', 'MILESTONE', CURRENT_TIMESTAMP),
    ('00000000-0000-0000-0000-000000000103'::UUID, 'Influencer', 'Built a chain of 100 users', 'badge3.png', 'MILESTONE', CURRENT_TIMESTAMP)
ON CONFLICT (id) DO NOTHING;
```

### Data Migration

```sql
-- V{N}__Migrate_{Description}.sql

-- Example: Split name into first_name and last_name

-- Add new columns
ALTER TABLE users ADD COLUMN IF NOT EXISTS first_name VARCHAR(100);
ALTER TABLE users ADD COLUMN IF NOT EXISTS last_name VARCHAR(100);

-- Migrate data
UPDATE users
SET
    first_name = SPLIT_PART(name, ' ', 1),
    last_name = SPLIT_PART(name, ' ', 2)
WHERE first_name IS NULL;

-- Verify migration
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM users
        WHERE name IS NOT NULL AND (first_name IS NULL OR last_name IS NULL)
    ) THEN
        RAISE WARNING 'Some names could not be split properly';
    END IF;
END $$;

-- Optionally drop old column (in separate migration)
-- ALTER TABLE users DROP COLUMN IF EXISTS name;
```

## Testing Migrations

### Unit Testing

Create test migrations in `src/test/resources/db/migration/` for testing purposes only:

```sql
-- Test data for integration tests
INSERT INTO users (id, username, email, password_hash, created_at, updated_at)
VALUES (
    '00000000-0000-0000-0000-000000000001'::UUID,
    'testuser',
    'test@example.com',
    '$2a$10$N9qo8uLOickgx2ZMRZoMye...',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
);
```

### Integration Testing

Test migrations with the full application:

```java
@SpringBootTest
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
public class MigrationIntegrationTest {

    @Autowired
    private Flyway flyway;

    @Test
    public void testMigrationSucceeds() {
        // Flyway runs automatically on application startup
        MigrationInfo[] migrations = flyway.info().all();

        // Verify all migrations succeeded
        for (MigrationInfo migration : migrations) {
            assertEquals(MigrationState.SUCCESS, migration.getState());
        }
    }
}
```

### Load Testing

Test migrations with production-like data volumes:

```sql
-- Generate test data
INSERT INTO users (id, username, email, password_hash, created_at, updated_at)
SELECT
    gen_random_uuid(),
    'user_' || generate_series,
    'user_' || generate_series || '@example.com',
    '$2a$10$N9qo8uLOickgx2ZMRZoMye...',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
FROM generate_series(1, 100000);

-- Test query performance
EXPLAIN ANALYZE SELECT * FROM users WHERE username = 'user_50000';
```

## Deployment Process

### Development

1. Create migration file
2. Test locally with Docker
3. Run integration tests
4. Commit and push

### Staging

1. Pull latest code
2. Run `./gradlew flywayMigrate` (or let application auto-migrate)
3. Verify with `./gradlew flywayInfo`
4. Test application functionality
5. Monitor logs for errors

### Production

**Before Migration:**
1. [ ] Schedule maintenance window
2. [ ] Notify stakeholders
3. [ ] Create database backup
4. [ ] Document rollback plan
5. [ ] Review migration checklist

**During Migration:**
1. [ ] Put application in maintenance mode (optional)
2. [ ] Stop application services
3. [ ] Backup database: `pg_dump -Fc chaindb > backup_pre_migration.dump`
4. [ ] Apply migration: `./gradlew flywayMigrate`
5. [ ] Verify migration: `./gradlew flywayInfo`
6. [ ] Test critical queries
7. [ ] Start application services
8. [ ] Monitor logs and metrics

**After Migration:**
1. [ ] Verify application health: `/actuator/health`
2. [ ] Run smoke tests
3. [ ] Monitor performance metrics
4. [ ] Check for errors in logs
5. [ ] Update documentation
6. [ ] Notify stakeholders of completion

## Migration Checklist

Before committing a migration, verify:

- [ ] Migration file named correctly (`V{N}__{Description}.sql`)
- [ ] Version number is sequential (no gaps)
- [ ] SQL is idempotent (can run multiple times safely)
- [ ] Uses `IF NOT EXISTS` where appropriate
- [ ] Uses `CREATE INDEX CONCURRENTLY` for indexes
- [ ] Foreign keys defined with appropriate `ON DELETE` actions
- [ ] Indexes created for all foreign key columns
- [ ] Indexes created for columns used in WHERE clauses
- [ ] Check constraints added for data validation
- [ ] Comments added to tables and important columns
- [ ] Pre and post-migration validation included
- [ ] Tested on local database
- [ ] Tested with application running
- [ ] Integration tests pass
- [ ] Rollback procedure documented
- [ ] Code review completed

## Troubleshooting

### Migration Failed

**Check Flyway history:**
```sql
SELECT * FROM flyway_schema_history ORDER BY installed_rank DESC;
```

**If migration failed mid-execution:**
```bash
# 1. Manually fix the database to the expected state
# 2. Mark the migration as successful (if it's partially applied)
./gradlew flywayRepair

# 3. Or skip the failed migration and create a fix migration
# Delete the failed migration record from flyway_schema_history
DELETE FROM flyway_schema_history WHERE version = 'X';
```

### Checksum Mismatch

If you get "Migration checksum mismatch" error:

```bash
# Option 1: Repair Flyway history (if migration already applied)
./gradlew flywayRepair

# Option 2: Revert file changes (if migration not yet applied)
git checkout backend/src/main/resources/db/migration/V{N}__Migration.sql

# Option 3: Create new migration (if changes are intentional)
# Never modify an already-applied migration!
```

### Migration Too Slow

If index creation or data migration is slow:

```sql
-- Option 1: Create index CONCURRENTLY (separate migration, outside transaction)
CREATE INDEX CONCURRENTLY idx_name ON table (column);

-- Option 2: Add constraint NOT VALID, then validate separately
ALTER TABLE table ADD CONSTRAINT constraint_name CHECK (...) NOT VALID;
-- Later:
ALTER TABLE table VALIDATE CONSTRAINT constraint_name;

-- Option 3: Batch data migration
UPDATE table SET new_column = old_column WHERE id IN (
    SELECT id FROM table WHERE new_column IS NULL LIMIT 10000
);
-- Run multiple times until complete
```

### Out of Order Migration

If you need to add a migration between existing ones:

```bash
# Instead of V5, use V4.1
V4__Add_Magic_Link_Auth.sql         (already applied)
V4.1__Hotfix_Magic_Link_Index.sql   (new)
V5__Add_User_Preferences.sql        (already applied)

# Flyway will apply V4.1 even though V5 already exists
```

## Best Practices Summary

1. **Always backup before migration**
2. **Test on staging first**
3. **Write idempotent SQL** (use IF NOT EXISTS)
4. **Use CREATE INDEX CONCURRENTLY** (avoid table locks)
5. **Add comments** (document purpose and usage)
6. **Validate before and after** (pre/post-migration checks)
7. **Never modify applied migrations** (create new migration instead)
8. **Keep migrations small** (one logical change per migration)
9. **Document rollback procedure** (compensating migration)
10. **Monitor after deployment** (watch logs and metrics)

## References

- [Flyway Documentation](https://flywaydb.org/documentation/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Database Consolidation Plan](DATABASE_CONSOLIDATION_PLAN.md)
- [Backup Procedures](BACKUP_PROCEDURES.md)

---

**Last Updated:** 2025-01-10
**Version:** 1.0
