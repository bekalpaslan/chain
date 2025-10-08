# The Chain: Migration & Refactoring Plan

## Executive Summary

Based on comprehensive analysis of `definition.md` requirements against the current codebase, this document outlines **critical gaps**, **redundant implementations**, and a **phased migration plan** to align the system with the full specification.

**Severity Levels:**
- 🔴 **CRITICAL**: Core functionality missing or incorrectly implemented
- 🟡 **HIGH**: Important features missing, impacts user experience
- 🟢 **MEDIUM**: Nice-to-have features, can be deferred
- ⚪ **LOW**: Future enhancements, not MVP

---

## 1. CRITICAL SCHEMA GAPS (🔴 MUST FIX)

### 1.1 User Table - Missing Authentication Fields

**Current State:**
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY,
    chain_key VARCHAR(32),
    display_name VARCHAR(50),
    position INTEGER,
    parent_id UUID,
    child_id UUID,  -- ❌ WRONG: Should track MULTIPLE invitees
    device_id VARCHAR(255),
    device_fingerprint VARCHAR(255),
    share_location BOOLEAN,
    location_lat DECIMAL,
    location_lon DECIMAL,
    location_country VARCHAR(2),
    location_city VARCHAR(100),
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    deleted_at TIMESTAMP
);
```

**Required Changes:**
```sql
ALTER TABLE users ADD COLUMN email VARCHAR(255) UNIQUE;
ALTER TABLE users ADD COLUMN email_verified BOOLEAN DEFAULT FALSE;
ALTER TABLE users ADD COLUMN password_hash VARCHAR(255);
ALTER TABLE users ADD COLUMN phone VARCHAR(20);
ALTER TABLE users ADD COLUMN phone_verified BOOLEAN DEFAULT FALSE;
ALTER TABLE users ADD COLUMN apple_user_id VARCHAR(255) UNIQUE;
ALTER TABLE users ADD COLUMN google_user_id VARCHAR(255) UNIQUE;
ALTER TABLE users ADD COLUMN real_name VARCHAR(100);
ALTER TABLE users ADD COLUMN is_guest BOOLEAN DEFAULT FALSE;
ALTER TABLE users ADD COLUMN avatar_emoji VARCHAR(10);

-- Status fields
ALTER TABLE users ADD COLUMN status VARCHAR(20) DEFAULT 'active';
ALTER TABLE users ADD COLUMN removal_reason VARCHAR(50);
ALTER TABLE users ADD COLUMN removed_at TIMESTAMP;

-- Stats fields
ALTER TABLE users ADD COLUMN last_active_at TIMESTAMP;
ALTER TABLE users ADD COLUMN wasted_tickets_count INTEGER DEFAULT 0;
ALTER TABLE users ADD COLUMN total_tickets_generated INTEGER DEFAULT 0;

-- Settings (JSONB)
ALTER TABLE users ADD COLUMN notification_prefs JSONB DEFAULT '{"push":true,"email":true,"sms":false}';
ALTER TABLE users ADD COLUMN geo_location JSONB;

-- Constraints
ALTER TABLE users ADD CONSTRAINT chk_status CHECK (status IN ('active', 'removed', 'seed'));
ALTER TABLE users ADD CONSTRAINT chk_removal_reason CHECK (
    removal_reason IS NULL OR
    removal_reason IN ('3_failed_attempts', 'inactive_when_reactivated', 'admin_action')
);

-- Remove child_id (wrong design for multiple invitees)
ALTER TABLE users DROP COLUMN child_id;
```

**Issues:**
1. ❌ **No authentication fields**: Email, password, social auth IDs missing
2. ❌ **No user status tracking**: Can't track removed users
3. ❌ **`child_id` is WRONG**: User can have MULTIPLE invitees (after removals)
4. ❌ **No stats fields**: Can't track wasted tickets, attempts
5. ❌ **Display name not case-insensitive unique**: Should be unique ignoring case

### 1.2 Tickets Table - Missing Critical Fields

**Current State:**
```sql
CREATE TABLE tickets (
    id UUID PRIMARY KEY,
    owner_id UUID NOT NULL,
    issued_at TIMESTAMP NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    status VARCHAR(20) NOT NULL,
    signature TEXT NOT NULL,  -- ❓ What is this for?
    payload TEXT NOT NULL,    -- ❓ What is this for?
    claimed_by UUID,
    claimed_at TIMESTAMP,
    message VARCHAR(100)
);
```

**Required Changes:**
```sql
ALTER TABLE tickets ADD COLUMN ticket_code VARCHAR(50) UNIQUE NOT NULL;
ALTER TABLE tickets ADD COLUMN next_position INTEGER NOT NULL;
ALTER TABLE tickets ADD COLUMN attempt_number INTEGER NOT NULL DEFAULT 1;
ALTER TABLE tickets ADD COLUMN rule_version INTEGER NOT NULL DEFAULT 1;
ALTER TABLE tickets ADD COLUMN duration_hours INTEGER NOT NULL DEFAULT 24;
ALTER TABLE tickets ADD COLUMN qr_code_url VARCHAR(500);

-- Remove unclear fields
ALTER TABLE tickets DROP COLUMN signature;  -- Not in requirements
ALTER TABLE tickets DROP COLUMN payload;    -- Not in requirements

-- Add constraints
ALTER TABLE tickets ADD CONSTRAINT chk_attempt CHECK (attempt_number BETWEEN 1 AND 3);
ALTER TABLE tickets ADD CONSTRAINT chk_duration CHECK (duration_hours > 0);
```

**Issues:**
1. ❌ **No `ticket_code`**: Required for QR code/link sharing
2. ❌ **No `next_position`**: Need to know what position invitee will get
3. ❌ **No `attempt_number`**: Critical for 3-strike rule
4. ❌ **No `rule_version`**: Can't implement grandfathering
5. ❌ **No `duration_hours`**: Can't support dynamic rule changes
6. ❓ **`signature` and `payload` unclear**: Not in requirements, purpose unknown

### 1.3 Missing Tables - ENTIRE ENTITIES

**Missing Tables:**
1. 🔴 **`invitations`** - Track all invitation attempts (not just successful attachments)
2. 🔴 **`badges`** - Badge definitions
3. 🔴 **`user_badges`** - Badge awards
4. 🔴 **`rule_versions`** - Dynamic rule system
5. 🔴 **`rule_changes`** - Scheduled rule changes
6. 🔴 **`chain_events`** - Event log/audit trail
7. 🔴 **`chain_stats`** - Snapshot statistics
8. 🔴 **`notifications`** - User notifications
9. 🔴 **`auth_sessions`** - Session management (JWT refresh tokens)
10. 🔴 **`password_reset_tokens`** - Password reset flow
11. 🔴 **`magic_link_tokens`** - Passwordless login
12. 🔴 **`email_verification_tokens`** - Email verification
13. 🟡 **`display_name_history`** - Track name changes
14. 🟡 **`admin_users`** - Admin authentication
15. 🟡 **`admin_audit_log`** - Admin action tracking
16. 🟡 **`admin_moderation`** - User reports/moderation

---

## 2. BUSINESS LOGIC GAPS (🔴 CRITICAL)

### 2.1 3-Strike Rule - NOT IMPLEMENTED
**Requirement:** After 3 failed ticket attempts, user is removed from chain

**Current State:** ❌ No attempt tracking, no removal logic

**Required Implementation:**
```java
// TicketService.java
public void handleTicketExpiration(Ticket ticket) {
    User owner = userRepository.findById(ticket.getOwnerId());
    owner.setWastedTicketsCount(owner.getWastedTicketsCount() + 1);

    if (ticket.getAttemptNumber() >= 3) {
        // Remove user from chain
        owner.setStatus(UserStatus.REMOVED);
        owner.setRemovalReason(RemovalReason.THREE_FAILED_ATTEMPTS);
        owner.setRemovedAt(Instant.now());

        // Reactivate parent as tip
        User parent = userRepository.findByPosition(owner.getPosition() - 1);
        notificationService.sendTipReactivationNotification(parent);

        // Log event
        chainEventService.logRemoval(owner, RemovalReason.THREE_FAILED_ATTEMPTS);
    } else {
        // Return ticket for next attempt
        notificationService.sendTicketReturnedNotification(owner, ticket.getAttemptNumber());
    }
}
```

### 2.2 Chain Reversion - NOT IMPLEMENTED
**Requirement:** When user removed, chain reverts to previous active member

**Current State:** ❌ No reactivation logic

**Required Implementation:**
- Find parent by `position - 1`
- Send urgent notifications (push, email, SMS)
- Start 24-hour countdown
- Monitor if parent generates ticket
- Remove parent if inactive

### 2.3 Multiple Invitees - WRONG SCHEMA
**Requirement:** User can invite multiple people (after removals)

**Current State:** ❌ `child_id` allows only ONE child

**Solution:**
```sql
-- Remove child_id from users table
ALTER TABLE users DROP COLUMN child_id;

-- Use invitations table to track ALL invitations
CREATE TABLE invitations (
    id UUID PRIMARY KEY,
    inviter_position INTEGER NOT NULL,
    invitee_position INTEGER, -- NULL until they join
    status VARCHAR(20) NOT NULL, -- 'pending', 'joined', 'removed'
    invited_at TIMESTAMP NOT NULL,
    is_active_branch BOOLEAN DEFAULT FALSE, -- Which invitee continued the chain
    FOREIGN KEY (inviter_position) REFERENCES users(position),
    FOREIGN KEY (invitee_position) REFERENCES users(position)
);
```

### 2.4 Visibility Rules - NOT IMPLEMENTED
**Requirement:** Users see ONLY inviter + invitees (not entire chain)

**Current State:** ❌ No visibility filtering in API

**Required Implementation:**
```java
// ChainService.java
public ChainVisibilityDTO getMyChainView(Integer myPosition) {
    User me = userRepository.findByPosition(myPosition);
    User inviter = userRepository.findByPosition(myPosition - 1);
    List<User> myInvitees = invitationRepository
        .findByInviterPosition(myPosition)
        .stream()
        .map(inv -> userRepository.findByPosition(inv.getInviteePosition()))
        .collect(Collectors.toList());

    return new ChainVisibilityDTO(me, inviter, myInvitees);
}
```

---

## 3. AUTHENTICATION GAPS (🔴 CRITICAL)

### 3.1 NO Authentication System
**Current State:** ❌ No login, no password, no JWT, no sessions

**Required:**
1. Email + password registration
2. Sign in with Apple integration
3. Sign in with Google integration
4. JWT access/refresh token flow
5. Password reset flow
6. Magic link login
7. Email verification
8. Session management

**Implementation Priority:**
1. **Phase 1 (MVP):**  Email/password + JWT
2. **Phase 2:** Social auth (Apple, Google)
3. **Phase 3:** Magic links, email verification

### 3.2 Guest Mode - NOT IMPLEMENTED
**Requirement:** Allow users to join without full registration

**Implementation:**
```java
public User registerAsGuest(String ticketCode) {
    Ticket ticket = ticketService.validateTicket(ticketCode);
    User user = User.builder()
        .displayName(generateGuestName())
        .position(ticket.getNextPosition())
        .isGuest(true)
        .build();

    // Limited functionality, prompt to upgrade
    return userRepository.save(user);
}
```

---

## 4. MISSING FEATURES (🟡 HIGH PRIORITY)

### 4.1 Badge System
**Tables:**
```sql
CREATE TABLE badges (
    badge_type VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    icon_emoji VARCHAR(10),
    requirement_config JSONB
);

CREATE TABLE user_badges (
    id UUID PRIMARY KEY,
    user_position INTEGER NOT NULL,
    badge_type VARCHAR(50) NOT NULL,
    earned_at TIMESTAMP NOT NULL,
    context JSONB,
    FOREIGN KEY (user_position) REFERENCES users(position),
    FOREIGN KEY (badge_type) REFERENCES badges(badge_type)
);

INSERT INTO badges VALUES
('chain_savior', 'Chain Savior', 'Successfully attached after invitee removed', '🦸', '{"removals_saved": 1}'),
('chain_guardian', 'Chain Guardian', 'Saved the chain 5+ times', '🛡️', '{"removals_saved": 5}'),
('chain_legend', 'Chain Legend', 'Saved the chain 10+ times', '⭐', '{"removals_saved": 10}');
```

### 4.2 Dynamic Rule System
**Tables:**
```sql
CREATE TABLE rule_versions (
    version INTEGER PRIMARY KEY,
    ticket_duration_hours INTEGER NOT NULL DEFAULT 24,
    max_attempts INTEGER NOT NULL DEFAULT 3,
    visibility_range INTEGER NOT NULL DEFAULT 1,
    seed_unlimited_time BOOLEAN NOT NULL DEFAULT TRUE,
    reactivation_timeout_hours INTEGER NOT NULL DEFAULT 24,
    custom_rules JSONB,
    effective_from TIMESTAMP NOT NULL,
    effective_until TIMESTAMP,
    created_by UUID,
    created_at TIMESTAMP NOT NULL
);

CREATE TABLE rule_changes (
    change_id VARCHAR(50) PRIMARY KEY,
    from_version INTEGER NOT NULL,
    to_version INTEGER NOT NULL,
    mode VARCHAR(20) NOT NULL, -- 'instant' or 'scheduled'
    announced_at TIMESTAMP NOT NULL,
    effective_at TIMESTAMP NOT NULL,
    applied_at TIMESTAMP,
    reason TEXT,
    public_announcement TEXT,
    notification_config JSONB,
    status VARCHAR(20) NOT NULL, -- 'announced', 'pending', 'applied', 'cancelled'
    FOREIGN KEY (from_version) REFERENCES rule_versions(version),
    FOREIGN KEY (to_version) REFERENCES rule_versions(version)
);
```

### 4.3 Notification System
**Table:**
```sql
CREATE TABLE notifications (
    id UUID PRIMARY KEY,
    user_position INTEGER NOT NULL,
    notification_type VARCHAR(50) NOT NULL,
    title VARCHAR(200) NOT NULL,
    body TEXT NOT NULL,
    push_sent BOOLEAN DEFAULT FALSE,
    push_sent_at TIMESTAMP,
    email_sent BOOLEAN DEFAULT FALSE,
    email_sent_at TIMESTAMP,
    sms_sent BOOLEAN DEFAULT FALSE,
    sms_sent_at TIMESTAMP,
    read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP,
    related_ticket_id UUID,
    related_rule_change_id VARCHAR(50),
    related_event_id UUID,
    action_url VARCHAR(500),
    action_label VARCHAR(100),
    expires_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL,
    FOREIGN KEY (user_position) REFERENCES users(position)
);
```

### 4.4 Chain Events Log
**Table:**
```sql
CREATE TABLE chain_events (
    id UUID PRIMARY KEY,
    event_type VARCHAR(50) NOT NULL,
    user_position INTEGER,
    ticket_id UUID,
    badge_type VARCHAR(50),
    rule_change_id VARCHAR(50),
    event_data JSONB,
    occurred_at TIMESTAMP NOT NULL DEFAULT NOW(),
    FOREIGN KEY (user_position) REFERENCES users(position),
    FOREIGN KEY (ticket_id) REFERENCES tickets(id)
);

CREATE INDEX idx_chain_events_type ON chain_events(event_type);
CREATE INDEX idx_chain_events_occurred_at ON chain_events(occurred_at);
CREATE INDEX idx_chain_events_user ON chain_events(user_position);
```

---

## 5. API ENDPOINTS - MISSING

### 5.1 Critical Missing Endpoints (🔴)
```
POST   /auth/register          ❌ Not implemented
POST   /auth/login             ❌ Not implemented
POST   /auth/refresh           ❌ Not implemented
POST   /auth/logout            ❌ Not implemented
POST   /auth/forgot-password   ❌ Not implemented
POST   /auth/reset-password    ❌ Not implemented
GET    /users/me               ❌ Not implemented
PATCH  /users/me               ❌ Not implemented
GET    /chain/my-view          ❌ Not implemented (visibility rules)
GET    /tickets/active         ❌ Not implemented
GET    /tickets/history        ❌ Not implemented
GET    /notifications          ❌ Not implemented
```

### 5.2 Existing Endpoints - Review Needed (🟡)
```
POST   /tickets/generate       ✅ Exists - needs validation (tip check, attempt tracking)
POST   /tickets/scan           ✅ Exists - needs expansion (auth, guest mode)
GET    /tickets/my-tickets     ✅ Exists - may need refactor
GET    /chain/stats            ✅ Exists - needs expansion (more metrics)
GET    /chain/my-info          ❓ Unclear implementation
```

---

## 6. REDUNDANT OR UNCLEAR IMPLEMENTATIONS

### 6.1 Ticket Signature & Payload
**Current Schema:**
```sql
signature TEXT NOT NULL
payload TEXT NOT NULL
```

**Analysis:**
- ❓ Not mentioned in requirements
- ❓ Purpose unclear - are these for JWT-like signed tickets?
- ❓ If for security, should use `ticket_code` with HMAC verification instead

**Recommendation:**
1. **Option A (Remove):** If not needed, remove these fields
2. **Option B (Clarify):** Document purpose and keep if security-critical

### 6.2 Attachments Table vs Invitations
**Current:**
```sql
CREATE TABLE attachments (
    parent_id UUID,
    child_id UUID,
    ticket_id UUID,
    attached_at TIMESTAMP
);
```

**Issue:**
- ✅ Tracks successful attachments
- ❌ Doesn't track FAILED invitations
- ❌ Doesn't track removal status

**Solution:**
- Keep `attachments` for successful joins
- Add `invitations` for ALL attempts (including removed)

### 6.3 Device ID & Fingerprint
**Current:**
```sql
device_id VARCHAR(255) NOT NULL
device_fingerprint VARCHAR(255) NOT NULL
```

**Analysis:**
- ✅ Good for tracking unique devices
- ❌ Should NOT be `NOT NULL` - users can switch devices
- ❌ Missing multi-device support (should be separate `devices` table)

**Recommendation:**
```sql
ALTER TABLE users ALTER COLUMN device_id DROP NOT NULL;
ALTER TABLE users ALTER COLUMN device_fingerprint DROP NOT NULL;

-- Better: Create devices table
CREATE TABLE user_devices (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    device_id VARCHAR(255) NOT NULL,
    device_fingerprint VARCHAR(255),
    device_name VARCHAR(100),
    device_os VARCHAR(50),
    last_used_at TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);
```

---

## 7. PHASED MIGRATION PLAN

### Phase 1: Authentication & Core Fixes (Week 1-2) 🔴
**Goal:** Make system functional with basic auth

1. **Database Migrations:**
   - Add authentication fields to `users` table
   - Add `ticket_code`, `attempt_number`, `next_position` to `tickets`
   - Create `auth_sessions`, `password_reset_tokens` tables
   - Remove `child_id`, make device fields nullable

2. **Backend Implementation:**
   - JWT authentication (access + refresh)
   - Email/password registration
   - Login endpoint
   - Password reset flow
   - Session management

3. **API Endpoints:**
   - `POST /auth/register`
   - `POST /auth/login`
   - `POST /auth/refresh`
   - `POST /auth/logout`
   - `POST /auth/forgot-password`
   - `POST /auth/reset-password`
   - `GET /users/me`

4. **Mobile App:**
   - Login screen
   - Registration flow
   - Token storage (secure)
   - Auto-refresh logic

**Success Criteria:**
- Users can register with email/password
- Users can login and receive JWT tokens
- Tokens refresh automatically
- Password reset works

### Phase 2: 3-Strike Rule & Removals (Week 3) 🔴
**Goal:** Implement core chain mechanics

1. **Database:**
   - Add `status`, `removal_reason`, `removed_at` to `users`
   - Create `invitations` table
   - Create `chain_events` table
   - Add `wasted_tickets_count` tracking

2. **Backend Logic:**
   - Ticket expiration handler (background job)
   - 3-strike removal logic
   - Chain reversion logic
   - Parent reactivation
   - Event logging

3. **API Endpoints:**
   - `GET /tickets/active` (with attempt count)
   - `GET /tickets/history`
   - `GET /chain/timeline` (events)

4. **Mobile App:**
   - Ticket attempt counter
   - Removal warning after 2 failures
   - Reactivation notifications
   - Chain events timeline

**Success Criteria:**
- Tickets expire after 24 hours
- Users removed after 3 failures
- Chain reverts to parent
- Parent receives reactivation notification

### Phase 3: Visibility & Badges (Week 4) 🟡
**Goal:** Proper privacy and gamification

1. **Database:**
   - Create `badges`, `user_badges` tables
   - Create `invitations` (if not done in Phase 2)

2. **Backend Logic:**
   - Visibility filtering (inviter + invitees only)
   - Badge awarding logic
   - Badge display in chain view

3. **API Endpoints:**
   - `GET /chain/my-view` (filtered visibility)
   - `GET /users/me/badges`

4. **Mobile App:**
   - Chain view (inviter + invitees only)
   - Badge display
   - Badge celebration animations

**Success Criteria:**
- Users see only inviter + invitees
- Badges awarded automatically
- Badge icons displayed correctly

### Phase 4: Notifications & Real-time (Week 5) 🟡
**Goal:** Engagement and urgency

1. **Database:**
   - Create `notifications` table
   - Add `notification_prefs` to `users`

2. **Backend:**
   - Push notification service (FCM/APNs)
   - Email notification service
   - WebSocket events
   - Notification preferences API

3. **API Endpoints:**
   - `GET /notifications`
   - `PATCH /notifications/:id/read`
   - `POST /notifications/preferences`
   - WebSocket: `wss://api/ws`

4. **Mobile App:**
   - Push notification setup
   - In-app notification center
   - WebSocket connection
   - Notification preferences screen

**Success Criteria:**
- Push notifications work
- WebSocket updates in real-time
- Email notifications sent
- Users can configure preferences

### Phase 5: Dynamic Rules (Week 6) 🟢
**Goal:** Flexibility for future growth

1. **Database:**
   - Create `rule_versions`, `rule_changes` tables
   - Add `rule_version`, `duration_hours` to `tickets`

2. **Backend:**
   - Rule management API
   - Scheduled rule changes
   - Grandfathering logic
   - Rule change notifications

3. **API Endpoints:**
   - `GET /rules/current`
   - `GET /rules/upcoming`
   - `POST /admin/rules/create`

4. **Admin Dashboard:**
   - Rule change UI
   - Schedule changes
   - Preview impact

**Success Criteria:**
- Rules can be changed dynamically
- Existing tickets grandfathered
- Users notified of changes

### Phase 6: Social Auth & Polish (Week 7-8) 🟢
**Goal:** Better UX, production-ready

1. **Backend:**
   - Sign in with Apple
   - Sign in with Google
   - Guest mode
   - Display name change (30-day cooldown)
   - Email verification
   - Magic links

2. **API Endpoints:**
   - `POST /auth/apple`
   - `POST /auth/google`
   - `POST /auth/upgrade-guest`
   - `POST /auth/verify-email`
   - `POST /auth/magic-link/request`

3. **Mobile App:**
   - Social login buttons
   - Guest mode flow
   - Upgrade prompts
   - Email verification UI

**Success Criteria:**
- Social auth works
- Guest users can upgrade
- Email verification functional

---

## 8. DATA MIGRATION STRATEGY

### 8.1 Existing Data Preservation
**Current State:** ~3 users in system (seed + 2 test users)

**Strategy:**
1. **Backup current data:**
   ```sql
   pg_dump chaindb > backup_pre_migration.sql
   ```

2. **Run migrations in order:**
   - Add nullable columns first
   - Populate defaults for existing users
   - Add `NOT NULL` constraints after

3. **Test migration on staging:**
   - Verify existing users still work
   - Verify chain continuity
   - Test new features with migrated data

### 8.2 Example Migration Script
```sql
-- Phase 1 Migration
BEGIN;

-- Add new columns (nullable first)
ALTER TABLE users ADD COLUMN email VARCHAR(255);
ALTER TABLE users ADD COLUMN password_hash VARCHAR(255);
ALTER TABLE users ADD COLUMN avatar_emoji VARCHAR(10);
ALTER TABLE users ADD COLUMN status VARCHAR(20) DEFAULT 'active';

-- Populate defaults for existing users
UPDATE users SET avatar_emoji = '👤' WHERE avatar_emoji IS NULL;
UPDATE users SET status = 'active' WHERE status IS NULL;

-- Add constraints
ALTER TABLE users ADD CONSTRAINT users_email_key UNIQUE (email);
ALTER TABLE users ALTER COLUMN status SET NOT NULL;

-- Create new tables
CREATE TABLE auth_sessions (...);
CREATE TABLE invitations (...);

-- Remove obsolete columns
ALTER TABLE users DROP COLUMN child_id;

COMMIT;
```

---

## 9. TESTING STRATEGY

### 9.1 Unit Tests - Missing
**Current:** Only controller tests exist

**Required:**
- Service layer tests
- Repository tests
- Entity validation tests
- Business logic tests (3-strike rule, removals)

### 9.2 Integration Tests
**Required:**
- End-to-end ticket flow
- Multi-user removal scenarios
- Chain reversion scenarios
- Concurrent ticket generation

### 9.3 Load Tests
**Scenarios:**
- 1000 users attempting to scan same ticket
- Rapid ticket expiration/generation
- Concurrent removals and reversions

---

## 10. TECHNICAL DEBT

### 10.1 Chain Key Generation
**Current:**
```java
private String generateChainKey() {
    return UUID.randomUUID().toString()
        .replace("-", "")
        .substring(0, 12)
        .toUpperCase();
}
```

**Issues:**
- ❌ Random, not position-based
- ❌ No "CK-" prefix
- ❌ Could collide (UUID substring not guaranteed unique)

**Fix:**
```java
private String generateChainKey(Integer position) {
    return String.format("CK-%08d", position);
}
```

### 10.2 Missing Indexes
**Required indexes:**
```sql
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_tickets_attempt_number ON tickets(attempt_number);
CREATE INDEX idx_tickets_ticket_code ON tickets(ticket_code);
CREATE INDEX idx_invitations_inviter ON invitations(inviter_position);
CREATE INDEX idx_invitations_invitee ON invitations(invitee_position);
CREATE INDEX idx_invitations_status ON invitations(status);
```

### 10.3 Missing Foreign Key Constraints
**Current:** Using UUIDs without proper foreign keys in code

**Fix:**
```sql
ALTER TABLE tickets ADD CONSTRAINT fk_tickets_owner
    FOREIGN KEY (owner_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE invitations ADD CONSTRAINT fk_invitations_inviter
    FOREIGN KEY (inviter_position) REFERENCES users(position);
```

---

## 11. CONFIGURATION CHANGES

### 11.1 Application Properties
**Add:**
```yaml
# JWT Configuration
jwt:
  secret: ${JWT_SECRET}
  access-token-expiration: 3600000  # 1 hour
  refresh-token-expiration: 2592000000  # 30 days

# Ticket Configuration
ticket:
  default-duration-hours: 24
  max-attempts: 3

# Notification Configuration
notification:
  push:
    fcm-server-key: ${FCM_SERVER_KEY}
  email:
    smtp-host: ${SMTP_HOST}
    smtp-port: 587
    smtp-username: ${SMTP_USERNAME}
    smtp-password: ${SMTP_PASSWORD}
  sms:
    twilio-account-sid: ${TWILIO_SID}
    twilio-auth-token: ${TWILIO_TOKEN}
    twilio-phone-number: ${TWILIO_PHONE}

# Social Auth
auth:
  apple:
    client-id: ${APPLE_CLIENT_ID}
    team-id: ${APPLE_TEAM_ID}
    key-id: ${APPLE_KEY_ID}
  google:
    client-id: ${GOOGLE_CLIENT_ID}
    client-secret: ${GOOGLE_CLIENT_SECRET}
```

---

## 12. SUMMARY & PRIORITIES

### Must-Have for MVP (Weeks 1-3)
- ✅ Authentication (email/password, JWT)
- ✅ 3-strike removal rule
- ✅ Chain reversion logic
- ✅ Multiple invitees support
- ✅ Status tracking (active/removed)
- ✅ Basic notifications (push)

### Should-Have for V1 (Weeks 4-6)
- ✅ Visibility rules (inviter + invitees only)
- ✅ Badge system
- ✅ Real-time WebSocket updates
- ✅ Email notifications
- ✅ Dynamic rule changes
- ✅ Chain events timeline

### Nice-to-Have for Future
- Social auth (Apple, Google)
- Guest mode
- Magic link login
- Admin dashboard
- Moderation system
- Public chain visualization

---

**Generated with Claude Code** - Complete Migration & Refactoring Plan