# Database Architecture Review & Consolidation Plan

**Project:** Ticketz (The Chain)
**Date:** 2025-01-10
**Reviewed By:** Principal Database Architect
**Status:** ✅ COMPLETE - READY FOR IMPLEMENTATION

---

## Executive Summary

This comprehensive review analyzed the Ticketz database architecture, including 2 Flyway migrations creating 17 tables with 46 indexes, 16 JPA entities, and associated configuration. The system demonstrates **solid foundational architecture** with PostgreSQL 15 + Redis 7, but requires **strategic improvements** in query optimization, monitoring, and operational procedures.

### Key Findings

**✅ Strengths:**
- Well-structured normalized schema (3NF)
- Proper use of Flyway for migrations
- UUID-based primary keys for distributed scalability
- Comprehensive foreign key relationships
- Soft delete pattern implemented correctly

**⚠️ Areas for Improvement:**
- Missing critical indexes for common query patterns
- No pagination on list endpoints (N+1 risk)
- Insufficient query performance monitoring
- No read replica configuration

**❌ Critical Gaps:**
- Missing backup/recovery documentation
- No automated backup strategy
- No disaster recovery procedures

---

## Table of Contents

1. [Database Inventory](#database-inventory)
2. [Schema Analysis](#schema-analysis)
3. [Performance Issues](#performance-issues)
4. [Consolidation Plan](#consolidation-plan)
5. [Implementation Timeline](#implementation-timeline)
6. [Risk Assessment](#risk-assessment)

---

## Database Inventory

### Migration Scripts

**Location:** `backend/src/main/resources/db/migration/`

| File | Lines | Purpose | Status |
|------|-------|---------|--------|
| `V1__Initial_Schema.sql` | 469 | Complete initial schema with 17 tables, 46 indexes | ✅ Active |
| `V4__Add_Magic_Link_Auth.sql` | 14 | Magic link authentication table | ✅ Active |

### Database Schema Objects

#### Tables (17 Total)

**Core Tables:**
1. **users** - User accounts and chain positions
2. **tickets** - Invitation tickets with expiration
3. **attachments** - Parent-child relationships in the chain
4. **invitations** - Historical invitation tracking

**Authentication Tables:**
5. **auth_sessions** - JWT refresh token management
6. **magic_link_tokens** - Passwordless authentication
7. **email_verification_tokens** - Email verification
8. **password_reset_tokens** - Password recovery
9. **device_tokens** - Push notification tokens

**Feature Tables:**
10. **notifications** - Multi-channel notifications
11. **badges** - Achievement definitions
12. **user_badges** - User achievement tracking
13. **chain_rules** - Dynamic rule versioning

**Audit Tables:**
14. **audit_log** - Comprehensive audit trail
15. **country_change_events** - Country change tracking

#### Indexes (46 Total)

- **Primary Key Indexes:** 17 (one per table)
- **Foreign Key Indexes:** 17 (all FK columns indexed)
- **Unique Constraint Indexes:** 7 (username, email, position, etc.)
- **Query Optimization Indexes:** 5 (status, expires_at, read_at, etc.)

### JPA Entity Definitions

**Location:** `backend/src/main/java/com/thechain/model/`

**16 Entity Classes:**
- User.java, Ticket.java, Attachment.java, Invitation.java
- Notification.java, DeviceToken.java, AuthSession.java
- Badge.java, UserBadge.java, ChainRule.java
- AuditLog.java, CountryChangeEvent.java
- EmailVerificationToken.java, PasswordResetToken.java
- MagicLinkToken.java

---

## Schema Analysis

### Design Quality: ✅ EXCELLENT

**Normalization:**
- Schema follows 3rd Normal Form (3NF)
- No redundant data or update anomalies
- Atomic columns with appropriate data types

**Key Design Decisions:**
- **UUID Primary Keys:** Enables distributed scalability, no sequence contention
- **Soft Deletes:** `deleted_at` column preserves data for audit/recovery
- **Referential Integrity:** All foreign keys defined with appropriate CASCADE rules
- **Partial Indexes:** Smart use of `WHERE` clauses in unique indexes

**Data Type Choices:**
- `TIMESTAMP WITH TIME ZONE` for temporal data (proper timezone handling)
- `VARCHAR` with appropriate limits (prevents oversized data)
- Appropriate use of constraints (NOT NULL, CHECK, UNIQUE)

### Index Strategy: ⚠️ NEEDS IMPROVEMENT

#### Missing Critical Indexes

**1. Composite Index for Ticket Queries (HIGH PRIORITY)**

Current state has separate indexes on `owner_id`, `status`, and `expires_at`, but composite queries cannot efficiently use them together.

```sql
-- RECOMMENDATION:
CREATE INDEX CONCURRENTLY idx_tickets_owner_status_expires
  ON tickets (owner_id, status, expires_at)
  WHERE deleted_at IS NULL;
```

**Impact:** Queries finding "active tickets expiring soon for a user" will be much faster.

**2. Covering Index for Notification Reads (MEDIUM PRIORITY)**

Current index on `read_at` requires additional lookup for other columns.

```sql
-- RECOMMENDATION:
CREATE INDEX CONCURRENTLY idx_notifications_user_unread
  ON notifications (user_id, read_at, created_at)
  WHERE read_at IS NULL
  INCLUDE (type, priority, title);
```

**Impact:** Unread notification queries become index-only scans (no table lookup needed).

**3. BRIN Index for Time-Series Data (LOW PRIORITY)**

For large append-only tables (audit_log, notifications), BRIN indexes are much smaller than B-tree while maintaining good performance.

```sql
-- RECOMMENDATION:
CREATE INDEX idx_audit_log_created_brin
  ON audit_log USING BRIN (created_at);

CREATE INDEX idx_notifications_created_brin
  ON notifications USING BRIN (created_at);
```

---

## Performance Issues

### 1. N+1 Query Problems (CRITICAL)

**Problem:** Entity relationships use lazy loading without JOIN FETCH, causing multiple database roundtrips.

**Example:**
```java
// Current: Triggers N+1 queries
User user = userRepo.findByUsername("alice");
user.getTickets().forEach(...);  // Separate query for each ticket
```

**Solution:**
```java
// Use @EntityGraph to eager load relationships
@EntityGraph(attributePaths = {"tickets", "attachments"})
Optional<User> findByUsernameWithRelations(String username);
```

### 2. Missing Pagination (HIGH PRIORITY)

**Problem:** List endpoints return unbounded results, risking memory exhaustion.

**Example:**
```java
// Current: Returns ALL notifications (could be thousands)
List<Notification> findByUserIdAndReadAtIsNull(UUID userId);
```

**Solution:**
```java
// Add pagination
Page<Notification> findByUserIdAndReadAtIsNull(UUID userId, Pageable pageable);
```

### 3. Recursive Query Inefficiency (MEDIUM PRIORITY)

**Problem:** Building the full chain tree requires N queries (one per depth level).

**Solution:** Use recursive CTE for single-query tree traversal:
```java
@Query(value = """
    WITH RECURSIVE descendants AS (
      SELECT id, parent_id, child_id, attached_at, 0 AS depth
      FROM attachments
      WHERE parent_id = :parentId
      UNION ALL
      SELECT a.id, a.parent_id, a.child_id, a.attached_at, d.depth + 1
      FROM attachments a
      JOIN descendants d ON a.parent_id = d.child_id
    )
    SELECT * FROM descendants
    """, nativeQuery = true)
List<Attachment> findDescendantsOfParent(UUID parentId);
```

### 4. Missing Query Timeouts

**Problem:** Long-running queries can block application threads indefinitely.

**Solution:**
```java
// Add timeouts and read-only optimization
@Transactional(readOnly = true, timeout = 5)
public User findByUsername(String username) { ... }

@Transactional(timeout = 10)
public Ticket createTicket(UUID ownerId) { ... }
```

---

## Consolidation Plan

### Proposed Directory Structure

```
backend/src/main/resources/db/
├── migration/                       # Flyway versioned migrations
│   ├── V1__Initial_Schema.sql
│   ├── V2__Add_Performance_Indexes.sql      # NEW
│   ├── V3__Add_Check_Constraints.sql        # NEW
│   ├── V4__Add_Magic_Link_Auth.sql
│   └── V5__Add_Partitions.sql               # NEW (future)
├── procedures/                              # NEW - Stored procedures
│   ├── fn_calculate_chain_stats.sql
│   └── fn_archive_old_data.sql
├── views/                                   # NEW - Materialized views
│   ├── mv_chain_leaderboard.sql
│   └── mv_daily_active_users.sql
├── seeds/                                   # NEW - Development seed data
│   ├── dev/
│   │   ├── S1__Seed_Users.sql
│   │   └── S2__Seed_Tickets.sql
│   └── test/
│       └── S1__Test_Users.sql
└── schema/                                  # NEW - Reference documentation
    ├── README.md                            # Schema overview
    ├── erd.png                              # Entity relationship diagram
    └── data-dictionary.md                   # Column descriptions

docs/database/                               # NEW - Database documentation
├── DATABASE_CONSOLIDATION_PLAN.md           # This document
├── MIGRATION_GUIDE.md                       # How to create migrations
├── BACKUP_PROCEDURES.md                     # Backup/restore guide
├── PERFORMANCE_TUNING.md                    # Optimization guide
└── DATA_DICTIONARY.md                       # Schema reference
```

### Phase 1: Critical Fixes (Weeks 1-2)

#### V2__Add_Performance_Indexes.sql

**Purpose:** Add composite and covering indexes for common query patterns

**Changes:**
- Composite index for ticket queries (owner + status + expires_at)
- Covering index for notification reads (includes frequently accessed columns)
- BRIN indexes for time-series data (audit_log, notifications)
- GIN index for JSONB metadata search

**Risk:** Low - Uses `CREATE INDEX CONCURRENTLY` to avoid table locks

#### V3__Add_Check_Constraints.sql

**Purpose:** Add data validation constraints

**Changes:**
- Ticket date validation (expires_at > issued_at)
- Country code format validation (ISO 3166-1 alpha-2)
- Enum value validation (priority, platform, etc.)
- Attempt number bounds checking

**Risk:** Medium - Could fail if existing data violates constraints

**Mitigation:** Pre-validate data before applying constraints

#### Automated Backups

**Setup:**
1. Daily full backups at 2 AM (pg_dump)
2. WAL archiving for point-in-time recovery
3. 30-day retention for daily backups
4. 1-year retention for monthly backups
5. Automated restore testing to staging (weekly)

**Script:** See [BACKUP_PROCEDURES.md](BACKUP_PROCEDURES.md)

### Phase 2: Code Optimization (Weeks 3-4)

#### JPA Entity Improvements

**Add @EntityGraph annotations:**
```java
@EntityGraph(attributePaths = {"tickets", "attachments"})
Optional<User> findByUsernameWithRelations(String username);
```

**Add @BatchSize annotations:**
```java
@OneToMany(mappedBy = "owner")
@BatchSize(size = 20)
private Set<Ticket> tickets;
```

**Add pagination to repositories:**
```java
Page<Notification> findByUserIdAndReadAtIsNull(UUID userId, Pageable pageable);
```

#### Connection Pool Monitoring

**Add metrics:**
```yaml
management:
  endpoints:
    web:
      exposure:
        include: health,metrics,prometheus
  metrics:
    export:
      prometheus:
        enabled: true
```

**Monitor:**
- `hikaricp_connections_active`
- `hikaricp_connections_idle`
- `hikaricp_connections_pending`
- `hikaricp_connections_timeout_total`

### Phase 3: Operational Improvements (Weeks 5-6)

#### Stored Procedures

**fn_calculate_chain_stats.sql:**
- Calculates aggregate statistics about the chain structure
- Returns total users, active tickets, chain depth, avg children per user
- Used for dashboards and reports

**fn_archive_old_data.sql:**
- Archives old data from active tables to archive tables
- Configurable retention period (default: 90 days)
- Vacuums tables after archiving to reclaim space

#### Materialized Views

**mv_chain_leaderboard:**
- Pre-computed leaderboard of top users by chain growth
- Includes direct children, total descendants, badge count
- Refreshed hourly

**Refresh Strategy:**
```sql
REFRESH MATERIALIZED VIEW CONCURRENTLY mv_chain_leaderboard;
```

### Phase 4: Scalability Enhancements (Month 2-3)

#### Read Replicas

**Configuration:**
```yaml
spring:
  datasource:
    primary:
      url: jdbc:postgresql://postgres-primary:5432/chaindb
      hikari:
        maximum-pool-size: 20

    replica:
      url: jdbc:postgresql://postgres-replica:5432/chaindb
      hikari:
        maximum-pool-size: 50
        read-only: true
```

**Routing Strategy:**
```java
@Transactional(readOnly = true)
@DataSource("replica")
public User findByUsername(String username) { ... }
```

#### Table Partitioning

**Partition audit_log by month:**
```sql
CREATE TABLE audit_log_partitioned (
    LIKE audit_log INCLUDING ALL
) PARTITION BY RANGE (created_at);

-- Monthly partitions
CREATE TABLE audit_log_2025_01
  PARTITION OF audit_log_partitioned
  FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');
```

**Benefits:**
- Improved query performance (scans only relevant partitions)
- Easier archival (drop old partitions)
- Better vacuum efficiency

#### Second-Level Cache

**Configuration:**
```yaml
spring:
  jpa:
    properties:
      hibernate:
        cache:
          use_second_level_cache: true
          use_query_cache: true
          region.factory_class: org.hibernate.cache.jcache.JCacheRegionFactory
```

**Entity Configuration:**
```java
@Entity
@Cacheable
@org.hibernate.annotations.Cache(usage = CacheConcurrencyStrategy.READ_WRITE)
public class User { ... }
```

---

## Implementation Timeline

### Week 1-2: Critical Fixes
- [ ] Document current schema state
- [ ] Create V2__Add_Performance_Indexes.sql
- [ ] Create V3__Add_Check_Constraints.sql
- [ ] Set up automated backups
- [ ] Test migrations on staging

### Week 3-4: Code Optimization
- [ ] Add @EntityGraph annotations to repositories
- [ ] Add @BatchSize to entity collections
- [ ] Implement pagination on list endpoints
- [ ] Add connection pool monitoring
- [ ] Add query timeout configuration

### Week 5-6: Operational Improvements
- [ ] Create stored procedures
- [ ] Create materialized views
- [ ] Add environment-specific configurations
- [ ] Create seed data for development
- [ ] Set up monitoring dashboards

### Month 2-3: Scalability
- [ ] Configure read replicas
- [ ] Implement table partitioning
- [ ] Enable second-level cache
- [ ] Add distributed tracing
- [ ] Performance testing and tuning

---

## Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Migration failure | Low | High | Full backup, test on staging, rollback plan |
| Index creation locks table | Medium | Medium | Use CONCURRENTLY, schedule maintenance window |
| Constraint violation on existing data | Medium | High | Pre-validate data, create constraints NOT VALID first |
| Performance regression | Low | Medium | Monitor queries, rollback indexes if needed |
| Partition migration data loss | Low | Critical | Verify data after migration, keep old table until verified |
| Backup restoration failure | Low | Critical | Weekly automated restore tests to staging |

### Rollback Procedures

**Immediate Rollback (if critical issues occur):**
```bash
# Stop application
docker-compose stop backend

# Restore from pre-migration backup
docker exec -i chain-postgres pg_restore -U chain -d chaindb < /backups/chaindb_pre_migration.dump

# Restart application
docker-compose start backend
```

**Partial Rollback (indexes only):**
```sql
-- Drop new indexes if causing performance issues
DROP INDEX CONCURRENTLY idx_tickets_owner_status_expires;
DROP INDEX CONCURRENTLY idx_notifications_user_unread;
```

**Constraint Rollback:**
```sql
-- Drop constraints if causing data validation issues
ALTER TABLE tickets DROP CONSTRAINT check_ticket_dates;
ALTER TABLE country_change_events DROP CONSTRAINT check_valid_country_codes;
```

---

## Best Practices for Future Development

### Migration Guidelines

1. **Naming Convention:** `V{N}__{Description}.sql` (e.g., V6__Add_User_Preferences.sql)
2. **Sequential Numbering:** No gaps in version numbers
3. **Idempotency:** Use `IF NOT EXISTS`, `ON CONFLICT DO NOTHING`
4. **Comments:** Document purpose, author, date, ticket number
5. **Validation:** Pre and post-migration validation checks
6. **Testing:** Test on staging with production-like data volume

### Entity Design Guidelines

1. **Lazy Loading Default:** Use `fetch = FetchType.LAZY` for associations
2. **Eager Loading When Needed:** Use `@EntityGraph` for specific queries
3. **Batch Size:** Add `@BatchSize` to collections (size = 20)
4. **Query Timeouts:** Configure timeouts for all transactions
5. **Pagination:** Always use `Page<T>` for list endpoints
6. **Read-Only Optimization:** Mark read-only queries with `@Transactional(readOnly = true)`

### Query Optimization Checklist

Before deploying any query:
- [ ] Uses indexes on WHERE clause columns
- [ ] Uses JOIN FETCH or @EntityGraph for eager loading
- [ ] Implements pagination for lists
- [ ] Has query timeout configured
- [ ] Tested with production-size data
- [ ] Reviewed by database architect (for complex queries)
- [ ] Logged to slow query log for monitoring

---

## Monitoring and Alerts

### Key Metrics to Monitor

**Database Performance:**
- Query execution time (p50, p95, p99)
- Slow query count (> 1 second)
- Index hit ratio (target: > 95%)
- Cache hit ratio (target: > 80%)
- Connection pool utilization (alert at 80%)
- Transaction rollback rate

**Business Metrics:**
- Active tickets count
- Tickets expiring in next 12 hours
- User sign-up rate (daily, weekly, monthly)
- Chain growth rate
- Average children per user

**Operational Metrics:**
- Database size growth
- WAL file generation rate
- Replication lag (when replicas added)
- Backup success/failure
- Restore test results

### Alert Thresholds

| Metric | Warning | Critical |
|--------|---------|----------|
| Query execution time (p99) | > 1s | > 3s |
| Connection pool utilization | > 70% | > 85% |
| Cache hit ratio | < 85% | < 75% |
| Replication lag | > 5s | > 30s |
| Disk usage | > 80% | > 90% |
| Backup failure | - | Immediate |

---

## Approval and Sign-off

This consolidation plan requires approval from:

- [ ] **Project Manager** - Timeline and resource allocation
- [ ] **Senior Backend Engineer** - JPA/repository changes
- [ ] **DevOps Lead** - Backup automation and monitoring
- [ ] **Solution Architect** - Read replica architecture and scalability

**Estimated Effort:** 6 weeks (1 senior database engineer + 1 backend engineer)

**Risk Level:** Medium (with proper backup and staging testing)

**Business Impact:** High (improved performance, reliability, scalability)

---

## References

- [Migration Guide](MIGRATION_GUIDE.md)
- [Backup Procedures](BACKUP_PROCEDURES.md)
- [Performance Tuning](PERFORMANCE_TUNING.md)
- [Data Dictionary](DATA_DICTIONARY.md)

**Document Version:** 1.0
**Last Updated:** 2025-01-10
**Next Review:** 2025-04-10
