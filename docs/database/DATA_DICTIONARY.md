# Database Data Dictionary

This document provides a comprehensive reference for all tables, columns, constraints, and indexes in the Ticketz database.

**Database:** chaindb
**DBMS:** PostgreSQL 15
**Last Updated:** 2025-01-10

---

## Table of Contents

- [Tables](#tables)
  - [users](#users)
  - [tickets](#tickets)
  - [attachments](#attachments)
  - [invitations](#invitations)
  - [notifications](#notifications)
  - [device_tokens](#device_tokens)
  - [auth_sessions](#auth_sessions)
  - [badges](#badges)
  - [user_badges](#user_badges)
  - [chain_rules](#chain_rules)
  - [audit_log](#audit_log)
  - [country_change_events](#country_change_events)
  - [email_verification_tokens](#email_verification_tokens)
  - [password_reset_tokens](#password_reset_tokens)
  - [magic_link_tokens](#magic_link_tokens)
- [Enumerations](#enumerations)
- [Indexes](#indexes)
- [Relationships](#relationships)

---

## Tables

### users

**Purpose:** Stores user account information and chain position data.

**Entity:** User.java

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | UUID | NOT NULL | gen_random_uuid() | Primary key, globally unique user identifier |
| username | VARCHAR(50) | NOT NULL | - | Unique username, 3-50 characters, alphanumeric + underscore |
| email | VARCHAR(255) | NOT NULL | - | Unique email address, case-insensitive storage |
| password_hash | VARCHAR(255) | NOT NULL | - | BCrypt hash of user password (60 chars) |
| display_name | VARCHAR(100) | NULL | - | User's display name, can differ from username |
| bio | TEXT | NULL | - | User biography or description |
| avatar_url | VARCHAR(500) | NULL | - | URL to user's avatar image |
| position | BIGINT | NOT NULL | - | Unique position in the global chain (1-indexed) |
| chain_key | VARCHAR(100) | NOT NULL | - | Unique chain identifier for this user |
| country_code | VARCHAR(2) | NULL | - | ISO 3166-1 alpha-2 country code |
| phone_number | VARCHAR(20) | NULL | - | Phone number in E.164 format |
| google_id | VARCHAR(255) | NULL | - | Google OAuth identifier (unique if provided) |
| apple_id | VARCHAR(255) | NULL | - | Apple OAuth identifier (unique if provided) |
| email_verified | BOOLEAN | NOT NULL | FALSE | Whether email has been verified |
| two_factor_enabled | BOOLEAN | NOT NULL | FALSE | Whether 2FA is enabled for this account |
| account_status | VARCHAR(20) | NOT NULL | 'ACTIVE' | Account status: ACTIVE, SUSPENDED, BANNED |
| last_login_at | TIMESTAMP WITH TIME ZONE | NULL | - | Timestamp of last successful login |
| created_at | TIMESTAMP WITH TIME ZONE | NOT NULL | CURRENT_TIMESTAMP | Account creation timestamp |
| updated_at | TIMESTAMP WITH TIME ZONE | NOT NULL | CURRENT_TIMESTAMP | Last update timestamp |
| deleted_at | TIMESTAMP WITH TIME ZONE | NULL | - | Soft delete timestamp (NULL = active) |

**Constraints:**
- PRIMARY KEY: id
- UNIQUE: username (case-insensitive via LOWER())
- UNIQUE: email (case-insensitive via LOWER())
- UNIQUE: position (only for non-deleted users)
- UNIQUE: chain_key (only for non-deleted users)
- UNIQUE: display_name (case-insensitive, only for non-deleted users)
- UNIQUE: google_id (only if not NULL)
- UNIQUE: apple_id (only if not NULL)

**Indexes:**
- PRIMARY KEY index on id
- UNIQUE index on LOWER(username)
- UNIQUE index on LOWER(email)
- UNIQUE partial index on position WHERE deleted_at IS NULL
- UNIQUE partial index on chain_key WHERE deleted_at IS NULL
- UNIQUE partial index on LOWER(display_name) WHERE deleted_at IS NULL
- UNIQUE partial index on google_id WHERE google_id IS NOT NULL
- UNIQUE partial index on apple_id WHERE apple_id IS NOT NULL

---

### tickets

**Purpose:** Stores invitation tickets with expiration and attempt tracking.

**Entity:** Ticket.java

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | UUID | NOT NULL | gen_random_uuid() | Primary key, unique ticket identifier |
| owner_id | UUID | NOT NULL | - | Foreign key to users(id), ticket owner |
| ticket_code | VARCHAR(100) | NOT NULL | - | Unique ticket code for redemption |
| signature | TEXT | NULL | - | Cryptographic signature for ticket validation |
| issued_at | TIMESTAMP WITH TIME ZONE | NOT NULL | CURRENT_TIMESTAMP | Timestamp when ticket was issued |
| expires_at | TIMESTAMP WITH TIME ZONE | NOT NULL | - | Expiration timestamp (typically 7 days from issue) |
| status | VARCHAR(20) | NOT NULL | 'ACTIVE' | Ticket status: ACTIVE, USED, EXPIRED, CANCELLED |
| attempt_number | INTEGER | NOT NULL | 0 | Current attempt count (0-indexed) |
| max_attempts | INTEGER | NOT NULL | 3 | Maximum allowed attempts (3-strike system) |
| used_at | TIMESTAMP WITH TIME ZONE | NULL | - | Timestamp when ticket was successfully used |
| used_by_id | UUID | NULL | - | Foreign key to users(id), who used this ticket |
| created_at | TIMESTAMP WITH TIME ZONE | NOT NULL | CURRENT_TIMESTAMP | Creation timestamp |
| updated_at | TIMESTAMP WITH TIME ZONE | NOT NULL | CURRENT_TIMESTAMP | Last update timestamp |
| deleted_at | TIMESTAMP WITH TIME ZONE | NULL | - | Soft delete timestamp |

**Constraints:**
- PRIMARY KEY: id
- FOREIGN KEY: owner_id → users(id) ON DELETE CASCADE
- FOREIGN KEY: used_by_id → users(id) ON DELETE SET NULL
- UNIQUE: owner_id (only one ACTIVE ticket per user per time)
- CHECK: attempt_number >= 0 AND attempt_number <= max_attempts

**Indexes:**
- PRIMARY KEY index on id
- Foreign key index on owner_id
- Foreign key index on used_by_id
- UNIQUE partial index on owner_id WHERE status = 'ACTIVE' AND deleted_at IS NULL
- Index on status
- Index on expires_at

---

### attachments

**Purpose:** Represents parent-child relationships in the invitation chain.

**Entity:** Attachment.java

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | UUID | NOT NULL | gen_random_uuid() | Primary key, unique attachment identifier |
| parent_id | UUID | NOT NULL | - | Foreign key to users(id), the parent in relationship |
| child_id | UUID | NOT NULL | - | Foreign key to users(id), the child in relationship |
| attached_at | TIMESTAMP WITH TIME ZONE | NOT NULL | CURRENT_TIMESTAMP | Timestamp when relationship was established |
| created_at | TIMESTAMP WITH TIME ZONE | NOT NULL | CURRENT_TIMESTAMP | Creation timestamp |
| deleted_at | TIMESTAMP WITH TIME ZONE | NULL | - | Soft delete timestamp |

**Constraints:**
- PRIMARY KEY: id
- FOREIGN KEY: parent_id → users(id) ON DELETE CASCADE
- FOREIGN KEY: child_id → users(id) ON DELETE CASCADE
- UNIQUE: (parent_id, child_id) - cannot have duplicate relationships

**Indexes:**
- PRIMARY KEY index on id
- Foreign key index on parent_id
- Foreign key index on child_id

---

### invitations

**Purpose:** Historical tracking of invitation events.

**Entity:** Invitation.java

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | UUID | NOT NULL | gen_random_uuid() | Primary key, unique invitation identifier |
| ticket_id | UUID | NOT NULL | - | Foreign key to tickets(id), the ticket used |
| inviter_id | UUID | NOT NULL | - | Foreign key to users(id), who sent the invitation |
| invitee_id | UUID | NOT NULL | - | Foreign key to users(id), who accepted the invitation |
| invited_at | TIMESTAMP WITH TIME ZONE | NOT NULL | CURRENT_TIMESTAMP | Timestamp when invitation was sent |
| accepted_at | TIMESTAMP WITH TIME ZONE | NULL | - | Timestamp when invitation was accepted |
| created_at | TIMESTAMP WITH TIME ZONE | NOT NULL | CURRENT_TIMESTAMP | Creation timestamp |

**Constraints:**
- PRIMARY KEY: id
- FOREIGN KEY: ticket_id → tickets(id) ON DELETE CASCADE
- FOREIGN KEY: inviter_id → users(id) ON DELETE CASCADE
- FOREIGN KEY: invitee_id → users(id) ON DELETE CASCADE

**Indexes:**
- PRIMARY KEY index on id
- Foreign key index on ticket_id
- Foreign key index on inviter_id
- Foreign key index on invitee_id

---

### notifications

**Purpose:** Multi-channel notification system for user communications.

**Entity:** Notification.java

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | UUID | NOT NULL | gen_random_uuid() | Primary key, unique notification identifier |
| user_id | UUID | NOT NULL | - | Foreign key to users(id), recipient |
| type | VARCHAR(20) | NOT NULL | - | Notification type: EMAIL, PUSH, SMS, IN_APP |
| priority | VARCHAR(10) | NOT NULL | 'NORMAL' | Priority: LOW, NORMAL, HIGH, URGENT |
| title | VARCHAR(255) | NOT NULL | - | Notification title/subject |
| message | TEXT | NOT NULL | - | Notification body/content |
| metadata | JSONB | NULL | - | Additional metadata (flexible structure) |
| sent_at | TIMESTAMP WITH TIME ZONE | NULL | - | When notification was sent |
| read_at | TIMESTAMP WITH TIME ZONE | NULL | - | When user read the notification |
| failed_at | TIMESTAMP WITH TIME ZONE | NULL | - | If delivery failed, timestamp of failure |
| failure_reason | TEXT | NULL | - | Reason for delivery failure |
| created_at | TIMESTAMP WITH TIME ZONE | NOT NULL | CURRENT_TIMESTAMP | Creation timestamp |

**Constraints:**
- PRIMARY KEY: id
- FOREIGN KEY: user_id → users(id) ON DELETE CASCADE
- CHECK: type IN ('EMAIL', 'PUSH', 'SMS', 'IN_APP')
- CHECK: priority IN ('LOW', 'NORMAL', 'HIGH', 'URGENT')

**Indexes:**
- PRIMARY KEY index on id
- Foreign key index on user_id
- Index on read_at (for unread queries)

---

### device_tokens

**Purpose:** Stores push notification device tokens for mobile devices.

**Entity:** DeviceToken.java

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | UUID | NOT NULL | gen_random_uuid() | Primary key, unique token identifier |
| user_id | UUID | NOT NULL | - | Foreign key to users(id), device owner |
| token | VARCHAR(500) | NOT NULL | - | FCM/APNs device token |
| platform | VARCHAR(20) | NOT NULL | - | Platform: IOS, ANDROID, WEB |
| device_name | VARCHAR(100) | NULL | - | User-friendly device name |
| last_used_at | TIMESTAMP WITH TIME ZONE | NOT NULL | CURRENT_TIMESTAMP | Last time token was used successfully |
| created_at | TIMESTAMP WITH TIME ZONE | NOT NULL | CURRENT_TIMESTAMP | Registration timestamp |

**Constraints:**
- PRIMARY KEY: id
- FOREIGN KEY: user_id → users(id) ON DELETE CASCADE
- UNIQUE: token (same token cannot be registered twice)
- CHECK: platform IN ('IOS', 'ANDROID', 'WEB')

**Indexes:**
- PRIMARY KEY index on id
- Foreign key index on user_id
- UNIQUE index on token

---

### auth_sessions

**Purpose:** JWT refresh token session management.

**Entity:** AuthSession.java

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | UUID | NOT NULL | gen_random_uuid() | Primary key, unique session identifier |
| user_id | UUID | NOT NULL | - | Foreign key to users(id), session owner |
| refresh_token | VARCHAR(500) | NOT NULL | - | JWT refresh token (hashed) |
| access_token_jti | VARCHAR(100) | NULL | - | JTI claim of associated access token |
| ip_address | VARCHAR(50) | NULL | - | IP address where session was created |
| user_agent | TEXT | NULL | - | Browser/client user agent string |
| expires_at | TIMESTAMP WITH TIME ZONE | NOT NULL | - | Token expiration timestamp |
| revoked_at | TIMESTAMP WITH TIME ZONE | NULL | - | If revoked, timestamp of revocation |
| created_at | TIMESTAMP WITH TIME ZONE | NOT NULL | CURRENT_TIMESTAMP | Session creation timestamp |

**Constraints:**
- PRIMARY KEY: id
- FOREIGN KEY: user_id → users(id) ON DELETE CASCADE
- UNIQUE: refresh_token

**Indexes:**
- PRIMARY KEY index on id
- Foreign key index on user_id
- UNIQUE index on refresh_token
- Index on expires_at (for cleanup queries)

---

### badges

**Purpose:** Achievement and milestone badge definitions.

**Entity:** Badge.java

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | UUID | NOT NULL | gen_random_uuid() | Primary key, unique badge identifier |
| name | VARCHAR(100) | NOT NULL | - | Badge display name |
| description | TEXT | NOT NULL | - | Description of how to earn this badge |
| icon_url | VARCHAR(500) | NULL | - | URL to badge icon image |
| badge_type | VARCHAR(20) | NOT NULL | - | Type: ACHIEVEMENT, MILESTONE, SPECIAL |
| criteria | JSONB | NULL | - | Programmatic criteria for awarding |
| is_active | BOOLEAN | NOT NULL | TRUE | Whether badge is currently active |
| display_order | INTEGER | NOT NULL | 0 | Sort order for display |
| created_at | TIMESTAMP WITH TIME ZONE | NOT NULL | CURRENT_TIMESTAMP | Creation timestamp |

**Constraints:**
- PRIMARY KEY: id
- UNIQUE: name
- CHECK: badge_type IN ('ACHIEVEMENT', 'MILESTONE', 'SPECIAL')

**Indexes:**
- PRIMARY KEY index on id
- UNIQUE index on name

---

### user_badges

**Purpose:** Tracks which badges users have earned.

**Entity:** UserBadge.java

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | UUID | NOT NULL | gen_random_uuid() | Primary key, unique user-badge mapping |
| user_id | UUID | NOT NULL | - | Foreign key to users(id), badge recipient |
| badge_id | UUID | NOT NULL | - | Foreign key to badges(id), earned badge |
| earned_at | TIMESTAMP WITH TIME ZONE | NOT NULL | CURRENT_TIMESTAMP | Timestamp when badge was earned |
| progress | INTEGER | NULL | - | Progress towards next level (optional) |

**Constraints:**
- PRIMARY KEY: id
- FOREIGN KEY: user_id → users(id) ON DELETE CASCADE
- FOREIGN KEY: badge_id → badges(id) ON DELETE CASCADE
- UNIQUE: (user_id, badge_id) - user can earn each badge only once

**Indexes:**
- PRIMARY KEY index on id
- Foreign key index on user_id
- Foreign key index on badge_id
- UNIQUE composite index on (user_id, badge_id)

---

### chain_rules

**Purpose:** Versioned configuration for chain rules and business logic.

**Entity:** ChainRule.java

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | UUID | NOT NULL | gen_random_uuid() | Primary key, unique rule identifier |
| version | INTEGER | NOT NULL | - | Rule version number |
| rule_content | JSONB | NOT NULL | - | Rule definition in JSON format |
| description | TEXT | NULL | - | Human-readable description of changes |
| is_active | BOOLEAN | NOT NULL | FALSE | Whether this version is currently active |
| effective_from | TIMESTAMP WITH TIME ZONE | NULL | - | When this version becomes effective |
| created_by_id | UUID | NULL | - | Foreign key to users(id), who created this rule |
| created_at | TIMESTAMP WITH TIME ZONE | NOT NULL | CURRENT_TIMESTAMP | Creation timestamp |

**Constraints:**
- PRIMARY KEY: id
- FOREIGN KEY: created_by_id → users(id) ON DELETE SET NULL
- UNIQUE: version

**Indexes:**
- PRIMARY KEY index on id
- UNIQUE index on version

---

### audit_log

**Purpose:** Comprehensive audit trail for all significant actions.

**Entity:** AuditLog.java

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | UUID | NOT NULL | gen_random_uuid() | Primary key, unique log entry identifier |
| user_id | UUID | NULL | - | Foreign key to users(id), who performed the action |
| action | VARCHAR(50) | NOT NULL | - | Action type: CREATE, UPDATE, DELETE, LOGIN, etc. |
| entity_type | VARCHAR(50) | NOT NULL | - | Entity affected: USER, TICKET, INVITATION, etc. |
| entity_id | UUID | NULL | - | ID of the affected entity |
| old_value | JSONB | NULL | - | Previous state (for updates) |
| new_value | JSONB | NULL | - | New state (for creates/updates) |
| ip_address | VARCHAR(50) | NULL | - | IP address of requester |
| user_agent | TEXT | NULL | - | User agent of requester |
| metadata | JSONB | NULL | - | Additional context |
| created_at | TIMESTAMP WITH TIME ZONE | NOT NULL | CURRENT_TIMESTAMP | When action occurred |

**Constraints:**
- PRIMARY KEY: id
- FOREIGN KEY: user_id → users(id) ON DELETE SET NULL

**Indexes:**
- PRIMARY KEY index on id
- Foreign key index on user_id
- Composite index on (entity_type, entity_id) for entity history queries

---

### country_change_events

**Purpose:** Tracks user country changes with time-windowing.

**Entity:** CountryChangeEvent.java

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | UUID | NOT NULL | gen_random_uuid() | Primary key, unique event identifier |
| user_id | UUID | NOT NULL | - | Foreign key to users(id), user changing country |
| old_country_code | VARCHAR(2) | NOT NULL | - | Previous country code (ISO 3166-1 alpha-2) |
| new_country_code | VARCHAR(2) | NOT NULL | - | New country code (ISO 3166-1 alpha-2) |
| change_reason | VARCHAR(100) | NULL | - | Reason for change (user-provided or system) |
| ip_address | VARCHAR(50) | NULL | - | IP address at time of change |
| created_at | TIMESTAMP WITH TIME ZONE | NOT NULL | CURRENT_TIMESTAMP | Event timestamp |

**Constraints:**
- PRIMARY KEY: id
- FOREIGN KEY: user_id → users(id) ON DELETE CASCADE
- CHECK: old_country_code ~ '^[A-Z]{2}$'
- CHECK: new_country_code ~ '^[A-Z]{2}$'

**Indexes:**
- PRIMARY KEY index on id
- Foreign key index on user_id

---

### email_verification_tokens

**Purpose:** Tokens for email verification workflow.

**Entity:** EmailVerificationToken.java

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | UUID | NOT NULL | gen_random_uuid() | Primary key, unique token identifier |
| user_id | UUID | NOT NULL | - | Foreign key to users(id), user verifying email |
| token | VARCHAR(255) | NOT NULL | - | Verification token (hashed) |
| expires_at | TIMESTAMP WITH TIME ZONE | NOT NULL | - | Token expiration timestamp |
| used_at | TIMESTAMP WITH TIME ZONE | NULL | - | When token was used (NULL = not used) |
| created_at | TIMESTAMP WITH TIME ZONE | NOT NULL | CURRENT_TIMESTAMP | Creation timestamp |

**Constraints:**
- PRIMARY KEY: id
- FOREIGN KEY: user_id → users(id) ON DELETE CASCADE
- UNIQUE: token

**Indexes:**
- PRIMARY KEY index on id
- Foreign key index on user_id
- UNIQUE index on token

---

### password_reset_tokens

**Purpose:** Tokens for password reset workflow.

**Entity:** PasswordResetToken.java

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | UUID | NOT NULL | gen_random_uuid() | Primary key, unique token identifier |
| user_id | UUID | NOT NULL | - | Foreign key to users(id), user resetting password |
| token | VARCHAR(255) | NOT NULL | - | Reset token (hashed) |
| expires_at | TIMESTAMP WITH TIME ZONE | NOT NULL | - | Token expiration timestamp |
| used_at | TIMESTAMP WITH TIME ZONE | NULL | - | When token was used (NULL = not used) |
| created_at | TIMESTAMP WITH TIME ZONE | NOT NULL | CURRENT_TIMESTAMP | Creation timestamp |

**Constraints:**
- PRIMARY KEY: id
- FOREIGN KEY: user_id → users(id) ON DELETE CASCADE
- UNIQUE: token

**Indexes:**
- PRIMARY KEY index on id
- Foreign key index on user_id
- UNIQUE index on token

---

### magic_link_tokens

**Purpose:** Tokens for passwordless magic link authentication.

**Entity:** MagicLinkToken.java

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | UUID | NOT NULL | gen_random_uuid() | Primary key, unique token identifier |
| user_id | UUID | NOT NULL | - | Foreign key to users(id), user authenticating |
| token | VARCHAR(255) | NOT NULL | - | Magic link token (hashed) |
| expires_at | TIMESTAMP WITH TIME ZONE | NOT NULL | - | Token expiration timestamp (typically 15 minutes) |
| used_at | TIMESTAMP WITH TIME ZONE | NULL | - | When token was used (NULL = not used) |
| ip_address | VARCHAR(50) | NULL | - | IP address where token was requested |
| created_at | TIMESTAMP WITH TIME ZONE | NOT NULL | CURRENT_TIMESTAMP | Creation timestamp |

**Constraints:**
- PRIMARY KEY: id
- FOREIGN KEY: user_id → users(id) ON DELETE CASCADE
- UNIQUE: token

**Indexes:**
- PRIMARY KEY index on id
- Foreign key index on user_id
- UNIQUE index on token

---

## Enumerations

### Ticket Status

| Value | Description |
|-------|-------------|
| ACTIVE | Ticket is valid and can be used |
| USED | Ticket has been successfully redeemed |
| EXPIRED | Ticket has passed expiration timestamp |
| CANCELLED | Ticket was manually cancelled by owner or admin |

### Notification Type

| Value | Description |
|-------|-------------|
| EMAIL | Sent via email |
| PUSH | Push notification to mobile device |
| SMS | Text message |
| IN_APP | In-app notification banner |

### Notification Priority

| Value | Description |
|-------|-------------|
| LOW | Non-urgent, can be batched |
| NORMAL | Standard priority |
| HIGH | Important, send soon |
| URGENT | Critical, send immediately |

### Device Platform

| Value | Description |
|-------|-------------|
| IOS | Apple iOS devices |
| ANDROID | Android devices |
| WEB | Web push notifications |

### Badge Type

| Value | Description |
|-------|-------------|
| ACHIEVEMENT | One-time achievement (e.g., "First Invite") |
| MILESTONE | Progress-based milestone (e.g., "100 Invites") |
| SPECIAL | Special event or admin-awarded badges |

### Account Status

| Value | Description |
|-------|-------------|
| ACTIVE | Account is active and in good standing |
| SUSPENDED | Account temporarily suspended |
| BANNED | Account permanently banned |

---

## Indexes

### Performance Indexes

| Index Name | Table | Columns | Type | Purpose |
|------------|-------|---------|------|---------|
| idx_tickets_status | tickets | status | B-tree | Filter tickets by status |
| idx_tickets_expires_at | tickets | expires_at | B-tree | Find expiring tickets |
| idx_notifications_read_at | notifications | read_at | B-tree | Find unread notifications |
| idx_auth_sessions_refresh_token | auth_sessions | refresh_token | B-tree | Lookup by refresh token |
| idx_auth_sessions_expires_at | auth_sessions | expires_at | B-tree | Cleanup expired sessions |

### Unique Constraint Indexes

| Index Name | Table | Columns | Purpose |
|------------|-------|---------|---------|
| users_username_unique | users | LOWER(username) | Case-insensitive unique username |
| users_email_unique | users | LOWER(email) | Case-insensitive unique email |
| users_position_unique | users | position WHERE deleted_at IS NULL | One user per position in chain |
| users_chain_key_unique | users | chain_key WHERE deleted_at IS NULL | Unique chain key per active user |
| users_display_name_unique | users | LOWER(display_name) WHERE deleted_at IS NULL | Unique display name |
| users_google_id_unique | users | google_id WHERE google_id IS NOT NULL | Unique Google OAuth ID |
| users_apple_id_unique | users | apple_id WHERE apple_id IS NOT NULL | Unique Apple OAuth ID |
| tickets_owner_active_unique | tickets | owner_id WHERE status = 'ACTIVE' AND deleted_at IS NULL | One active ticket per user |

---

## Relationships

### Entity Relationship Diagram

```
users (1) ----< (*) tickets
  |                   |
  |                   |
  | (parent)          | (1)
  |                   |
  v                   v
attachments       invitations
  ^                   ^
  |                   |
  | (child)           | (ticket)
  |                   |
users (*)         tickets (1)

users (1) ----< (*) notifications
users (1) ----< (*) device_tokens
users (1) ----< (*) auth_sessions
users (1) ----< (*) user_badges
users (1) ----< (*) audit_log
users (1) ----< (*) country_change_events
users (1) ----< (*) email_verification_tokens
users (1) ----< (*) password_reset_tokens
users (1) ----< (*) magic_link_tokens

badges (1) ----< (*) user_badges
```

### Foreign Key Relationships

| Child Table | Child Column | Parent Table | Parent Column | On Delete | On Update |
|-------------|--------------|--------------|---------------|-----------|-----------|
| tickets | owner_id | users | id | CASCADE | CASCADE |
| tickets | used_by_id | users | id | SET NULL | CASCADE |
| attachments | parent_id | users | id | CASCADE | CASCADE |
| attachments | child_id | users | id | CASCADE | CASCADE |
| invitations | ticket_id | tickets | id | CASCADE | CASCADE |
| invitations | inviter_id | users | id | CASCADE | CASCADE |
| invitations | invitee_id | users | id | CASCADE | CASCADE |
| notifications | user_id | users | id | CASCADE | CASCADE |
| device_tokens | user_id | users | id | CASCADE | CASCADE |
| auth_sessions | user_id | users | id | CASCADE | CASCADE |
| user_badges | user_id | users | id | CASCADE | CASCADE |
| user_badges | badge_id | badges | id | CASCADE | CASCADE |
| chain_rules | created_by_id | users | id | SET NULL | CASCADE |
| audit_log | user_id | users | id | SET NULL | CASCADE |
| country_change_events | user_id | users | id | CASCADE | CASCADE |
| email_verification_tokens | user_id | users | id | CASCADE | CASCADE |
| password_reset_tokens | user_id | users | id | CASCADE | CASCADE |
| magic_link_tokens | user_id | users | id | CASCADE | CASCADE |

---

## Common Query Patterns

### Find Active Ticket for User

```sql
SELECT * FROM tickets
WHERE owner_id = :user_id
  AND status = 'ACTIVE'
  AND deleted_at IS NULL;
```

**Uses Index:** tickets_owner_active_unique

### Find Unread Notifications

```sql
SELECT * FROM notifications
WHERE user_id = :user_id
  AND read_at IS NULL
ORDER BY created_at DESC;
```

**Uses Index:** Foreign key index on user_id + idx_notifications_read_at

### Find Expiring Tickets (next 12 hours)

```sql
SELECT * FROM tickets
WHERE status = 'ACTIVE'
  AND expires_at < (CURRENT_TIMESTAMP + INTERVAL '12 hours')
  AND expires_at > CURRENT_TIMESTAMP;
```

**Uses Index:** idx_tickets_expires_at + idx_tickets_status

### Get User Chain Descendants

```sql
WITH RECURSIVE descendants AS (
  SELECT id, parent_id, child_id, 0 AS depth
  FROM attachments
  WHERE parent_id = :user_id AND deleted_at IS NULL

  UNION ALL

  SELECT a.id, a.parent_id, a.child_id, d.depth + 1
  FROM attachments a
  JOIN descendants d ON a.parent_id = d.child_id
  WHERE a.deleted_at IS NULL
)
SELECT * FROM descendants;
```

**Uses Index:** Foreign key indexes on attachments

### Audit Trail for Entity

```sql
SELECT * FROM audit_log
WHERE entity_type = 'USER'
  AND entity_id = :user_id
ORDER BY created_at DESC;
```

**Uses Index:** Composite index on (entity_type, entity_id)

---

## Data Retention and Archiving

### Tables Requiring Archiving

| Table | Retention Period | Archive Strategy |
|-------|------------------|------------------|
| audit_log | 90 days active, 1 year archive | Move to audit_log_archive monthly |
| notifications | 30 days active, 90 days archive | Move read notifications to archive |
| auth_sessions | 90 days active | Delete expired sessions |
| email_verification_tokens | 7 days after use | Delete used tokens |
| password_reset_tokens | 7 days after use | Delete used tokens |
| magic_link_tokens | 1 day after use | Delete used tokens |

---

## References

- [Database Consolidation Plan](DATABASE_CONSOLIDATION_PLAN.md)
- [Migration Guide](MIGRATION_GUIDE.md)
- [Backup Procedures](BACKUP_PROCEDURES.md)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)

---

**Last Updated:** 2025-01-10
**Version:** 1.0
**Database Version:** Flyway V4
