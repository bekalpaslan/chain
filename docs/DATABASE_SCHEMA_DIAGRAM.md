# Database Schema Diagram - The Chain

## Entity Relationship Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           USERS (Core Entity)                           │
│─────────────────────────────────────────────────────────────────────────│
│ PK │ id (UUID)                                                          │
│ UK │ chain_key (VARCHAR(32))                                            │
│ UK │ username (VARCHAR(50))                                              │
│ UK │ position (INTEGER)                                                 │
│ FK │ parent_id (UUID) -> users.id                                       │
│    │ display_name (VARCHAR(50))                                         │
│    │ password_hash (VARCHAR(255))                                       │
│    │ email (VARCHAR(255))                                               │
│    │ belongs_to (VARCHAR(2)) -- Country code                            │
│    │ status (VARCHAR(20)) -- active, removed, seed                      │
│    │ inviter_position (INTEGER)                                         │
│    │ invitee_position (INTEGER)                                         │
│    │ wasted_tickets_count (INTEGER)                                     │
│    │ total_tickets_generated (INTEGER)                                  │
│    │ created_at, updated_at, deleted_at                                 │
└──┬──────────────────────────────────────────────────────────────────┬───┘
   │                                                                  │
   │                                                                  │
   │ 1                                                                │ 1
   │                                                                  │
   ▼ *                                                                ▼ *
┌─────────────────────────────┐                    ┌──────────────────────────────┐
│      TICKETS                │                    │      INVITATIONS             │
│─────────────────────────────│                    │──────────────────────────────│
│ PK │ id (UUID)              │                    │ PK │ id (UUID)               │
│ FK │ owner_id -> users.id   │◄───────┐           │ FK │ parent_id -> users.id   │
│ FK │ claimed_by -> users.id │        │           │ FK │ child_id -> users.id    │
│    │ ticket_code (VARCHAR)  │        │           │ FK │ ticket_id -> tickets.id │
│    │ next_position (INT)    │        │           │    │ status (VARCHAR(20))    │
│    │ attempt_number (INT)   │        │           │    │ invited_at (TIMESTAMP)  │
│    │ rule_version (INT)     │        │           │    │ accepted_at (TIMESTAMP) │
│    │ duration_hours (INT)   │        │           └──────────────────────────────┘
│    │ qr_code_url (VARCHAR)  │        │
│    │ issued_at (TIMESTAMP)  │        │
│    │ expires_at (TIMESTAMP) │        │           ┌──────────────────────────────┐
│    │ used_at (TIMESTAMP)    │        │           │      ATTACHMENTS             │
│    │ status (VARCHAR(20))   │        │           │──────────────────────────────│
│    │ signature (TEXT)       │        │           │ PK │ id (UUID)               │
│    │ payload (TEXT)         │        │           │ FK │ parent_id -> users.id   │
│    │ message (VARCHAR(100)) │        │           │ FK │ child_id -> users.id    │
└─────────────────────────────┘        └───────────│ FK │ ticket_id -> tickets.id │
                                                   │    │ attached_at (TIMESTAMP) │
                                                   └──────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│                         CHAIN RULES (Game Config)                       │
│─────────────────────────────────────────────────────────────────────────│
│ PK │ id (UUID)                                                          │
│ UK │ version (INTEGER)                                                  │
│ FK │ created_by -> users.id                                             │
│    │ ticket_duration_hours (INTEGER) -- Default: 24                     │
│    │ max_attempts (INTEGER) -- Default: 3 (3-strike rule)               │
│    │ visibility_range (INTEGER) -- Default: 1 (±1 visibility)           │
│    │ seed_unlimited_time (BOOLEAN) -- Default: TRUE                     │
│    │ reactivation_timeout_hours (INTEGER) -- Default: 24                │
│    │ additional_rules (JSONB)                                           │
│    │ deployment_mode (VARCHAR) -- INSTANT or SCHEDULED                  │
│    │ effective_from (TIMESTAMP)                                         │
│    │ applied_at (TIMESTAMP)                                             │
│    │ change_description (TEXT)                                          │
└─────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────┐         ┌──────────────────────────────────┐
│      BADGES              │         │      USER_BADGES                 │
│──────────────────────────│         │──────────────────────────────────│
│ PK │ id (UUID)           │         │ PK │ id (UUID)                   │
│ UK │ badge_type (VARCHAR)│◄────────│ FK │ badge_type -> badges.type   │
│    │ name (VARCHAR(100)) │         │    │ user_position (INTEGER)     │
│    │ icon (VARCHAR(10))  │         │    │ earned_at (TIMESTAMP)       │
│    │ description (TEXT)  │         │    │ context (JSONB)             │
└──────────────────────────┘         └──────────────────────────────────┘
                                     UK: (user_position, badge_type)

┌─────────────────────────────────────────────────────────────────────────┐
│                         NOTIFICATIONS                                   │
│─────────────────────────────────────────────────────────────────────────│
│ PK │ id (UUID)                                                          │
│ FK │ user_id -> users.id (ON DELETE CASCADE)                            │
│    │ notification_type (VARCHAR) -- BECAME_TIP, TICKET_EXPIRING, etc.   │
│    │ title (VARCHAR(200))                                               │
│    │ body (TEXT)                                                        │
│    │ sent_via_push (BOOLEAN)                                            │
│    │ sent_via_email (BOOLEAN)                                           │
│    │ action_url (VARCHAR(500))                                          │
│    │ priority (VARCHAR) -- CRITICAL, IMPORTANT, NORMAL, LOW             │
│    │ created_at, sent_at, read_at (TIMESTAMP)                           │
│    │ metadata (JSONB)                                                   │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│                         DEVICE_TOKENS                                   │
│─────────────────────────────────────────────────────────────────────────│
│ PK │ id (UUID)                                                          │
│ FK │ user_id -> users.id (ON DELETE CASCADE)                            │
│    │ device_id (VARCHAR(255))                                           │
│    │ platform (VARCHAR) -- ios, android, web                            │
│    │ push_token (TEXT)                                                  │
│    │ created_at, updated_at, revoked_at (TIMESTAMP)                     │
└─────────────────────────────────────────────────────────────────────────┘
UK: (user_id, device_id)

┌─────────────────────────────────────────────────────────────────────────┐
│                    COUNTRY_CHANGE_EVENTS (Admin)                        │
│─────────────────────────────────────────────────────────────────────────│
│ PK │ id (UUID)                                                          │
│ FK │ created_by -> users.id                                             │
│    │ event_name (VARCHAR(100))                                          │
│    │ description (TEXT)                                                 │
│    │ enabled_at (TIMESTAMP)                                             │
│    │ disabled_at (TIMESTAMP)                                            │
│    │ applies_to (VARCHAR) -- all, specific_users                        │
│    │ allowed_countries (TEXT[])                                         │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│                         AUDIT_LOG                                       │
│─────────────────────────────────────────────────────────────────────────│
│ PK │ id (UUID)                                                          │
│ FK │ actor_id -> users.id                                               │
│    │ actor_type (VARCHAR) -- user, admin, system                        │
│    │ action_type (VARCHAR(50))                                          │
│    │ entity_type (VARCHAR(50))                                          │
│    │ entity_id (UUID)                                                   │
│    │ description (TEXT)                                                 │
│    │ metadata (JSONB)                                                   │
│    │ ip_address (VARCHAR(45))                                           │
│    │ user_agent (TEXT)                                                  │
│    │ created_at (TIMESTAMP)                                             │
└─────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────┐
│                    AUTHENTICATION TABLES                                 │
└──────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────┐  ┌─────────────────────────────────────┐
│      AUTH_SESSIONS          │  │   PASSWORD_RESET_TOKENS             │
│─────────────────────────────│  │─────────────────────────────────────│
│ PK │ id (UUID)              │  │ PK │ id (UUID)                      │
│ FK │ user_id -> users.id    │  │ FK │ user_id -> users.id            │
│ UK │ refresh_token (VARCHAR)│  │ UK │ token (VARCHAR(255))           │
│    │ ip_address (VARCHAR)   │  │    │ created_at (TIMESTAMP)         │
│    │ user_agent (TEXT)      │  │    │ expires_at (TIMESTAMP)         │
│    │ created_at (TIMESTAMP) │  │    │ used_at (TIMESTAMP)            │
│    │ expires_at (TIMESTAMP) │  └─────────────────────────────────────┘
│    │ revoked_at (TIMESTAMP) │
└─────────────────────────────┘  ┌─────────────────────────────────────┐
                                 │   MAGIC_LINK_TOKENS                 │
┌─────────────────────────────┐  │─────────────────────────────────────│
│EMAIL_VERIFICATION_TOKENS    │  │ PK │ id (UUID)                      │
│─────────────────────────────│  │    │ email (VARCHAR(255))           │
│ PK │ id (UUID)              │  │ UK │ token (VARCHAR(255))           │
│ FK │ user_id -> users.id    │  │    │ created_at (TIMESTAMP)         │
│ UK │ token (VARCHAR(255))   │  │    │ expires_at (TIMESTAMP)         │
│    │ created_at (TIMESTAMP) │  │    │ used_at (TIMESTAMP)            │
│    │ expires_at (TIMESTAMP) │  └─────────────────────────────────────┘
│    │ verified_at (TIMESTAMP)│
└─────────────────────────────┘
```

## Table Relationships Summary

### Core Chain Relationships
```
users (1) ──< tickets (*)         -- User owns tickets
users (1) ──< invitations (*) as parent
users (1) ──< invitations (1) as child
users (1) ──< attachments (*) as parent
users (1) ──< attachments (1) as child
tickets (1) ──< invitations (*)   -- Ticket used for invitation
tickets (1) ──< attachments (*)   -- Ticket used for attachment
users (1) ──< users (*) as parent -- Hierarchical chain
```

### Badge Relationships
```
badges (1) ──< user_badges (*)    -- Badge earned by users
```

### Notification Relationships
```
users (1) ──< notifications (*)   -- User receives notifications
users (1) ──< device_tokens (*)   -- User has multiple devices
```

### Authentication Relationships
```
users (1) ──< auth_sessions (*)              -- User has multiple sessions
users (1) ──< password_reset_tokens (*)      -- User can reset password
users (1) ──< email_verification_tokens (*)  -- User can verify email
```

### Admin Relationships
```
users (1) ──< chain_rules (*) as creator     -- Admin creates rules
users (1) ──< country_change_events (*)      -- Admin creates events
users (1) ──< audit_log (*)                  -- User actions logged
```

## Index Strategy

### Primary Access Patterns

1. **User Authentication**
   - `idx_users_username` (UNIQUE)
   - `idx_users_email` (UNIQUE, partial: WHERE NOT NULL)

2. **Chain Navigation**
   - `idx_users_position` (UNIQUE)
   - `idx_users_parent_id`
   - `idx_users_chain_key` (UNIQUE)

3. **Ticket Operations**
   - `idx_tickets_owner_id`
   - `idx_tickets_status`
   - `idx_tickets_one_active_per_user` (partial: WHERE status = 'ACTIVE')
   - `idx_tickets_expires_at` (for expiration queries)

4. **Invitation Tracking**
   - `idx_invitations_parent_id`
   - `idx_invitations_child_id` (UNIQUE)
   - `idx_invitations_ticket_id`

5. **Notification Delivery**
   - `idx_notifications_user_id`
   - `idx_notifications_created_at`
   - `idx_notifications_read_at`

## Constraint Summary

### Unique Constraints
- users: chain_key, username, position, display_name (case-insensitive)
- tickets: one active ticket per user (partial unique index)
- invitations: child_id (each user invited only once)
- attachments: child_id (each user attached only once)
- chain_rules: version
- user_badges: (user_position, badge_type)
- All token tables: token

### Check Constraints
- users.status: IN ('active', 'removed', 'seed')
- users.removal_reason: IN ('3_failed_attempts', 'inactive_when_reactivated', 'admin_action')
- users.belongs_to: 2 uppercase letters or NULL
- tickets.status: IN ('ACTIVE', 'USED', 'EXPIRED', 'CANCELLED')
- tickets.expires_at > issued_at
- invitations.status: IN ('ACTIVE', 'REMOVED', 'REVERTED')
- notifications.priority: IN ('CRITICAL', 'IMPORTANT', 'NORMAL', 'LOW')
- chain_rules.deployment_mode: IN ('INSTANT', 'SCHEDULED')

### Foreign Key Constraints (with CASCADE)
- tickets.owner_id -> users.id (ON DELETE CASCADE)
- notifications.user_id -> users.id (ON DELETE CASCADE)
- device_tokens.user_id -> users.id (ON DELETE CASCADE)
- auth_sessions.user_id -> users.id (ON DELETE CASCADE)
- password_reset_tokens.user_id -> users.id (ON DELETE CASCADE)
- email_verification_tokens.user_id -> users.id (ON DELETE CASCADE)

## Data Types Reference

| Domain | PostgreSQL Type | Java Type | Hibernate Type |
|--------|-----------------|-----------|----------------|
| Identity | UUID | UUID | uuid |
| Strings | VARCHAR(n) | String | varchar |
| Numbers | INTEGER | Integer | int4 |
| Flags | BOOLEAN | Boolean | bool |
| Times | TIMESTAMP WITH TIME ZONE | Instant | timestamptz |
| Enums | VARCHAR(n) + CHECK | Enum | varchar |
| JSON | JSONB | Map<String, Object> | jsonb |
| Long Text | TEXT | String | text |

## Column Naming Convention

```
PostgreSQL (snake_case)     →     Java (camelCase)
────────────────────────────────────────────────────
chain_key                   →     chainKey
display_name                →     displayName
parent_id                   →     parentId
password_hash               →     passwordHash
apple_user_id               →     appleUserId
wasted_tickets_count        →     wastedTicketsCount
created_at                  →     createdAt
```

Exception: `belongs_to` → `associatedWith` (with @Column annotation)

## Seed Data

### Default Chain Rule (Version 1)
```sql
version: 1
ticket_duration_hours: 24
max_attempts: 3
visibility_range: 1
seed_unlimited_time: TRUE
reactivation_timeout_hours: 24
deployment_mode: 'INSTANT'
```

### Predefined Badges
1. **chain_savior** - Chain Savior 🦸
2. **chain_guardian** - Chain Guardian 🛡️
3. **chain_legend** - Chain Legend ⭐

### Seed User
```sql
username: alpaslan
chain_key: SEED00000001
position: 1
status: seed
belongs_to: US
```

## Schema Statistics

| Metric | Count |
|--------|-------|
| Tables | 17 |
| Total Columns | 167 |
| Primary Keys | 17 |
| Foreign Keys | 17 |
| Unique Constraints | 14 |
| Check Constraints | 11 |
| Indexes | 56 |
| Default Values | 31 |
| JSONB Columns | 5 |
| Timestamp Columns | 42 |

## Migration Versions

| Version | Purpose | Tables Added | Tables Modified |
|---------|---------|--------------|-----------------|
| V1 (consolidated) | Complete schema | 17 | - |
| V4 (optimization) | Missing columns | 0 | tickets (3 columns), all (comments) |

---

**Last Updated:** 2025-10-09
**Schema Version:** V1 (consolidated) or V4 (optimized)
**Database:** PostgreSQL 12+
**ORM:** Hibernate 6.x with JPA
