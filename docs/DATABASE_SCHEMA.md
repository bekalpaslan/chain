# Database Schema

## Overview

The Chain uses **PostgreSQL** as the primary database for relational data and **Redis** for caching, session management, and real-time features.

---

## PostgreSQL Schema

### Table: `users`

Core user information and chain position.

```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    chain_key VARCHAR(32) UNIQUE NOT NULL,           -- Immutable public identifier
    display_name VARCHAR(50) NOT NULL,
    position INTEGER UNIQUE NOT NULL,                -- Position in chain (sequential)
    parent_id UUID REFERENCES users(id),             -- NULL for seed user
    child_id UUID REFERENCES users(id),              -- NULL if no child yet
    device_id VARCHAR(255) NOT NULL,                 -- For device-based auth
    device_fingerprint VARCHAR(255) NOT NULL,
    share_location BOOLEAN DEFAULT false,
    location_lat DECIMAL(9,6),
    location_lon DECIMAL(9,6),
    location_country CHAR(2),                        -- ISO country code
    location_city VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE,             -- Soft delete

    INDEX idx_users_chain_key (chain_key),
    INDEX idx_users_parent_id (parent_id),
    INDEX idx_users_child_id (child_id),
    INDEX idx_users_position (position),
    INDEX idx_users_device_id (device_id),
    INDEX idx_users_created_at (created_at),
    INDEX idx_users_location_country (location_country)
);

-- Generate unique chain_key on insert
CREATE OR REPLACE FUNCTION generate_chain_key()
RETURNS TRIGGER AS $$
BEGIN
    NEW.chain_key := UPPER(SUBSTRING(MD5(RANDOM()::TEXT || NEW.id::TEXT) FROM 1 FOR 12));
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_insert_users
    BEFORE INSERT ON users
    FOR EACH ROW
    EXECUTE FUNCTION generate_chain_key();

-- Auto-increment position
CREATE SEQUENCE users_position_seq START 1;

CREATE OR REPLACE FUNCTION set_user_position()
RETURNS TRIGGER AS $$
BEGIN
    NEW.position := nextval('users_position_seq');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_insert_users_position
    BEFORE INSERT ON users
    FOR EACH ROW
    EXECUTE FUNCTION set_user_position();
```

---

### Table: `tickets`

Invitation tickets with expiration and tracking.

```sql
CREATE TABLE tickets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    issued_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'active',    -- active, used, expired, cancelled
    signature TEXT NOT NULL,                         -- Server signature for validation
    payload TEXT NOT NULL,                           -- Signed JSON payload
    claimed_by UUID REFERENCES users(id),            -- User who claimed it
    claimed_at TIMESTAMP WITH TIME ZONE,
    message VARCHAR(100),                            -- Optional message from issuer

    CHECK (status IN ('active', 'used', 'expired', 'cancelled')),
    CHECK (expires_at > issued_at),

    INDEX idx_tickets_owner_id (owner_id),
    INDEX idx_tickets_status (status),
    INDEX idx_tickets_expires_at (expires_at),
    INDEX idx_tickets_claimed_by (claimed_by)
);

-- Constraint: One active ticket per user
CREATE UNIQUE INDEX idx_tickets_one_active_per_user
    ON tickets(owner_id)
    WHERE status = 'active';
```

---

### Table: `attachments`

Historical record of all parent-child relationships.

```sql
CREATE TABLE attachments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    parent_id UUID NOT NULL REFERENCES users(id),
    child_id UUID NOT NULL REFERENCES users(id),
    ticket_id UUID NOT NULL REFERENCES tickets(id),
    attached_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    UNIQUE(parent_id, child_id),
    UNIQUE(child_id),                                -- Each child can only be attached once

    INDEX idx_attachments_parent_id (parent_id),
    INDEX idx_attachments_child_id (child_id),
    INDEX idx_attachments_ticket_id (ticket_id),
    INDEX idx_attachments_attached_at (attached_at)
);
```

---

### Table: `wasted_tickets`

Log of expired/cancelled tickets for transparency.

```sql
CREATE TABLE wasted_tickets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ticket_id UUID NOT NULL REFERENCES tickets(id),
    owner_id UUID NOT NULL REFERENCES users(id),
    reason VARCHAR(20) NOT NULL,                     -- expired, cancelled
    wasted_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CHECK (reason IN ('expired', 'cancelled')),

    INDEX idx_wasted_tickets_owner_id (owner_id),
    INDEX idx_wasted_tickets_wasted_at (wasted_at)
);
```

---

### Table: `auth_tokens`

JWT refresh tokens for authentication.

```sql
CREATE TABLE auth_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    refresh_token TEXT NOT NULL UNIQUE,
    device_id VARCHAR(255) NOT NULL,
    issued_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    revoked_at TIMESTAMP WITH TIME ZONE,
    last_used_at TIMESTAMP WITH TIME ZONE,

    INDEX idx_auth_tokens_user_id (user_id),
    INDEX idx_auth_tokens_refresh_token (refresh_token),
    INDEX idx_auth_tokens_expires_at (expires_at)
);
```

---

### Table: `chain_stats_snapshots`

Daily snapshots of global chain statistics.

```sql
CREATE TABLE chain_stats_snapshots (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    snapshot_date DATE NOT NULL UNIQUE,
    total_users INTEGER NOT NULL,
    active_tickets INTEGER NOT NULL,
    wasted_tickets_total INTEGER NOT NULL,
    new_users_today INTEGER NOT NULL,
    countries_count INTEGER NOT NULL,
    average_growth_rate DECIMAL(10,2),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    INDEX idx_chain_stats_snapshot_date (snapshot_date)
);
```

---

### Table: `events_log`

Audit log for important chain events.

```sql
CREATE TABLE events_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_type VARCHAR(50) NOT NULL,                 -- user_joined, ticket_generated, ticket_expired, etc.
    user_id UUID REFERENCES users(id),
    related_user_id UUID REFERENCES users(id),       -- For attachment events
    ticket_id UUID REFERENCES tickets(id),
    event_data JSONB,                                -- Additional event-specific data
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    INDEX idx_events_log_event_type (event_type),
    INDEX idx_events_log_user_id (user_id),
    INDEX idx_events_log_created_at (created_at)
);
```

---

### Table: `user_activity`

Track user engagement metrics.

```sql
CREATE TABLE user_activity (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    activity_date DATE NOT NULL,
    login_count INTEGER DEFAULT 0,
    ticket_views INTEGER DEFAULT 0,
    chain_views INTEGER DEFAULT 0,
    last_activity_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    UNIQUE(user_id, activity_date),

    INDEX idx_user_activity_user_id (user_id),
    INDEX idx_user_activity_date (activity_date)
);
```

---

## Views

### View: `chain_tree_view`

Materialized view for efficient chain tree queries.

```sql
CREATE MATERIALIZED VIEW chain_tree_view AS
SELECT
    u.id,
    u.chain_key,
    u.display_name,
    u.position,
    u.parent_id,
    u.child_id,
    u.location_country,
    u.location_city,
    u.created_at,
    u.deleted_at,
    COALESCE(wt.wasted_count, 0) as wasted_tickets_count,
    CASE WHEN u.child_id IS NOT NULL THEN TRUE ELSE FALSE END as has_child
FROM users u
LEFT JOIN (
    SELECT owner_id, COUNT(*) as wasted_count
    FROM wasted_tickets
    GROUP BY owner_id
) wt ON u.id = wt.owner_id
WHERE u.deleted_at IS NULL;

CREATE UNIQUE INDEX idx_chain_tree_view_id ON chain_tree_view(id);
CREATE INDEX idx_chain_tree_view_position ON chain_tree_view(position);
CREATE INDEX idx_chain_tree_view_parent_id ON chain_tree_view(parent_id);

-- Refresh hourly via scheduled job
```

---

## Redis Schema

### Key Patterns

**Active tickets cache:**
```
ticket:{ticket_id} → JSON
{
  "id": "uuid",
  "ownerId": "uuid",
  "expiresAt": "ISO-8601",
  "status": "active",
  "signature": "...",
  "payload": "..."
}
TTL: 24 hours
```

**User session:**
```
session:{user_id} → JSON
{
  "userId": "uuid",
  "deviceId": "...",
  "lastActivity": "ISO-8601"
}
TTL: 7 days
```

**Real-time chain stats:**
```
chain:stats:current → JSON
{
  "totalUsers": 123456,
  "activeTickets": 8901,
  "lastUpdate": "ISO-8601"
}
TTL: 60 seconds
```

**Rate limiting:**
```
ratelimit:{endpoint}:{user_id|ip} → INTEGER (counter)
TTL: varies by endpoint
```

**Ticket expiration queue:**
```
SORTED SET: tickets:expiring
ZADD tickets:expiring {unix_timestamp} {ticket_id}
```

**Device fingerprint tracking (abuse prevention):**
```
device:{fingerprint}:registrations → SET of user_ids
TTL: 30 days
```

**WebSocket connections:**
```
ws:connections:{user_id} → SET of connection_ids
TTL: session based
```

---

## Relationships Diagram

```
users (1) ──< attachments >── (1) users
  │                               │
  │                               │
  └──< tickets >─────────────────┘
        │
        └──< wasted_tickets

users (1) ──< auth_tokens
users (1) ──< user_activity
users (1) ──< events_log
```

---

## Data Integrity Rules

1. **Chain Continuity:** Every user (except seed) must have a parent_id
2. **One Child Per User:** Each user can attach exactly one child
3. **One Active Ticket:** Each user can have maximum one active ticket
4. **Immutable Chain Key:** Once assigned, chain_key cannot change
5. **Sequential Positions:** Positions are auto-incremented, no gaps
6. **Soft Deletes:** Deleted users remain in chain with deleted_at timestamp
7. **Ticket Expiration:** Expired tickets automatically moved to wasted_tickets

---

## Seed Data

```sql
-- The Chain starts with a single seed user
INSERT INTO users (
    id,
    display_name,
    parent_id,
    device_id,
    device_fingerprint,
    location_country
) VALUES (
    gen_random_uuid(),
    'The Seeder',
    NULL,
    'seed-device',
    'seed-fingerprint',
    'US'
);
```

---

## Migrations Strategy

- Use Flyway or Liquibase for version-controlled migrations
- Each migration numbered sequentially: `V001__initial_schema.sql`
- Never modify existing migrations, always create new ones
- Test migrations on staging before production

---

## Backup & Recovery

- **PostgreSQL:** Daily full backups + WAL archiving for point-in-time recovery
- **Redis:** RDB snapshots every 6 hours + AOF for durability
- Retention: 30 days for full backups, 7 days for incremental

---

## Performance Considerations

1. **Partitioning:** Consider partitioning `events_log` by date if volume exceeds 10M rows
2. **Archival:** Move old wasted_tickets to archive table after 1 year
3. **Materialized Views:** Refresh `chain_tree_view` hourly or on-demand
4. **Indexes:** Monitor slow queries and add composite indexes as needed
5. **Connection Pooling:** Use HikariCP with max 20 connections per service instance
