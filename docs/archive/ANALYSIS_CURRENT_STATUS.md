# The Chain - Functional Requirements Document

**Version:** 2.1
**Date:** October 8, 2025
**Status:** 🚧 Phase 1 & 2 Infrastructure Complete - Business Logic In Progress
**Author:** Alpaslan Bek
**Document Type:** Functional Requirements Specification

> **📊 Implementation Status:** See [IMPLEMENTATION_STATUS.md](./IMPLEMENTATION_STATUS.md) for detailed technical status, completed features, and next steps.

---

## 1. Document Purpose & Scope

### 1.1 Purpose
This document defines the complete functional requirements for **The Chain** mobile application and backend systems. It serves as the authoritative reference for development, testing, and project stakeholders.

**Current Status:** This document contains the full requirements specification. The database schema (V1 + V2 migrations), entity models, and repository layer are complete. Business logic implementation is in progress.

### 1.2 Scope
This document covers:
- User registration and authentication flows
- Ticket generation and invitation system
- Chain mechanics and state management
- Country-based identity system
- Notification requirements
- Admin features and rule management
- Data models and API specifications

### 1.3 Audience
- Development team (backend, mobile, infrastructure)
- QA/Testing team
- Product management
- UX/UI designers
- Project stakeholders

---

## 2. System Overview

### 2.1 Product Definition
**The Chain** is a linear, invitation-only social network where:
- Every user is connected in a single, global chain
- Only one person (the "tip") can invite at any given time
- Invitations expire after 24 hours with 3 attempts maximum
- Failed attempts result in removal and chain reversion
- Visibility is limited to ±1 position (inviter and invitee)

### 2.2 Core Principles
1. **Linear Structure:** No forking - single continuous chain
2. **Time Pressure:** 24-hour ticket expiration creates urgency
3. **Accountability:** 3-strike removal system maintains momentum
4. **Privacy:** Display names separate from personal identity
5. **Cultural Identity:** Country affiliation (not location tracking)
6. **Transparency:** Public statistics, private personal data

### 2.3 System Architecture
```
┌─────────────────────────────────────────────────────┐
│                  Mobile App (Flutter)                │
│  • iOS (App Store)                                   │
│  • Android (Google Play)                             │
└──────────────────┬──────────────────────────────────┘
                   │ HTTPS/REST + WebSocket
┌──────────────────▼──────────────────────────────────┐
│              Backend API (Spring Boot)               │
│  • Authentication Service                            │
│  • Ticket Service                                    │
│  • Chain Management Service                          │
│  • Notification Service                              │
│  • Admin Service                                     │
└──────────────────┬──────────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────────┐
│                  Data Layer                          │
│  • PostgreSQL (primary data)                         │
│  • Redis (caching, sessions)                         │
└─────────────────────────────────────────────────────┘
```

### 2.4 Implementation Progress

**✅ Completed:**
- Database schema (V1 + V2 migrations applied)
- Entity models (User, Ticket, Invitation, Badge, ChainRule, Notification)
- Repository layer (JPA repositories with custom queries)
- Basic service layer (ChainService, AuthService, TicketService)
- Docker containerization
- Flyway migration system

**⏳ In Progress:**
- JWT authentication implementation
- Ticket expiration scheduler
- 3-strike removal logic
- Chain reversion mechanics
- Notification delivery system

**🔄 Pending:**
- Badge awarding logic
- Social authentication (Apple, Google)
- WebSocket real-time updates
- Mobile app (Flutter)
- Admin dashboard

> For detailed implementation status, see [IMPLEMENTATION_STATUS.md](./IMPLEMENTATION_STATUS.md)

---

## 3. User Types & Roles

### 3.1 End Users

#### 3.1.1 The Seed (Position #1)
**Special Properties:**
- Origin of the chain
- Never expires as tip
- Cannot be removed
- Managed account (admin-controlled)

**Capabilities:**
- Generate tickets (unlimited attempts)
- View chain statistics
- Cannot change country or display name

#### 3.1.2 Active Member
**Properties:**
- Successfully joined via ticket
- Currently in chain (not removed)
- Can see inviter and invitee(s)

**Capabilities:**
- View their ±1 chain position
- Become tip when predecessor fails
- Generate tickets when tip (24h, 3 attempts)
- View global statistics
- Update profile settings (limited)

#### 3.1.3 Current Tip
**Properties:**
- Last active member in chain
- Responsible for chain growth
- Under time pressure (24h per ticket)

**Capabilities:**
- Generate invitation tickets
- Share tickets via QR/link
- Track ticket status
- View expiration countdown
- Attempt counter (1/3, 2/3, 3/3)

#### 3.1.4 Removed Member (Side-Chain)
**Properties:**
- Failed 3 invitation attempts OR
- Inactive when reactivated as tip
- Visible in chain history
- Cannot rejoin

**Capabilities:**
- View global statistics
- See their inviter (only)
- No ticket generation
- Read-only access

### 3.2 Admin Users

#### 3.2.1 Super Admin
**Capabilities:**
- Full system access
- Create/modify rule changes
- Manage seed user
- Override user status
- Access analytics dashboard
- Create country change events
- View audit logs

#### 3.2.2 Moderator
**Capabilities:**
- Review user reports
- Reset inappropriate display names
- View moderation queue
- Limited analytics access

---

## 4. Functional Requirements

### 4.1 User Registration & Authentication

#### FR-1.1: Invitation-Only Registration
**Priority:** CRITICAL  
**Description:** Users can ONLY register by scanning a valid invitation ticket. No traditional signup exists.

**Requirements:**
- Registration requires valid ticket code
- Ticket must not be expired (within 24h of generation)
- Ticket must not be already used
- Ticket must belong to current tip
- One ticket = one user registration

**Acceptance Criteria:**
- ✓ Cannot access registration without ticket
- ✓ Expired tickets show error message
- ✓ Used tickets cannot be reused
- ✓ Registration fails if tip changes during process

**Error Handling:**
| Error | User Message | Action |
|-------|--------------|--------|
| Ticket expired | "This ticket expired on [date]. Ask for a new one." | Block registration |
| Ticket used | "Someone else already used this ticket." | Block registration |
| Ticket invalid | "Invalid ticket code. Please scan again." | Retry scan |

---

#### FR-1.2: Display Name Selection
**Priority:** CRITICAL  
**Description:** Users choose a public display name (3-20 characters) separate from real identity.

**Requirements:**
- Display name must be unique (case-insensitive)
- 3-20 characters, alphanumeric + underscore + hyphen only
- No profanity or reserved names
- Real-time availability checking
- 30-day cooldown for changes

**Validation Rules:**
```javascript
{
  min_length: 3,
  max_length: 20,
  pattern: /^[a-zA-Z0-9_-]+$/,
  case_insensitive_unique: true,
  reserved: ["admin", "system", "thechain", "moderator", "support"],
  profanity_filter: true
}
```

**Acceptance Criteria:**
- ✓ Display name uniqueness validated before submission
- ✓ Invalid names show inline error
- ✓ Suggestions provided if name taken
- ✓ Name appears immediately after registration

---

#### FR-1.3: Avatar Selection
**Priority:** HIGH  
**Description:** Users select an emoji avatar from predefined set.

**Requirements:**
- Curated emoji list (40-50 emojis)
- One emoji per user
- Can change anytime (no cooldown)
- Emoji + display name shown in chain view

**Default Emoji Set:**
```
🌙 🌟 ⚡ 🔥 🌊 💎 🎭 🎪 🎨 🎯 
🎲 🎸 🚀 🌈 ⭐ 🌸 🦄 🐉 🦅 🦁 
🐺 🦊 🐻 🐼 🦋 🌺 🌻 🌷 🍀 🌴
💫 ✨ 🌠 🔮 🎯 🎪 🎢 🎡 🎠 🎰
```

**Acceptance Criteria:**
- ✓ Visual emoji picker in registration
- ✓ Emoji displays next to display name everywhere
- ✓ Change reflected immediately

---

#### FR-1.4: Country Affiliation (Mandatory)
**Priority:** CRITICAL  
**Description:** Users declare which country they feel connected to (cultural identity, not GPS location).

**Requirements:**
- Must select country during registration
- Permanent by default (cannot change)
- ISO 3166-1 alpha-2 country codes
- All 249 countries available
- Popular countries highlighted
- Search functionality
- Admin can temporarily unlock for special events

**Data Structure:**
```json
{
  "country_code": "NL",
  "country_name": "Netherlands", 
  "country_flag": "🇳🇱",
  "country_locked": true,
  "country_changed_at": null
}
```

**Acceptance Criteria:**
- ✓ Cannot proceed without country selection
- ✓ Country displayed as flag emoji in chain view
- ✓ Change button shows "Locked" by default
- ✓ Country contributes to global statistics

**Search & Filter:**
- Search by country name
- Filter by region (Europe, Asia, Americas, Africa, Oceania)
- Popular countries shown first
- Recent selections saved

---

#### FR-1.5: Authentication Methods
**Priority:** CRITICAL  
**Description:** Multiple authentication options with email as primary identifier.

**Supported Methods:**

**1. Email + Password**
```
Requirements:
- Valid email format
- Password: 8+ chars, 1 uppercase, 1 lowercase, 1 number, 1 special
- Email verification required within 24h
- Password reset via email
```

**2. Sign in with Apple**
```
Requirements:
- Apple ID authentication
- Handle private relay emails
- Store apple_user_id for account linking
```

**3. Sign in with Google**
```
Requirements:
- Google OAuth 2.0
- Store google_user_id for account linking
- Request email scope
```

**Security Requirements:**
- Passwords hashed with bcrypt (cost factor: 12)
- JWT access tokens (1 hour expiry)
- JWT refresh tokens (30 days expiry)
- Token rotation on refresh
- Session tracking per device
- Rate limiting: 5 login attempts per 15 minutes

**Acceptance Criteria:**
- ✓ All three auth methods work end-to-end
- ✓ Tokens expire correctly
- ✓ Password reset email delivered within 1 minute
- ✓ Social auth handles email conflicts gracefully

---

#### FR-1.6: Email Verification
**Priority:** HIGH  
**Description:** Email addresses must be verified before full account access.

**Requirements:**
- Verification email sent immediately after registration
- Link valid for 24 hours
- Can request resend (max 3 times per hour)
- Unverified users can still use app but with limitations

**Unverified Limitations:**
- Cannot receive email notifications
- Cannot use password reset
- Warning banner in app

**Acceptance Criteria:**
- ✓ Email delivered within 60 seconds
- ✓ Link works on both mobile and desktop
- ✓ Verification updates user status immediately

---

### 4.2 Ticket System

#### FR-2.1: Ticket Generation (Tip Only)
**Priority:** CRITICAL  
**Description:** Only the current tip can generate invitation tickets.

**Requirements:**
- Only one active ticket per user at a time
- Tickets expire after 24 hours (configurable via rules)
- Maximum 3 attempts per user
- Ticket contains cryptographic signature
- QR code generated automatically
- Share link generated automatically

**Ticket Data Structure:**
```json
{
  "ticket_id": "tkt_abc123xyz",
  "issuer_position": 10247,
  "next_position": 10248,
  "issued_at": "2025-10-20T10:00:00Z",
  "expires_at": "2025-10-21T10:00:00Z",
  "status": "active",
  "attempt_number": 1,
  "rule_version": 12,
  "duration_hours": 24,
  "qr_code_url": "https://cdn.thechain.app/qr/tkt_abc123xyz.png",
  "share_url": "https://thechain.app/join/tkt_abc123xyz"
}
```

**QR Code Specifications:**
- Format: QR Code (Version 5, Error Correction Level M)
- Content: `thechain://join/tkt_abc123xyz`
- Size: 512x512 pixels
- File format: PNG
- Stored in CDN for distribution

**Acceptance Criteria:**
- ✓ Only tip can generate ticket
- ✓ Cannot generate if active ticket exists
- ✓ QR code renders correctly
- ✓ Share link opens app or app store

---

#### FR-2.2: Ticket Expiration
**Priority:** CRITICAL  
**Description:** Tickets automatically expire after configured duration.

**Requirements:**
- Default: 24 hours from generation
- Configurable via rule system (admin)
- Expired tickets cannot be used for registration
- System checks expiration on every validation
- Expired tickets return to issuer
- Attempt counter increments

**Expiration Process:**
```
1. Ticket expires at configured time
2. Status changes: "active" → "expired"
3. Notification sent to issuer
4. Attempt counter increments (1→2, 2→3)
5. If attempt < 3: Issuer can generate new ticket
6. If attempt = 3: Issuer removed from chain
```

**Notifications:**
| Timing | Recipient | Message |
|--------|-----------|---------|
| 12h before | Issuer | "⏰ Your ticket expires in 12 hours" |
| 1h before | Issuer | "🚨 Your ticket expires in 1 hour!" |
| On expiration | Issuer | "❌ Ticket expired. Attempt X/3" |

**Acceptance Criteria:**
- ✓ Expired tickets rejected in validation
- ✓ Notifications sent at correct times
- ✓ Attempt counter accurate
- ✓ Can generate new ticket after expiration (if <3 attempts)

---

#### FR-2.3: Ticket Validation
**Priority:** CRITICAL  
**Description:** Robust validation before allowing registration.

**Validation Checks:**
1. Ticket code exists in database
2. Ticket status is "active" (not expired/used)
3. Current time < expires_at
4. Issuer is current tip
5. next_position matches current chain length + 1

**Error Responses:**
| Check Failed | HTTP Status | Error Code | Message |
|--------------|-------------|------------|---------|
| Not found | 404 | TICKET_NOT_FOUND | "Invalid ticket code" |
| Expired | 400 | TICKET_EXPIRED | "Ticket expired on [date]" |
| Used | 400 | TICKET_USED | "Ticket already used" |
| Wrong tip | 400 | TIP_CHANGED | "Chain tip changed, ticket invalid" |
| Position mismatch | 400 | POSITION_CONFLICT | "Chain position conflict" |

**Acceptance Criteria:**
- ✓ All validation checks execute in order
- ✓ Appropriate error returned for each case
- ✓ Validation response time < 200ms
- ✓ Concurrent validations handled correctly

---

#### FR-2.4: Ticket Usage
**Priority:** CRITICAL  
**Description:** Ticket marked as used upon successful registration.

**Requirements:**
- Atomic operation (registration + ticket use)
- Status changes: "active" → "used"
- used_at timestamp recorded
- invitee_position updated in invitations table
- Cannot be reused after successful use

**Transaction Flow:**
```sql
BEGIN TRANSACTION;
  -- 1. Validate ticket still active
  SELECT * FROM tickets WHERE id = ? AND status = 'active' FOR UPDATE;
  
  -- 2. Create user
  INSERT INTO users (...) VALUES (...);
  
  -- 3. Update ticket
  UPDATE tickets SET status = 'used', used_at = NOW() WHERE id = ?;
  
  -- 4. Update invitation
  INSERT INTO invitations (inviter_position, invitee_position, status) 
  VALUES (?, ?, 'active');
  
  -- 5. Update issuer's invitee pointer
  UPDATE users SET invitee_position = ? WHERE position = ?;
  
COMMIT;
```

**Race Condition Handling:**
- Pessimistic locking (FOR UPDATE)
- Unique constraints on position
- Idempotency key for retries

**Acceptance Criteria:**
- ✓ Registration + ticket use is atomic
- ✓ Concurrent registrations handled correctly
- ✓ Only one person can use each ticket
- ✓ Chain integrity maintained

---

### 4.3 Chain Mechanics

#### FR-3.1: Chain Structure (Linear)
**Priority:** CRITICAL  
**Description:** Single, linear chain connecting all users.

**Properties:**
- No forking - one continuous line
- Position numbers never reused
- Gaps visible when users removed
- Positions immutable (never shift)

**Chain Representation:**
```
[#1 Seed] → [#2] → [#3] → ╳[#4 removed] → [#5] → [#6] → ...
```

**Data Integrity Rules:**
1. Each position has exactly one user (or removed marker)
2. inviter_position = current_position - N (where N accounts for gaps)
3. Chain Key format: CK-{position:05d}
4. Position sequence: 1, 2, 3, 4, ...

**Acceptance Criteria:**
- ✓ Positions never duplicate
- ✓ Removed users remain in history
- ✓ Chain continuous despite gaps
- ✓ Statistics accurate with removals

---

#### FR-3.2: Tip Management
**Priority:** CRITICAL  
**Description:** System automatically manages who is the current tip.

**Tip Definition:**
- The last active (non-removed) user in the chain
- Can generate tickets
- Responsible for chain growth
- Changes when:
  - They successfully invite someone
  - They are removed (reverts to previous)

**Tip Identification Algorithm:**
```sql
SELECT u.* 
FROM users u
WHERE u.status = 'active'
  AND NOT EXISTS (
    SELECT 1 FROM invitations i
    WHERE i.inviter_position = u.position
      AND i.status = 'active'
  )
ORDER BY u.position DESC
LIMIT 1;
```

**Tip Transition Events:**
| Event | Old Tip | New Tip | Notification |
|-------|---------|---------|--------------|
| Successful invite | #100 | #101 | "You're no longer the tip" |
| Tip removed (3 fails) | #100 | #99 | "You're the tip again!" |
| Tip removed (inactive) | #100 | #99 | "You're the tip again!" |

**Acceptance Criteria:**
- ✓ Tip correctly identified at all times
- ✓ Only tip can generate tickets
- ✓ Tip changes trigger notifications
- ✓ Multiple concurrent tip queries consistent

---

#### FR-3.3: Removal System (3-Strike Rule)
**Priority:** CRITICAL  
**Description:** Users removed after 3 failed invitation attempts.

**Removal Triggers:**
1. **3 Expired Tickets:** User fails to get anyone to join within 3 attempts
2. **Inactive When Reactivated:** User doesn't respond within 24h when becoming tip again

**Removal Process:**
```
Attempt 1: Ticket expires → Attempt 2 available
Attempt 2: Ticket expires → Attempt 3 available (warning)
Attempt 3: Ticket expires → User REMOVED
  ↓
1. User status = "removed"
2. removal_reason = "3_failed_attempts"
3. removed_at = NOW()
4. Chain event logged
5. Tip reverts to inviter
6. Notifications sent
```

**Removal Notification Sequence:**
| Recipient | Message |
|-----------|---------|
| Removed user | "❌ You were removed after 3 failed attempts" |
| New tip (inviter) | "🔥 You're the tip again! Your invitee was removed." |
| Inviter's inviter | "⚠️ Your invitee's invitee was removed" |

**Side-Chain Visibility:**
- Removed users remain visible in database
- Show as ╳ in system views
- Inviter can still see them (marked removed)
- Cannot see rest of chain
- Read-only app access

**Acceptance Criteria:**
- ✓ Exactly 3 attempts allowed
- ✓ Removal automatic after 3rd failure
- ✓ Tip reverts correctly
- ✓ Removed user cannot generate tickets
- ✓ Chain statistics updated

---

#### FR-3.4: Chain Reversion (Cascading Removal)
**Priority:** CRITICAL  
**Description:** Chain reverts when reactivated tip fails to respond.

**Scenario:**
```
[#97] → [#98] → [#99] → ╳[#100 removed]
                  ↑ tip reverts to #99

#99 has 24h to generate ticket
IF #99 doesn't respond:
  → #99 removed (reason: "inactive_when_reactivated")
  → tip reverts to #98
  
This can cascade multiple times
```

**Cascade Prevention:**
- Maximum cascade depth: None (can go back to seed)
- Seed (#1) never times out
- Each reactivation sends urgent notification

**Reactivation Notification:**
```
🚨 YOU'RE THE TIP AGAIN!

Your invitee failed 3 times and was removed.

You have 24 hours to generate a ticket
or you'll be removed too.

[GENERATE TICKET NOW]
```

**Acceptance Criteria:**
- ✓ 24h timeout enforced for reactivated tips
- ✓ Cascading works correctly
- ✓ Seed immune to timeout
- ✓ Urgent notifications sent
- ✓ Chain can recover from deep cascades

---

#### FR-3.5: Visibility Rules (±1 Only)
**Priority:** CRITICAL  
**Description:** Users can only see their direct inviter and invitee(s).

**Visibility Matrix:**
| User Position | Can See | Cannot See |
|---------------|---------|------------|
| #8 | #7 (inviter), #9 (invitee) | #6, #10, #11, ... |
| #9 (removed) | #8 (inviter) | Everyone else |
| #1 (seed) | Nobody (is root), #2 (invitee) | #3, #4, ... |

**Display Logic:**
```javascript
function getVisibleUsers(currentUser) {
  return {
    inviter: currentUser.inviter_position 
      ? getUser(currentUser.inviter_position) 
      : null,
    invitees: getInvitees(currentUser.position) // Array, can be multiple
  };
}
```

**Privacy Implications:**
- Cannot traverse chain beyond ±1
- Total chain length visible (global stat)
- Cannot see who else is in chain
- Geographic stats aggregated only

**Future: Dynamic Visibility:**
- Rule system can change to ±2, ±3, etc.
- Admin announces changes in advance
- Display names chosen with this in mind

**Acceptance Criteria:**
- ✓ API never returns users outside ±1
- ✓ UI only shows inviter + invitees
- ✓ Global stats don't expose individuals
- ✓ Removed users see only inviter

---

#### FR-3.6: Badges & Achievements
**Priority:** MEDIUM  
**Description:** Reward system for significant actions.

**Badge Types:**

**1. Chain Savior 🦸**
- **Earned:** Successfully attach someone after your invitee was removed
- **Condition:** Became tip due to invitee's 3 failed attempts, then succeeded
- **Visibility:** Shown to inviter and invitees

**2. Chain Guardian 🛡️** (Future)
- **Earned:** Save chain after 5+ consecutive removals
- **Condition:** Tip reverted through 5+ people before you succeeded

**3. Chain Legend ⭐** (Future)
- **Earned:** Save chain after 10+ consecutive removals

**Badge Display:**
```
[#8] 🦸 SkyWalker invited you
      ↓
    YOU (#9)
```

**Badge Data:**
```json
{
  "badge_type": "chain_savior",
  "name": "Chain Savior",
  "icon": "🦸",
  "earned_at": "2025-10-20T14:30:00Z",
  "context": {
    "removed_positions": [9],
    "collapse_depth": 1
  }
}
```

**Acceptance Criteria:**
- ✓ Badge awarded automatically
- ✓ Visible to users in ±1 range
- ✓ Persists even if user later removed
- ✓ Context data stored for history

---

### 4.4 Statistics & Analytics

#### FR-4.1: Global Statistics (Public)
**Priority:** HIGH  
**Description:** Real-time chain statistics visible to all users.

**Metrics:**
```json
{
  "total_positions_issued": 10247,
  "active_members": 9891,
  "removed_members": 356,
  "success_rate": 96.5,
  "current_tip": {
    "position": 10247,
    "display_name": "Anonymous",
    "has_active_ticket": true
  },
  "growth": {
    "last_hour": 3,
    "last_24h": 47,
    "last_7d": 347
  },
  "geography": {
    "countries_represented": 47,
    "top_countries": [
      {"code": "US", "count": 892, "flag": "🇺🇸"},
      {"code": "NL", "count": 247, "flag": "🇳🇱"}
    ]
  },
  "health": {
    "avg_time_per_link_hours": 14.3,
    "ticket_waste_rate": 32.5,
    "removal_rate_7d": 3.2,
    "longest_active_streak": 8423,
    "current_active_streak": 543
  }
}
```

**Update Frequency:**
- Real-time via WebSocket for active users
- Polling fallback every 30 seconds
- Cached for 5 seconds (Redis)

**Acceptance Criteria:**
- ✓ Statistics accurate within 5 seconds
- ✓ All users see same numbers
- ✓ Performance < 100ms response time
- ✓ Updates pushed via WebSocket

---

#### FR-4.2: Country Distribution
**Priority:** MEDIUM  
**Description:** Visualize global reach by country.

**Data:**
- Total countries represented
- Member count per country
- Percentage distribution
- Regional groupings (Europe, Asia, etc.)
- Growth trends by region

**Visualization:**
- World map heatmap (intensity = member count)
- Top 10 countries list
- Regional pie chart
- Timeline of new countries joining

**API Endpoint:**
```
GET /api/v1/chain/geography

Response:
{
  "countries": [
    {
      "code": "NL",
      "name": "Netherlands",
      "flag": "🇳🇱",
      "member_count": 247,
      "percentage": 2.4,
      "first_member_position": 47,
      "latest_member_position": 10203
    }
  ],
  "regions": [
    {
      "name": "Europe",
      "countries": 23,
      "members": 3456,
      "percentage": 33.7
    }
  ],
  "total_countries": 47,
  "total_members": 10248
}
```

**Acceptance Criteria:**
- ✓ All countries with members shown
- ✓ Map renders correctly on mobile
- ✓ Real-time updates when new country joins
- ✓ Privacy preserved (no individual locations)

---

#### FR-4.3: Personal Statistics
**Priority:** MEDIUM  
**Description:** User's individual stats and history.

**User Stats:**
```json
{
  "chain_key": "CK-10248",
  "position": 10248,
  "joined_at": "2025-10-20T14:30:00Z",
  "days_in_chain": 87,
  "status": "active",
  "badges": ["chain_savior"],
  "invitation_history": {
    "total_tickets_generated": 3,
    "successful_invites": 1,
    "wasted_tickets": 2,
    "success_rate": 33.3
  },
  "chain_impact": {
    "people_after_you": 1247,
    "your_branch_active": 1189,
    "your_branch_removed": 58
  }
}
```

**Acceptance Criteria:**
- ✓ Stats accurate and up-to-date
- ✓ History shows all invitation attempts
- ✓ Branch impact calculated correctly
- ✓ Removed users can still see their stats

---

### 4.5 Notification System

#### FR-5.1: Notification Channels
**Priority:** HIGH  
**Description:** Multi-channel notification delivery.

**Channels:**
1. **Push Notifications** (Primary)
   - iOS: APNs
   - Android: FCM
   - Delivery: Immediate
   - Requires device token

2. **Email Notifications** (Secondary)
   - SMTP via SendGrid/AWS SES
   - Delivery: Within 60 seconds
   - Requires verified email

3. **In-App Notifications** (Tertiary)
   - Notification center in app
   - Persisted in database
   - Read/unread status

**User Preferences:**
```json
{
  "notification_preferences": {
    "push": true,
    "email": true,
    "frequency": "all" // "all", "important_only", "daily_digest"
  }
}
```

**Acceptance Criteria:**
- ✓ All three channels operational
- ✓ User preferences respected
- ✓ Push notifications appear within 10 seconds
- ✓ Email delivery within 60 seconds
- ✓ Notification center shows history

---

#### FR-5.2: Notification Types
**Priority:** HIGH  
**Description:** Define all notification scenarios.

**Critical Notifications (Always Sent):**

| Event | Title | Body | Channels | Action |
|-------|-------|------|----------|--------|
| Became Tip | "🔥 You're the tip!" | "Your invitee was removed. Generate a ticket within 24h." | Push, Email | Open app → Generate |
| Ticket Expiring (1h) | "🚨 1 hour left!" | "Your ticket expires soon. Share it now!" | Push | Open app → Ticket |
| Removed | "❌ Chain Ended" | "You were removed after 3 failed attempts." | Push, Email | Open app → Stats |

**Important Notifications (Respect Preferences):**

| Event | Title | Body | Channels | Action |
|-------|-------|------|----------|--------|
| Invitee Joined | "🎉 Success!" | "Your invitee joined the chain!" | Push | Open app → View |
| Invitee Failed (1/3) | "⚠️ Attempt 1 failed" | "Your invitee's ticket expired (1/3)." | Push | None |
| Badge Earned | "🦸 Badge Unlocked!" | "You earned Chain Savior!" | Push | Open app → Profile |
| Rule Change | "📢 Rule Update" | "Ticket duration changed: 24h → 23h" | Push, Email | Open app → Details |

**Informational Notifications:**

| Event | Title | Body | Channels | Frequency |
|-------|-------|------|----------|-----------|
| Milestone Reached | "🎊 10,000 Members!" | "The chain hit 10K!" | Push | Once |
| Daily Summary | "📊 Chain Update" | "Chain grew by 47 today" | Email | Daily digest |

**Acceptance Criteria:**
- ✓ All notifications sent at correct triggers
- ✓ Content clear and actionable
- ✓ Deep links work correctly
- ✓ User preferences honored

---

#### FR-5.3: Notification Scheduling
**Priority:** MEDIUM  
**Description:** Time-based notification delivery.

**Scheduled Notifications:**

**Ticket Expiration Reminders:**
```
Time: 12h before expiration
  → "⏰ 12 hours left to share your ticket"

Time: 1h before expiration
  → "🚨 1 hour left! Your ticket expires soon!"
```

**Rule Change Reminders:**
```
Time: 72h before change
  → "📢 Rule change in 3 days: Ticket duration → 23h"

Time: 24h before change
  → "⏰ Tomorrow: New rules take effect"

Time: 1h before change
  → "🚨 1 hour until rule change!"

Time: At change
  → "✅ New rules now active"
```

**Scheduling System:**
- Redis-based job queue
- Cron jobs for recurring checks
- Retry logic for failed deliveries
- Timezone awareness (UTC stored, local display)

**Acceptance Criteria:**
- ✓ Scheduled notifications fire at correct time (±30 seconds)
- ✓ Timezone conversion accurate
- ✓ Failed notifications retried up to 3 times
- ✓ Duplicate notifications prevented

---

### 4.6 Rule Management System

#### FR-6.1: Dynamic Rules
**Priority:** HIGH  
**Description:** Admin can modify game rules during operation.

**Configurable Rules:**
```json
{
  "version": 12,
  "effective_from": "2025-10-15T12:00:00Z",
  "rules": {
    "ticket_duration_hours": 24,
    "max_attempts": 3,
    "visibility_range": 1,
    "seed_unlimited_time": true,
    "reactivation_timeout_hours": 24
  }
}
```

**Rule Change Types:**
1. **Time-based:** ticket_duration_hours
2. **Attempt-based:** max_attempts
3. **Visibility-based:** visibility_range
4. **Special:** seed_unlimited_time, reactivation_timeout_hours

**Acceptance Criteria:**
- ✓ Rules versioned and tracked
- ✓ Active rules retrieved correctly
- ✓ Historical rules preserved
- ✓ All systems use current rules

---

#### FR-6.2: Rule Change Deployment
**Priority:** HIGH  
**Description:** Two deployment modes for rule changes.

**Mode A: Instant Changes**
- Applied immediately upon creation
- No advance notice
- High-impact, urgent changes only
- Use cases: Emergency fixes, special events

**Mode B: Scheduled Changes**
- Announced in advance (configurable lead time)
- Applied at specific datetime
- Multiple reminders sent
- Use cases: Planned difficulty changes, experiments

**Deployment Process:**
```
1. Admin creates rule change
2. System validates change
3. IF instant:
     - Apply immediately
     - Notify all users
   ELSE IF scheduled:
     - Schedule change
     - Announce to users
     - Send reminders (72h, 24h, 1h)
     - Apply at scheduled time
     - Confirm to users
```

**Acceptance Criteria:**
- ✓ Instant changes apply within 1 minute
- ✓ Scheduled changes apply at exact time
- ✓ All users notified appropriately
- ✓ Countdown shown in app

---

#### FR-6.3: Grandfathering Rules
**Priority:** HIGH  
**Description:** Existing tickets unaffected by instant rule changes.

**Grandfathering Logic:**
```javascript
// When validating ticket
if (ticket.rule_version !== current_rule_version) {
  // Use rules from ticket's version
  const rules = getRuleVersion(ticket.rule_version);
  return validateWithRules(ticket, rules);
} else {
  // Use current rules
  return validateWithRules(ticket, current_rules);
}
```

**Example:**
```
User A generates ticket at 10:00 (24h duration)
Admin changes rule at 11:00 (24h → 20h)
User A's ticket still expires at 10:00+24h (not 10:00+20h)

User B generates ticket at 11:30 (after change)
User B's ticket expires at 11:30+20h
```

**Acceptance Criteria:**
- ✓ Existing tickets honor original rules
- ✓ New tickets use current rules
- ✓ No retroactive penalty
- ✓ Users informed of grandfathering

---

### 4.7 Country Change Events

#### FR-7.1: Temporary Country Unlocking
**Priority:** LOW (Future Feature)  
**Description:** Admin can temporarily allow country changes.

**Event Configuration:**
```json
{
  "event_name": "Migration Week 2025",
  "description": "Update your country affiliation",
  "enabled_at": "2025-11-01T00:00:00Z",
  "disabled_at": "2025-11-07T23:59:59Z",
  "applies_to": "all",
  "allowed_countries": null
}
```

**User Experience:**
1. Announcement sent to all users
2. Country field unlocks in settings
3. User selects new country
4. Confirmation required
5. Change logged permanently
6. Country locks again at event end

**Restrictions:**
- One change per event
- Cannot change back during same event
- Change permanent until next event

**Acceptance Criteria:**
- ✓ Country unlocks at event start
- ✓ Users can change once
- ✓ Locks automatically at event end
- ✓ Changes tracked in database

---

### 4.8 Admin Features

#### FR-8.1: Admin Dashboard
**Priority:** MEDIUM  
**Description:** Web-based admin control panel.

**Dashboard Sections:**

**1. Chain Health Overview**
```
- Current tip information
- Active members count
- Removal rate (7d, 30d)
- Growth rate
- Alert indicators
```

**2. Rule Management**
```
- View current rules
- Create new rule change
- View pending changes
- Cancel scheduled changes
- Apply scheduled change early
```

**3. User Management**
```
- Search users
- View user details
- Override user status
- Reset display name
- View invitation history
```

**4. Analytics**
```
- Growth charts
- Country distribution
- Ticket usage statistics
- Removal patterns
- Engagement metrics
```

**5. Audit Log**
```
- Admin actions
- System events
- Security logs
- Filter and search
```

**Acceptance Criteria:**
- ✓ Dashboard loads within 2 seconds
- ✓ Real-time data updates
- ✓ All admin functions accessible
- ✓ Secure authentication required

---

#### FR-8.2: User Moderation
**Priority:** MEDIUM  
**Description:** Admin tools for handling inappropriate content.

**Moderation Actions:**

**1. Display Name Reset**
- Reason: Profanity, impersonation, spam
- Action: Reset to "User{position}"
- Notification: User informed of reset
- User must choose new name on next login

**2. Avatar Reset**
- Reason: Inappropriate emoji usage
- Action: Reset to default (🌟)
- Notification: User informed

**3. Force Removal**
- Reason: Terms violation, abuse
- Action: Remove from chain (override 3-strike)
- Permanent: Cannot rejoin
- Notification: User informed with reason

**Moderation UI:**
```
┌─────────────────────────────────────────┐
│ MODERATE USER: #10248                   │
├─────────────────────────────────────────┤
│ Display name: InappropriateName         │
│ Avatar: 🌙                              │
│ Country: 🇳🇱 Netherlands                │
│                                         │
│ Action:                                 │
│ ○ Reset display name                    │
│ ○ Reset avatar                          │
│ ○ Force removal                         │
│                                         │
│ Reason (required):                      │
│ [_____________________________]         │
│                                         │
│ [CANCEL] [CONFIRM ACTION]               │
└─────────────────────────────────────────┘
```

**Acceptance Criteria:**
- ✓ All moderation actions logged
- ✓ Users notified of actions
- ✓ Reason required for all actions
- ✓ Cannot be undone without admin override

---

#### FR-8.3: Seed Management
**Priority:** HIGH  
**Description:** Special controls for position #1 (seed user).

**Seed Properties:**
- Cannot be removed
- Never times out as tip
- Managed by admin
- Cannot change display name or country without admin action

**Seed Controls:**
- Generate ticket (admin-triggered)
- View seed's invitation history
- Reset seed if chain breaks catastrophically

**Acceptance Criteria:**
- ✓ Seed immune to normal removal rules
- ✓ Admin can act on seed's behalf
- ✓ Seed's tickets work like normal tickets

---

### 4.9 Mobile App Features

#### FR-9.1: Onboarding Tutorial
**Priority:** HIGH  
**Description:** First-time user education flow.

**Tutorial Screens:**
1. **Welcome:** "You've been invited to The Chain"
2. **Visibility:** "You can only see ±1 position"
3. **Your Turn:** "When you're the tip, invite someone"
4. **Stakes:** "3 failed attempts = removal"
5. **Ready:** "Let's get started"

**Tutorial Properties:**
- Shown once after registration
- Can be skipped (with confirmation)
- Can be replayed from settings
- 5 screens, swipeable

**Acceptance Criteria:**
- ✓ Displays after first registration
- ✓ Skip button works
- ✓ Replay available in settings
- ✓ Clear and concise content

---

#### FR-9.2: QR Code Scanning
**Priority:** CRITICAL  
**Description:** In-app QR code scanner for ticket validation.

**Scanner Features:**
- Camera permission request
- Real-time QR detection
- Haptic feedback on scan
- Immediate validation
- Error handling (invalid codes)

**Scanner Flow:**
```
1. User taps "Scan Invitation"
2. Camera permission requested
3. Camera viewfinder opens
4. QR code detected
5. Vibrate + visual feedback
6. Ticket validated
7. IF valid: → Registration flow
   IF invalid: → Error message + retry
```

**Acceptance Criteria:**
- ✓ Scans QR codes within 1 second
- ✓ Works in low light
- ✓ Clear error messages
- ✓ Graceful permission denial

---

#### FR-9.3: Home Screen
**Priority:** HIGH  
**Description:** Main app view showing chain position.

**Components:**
1. **Your Position Card**
   ```
   Display name, avatar, country flag
   Position number, Chain Key
   Status indicator
   ```

2. **Chain View**
   ```
   Inviter (above)
   ↓
   YOU (center)
   ↓
   Invitee (below) or [No invitee yet]
   ```

3. **Actions**
   ```
   [Generate Ticket] (if tip)
   [View Profile]
   [Global Stats]
   ```

4. **Global Stats Summary**
   ```
   Total members
   Countries represented
   Your position / Total
   ```

**Refresh Behavior:**
- Pull-to-refresh updates all data
- Auto-refresh every 30 seconds
- WebSocket updates in real-time

**Acceptance Criteria:**
- ✓ Loads within 1 second
- ✓ Shows accurate data
- ✓ Real-time updates work
- ✓ Smooth animations

---

#### FR-9.4: Ticket Generation Screen
**Priority:** CRITICAL  
**Description:** Interface for creating and sharing tickets.

**Screen Layout:**
```
┌─────────────────────────────────┐
│   YOUR INVITATION TICKET        │
├─────────────────────────────────┤
│                                 │
│        [QR CODE IMAGE]          │
│        512x512 pixels           │
│                                 │
│   ⏱ Expires in 23h 47m          │
│   Position: #10248              │
│   Attempt: 1/3                  │
│                                 │
│   Share this QR code with       │
│   ONE person to invite them     │
│                                 │
│   [SHARE LINK INSTEAD]          │
│   [SAVE QR CODE]                │
│                                 │
└─────────────────────────────────┘
```

**Share Options:**
- Native share sheet (WhatsApp, Telegram, iMessage, Email, etc.)
- Copy link to clipboard
- Save QR as image
- Print (future)

**Countdown Timer:**
- Updates every second
- Color changes:
  - Green: >12h remaining
  - Yellow: 1-12h remaining
  - Red: <1h remaining

**Acceptance Criteria:**
- ✓ QR code renders correctly
- ✓ Share sheet works on iOS/Android
- ✓ Countdown accurate to second
- ✓ Cannot generate if already have active ticket

---

#### FR-9.5: Statistics Screen
**Priority:** MEDIUM  
**Description:** Global chain statistics and visualizations.

**Sections:**

**1. Chain Overview**
```
- Total positions issued
- Active members
- Success rate
- Current tip (anonymous)
```

**2. Growth Chart**
```
- Line graph of daily growth
- Last 7 days / 30 days toggle
- Annotations for milestones
```

**3. Country Map**
```
- Interactive world map
- Colored by member density
- Tap country for details
```

**4. Top Countries**
```
- List of top 10
- Member count
- Percentage
- Flag emoji
```

**Acceptance Criteria:**
- ✓ Charts render smoothly
- ✓ Map interactive
- ✓ Real-time updates
- ✓ Accessible color scheme

---

#### FR-9.6: Profile Screen
**Priority:** MEDIUM  
**Description:** User's personal profile and settings.

**Sections:**

**1. Public Profile**
```
- Display name + avatar
- Chain Key
- Country flag
- Badges
- Member since date
```

**2. Chain Position**
```
- Your inviter
- Your invitees
- Status
```

**3. Personal Stats**
```
- Tickets generated
- Success rate
- Days in chain
- Branch size
```

**4. Settings**
```
- Change display name (30-day cooldown)
- Change avatar
- Notification preferences
- Privacy settings
- About / Help
- Logout
```

**Acceptance Criteria:**
- ✓ Profile loads instantly
- ✓ Settings saved immediately
- ✓ Cooldown enforced
- ✓ Logout clears session

---

### 4.10 WebSocket Real-Time Updates

#### FR-10.1: WebSocket Connection
**Priority:** HIGH  
**Description:** Persistent connection for real-time updates.

**Connection:**
```
wss://api.thechain.app/v1/ws?token={jwt_token}
```

**Connection Lifecycle:**
```
1. User logs in → JWT token issued
2. App connects to WebSocket with token
3. Server validates token
4. Connection established
5. Server sends initial state
6. Bidirectional event flow
7. Heartbeat every 30 seconds
8. Reconnect on disconnect (exponential backoff)
```

**Heartbeat:**
```json
// Client → Server (every 30s)
{"type": "ping", "timestamp": 1634567890}

// Server → Client
{"type": "pong", "timestamp": 1634567890}
```

**Acceptance Criteria:**
- ✓ Connection stable for 24h+
- ✓ Automatic reconnection works
- ✓ Token refresh handled
- ✓ Graceful degradation if unavailable

---

#### FR-10.2: Real-Time Events
**Priority:** HIGH  
**Description:** Push updates to clients via WebSocket.

**Event Types:**

**1. You Became Tip**
```json
{
  "type": "you_became_tip",
  "data": {
    "reason": "invitee_removed",
    "removed_invitee_position": 10248,
    "timeout_hours": 24,
    "timestamp": "2025-10-20T10:00:00Z"
  }
}
```

**2. Invitee Status Changed**
```json
{
  "type": "invitee_status_changed",
  "data": {
    "invitee_position": 10248,
    "old_status": "active",
    "new_status": "removed",
    "removal_reason": "3_failed_attempts",
    "timestamp": "2025-10-20T09:00:00Z"
  }
}
```

**3. Ticket Expiring Soon**
```json
{
  "type": "ticket_expiring_soon",
  "data": {
    "ticket_id": "uuid",
    "expires_at": "2025-10-21T10:00:00Z",
    "time_remaining_seconds": 3600,
    "warning_level": "1_hour"
  }
}
```

**4. Rule Change Applied**
```json
{
  "type": "rule_change_applied",
  "data": {
    "change_id": "CHG-00043",
    "new_version": 13,
    "changes": {
      "ticket_duration_hours": {
        "from": 24,
        "to": 23
      }
    },
    "applied_at": "2025-10-15T12:00:00Z"
  }
}
```

**5. Global Stats Update**
```json
{
  "type": "stats_update",
  "data": {
    "total_positions": 10248,
    "active_members": 9892,
    "current_tip_position": 10248
  }
}
```

**Acceptance Criteria:**
- ✓ Events delivered within 1 second
- ✓ No duplicate events
- ✓ Events persisted if client offline
- ✓ UI updates smoothly on event

---

### 4.11 Security Requirements

#### FR-11.1: Authentication Security
**Priority:** CRITICAL

**Requirements:**
- JWT tokens signed with HS256
- Secret key: 256-bit minimum
- Access token: 1-hour expiry
- Refresh token: 30-day expiry
- Token rotation on refresh
- Secure httpOnly cookies for web

**Rate Limiting:**
| Endpoint | Limit | Window |
|----------|-------|--------|
| POST /auth/register | 3 requests | 1 hour |
| POST /auth/login | 5 requests | 15 minutes |
| POST /auth/forgot-password | 3 requests | 1 hour |
| GET /api/* | 300 requests | 15 minutes |

**Acceptance Criteria:**
- ✓ Tokens cannot be forged
- ✓ Expired tokens rejected
- ✓ Rate limits enforced
- ✓ Brute force attacks prevented

---

#### FR-11.2: Data Privacy
**Priority:** CRITICAL

**Personal Data Storage:**
- Passwords: bcrypt (cost: 12)
- Email: Encrypted at rest (AES-256)
- Display names: Public, not encrypted
- Country: Public, not encrypted

**Data Retention:**
- Active users: Indefinite
- Removed users: Indefinite (historical record)
- Tickets: 90 days after expiration
- Notifications: 30 days
- Sessions: 30 days after last use
- Audit logs: 1 year

**GDPR Compliance:**
- Right to access (export all data)
- Right to deletion (anonymize, keep chain intact)
- Right to rectification (update personal data)
- Data processing consent required

**Acceptance Criteria:**
- ✓ Passwords never stored plaintext
- ✓ Email encrypted at rest
- ✓ User can export their data
- ✓ Deletion anonymizes but preserves chain

---

#### FR-11.3: API Security
**Priority:** CRITICAL

**Protection Mechanisms:**
1. **CORS:** Whitelist origins only
2. **CSRF:** Token validation for state-changing operations
3. **SQL Injection:** Parameterized queries only
4. **XSS:** Input sanitization + output encoding
5. **DDoS:** Rate limiting + Cloudflare

**Request Validation:**
- Input length limits enforced
- Type validation (JSON schema)
- Sanitization of user input
- Rejection of malicious payloads

**Acceptance Criteria:**
- ✓ All API endpoints protected
- ✓ No SQL injection vulnerabilities
- ✓ XSS attacks blocked
- ✓ Rate limiting prevents abuse

---

### 4.12 Performance Requirements

#### FR-12.1: Response Time
**Priority:** HIGH

**Targets:**
| Operation | Target | Max |
|-----------|--------|-----|
| API GET | <100ms | 200ms |
| API POST | <200ms | 500ms |
| WebSocket event | <1s | 2s |
| Page load | <1s | 2s |
| Ticket validation | <200ms | 500ms |

**Measurement:**
- P50 (median)
- P95 (95th percentile)
- P99 (99th percentile)
- Measured under normal load

**Acceptance Criteria:**
- ✓ 95% of requests meet target
- ✓ No request exceeds max
- ✓ Performance monitoring in place
- ✓ Alerts on degradation

---

#### FR-12.2: Scalability
**Priority:** HIGH

**Capacity Targets:**
| Metric | Target | Max |
|--------|--------|-----|
| Concurrent users | 10,000 | 50,000 |
| Requests per second | 1,000 | 5,000 |
| WebSocket connections | 10,000 | 50,000 |
| Database connections | 100 | 500 |

**Scaling Strategy:**
- Horizontal scaling (add instances)
- Database read replicas
- Redis caching (5-second TTL)
- CDN for static assets
- Load balancing (round-robin)

**Acceptance Criteria:**
- ✓ System handles 10K concurrent users
- ✓ Auto-scaling triggers correctly
- ✓ No single point of failure
- ✓ Database queries optimized

---

### 4.13 Testing Requirements

#### FR-13.1: Unit Tests
**Priority:** HIGH

**Coverage Targets:**
- Backend: 80% line coverage minimum
- Mobile: 70% line coverage minimum
- Critical paths: 100% coverage

**Test Categories:**
- User registration flow
- Ticket generation/validation
- Chain mechanics (tip detection, removal)
- Authentication
- Rule system

**Acceptance Criteria:**
- ✓ All tests pass
- ✓ Coverage targets met
- ✓ CI/CD runs tests automatically
- ✓ No flaky tests

---

#### FR-13.2: Integration Tests
**Priority:** HIGH

**Test Scenarios:**
1. **End-to-End Registration:**
   - Seed generates ticket
   - User scans ticket
   - User completes registration
   - User becomes part of chain

2. **Tip Transition:**
   - User A is tip
   - User A invites User B
   - User B joins
   - User B becomes tip
   - User A no longer tip

3. **Removal Flow:**
   - User generates ticket
   - Ticket expires (1/3)
   - Repeat 2 more times
   - User removed
   - Tip reverts to inviter

4. **Rule Change:**
   - Admin creates scheduled change
   - Reminders sent correctly
   - Change applies at scheduled time
   - New tickets use new rules
   - Old tickets grandfathered

**Acceptance Criteria:**
- ✓ All scenarios pass
- ✓ Test data cleaned up after each run
- ✓ Tests run in isolated environment
- ✓ Tests complete within 5 minutes

---

#### FR-13.3: Performance Tests
**Priority:** MEDIUM

**Test Types:**
1. **Load Testing:** Normal expected load
2. **Stress Testing:** Beyond capacity to find breaking point
3. **Spike Testing:** Sudden traffic surge
4. **Endurance Testing:** Sustained load over 24h

**Tools:**
- JMeter or k6 for load generation
- New Relic/Datadog for monitoring
- Custom scripts for WebSocket testing

**Acceptance Criteria:**
- ✓ System stable under normal load
- ✓ Graceful degradation under stress
- ✓ No memory leaks over 24h
- ✓ Performance targets met

---

### 4.14 Deployment Requirements

#### FR-14.1: Environment Strategy
**Priority:** HIGH

**Environments:**

**1. Development (Local)**
- Docker Compose
- All services localhost
- Test data included
- Hot reload enabled

**2. Staging**
- Cloud-hosted (AWS/GCP)
- Mirror of production
- Synthetic test data
- Beta testing environment

**3. Production**
- Cloud-hosted (AWS/GCP)
- Auto-scaling enabled
- Real user data
- 99.9% uptime SLA

**Acceptance Criteria:**
- ✓ Parity between staging and production
- ✓ Automated deployments
- ✓ Rollback capability
- ✓ Zero-downtime deployments

---

#### FR-14.2: CI/CD Pipeline
**Priority:** HIGH

**Pipeline Stages:**
```
1. Code Push
   ↓
2. Lint & Format Check
   ↓
3. Unit Tests
   ↓
4. Build (Docker Images)
   ↓
5. Integration Tests
   ↓
6. Deploy to Staging
   ↓
7. Smoke Tests
   ↓
8. Manual Approval
   ↓
9. Deploy to Production
   ↓
10. Health Check
```

**Tools:**
- GitHub Actions (CI/CD)
- Docker Hub (image registry)
- Terraform (infrastructure as code)
- Ansible (configuration management)

**Acceptance Criteria:**
- ✓ Full pipeline runs in <15 minutes
- ✓ Failed tests block deployment
- ✓ Automated rollback on health check failure
- ✓ Deployment history tracked

---

#### FR-14.3: Monitoring & Alerting
**Priority:** HIGH

**Metrics to Monitor:**
- API response times (P50, P95, P99)
- Error rates (4xx, 5xx)
- Database query performance
- WebSocket connection count
- Memory/CPU usage
- Disk space
- Network throughput

**Alerts:**
| Condition | Severity | Action |
|-----------|----------|--------|
| Error rate >5% | CRITICAL | Page on-call |
| Response time >500ms (P95) | WARNING | Slack notification |
| Database CPU >80% | WARNING | Auto-scale |
| Disk >90% full | CRITICAL | Page on-call |
| Health check fails | CRITICAL | Auto-rollback |

**Tools:**
- Prometheus (metrics)
- Grafana (dashboards)
- Alertmanager (alerting)
- PagerDuty (on-call)

**Acceptance Criteria:**
- ✓ All metrics collected
- ✓ Dashboards accessible
- ✓ Alerts trigger correctly
- ✓ On-call rotation defined

---

## 5. Data Models

### 5.1 Entity Relationship Diagram

```
┌──────────────┐       ┌──────────────┐       ┌──────────────┐
│    users     │◄──────│ invitations  │──────►│   tickets    │
│              │       │              │       │              │
│ • position   │       │ • inviter_pos│       │ • issuer_pos │
│ • chain_key  │       │ • invitee_pos│       │ • next_pos   │
│ • display_nm │       │ • status     │       │ • expires_at │
│ • country_cd │       │ • invited_at │       │ • status     │
└──────┬───────┘       └──────────────┘       └──────────────┘
       │
       │
       ▼
┌──────────────┐       ┌──────────────┐
│ user_badges  │       │    badges    │
│              │       │              │
│ • user_pos   ├──────►│ • badge_type │
│ • badge_type │       │ • name       │
│ • earned_at  │       │ • icon       │
└──────────────┘       └──────────────┘
```

### 5.2 Core Tables (Detailed)

**Implementation Status:** ✅ **All tables created and migrated**

**Database Migrations Applied:**
- ✅ V1__initial_schema.sql (Oct 8, 18:52) - users, tickets, attachments
- ✅ V2__add_chain_mechanics.sql (Oct 8, 19:30) - invitations, badges, chain_rules, notifications, and more

**Total Tables:** 17 (excluding system tables)

For complete table schemas with all fields, constraints, and indexes, see [IMPLEMENTATION_STATUS.md - Database Schema](./IMPLEMENTATION_STATUS.md#database-schema)

**Key Implementation Notes:**
- Users table uses `invitee_position` (not childId) for active branch tracking
- Invitations table tracks ALL attempts (not just successful)
- Tickets support 3 attempts with rule versioning
- All entities use UUID primary keys except positions (INTEGER)
- JSONB columns for flexible context data (badges, notifications)

---

## 6. API Specification

### 6.1 API Endpoint Summary

> **Implementation Legend:** ✅ Implemented | ⏳ Partial | 🔄 Pending

**Authentication:**
- POST /api/v1/auth/register ⏳ Basic implementation
- POST /api/v1/auth/scan ✅ Ticket scanning registration
- POST /api/v1/auth/login 🔄 JWT integration pending
- POST /api/v1/auth/refresh 🔄 Pending
- POST /api/v1/auth/logout 🔄 Pending
- POST /api/v1/auth/forgot-password 🔄 Pending
- POST /api/v1/auth/reset-password 🔄 Pending
- POST /api/v1/auth/verify-email 🔄 Pending

**User:**
- GET /api/v1/users/me 🔄 Pending
- PATCH /api/v1/users/me 🔄 Pending
- GET /api/v1/users/me/badges 🔄 Pending
- GET /api/v1/users/me/history 🔄 Pending

**Tickets:**
- POST /api/v1/tickets/generate ✅ Implemented
- GET /api/v1/tickets/my-tickets ✅ Implemented
- POST /api/v1/tickets/scan ✅ Implemented
- GET /api/v1/tickets/validate/:code 🔄 Pending
- GET /api/v1/tickets/history 🔄 Pending

**Chain:**
- GET /api/v1/chain/stats ✅ Implemented
- GET /api/v1/chain/my-info ✅ Implemented
- GET /api/v1/chain/timeline 🔄 Pending
- GET /api/v1/chain/geography 🔄 Pending

**Rules:**
- GET /api/v1/rules/current 🔄 Pending (DB ready)
- GET /api/v1/rules/upcoming 🔄 Pending
- GET /api/v1/rules/history 🔄 Pending

**Countries:**
- GET /api/v1/countries 🔄 Pending
- GET /api/v1/countries/stats 🔄 Pending

**Notifications:**
- GET /api/v1/notifications 🔄 Pending (DB ready)
- PATCH /api/v1/notifications/:id/read 🔄 Pending
- POST /api/v1/notifications/read-all 🔄 Pending
- POST /api/v1/notifications/preferences 🔄 Pending

**Admin:**
- POST /api/v1/admin/auth/login 🔄 Pending
- GET /api/v1/admin/dashboard 🔄 Pending
- POST /api/v1/admin/rules/create 🔄 Pending (DB ready)
- POST /api/v1/admin/rules/apply-now/:id 🔄 Pending
- GET /api/v1/admin/users 🔄 Pending
- PATCH /api/v1/admin/users/:position 🔄 Pending

**System:**
- GET /api/v1/actuator/health ✅ Implemented
- GET /api/v1/admin/analytics

**See API Architecture section in previous documentation for detailed endpoint specifications**

---

## 7. Success Criteria

### 7.1 Launch Criteria (Must Have)

**Technical:**
- ✓ All critical features implemented
- ✓ 80% unit test coverage
- ✓ All integration tests passing
- ✓ Performance targets met
- ✓ Security audit passed
- ✓ Production environment stable

**User Experience:**
- ✓ Onboarding < 2 minutes
- ✓ Registration success rate > 95%
- ✓ App crash rate < 0.1%
- ✓ User satisfaction score > 4.0/5.0

**Business:**
- ✓ GDPR compliance verified
- ✓ Terms of Service finalized
- ✓ Privacy Policy published
- ✓ App Store guidelines met
- ✓ Support channels established

---

### 7.2 Post-Launch Metrics (6 Months)

**Growth:**
- Target: 10,000 active users
- Target: 50 countries represented
- Target: Chain length > 10,000

**Engagement:**
- Target: 80% ticket usage rate
- Target: < 5% removal rate
- Target: Average session duration > 3 minutes

**Retention:**
- Target: 60% Day-7 retention
- Target: 40% Day-30 retention
- Target: 30% Day-90 retention

**Technical:**
- Target: 99.9% uptime
- Target: <200ms API response time (P95)
- Target: < 0.1% error rate

---

## 8. Out of Scope (Future Phases)

The following features are explicitly **NOT** included in the initial launch but are planned for future releases:

### 8.1 Phase 2 Features (Month 7-12)
- Chain Stories (user-submitted phrases)
- Advanced analytics dashboard
- Social sharing integrations
- In-app achievements system
- Leaderboards
- Custom avatar uploads

### 8.2 Phase 3 Features (Year 2)
- Multiple chains (parallel experiments)
- Cross-chain interactions
- Tokenized proof-of-participation
- Web companion application
- API for third-party integrations
- Merchandise store

### 8.3 Explicitly Excluded
- Messaging between users
- User profiles beyond chain info
- Monetary transactions
- NFT integration
- Advertising platform
- Social media-style feeds

---

## 9. Appendices

### 9.1 Glossary

| Term | Definition |
|------|------------|
| **Chain** | The single, linear sequence of all users |
| **Tip** | The last active user who can generate tickets |
| **Ticket** | Time-limited invitation code (24h expiry) |
| **Position** | User's immutable number in the chain (#1, #2, ...) |
| **Chain Key** | Unique identifier (CK-00001, CK-00002, ...) |
| **Removal** | Forced exit after 3 failed attempts or inactivity |
| **Side-Chain** | Removed users visible in history but not active |
| **±1 Visibility** | Can only see inviter and invitee(s) |
| **Seed** | Position #1, origin of the chain |
| **Attempt** | One 24-hour window to get someone to join |
| **Reactivation** | Becoming tip again after invitee removed |

### 9.2 Abbreviations

| Abbreviation | Full Term |
|--------------|-----------|
| **JWT** | JSON Web Token |
| **API** | Application Programming Interface |
| **QR** | Quick Response (code) |
| **GDPR** | General Data Protection Regulation |
| **ISO** | International Organization for Standardization |
| **UTC** | Coordinated Universal Time |
| **CDN** | Content Delivery Network |
| **CORS** | Cross-Origin Resource Sharing |
| **CSRF** | Cross-Site Request Forgery |
| **XSS** | Cross-Site Scripting |

### 9.3 References

**External Documentation:**
- Spring Boot Documentation: https://spring.io/projects/spring-boot
- Flutter Documentation: https://flutter.dev/docs
- PostgreSQL Documentation: https://www.postgresql.org/docs/
- JWT Specification: https://tools.ietf.org/html/rfc7519
- ISO 3166 Country Codes: https://www.iso.org/iso-3166-country-codes.html

**Internal Documentation:**
- [IMPLEMENTATION_STATUS.md](./IMPLEMENTATION_STATUS.md) - Current technical status & progress (v2.1) ✅
- [MIGRATION_AND_REFACTORING_PLAN.md](./MIGRATION_AND_REFACTORING_PLAN.md) - Migration strategy ✅
- [PHASE1_MIGRATION_COMPLETE.md](./PHASE1_MIGRATION_COMPLETE.md) - Phase 1 completion report ✅
- [MIGRATION_PLAN_HTML_TO_PRODUCTION.md](./MIGRATION_PLAN_HTML_TO_PRODUCTION.md) - Deployment plan ✅

---

## 10. Document Control

### 10.1 Version History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | Oct 1, 2025 | Alpaslan Bek | Initial draft |
| 2.0 | Oct 8, 2025 | Alpaslan Bek | Complete rewrite with all features |
| 2.1 | Oct 8, 2025 | Alpaslan Bek | Updated with implementation progress, added status indicators |

### 10.2 Approval

| Role | Name | Signature | Date |
|------|------|-----------|------|
| Product Owner | Alpaslan Bek | ___________ | _____ |
| Lead Developer | ___________ | ___________ | _____ |
| QA Lead | ___________ | ___________ | _____ |
| Security Lead | ___________ | ___________ | _____ |

### 10.3 Change Management

All changes to this document must be:
1. Proposed via written change request
2. Reviewed by technical lead and product owner
3. Approved by both parties before implementation
4. Versioned and tracked in document history

---

**END OF DOCUMENT**

---

**Document Status:** DRAFT - Pending Approval  
**Next Review Date:** October 15, 2025  
**Distribution:** Development Team, Stakeholders  
**Classification:** Internal Use Only