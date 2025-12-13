# Schema Verification Checklist

This checklist ensures the consolidated database schema maintains exact compatibility with the backend JPA entities.

## Pre-Migration Verification

### 1. Database Backup
- [ ] Full database backup created
- [ ] Backup verified and tested
- [ ] Backup location documented: `_____________________`
- [ ] Backup timestamp: `_____________________`

### 2. Migration File Backup
- [ ] V1__initial_schema.sql backed up
- [ ] V2__add_chain_mechanics.sql backed up
- [ ] V3__switch_to_username_auth.sql backed up
- [ ] Archive location: `backend/src/main/resources/db/migration/archive/`

### 3. Current State Documentation
```sql
-- Run these queries and save results
SELECT table_name, (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = t.table_name) as column_count
FROM information_schema.tables t
WHERE table_schema = 'public'
ORDER BY table_name;

SELECT table_name, COUNT(*) as row_count FROM users UNION ALL
SELECT 'tickets', COUNT(*) FROM tickets UNION ALL
SELECT 'attachments', COUNT(*) FROM attachments UNION ALL
SELECT 'invitations', COUNT(*) FROM invitations UNION ALL
SELECT 'chain_rules', COUNT(*) FROM chain_rules UNION ALL
SELECT 'badges', COUNT(*) FROM badges UNION ALL
SELECT 'user_badges', COUNT(*) FROM user_badges UNION ALL
SELECT 'notifications', COUNT(*) FROM notifications;
```

Results:
- [ ] Saved to: `_____________________`

## Post-Migration Verification

### 1. Table Existence (17 tables)

Core Tables:
- [ ] users
- [ ] tickets
- [ ] attachments
- [ ] invitations

Chain Mechanics:
- [ ] chain_rules
- [ ] badges
- [ ] user_badges

Notifications:
- [ ] notifications
- [ ] device_tokens

Admin Tools:
- [ ] country_change_events
- [ ] audit_log

Authentication:
- [ ] auth_sessions
- [ ] password_reset_tokens
- [ ] magic_link_tokens
- [ ] email_verification_tokens

Verification Query:
```sql
SELECT COUNT(*) as table_count
FROM information_schema.tables
WHERE table_schema = 'public'
AND table_type = 'BASE TABLE';
-- Expected: 17
```

### 2. Users Table Schema Verification

```sql
SELECT column_name, data_type, character_maximum_length, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'users'
ORDER BY ordinal_position;
```

Required Columns (check each):
- [ ] id (UUID, NOT NULL, PRIMARY KEY)
- [ ] chain_key (VARCHAR(32), NOT NULL, UNIQUE)
- [ ] display_name (VARCHAR(50), NOT NULL)
- [ ] position (INTEGER, NOT NULL, UNIQUE)
- [ ] parent_id (UUID, NULL)
- [ ] username (VARCHAR(50), NOT NULL, UNIQUE)
- [ ] password_hash (VARCHAR(255), NOT NULL)
- [ ] email (VARCHAR(255), NULL)
- [ ] email_verified (BOOLEAN, DEFAULT FALSE)
- [ ] apple_user_id (VARCHAR(255), NULL)
- [ ] google_user_id (VARCHAR(255), NULL)
- [ ] real_name (VARCHAR(100), NULL)
- [ ] is_guest (BOOLEAN, DEFAULT FALSE)
- [ ] avatar_emoji (VARCHAR(10), DEFAULT '👤')
- [ ] belongs_to (VARCHAR(2), NULL)
- [ ] status (VARCHAR(20), DEFAULT 'active')
- [ ] removal_reason (VARCHAR(50), NULL)
- [ ] removed_at (TIMESTAMP WITH TIME ZONE, NULL)
- [ ] last_active_at (TIMESTAMP WITH TIME ZONE, NULL)
- [ ] wasted_tickets_count (INTEGER, DEFAULT 0)
- [ ] total_tickets_generated (INTEGER, DEFAULT 0)
- [ ] inviter_position (INTEGER, NULL)
- [ ] invitee_position (INTEGER, NULL)
- [ ] country_locked (BOOLEAN, DEFAULT TRUE)
- [ ] country_changed_at (TIMESTAMP WITH TIME ZONE, NULL)
- [ ] display_name_changed_at (TIMESTAMP WITH TIME ZONE, NULL)
- [ ] created_at (TIMESTAMP WITH TIME ZONE, NOT NULL)
- [ ] updated_at (TIMESTAMP WITH TIME ZONE, NOT NULL)
- [ ] deleted_at (TIMESTAMP WITH TIME ZONE, NULL)

### 3. Tickets Table Schema Verification

```sql
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'tickets'
ORDER BY ordinal_position;
```

Required Columns:
- [ ] id (UUID, PRIMARY KEY)
- [ ] owner_id (UUID, NOT NULL, FOREIGN KEY -> users)
- [ ] ticket_code (VARCHAR(50), NULL)
- [ ] next_position (INTEGER, NULL)
- [ ] attempt_number (INTEGER, DEFAULT 1)
- [ ] rule_version (INTEGER, DEFAULT 1)
- [ ] duration_hours (INTEGER, DEFAULT 24)
- [ ] qr_code_url (VARCHAR(500), NULL)
- [ ] issued_at (TIMESTAMP, NOT NULL)
- [ ] expires_at (TIMESTAMP, NOT NULL)
- [ ] used_at (TIMESTAMP, NULL)
- [ ] status (VARCHAR(20), NOT NULL, DEFAULT 'ACTIVE')
- [ ] signature (TEXT, NOT NULL)
- [ ] payload (TEXT, NOT NULL)
- [ ] claimed_by (UUID, NULL, FOREIGN KEY -> users)
- [ ] claimed_at (TIMESTAMP, NULL)
- [ ] message (VARCHAR(100), NULL)

### 4. Invitations Table Schema Verification

**CRITICAL: Verify UUID columns, NOT position columns**

```sql
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'invitations'
ORDER BY ordinal_position;
```

Required Columns (UUID-based):
- [ ] id (UUID, PRIMARY KEY)
- [ ] parent_id (UUID, NOT NULL, FOREIGN KEY -> users)
- [ ] child_id (UUID, NOT NULL, UNIQUE, FOREIGN KEY -> users)
- [ ] ticket_id (UUID, NOT NULL, FOREIGN KEY -> tickets)
- [ ] status (VARCHAR(20), NOT NULL, DEFAULT 'ACTIVE')
- [ ] invited_at (TIMESTAMP, NOT NULL)
- [ ] accepted_at (TIMESTAMP, NULL)

**NOT** position-based columns:
- [ ] ❌ inviter_position (should NOT exist)
- [ ] ❌ invitee_position (should NOT exist)

### 5. Chain Rules Table Schema Verification

```sql
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'chain_rules'
ORDER BY ordinal_position;
```

Required Columns:
- [ ] id (UUID, PRIMARY KEY)
- [ ] version (INTEGER, NOT NULL, UNIQUE)
- [ ] ticket_duration_hours (INTEGER, NOT NULL, DEFAULT 24)
- [ ] max_attempts (INTEGER, NOT NULL, DEFAULT 3)
- [ ] visibility_range (INTEGER, NOT NULL, DEFAULT 1)
- [ ] seed_unlimited_time (BOOLEAN, NOT NULL, DEFAULT TRUE)
- [ ] reactivation_timeout_hours (INTEGER, NOT NULL, DEFAULT 24)
- [ ] additional_rules (JSONB, NULL)
- [ ] created_by (UUID, NULL, FOREIGN KEY -> users)
- [ ] created_at (TIMESTAMP, NOT NULL)
- [ ] effective_from (TIMESTAMP, NOT NULL)
- [ ] applied_at (TIMESTAMP, NULL)
- [ ] deployment_mode (VARCHAR(20), NOT NULL, DEFAULT 'SCHEDULED')
- [ ] change_description (TEXT, NULL)

### 6. Index Verification

```sql
SELECT tablename, indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;
```

Critical Indexes (verify at minimum):

Users:
- [ ] idx_users_chain_key
- [ ] idx_users_parent_id
- [ ] idx_users_position
- [ ] idx_users_username
- [ ] idx_users_email (partial, WHERE email IS NOT NULL)
- [ ] idx_users_display_name_lower (on LOWER(display_name))

Tickets:
- [ ] idx_tickets_owner_id
- [ ] idx_tickets_status
- [ ] idx_tickets_expires_at
- [ ] idx_tickets_ticket_code
- [ ] idx_tickets_attempt_number
- [ ] idx_tickets_one_active_per_user (partial, WHERE status = 'ACTIVE')

Invitations:
- [ ] idx_invitations_parent_id
- [ ] idx_invitations_child_id
- [ ] idx_invitations_ticket_id
- [ ] idx_invitations_status

Attachments:
- [ ] idx_attachments_parent_id
- [ ] idx_attachments_child_id
- [ ] idx_attachments_ticket_id

### 7. Constraint Verification

```sql
SELECT conname, contype, pg_get_constraintdef(oid)
FROM pg_constraint
WHERE connamespace = 'public'::regnamespace
ORDER BY conname;
```

Critical Constraints:

Users:
- [ ] users_pkey (PRIMARY KEY on id)
- [ ] uq_users_username (UNIQUE on username)
- [ ] chk_users_status (CHECK: 'active', 'removed', 'seed')
- [ ] chk_users_belongs_to (CHECK: 2 uppercase letters or NULL)

Tickets:
- [ ] tickets_pkey (PRIMARY KEY on id)
- [ ] chk_tickets_status (CHECK: 'ACTIVE', 'USED', 'EXPIRED', 'CANCELLED')
- [ ] chk_tickets_expiration (CHECK: expires_at > issued_at)
- [ ] tickets_owner_id_fkey (FOREIGN KEY -> users)

Invitations:
- [ ] invitations_pkey (PRIMARY KEY on id)
- [ ] invitations_child_id_key (UNIQUE on child_id)
- [ ] chk_invitations_status (CHECK: 'ACTIVE', 'REMOVED', 'REVERTED')

### 8. Seed Data Verification

```sql
-- Chain rules
SELECT version, deployment_mode, ticket_duration_hours, max_attempts
FROM chain_rules
WHERE version = 1;
-- Expected: 1 row (version=1, deployment_mode='INSTANT', ticket_duration_hours=24, max_attempts=3)

-- Badges
SELECT badge_type, name, icon
FROM badges
ORDER BY badge_type;
-- Expected: 3 rows (chain_savior, chain_guardian, chain_legend)

-- Seed user
SELECT id, username, chain_key, position, status
FROM users
WHERE position = 1;
-- Expected: 1 row (username='alpaslan', chain_key='SEED00000001', position=1, status='seed')
```

Results:
- [ ] Default rule exists (version 1)
- [ ] 3 badges exist
- [ ] Seed user exists (alpaslan)

### 9. Foreign Key Relationships

```sql
SELECT
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
ORDER BY tc.table_name, kcu.column_name;
```

Expected Foreign Keys:
- [ ] tickets.owner_id -> users.id (ON DELETE CASCADE)
- [ ] tickets.claimed_by -> users.id
- [ ] attachments.parent_id -> users.id
- [ ] attachments.child_id -> users.id
- [ ] attachments.ticket_id -> tickets.id
- [ ] invitations.parent_id -> users.id
- [ ] invitations.child_id -> users.id
- [ ] invitations.ticket_id -> tickets.id
- [ ] chain_rules.created_by -> users.id
- [ ] user_badges.badge_type -> badges.badge_type
- [ ] notifications.user_id -> users.id (ON DELETE CASCADE)
- [ ] device_tokens.user_id -> users.id (ON DELETE CASCADE)
- [ ] country_change_events.created_by -> users.id
- [ ] audit_log.actor_id -> users.id
- [ ] auth_sessions.user_id -> users.id (ON DELETE CASCADE)
- [ ] password_reset_tokens.user_id -> users.id (ON DELETE CASCADE)
- [ ] email_verification_tokens.user_id -> users.id (ON DELETE CASCADE)

### 10. Data Type Compatibility

Java Entity -> PostgreSQL Mapping:

- [ ] UUID -> UUID ✓
- [ ] String -> VARCHAR ✓
- [ ] Integer -> INTEGER ✓
- [ ] Boolean -> BOOLEAN ✓
- [ ] Instant -> TIMESTAMP WITH TIME ZONE ✓
- [ ] Enum -> VARCHAR (with CHECK constraint) ✓
- [ ] Map<String, Object> -> JSONB ✓

### 11. Application Integration Tests

After migration, run these tests:

```bash
# Unit tests
./mvnw test

# Integration tests
./mvnw verify

# Specific entity tests
./mvnw test -Dtest=UserTest
./mvnw test -Dtest=TicketTest
./mvnw test -Dtest=AuthServiceTest
```

Test Results:
- [ ] All unit tests pass
- [ ] All integration tests pass
- [ ] No database constraint violations
- [ ] No serialization errors

### 12. API Endpoint Testing

Manual testing of critical endpoints:

Authentication:
- [ ] POST /api/auth/register (create new user)
- [ ] POST /api/auth/login (username/password)
- [ ] POST /api/auth/refresh (refresh token)
- [ ] POST /api/auth/logout

Ticket Operations:
- [ ] POST /api/tickets/generate (create ticket)
- [ ] GET /api/tickets/my (get user's tickets)
- [ ] POST /api/tickets/claim (claim ticket)

User Operations:
- [ ] GET /api/users/me (get current user)
- [ ] GET /api/users/chain (get chain visibility)
- [ ] PATCH /api/users/me (update profile)

### 13. Performance Validation

```sql
-- Query performance (should use indexes)
EXPLAIN ANALYZE SELECT * FROM users WHERE username = 'alpaslan';
EXPLAIN ANALYZE SELECT * FROM tickets WHERE owner_id = 'a0000000-0000-0000-0000-000000000001'::UUID AND status = 'ACTIVE';
EXPLAIN ANALYZE SELECT * FROM invitations WHERE parent_id = 'a0000000-0000-0000-0000-000000000001'::UUID;
```

Verify:
- [ ] All queries use index scans (not sequential scans)
- [ ] Query execution time < 10ms (empty database)
- [ ] No missing index warnings

### 14. Documentation Verification

```sql
-- Check table comments
SELECT
    c.relname AS table_name,
    pg_catalog.obj_description(c.oid, 'pg_class') AS table_comment
FROM pg_catalog.pg_class c
WHERE c.relnamespace = 'public'::regnamespace
AND c.relkind = 'r'
ORDER BY c.relname;

-- Check column comments
SELECT
    c.table_name,
    c.column_name,
    pgd.description
FROM pg_catalog.pg_statio_all_tables st
INNER JOIN pg_catalog.pg_description pgd ON pgd.objoid = st.relid
INNER JOIN information_schema.columns c ON (
    pgd.objsubid = c.ordinal_position AND
    c.table_schema = st.schemaname AND
    c.table_name = st.relname
)
WHERE c.table_schema = 'public'
ORDER BY c.table_name, c.ordinal_position;
```

Verify:
- [ ] All 17 tables have comments
- [ ] Key columns have comments (chain_key, position, username, etc.)

## Final Checklist

- [ ] All 17 tables exist
- [ ] All 50+ indexes created
- [ ] All foreign keys defined
- [ ] All check constraints active
- [ ] All unique constraints enforced
- [ ] Seed data inserted correctly
- [ ] Application starts without errors
- [ ] All tests pass
- [ ] API endpoints functional
- [ ] Query performance acceptable
- [ ] Documentation complete

## Rollback Criteria

If any of these conditions occur, perform rollback:
- [ ] Migration fails with errors
- [ ] Data loss detected
- [ ] Application won't start
- [ ] Critical tests fail
- [ ] Performance degradation > 50%

## Sign-off

**Migration Performed By:** _____________________
**Date:** _____________________
**Time:** _____________________
**Database:** _____________________
**Migration Type:** [ ] Option 1 (Fresh)  [ ] Option 2 (V4)  [ ] Option 3 (Recreation)
**Result:** [ ] Success  [ ] Failed  [ ] Rolled Back

**Notes:**
```
_____________________________________________________________________________
_____________________________________________________________________________
_____________________________________________________________________________
```

**Verified By:** _____________________
**Date:** _____________________
