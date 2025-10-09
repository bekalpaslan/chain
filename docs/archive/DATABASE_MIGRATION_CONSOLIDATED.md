# Database Migration Consolidation - Complete

## Summary

Successfully consolidated all database migrations into a single V1 initial schema migration and rebuilt the database from scratch.

## What Was Done

### 1. **Consolidated Migrations**
   - **Removed**: V1__phase1_authentication.sql, V2__add_email_auth.sql, V3__add_belongs_to_country.sql
   - **Created**: V1__initial_schema.sql (single comprehensive migration)

### 2. **Updated Docker Configuration**
   - Removed `schema.sql` mount from docker-compose.yml
   - Now using Flyway exclusively for schema management
   - Database is created empty and migrated by Flyway on application startup

### 3. **Rebuilt Database**
   - Dropped all data volumes
   - Recreated database from scratch
   - V1 migration applied successfully

## Current Database Schema

### Tables Created (8 total):

1. **users** - Core user table with authentication and profile fields
2. **tickets** - Invitation tickets with 3-strike rule support
3. **attachments** - Parent-child relationships
4. **auth_sessions** - JWT refresh token management
5. **password_reset_tokens** - Password reset flow
6. **magic_link_tokens** - Passwordless authentication
7. **email_verification_tokens** - Email verification flow
8. **flyway_schema_history** - Migration tracking

### Key Features in V1 Schema:

#### User Fields:
- **Authentication**: `email`, `password_hash`, `email_verified`
- **Social Auth**: `apple_user_id`, `google_user_id`
- **Profile**: `real_name`, `is_guest`, `avatar_emoji`, `belongs_to` (country)
- **Status**: `status`, `removal_reason`, `removed_at`
- **Activity**: `last_active_at`, `wasted_tickets_count`, `total_tickets_generated`

#### Tickets Fields:
- **3-Strike Rule**: `attempt_number`, `rule_version`
- **Invitation**: `ticket_code`, `next_position`
- **Security**: `signature`, `payload`

#### Authentication Tables:
- Complete token management for all auth flows
- Session tracking with device info
- Support for multiple authentication methods

### Indexes (17 total):
- Primary keys on all tables
- Unique indexes for email, social auth IDs (where not null)
- Case-insensitive unique index on display_name
- Performance indexes on foreign keys, status, timestamps
- Country code index for filtering by location

### Constraints:
- Status enum: `active`, `removed`, `seed`
- Removal reason enum: `3_failed_attempts`, `inactive_when_reactivated`, `admin_action`
- Country code format: 2-letter uppercase (ISO 3166-1 alpha-2)
- Ticket status enum: `ACTIVE`, `USED`, `EXPIRED`, `CANCELLED`

### Seed Data:
- **The Seeder** (position 1, US, status: seed)
- UUID: `a0000000-0000-0000-0000-000000000001`
- Chain Key: `SEED00000001`

## Flyway Migration History

```
version | description    | success
--------|----------------|--------
1       | initial schema | t
```

## Verification

All services are running and healthy:
- ✅ **Backend**: Healthy (port 8080)
- ✅ **PostgreSQL**: Healthy (port 5432)
- ✅ **Redis**: Healthy (port 6379)
- ✅ **Nginx**: Starting (port 80)

## Files Modified

1. **Removed**:
   - `backend/src/main/resources/db/migration/V1__phase1_authentication.sql`
   - `backend/src/main/resources/db/migration/V2__add_email_auth.sql`
   - `backend/src/main/resources/db/migration/V3__add_belongs_to_country.sql`

2. **Created**:
   - `backend/src/main/resources/db/migration/V1__initial_schema.sql`

3. **Updated**:
   - `docker-compose.yml` - Removed schema.sql mount

## Authentication Features

### Supported Methods:
1. **Email/Password** - Primary authentication
2. **Apple Sign-In** - Social authentication
3. **Google Sign-In** - Social authentication
4. **Magic Links** - Passwordless email login
5. **Password Reset** - Email-based password recovery
6. **Email Verification** - Email confirmation flow

### Session Management:
- JWT refresh tokens stored in `auth_sessions`
- Device tracking (device_id, device_fingerprint)
- IP address and user agent tracking
- Session expiration and revocation support

## Country Tracking

- Field: `belongs_to` (VARCHAR(2))
- Standard: ISO 3166-1 alpha-2
- Format: 2 uppercase letters (e.g., "US", "GB", "DE", "TR")
- Validation: Regex constraint `^[A-Z]{2}$`
- Indexed for efficient country-based queries

## Next Steps

The database is now clean and uses a single consolidated migration. Any future schema changes should be added as:
- V2__description.sql
- V3__description.sql
- etc.

## Migration Command

To rebuild the database from scratch again:
```bash
docker-compose down
docker volume rm ticketz_postgres_data ticketz_redis_data
docker-compose up -d
```

The V1 migration will automatically run on first startup.
