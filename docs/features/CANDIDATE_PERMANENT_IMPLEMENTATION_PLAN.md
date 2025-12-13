# Candidate/Permanent Member System - Implementation Plan

**Created:** November 4, 2025
**Status:** 📋 Planning Phase
**Estimated Effort:** 19-24 hours (2-3 working days)
**Target Completion:** TBD

---

## 🎯 Executive Summary

This document outlines the complete implementation plan for transitioning from the current "hot potato" 3-strike system to the new "probation period" candidate/permanent member system.

### Key Changes

1. **Two-Tier Membership:** Users start as "candidates" and must prove themselves to become "permanent"
2. **Depth-2 Promotion:** Candidates become permanent when their invitee successfully invites someone
3. **Halving Time Window:** Strike penalties decrease time (24h → 12h → 6h)
4. **Tip Reversion:** Failed candidates revert to last permanent member, not just parent
5. **Selective Ticketing:** Only candidates and reactivated permanents receive tickets

---

## 📊 Current System vs. New System

### Current (Simple Hot Potato)
```
Everyone gets 3 tries at 24h each
User → wastes ticket #1 (24h) → Strike 1
User → wastes ticket #2 (24h) → Strike 2
User → wastes ticket #3 (24h) → Strike 3 → REMOVED
```

### New (Probation Period with Escalation)
```
Candidate period with decreasing time
Candidate → wastes ticket #1 (24h) → Strike 1
Candidate → wastes ticket #2 (12h) → Strike 2
Candidate → wastes ticket #3 (6h) → Strike 3 → REMOVED
→ Ticket returns to last PERMANENT member

Permanent status achieved:
Your invitee successfully invites someone (depth-2)
```

---

## 🗺️ Implementation Roadmap

### Phase 1: Database & Schema (Priority: P0)
**Effort:** 3-4 hours

1.1. Update User entity with membership tier
1.2. Create database migration script
1.3. Add indexes for performance
1.4. Handle existing data (grandfathering)

### Phase 2: Core Business Logic (Priority: P0)
**Effort:** 8-10 hours

2.1. Implement depth-2 detection
2.2. Add halving time window logic
2.3. Create "find last permanent" algorithm
2.4. Update ticket creation rules
2.5. Modify chain reversion behavior

### Phase 3: Testing (Priority: P0)
**Effort:** 4-5 hours

3.1. Rewrite integration tests
3.2. Add unit tests for new methods
3.3. Test migration script
3.4. Edge case validation

### Phase 4: API & Frontend (Priority: P1)
**Effort:** 4-5 hours

4.1. Update API responses
4.2. Add frontend badges/indicators
4.3. Update dashboard UI
4.4. Add countdown timers with variable time

### Phase 5: Documentation (Priority: P1)
**Effort:** 2-3 hours

5.1. Update all documentation
5.2. Create user-facing rule explanation
5.3. Update API specification
5.4. Add migration notes

---

## 📐 Phase 1: Database & Schema Changes

### 1.1 User Entity Updates

**File:** `backend/src/main/java/com/thechain/entity/User.java`

**Current:**
```java
@Column(name = "status")
private String status; // "active", "removed", "seed"
```

**Option A: Overload status field**
```java
@Column(name = "status")
private String status; // "candidate", "permanent", "removed", "seed"
```

**Option B: Separate field (RECOMMENDED)**
```java
@Column(name = "status")
private String status; // "active", "removed", "seed"

@Column(name = "membership_tier")
private String membershipTier; // "candidate", "permanent", null for removed/seed

@Column(name = "promoted_to_permanent_at")
private Instant promotedToPermanentAt; // Timestamp of promotion
```

**Recommendation:** Use Option B to preserve existing status field behavior and add new semantics.

---

### 1.2 Database Migration Script

**File:** `backend/src/main/resources/db/migration/V007__add_membership_tier.sql`

```sql
-- Add new columns to users table
ALTER TABLE users
ADD COLUMN membership_tier VARCHAR(20) DEFAULT 'candidate',
ADD COLUMN promoted_to_permanent_at TIMESTAMP WITH TIME ZONE;

-- Add index for efficient queries
CREATE INDEX idx_users_membership_tier ON users(membership_tier);

-- Grandfather existing active users as permanent
UPDATE users
SET membership_tier = 'permanent',
    promoted_to_permanent_at = created_at
WHERE status = 'active';

-- Seed user is always permanent
UPDATE users
SET membership_tier = 'permanent',
    promoted_to_permanent_at = created_at
WHERE status = 'seed';

-- Removed users get NULL membership_tier
UPDATE users
SET membership_tier = NULL
WHERE status = 'removed';

-- Add constraint
ALTER TABLE users
ADD CONSTRAINT check_membership_tier
CHECK (membership_tier IN ('candidate', 'permanent') OR membership_tier IS NULL);

-- Add comment
COMMENT ON COLUMN users.membership_tier IS
'Membership tier: candidate (probationary), permanent (verified), NULL (removed/N/A)';

COMMENT ON COLUMN users.promoted_to_permanent_at IS
'Timestamp when user achieved permanent status (depth-2 requirement met)';
```

---

### 1.3 Add Computed Fields (Optional Performance Optimization)

**For fast queries without joins:**

```sql
-- Add field to track invitee depth
ALTER TABLE users
ADD COLUMN invitee_depth INTEGER DEFAULT 0;

-- Update existing users based on their children
UPDATE users u1
SET invitee_depth = CASE
    WHEN u1.active_child_id IS NULL THEN 0
    WHEN (SELECT active_child_id FROM users WHERE id = u1.active_child_id) IS NOT NULL THEN 2
    ELSE 1
END;

-- Add index
CREATE INDEX idx_users_invitee_depth ON users(invitee_depth);

-- Trigger to auto-update (optional)
CREATE OR REPLACE FUNCTION update_invitee_depth()
RETURNS TRIGGER AS $$
BEGIN
    -- When a child gets a child, update parent's depth to 2
    IF NEW.active_child_id IS NOT NULL AND OLD.active_child_id IS NULL THEN
        UPDATE users
        SET invitee_depth = 2
        WHERE id = NEW.parent_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_invitee_depth
AFTER UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION update_invitee_depth();
```

---

## 🧠 Phase 2: Core Business Logic Changes

### 2.1 Depth-2 Detection & Promotion

**New Service Method:** `ChainService.checkAndPromoteToPermament()`

**File:** `backend/src/main/java/com/thechain/service/ChainService.java`

```java
/**
 * Check if a candidate user should be promoted to permanent status.
 *
 * Promotion Criteria:
 * - User is currently a "candidate"
 * - User has successfully invited someone (activeChildId != null)
 * - User's child has successfully invited someone (depth-2)
 *
 * @param userId The user to check
 * @return true if user was promoted, false otherwise
 */
@Transactional
public boolean checkAndPromoteToPermament(UUID userId) {
    User user = userRepository.findById(userId)
        .orElseThrow(() -> new BusinessException("USER_NOT_FOUND", "User not found"));

    // Already permanent or removed - skip
    if (!"candidate".equals(user.getMembershipTier())) {
        log.debug("User {} is not a candidate (tier={}), skipping promotion check",
                  user.getChainKey(), user.getMembershipTier());
        return false;
    }

    // User must have successfully invited someone
    if (user.getActiveChildId() == null) {
        log.debug("User {} has no active child, cannot be promoted yet",
                  user.getChainKey());
        return false;
    }

    // Check if child has successfully invited someone (depth-2)
    User child = userRepository.findById(user.getActiveChildId())
        .orElseThrow(() -> new BusinessException("CHILD_NOT_FOUND", "Child not found"));

    if (child.getActiveChildId() != null) {
        // PROMOTION ACHIEVED! 🎉
        user.setMembershipTier("permanent");
        user.setPromotedToPermanentAt(Instant.now());
        userRepository.save(user);

        log.info("🎉 User {} PROMOTED to PERMANENT (depth-2 achieved)",
                 user.getChainKey());

        // Award badge
        Map<String, Object> badgeContext = new HashMap<>();
        badgeContext.put("promoted_at", Instant.now());
        badgeContext.put("child_position", child.getPosition());
        badgeContext.put("grandchild_position", child.getActiveChildId());

        awardBadge(user.getPosition(), Badge.CHAIN_BUILDER, badgeContext);

        return true;
    }

    return false;
}
```

**When to call:**
- After every successful registration: `RegistrationService.registerUser()`
- After ticket is used: `TicketService.useTicket()`

---

### 2.2 Halving Time Window Logic

**Update Method:** `TicketService.createTicketForUser()`

**Current Code:**
```java
Instant expiresAt = now.plusSeconds(expirationHours * 3600L);
```

**New Code:**
```java
/**
 * Calculate ticket expiration time based on user's strike count.
 * Implements halving rule: 24h → 12h → 6h
 */
private Instant calculateExpirationTime(User owner) {
    int strikeCount = owner.getWastedTicketsCount();

    int hours = switch(strikeCount) {
        case 0 -> 24;  // First attempt: full 24 hours
        case 1 -> 12;  // Second attempt: half time
        case 2 -> 6;   // Final attempt: quarter time
        default -> {
            // Should never reach here - user should be removed at 3 strikes
            log.error("User {} has {} strikes (should be removed at 3!)",
                      owner.getChainKey(), strikeCount);
            yield 6;  // Fallback to minimum time
        }
    };

    Instant expiresAt = Instant.now().plusSeconds(hours * 3600L);

    log.info("Ticket for user {} (strike {}/3) expires in {} hours at {}",
             owner.getChainKey(), strikeCount, hours, expiresAt);

    return expiresAt;
}
```

**Usage:**
```java
@Transactional
public Ticket createTicketForUser(UUID userId) {
    User user = userRepository.findById(userId)
            .orElseThrow(() -> new BusinessException("USER_NOT_FOUND", "User not found"));

    // Check if user already has active child (shouldn't create ticket)
    if (user.getActiveChildId() != null) {
        throw new BusinessException("ALREADY_HAS_INVITEE", "User already has an active invitee");
    }

    // ✅ NEW: Only candidates and reactivated permanents get tickets
    if ("permanent".equals(user.getMembershipTier()) && user.getActiveChildId() != null) {
        throw new BusinessException("USER_ALREADY_PERMANENT",
            "Permanent members with active children don't need tickets");
    }

    Instant now = Instant.now();
    Instant expiresAt = calculateExpirationTime(user); // ✅ NEW: Variable time

    // Rest of ticket creation...
}
```

---

### 2.3 Find Last Permanent Member Algorithm

**New Service Method:** `ChainService.findLastPermanentMember()`

```java
/**
 * Find the last permanent member up the chain.
 * Used when a candidate fails and ticket needs to revert.
 *
 * Algorithm:
 * 1. Start from current user
 * 2. Walk up the parent chain
 * 3. Stop at first "permanent" member or seed
 * 4. Return that user
 *
 * @param startingUserId The user to start from (usually removed candidate)
 * @return The last permanent member up the chain
 */
@Transactional(readOnly = true)
public User findLastPermanentMember(UUID startingUserId) {
    User current = userRepository.findById(startingUserId)
        .orElseThrow(() -> new BusinessException("USER_NOT_FOUND", "User not found"));

    // If starting user is already permanent, return them
    if ("permanent".equals(current.getMembershipTier()) || "seed".equals(current.getStatus())) {
        return current;
    }

    // Walk up the chain
    int steps = 0;
    final int MAX_STEPS = 1000; // Safety limit

    while (current.getParentId() != null && steps < MAX_STEPS) {
        User parent = userRepository.findById(current.getParentId())
            .orElseThrow(() -> new BusinessException("PARENT_NOT_FOUND",
                         "Parent not found for user " + current.getChainKey()));

        // Check if parent is permanent or seed
        if ("permanent".equals(parent.getMembershipTier()) || "seed".equals(parent.getStatus())) {
            log.info("Found last permanent member: {} (walked {} steps from {})",
                     parent.getChainKey(), steps + 1,
                     userRepository.findById(startingUserId).get().getChainKey());
            return parent;
        }

        current = parent;
        steps++;
    }

    // Safety check
    if (steps >= MAX_STEPS) {
        log.error("Exceeded max steps ({}) walking up chain from user {}",
                  MAX_STEPS, startingUserId);
        throw new BusinessException("CHAIN_WALK_EXCEEDED",
                                   "Chain walk exceeded maximum depth");
    }

    // If we reach here, we've hit the top of the chain without finding permanent
    // This shouldn't happen - seed should always be permanent
    log.warn("Reached top of chain from {} without finding permanent member. " +
             "Returning seed as fallback.", startingUserId);

    return userRepository.findByStatus("seed")
        .orElseThrow(() -> new BusinessException("SEED_NOT_FOUND", "Seed user not found"));
}
```

**Example Usage:**
```
Chain: Seed → Alice (P) → Bob (P) → Charlie (C) → Diana (C)

Diana fails:
  findLastPermanentMember(Diana.id)
  → Walk: Diana (C) → Charlie (C) → Bob (P) ✓
  → Return: Bob

Charlie fails (after Diana already failed):
  findLastPermanentMember(Charlie.id)
  → Walk: Charlie (C) → Bob (P) ✓
  → Return: Bob

Bob's ticket now (gets "Chain Savior" opportunity)
```

---

### 2.4 Update Ticket Creation Rules

**Method:** `TicketService.createTicketForUser()`

**Add checks:**
```java
@Transactional
public Ticket createTicketForUser(UUID userId) {
    User user = userRepository.findById(userId)
            .orElseThrow(() -> new BusinessException("USER_NOT_FOUND", "User not found"));

    // ✅ CHECK 1: User must not be removed
    if ("removed".equals(user.getStatus())) {
        throw new BusinessException("USER_REMOVED",
            "Removed users cannot receive tickets");
    }

    // ✅ CHECK 2: User must not have active child (already succeeded)
    if (user.getActiveChildId() != null) {
        throw new BusinessException("ALREADY_HAS_INVITEE",
            "User already has an active invitee");
    }

    // ✅ CHECK 3: Check for existing active ticket (avoid duplicates)
    ticketRepository.findByOwnerIdAndStatus(userId, Ticket.TicketStatus.ACTIVE)
            .ifPresent(existingTicket -> {
                throw new BusinessException("ACTIVE_TICKET_EXISTS",
                    "User already has an active ticket");
            });

    // ✅ NEW CHECK 4: Validate membership tier eligibility
    // Candidates always get tickets
    // Permanent members only get tickets if chain reverted to them
    String tier = user.getMembershipTier();
    if ("permanent".equals(tier)) {
        log.info("Creating ticket for permanent member {} (chain reversion scenario)",
                 user.getChainKey());
        // This is allowed - they're being reactivated as tip
    }

    // Create ticket with variable expiration time
    Instant now = Instant.now();
    Instant expiresAt = calculateExpirationTime(user); // ✅ Uses halving rule

    String payload = createPayload(userId, now, expiresAt);
    String signature = signPayload(payload);

    Ticket ticket = Ticket.builder()
            .ownerId(userId)
            .expiresAt(expiresAt)
            .status(Ticket.TicketStatus.ACTIVE)
            .payload(payload)
            .signature(signature)
            .attemptNumber(user.getWastedTicketsCount() + 1) // Track which attempt this is
            .build();

    ticket = ticketRepository.save(ticket);

    log.info("Ticket created for user {} ({}), tier={}, strike={}/3, duration={}h",
             user.getChainKey(), ticket.getId(), tier,
             user.getWastedTicketsCount(),
             (expiresAt.toEpochMilli() - now.toEpochMilli()) / 3600000);

    return ticket;
}
```

---

### 2.5 Modify Chain Reversion Behavior

**Update Method:** `TicketService.expireTicket()`

**Current (wrong):**
```java
// Automatically create a new ticket for the user
createTicketForUser(owner.getId());
```

**New (correct):**
```java
/**
 * Expires a ticket and handles reversion to last permanent member.
 */
@CacheEvict(value = CacheConfig.TICKET_CACHE, key = "#ticketId")
@Transactional
public void expireTicket(UUID ticketId) {
    Ticket ticket = ticketRepository.findById(ticketId)
            .orElseThrow(() -> new BusinessException("TICKET_NOT_FOUND", "Ticket not found"));

    if (ticket.getStatus() != Ticket.TicketStatus.ACTIVE) {
        log.warn("Attempted to expire non-active ticket {}", ticketId);
        return;
    }

    // Mark ticket as expired
    ticket.setStatus(Ticket.TicketStatus.EXPIRED);
    ticketRepository.save(ticket);

    // Get the owner
    User owner = userRepository.findById(ticket.getOwnerId())
            .orElseThrow(() -> new BusinessException("USER_NOT_FOUND", "Ticket owner not found"));

    // Increment wasted tickets count
    owner.setWastedTicketsCount(owner.getWastedTicketsCount() + 1);
    log.warn("User {} wasted ticket {}/3 (tier={})",
             owner.getChainKey(), owner.getWastedTicketsCount(), owner.getMembershipTier());

    // Check if user should be removed from chain (3 strikes rule)
    if (owner.getWastedTicketsCount() >= 3) {
        log.error("User {} reached 3 wasted tickets - removing from chain", owner.getChainKey());
        removeUserFromChain(owner);

        // ✅ NEW: Find last permanent member and give them the ticket
        User lastPermanent = chainService.findLastPermanentMember(owner.getId());

        if (lastPermanent.getId().equals(owner.getId())) {
            // Edge case: The removed user WAS the last permanent (shouldn't happen)
            log.error("Removed user {} was last permanent - walking up to parent",
                      owner.getChainKey());
            if (owner.getParentId() != null) {
                lastPermanent = userRepository.findById(owner.getParentId()).get();
            } else {
                // No parent - must be seed situation, get seed
                lastPermanent = userRepository.findByStatus("seed").get();
            }
        }

        log.info("Ticket reverting to last permanent member: {} (position {})",
                 lastPermanent.getChainKey(), lastPermanent.getPosition());

        // Clear last permanent's activeChildId (they lost their candidate)
        lastPermanent.setActiveChildId(null);
        userRepository.save(lastPermanent);

        // Create new ticket for last permanent member
        try {
            createTicketForUser(lastPermanent.getId());
            log.info("New ticket created for last permanent {} after candidate removal",
                     lastPermanent.getChainKey());

            // Check if they qualify for Chain Savior badge
            chainService.checkAndAwardChainSaviorBadge(lastPermanent);

        } catch (Exception e) {
            log.error("Failed to create ticket for last permanent member {}",
                      lastPermanent.getChainKey(), e);
        }

    } else {
        // User still has chances remaining
        userRepository.save(owner);

        // ✅ NEW: Only create ticket if they're still a candidate
        if ("candidate".equals(owner.getMembershipTier())) {
            try {
                createTicketForUser(owner.getId());
                log.info("New ticket auto-created for candidate {} (strike {}/3, next window shorter)",
                         owner.getChainKey(), owner.getWastedTicketsCount());
            } catch (Exception e) {
                log.error("Failed to auto-create ticket for candidate {}",
                          owner.getChainKey(), e);
            }
        } else {
            log.warn("User {} is permanent but wasted a ticket - no auto-ticket",
                     owner.getChainKey());
        }
    }

    log.info("Ticket {} expired for user {}", ticketId, owner.getChainKey());
}
```

---

## 🧪 Phase 3: Testing Strategy

### 3.1 New Integration Tests Needed

**File:** `backend/src/test/java/com/thechain/integration/CandidatePermanentIntegrationTest.java`

```java
@ActiveProfiles("test")
@Transactional
class CandidatePermanentIntegrationTest extends BaseIntegrationTest {

    @Test
    void newUser_StartsAsCandidate() {
        // When: User registers
        User user = createTestUser("Bob", 2);

        // Then: User is candidate by default
        assertThat(user.getMembershipTier()).isEqualTo("candidate");
        assertThat(user.getPromotedToPermanentAt()).isNull();
    }

    @Test
    void candidate_InvitesSomeone_StaysCandidate() {
        // Given: Candidate Bob invites Charlie
        User bob = createCandidate("Bob", 2);
        User charlie = createCandidate("Charlie", 3);
        bob.setActiveChildId(charlie.getId());
        userRepository.save(bob);

        // When: Check promotion
        boolean promoted = chainService.checkAndPromoteToPermament(bob.getId());

        // Then: Bob is still candidate (depth-1, needs depth-2)
        assertThat(promoted).isFalse();
        User updatedBob = userRepository.findById(bob.getId()).get();
        assertThat(updatedBob.getMembershipTier()).isEqualTo("candidate");
    }

    @Test
    void candidate_InviteeInvitesSomeone_BecomesPermament() {
        // Given: Bob → Charlie → Diana (depth-2)
        User bob = createCandidate("Bob", 2);
        User charlie = createCandidate("Charlie", 3);
        User diana = createCandidate("Diana", 4);

        bob.setActiveChildId(charlie.getId());
        charlie.setActiveChildId(diana.getId());
        userRepository.saveAll(List.of(bob, charlie, diana));

        // When: Check Bob's promotion
        boolean promoted = chainService.checkAndPromoteToPermament(bob.getId());

        // Then: Bob becomes permanent!
        assertThat(promoted).isTrue();
        User updatedBob = userRepository.findById(bob.getId()).get();
        assertThat(updatedBob.getMembershipTier()).isEqualTo("permanent");
        assertThat(updatedBob.getPromotedToPermanentAt()).isNotNull();
    }

    @Test
    void ticket_HalvingRule_24h_12h_6h() {
        // Given: Candidate with 0 strikes
        User candidate = createCandidate("Alice", 2);

        // First ticket: 24 hours
        Ticket ticket1 = ticketService.createTicketForUser(candidate.getId());
        long duration1 = ticket1.getExpiresAt().toEpochMilli() - ticket1.getIssuedAt().toEpochMilli();
        assertThat(duration1).isEqualTo(24 * 3600 * 1000L); // 24 hours

        // Expire first ticket
        ticketService.expireTicket(ticket1.getId());
        candidate = userRepository.findById(candidate.getId()).get();
        assertThat(candidate.getWastedTicketsCount()).isEqualTo(1);

        // Second ticket: 12 hours
        Ticket ticket2 = ticketRepository.findByOwnerIdAndStatus(
            candidate.getId(), Ticket.TicketStatus.ACTIVE).get();
        long duration2 = ticket2.getExpiresAt().toEpochMilli() - ticket2.getIssuedAt().toEpochMilli();
        assertThat(duration2).isEqualTo(12 * 3600 * 1000L); // 12 hours

        // Expire second ticket
        ticketService.expireTicket(ticket2.getId());
        candidate = userRepository.findById(candidate.getId()).get();
        assertThat(candidate.getWastedTicketsCount()).isEqualTo(2);

        // Third ticket: 6 hours
        Ticket ticket3 = ticketRepository.findByOwnerIdAndStatus(
            candidate.getId(), Ticket.TicketStatus.ACTIVE).get();
        long duration3 = ticket3.getExpiresAt().toEpochMilli() - ticket3.getIssuedAt().toEpochMilli();
        assertThat(duration3).isEqualTo(6 * 3600 * 1000L); // 6 hours
    }

    @Test
    void candidate_Fails_TicketGoesToLastPermanent() {
        // Given: Seed (P) → Alice (P) → Bob (C) → Charlie (C)
        User seed = userRepository.findByStatus("seed").get();
        User alice = createPermanent("Alice", 2);
        User bob = createCandidate("Bob", 3);
        User charlie = createCandidate("Charlie", 4);

        alice.setParentId(seed.getId());
        bob.setParentId(alice.getId());
        charlie.setParentId(bob.getId());
        alice.setActiveChildId(bob.getId());
        bob.setActiveChildId(charlie.getId());

        userRepository.saveAll(List.of(alice, bob, charlie));

        // Charlie wastes 3 tickets and gets removed
        charlie.setWastedTicketsCount(2);
        userRepository.save(charlie);

        Ticket charlieTicket = createExpiredTicket(charlie);

        // When: Charlie's ticket expires (3rd strike)
        ticketService.expireTicket(charlieTicket.getId());

        // Then: Charlie is removed
        User updatedCharlie = userRepository.findById(charlie.getId()).get();
        assertThat(updatedCharlie.getStatus()).isEqualTo("removed");

        // And: Bob (last permanent is Alice) gets the ticket
        User updatedAlice = userRepository.findById(alice.getId()).get();
        assertThat(updatedAlice.getActiveChildId()).isNull(); // Lost Bob

        // Alice should have a new ticket
        Optional<Ticket> aliceTicket = ticketRepository.findByOwnerIdAndStatus(
            alice.getId(), Ticket.TicketStatus.ACTIVE);
        assertThat(aliceTicket).isPresent();
    }

    @Test
    void findLastPermanent_SkipsMultipleCandidates() {
        // Given: Seed (P) → Alice (P) → Bob (C) → Charlie (C) → Diana (C)
        User seed = userRepository.findByStatus("seed").get();
        User alice = createPermanent("Alice", 2);
        User bob = createCandidate("Bob", 3);
        User charlie = createCandidate("Charlie", 4);
        User diana = createCandidate("Diana", 5);

        alice.setParentId(seed.getId());
        bob.setParentId(alice.getId());
        charlie.setParentId(bob.getId());
        diana.setParentId(charlie.getId());

        userRepository.saveAll(List.of(alice, bob, charlie, diana));

        // When: Find last permanent from Diana
        User lastPermanent = chainService.findLastPermanentMember(diana.getId());

        // Then: Should find Alice (skip Diana, Charlie, Bob)
        assertThat(lastPermanent.getId()).isEqualTo(alice.getId());
        assertThat(lastPermanent.getMembershipTier()).isEqualTo("permanent");
    }
}
```

---

### 3.2 Test Scenarios Matrix

| Scenario | Initial State | Action | Expected Result |
|----------|---------------|--------|-----------------|
| **New User** | None | Register | status=candidate, tier=candidate |
| **Depth-1** | Candidate, has child | Check promotion | Still candidate |
| **Depth-2** | Candidate, grandchild exists | Check promotion | Promoted to permanent |
| **Strike 1** | Candidate, 0 strikes | Ticket expires | Strike 1, new ticket 12h |
| **Strike 2** | Candidate, 1 strike | Ticket expires | Strike 2, new ticket 6h |
| **Strike 3** | Candidate, 2 strikes | Ticket expires | Removed, ticket to last permanent |
| **Reversion** | 3 candidates fail | Last fails | Ticket goes to last permanent |
| **Chain Savior** | Permanent gets ticket back | Invite succeeds | Awarded Chain Savior badge |
| **Grandfathered** | Existing active user | Migration runs | Becomes permanent |

---

## 🎨 Phase 4: API & Frontend Changes

### 4.1 API Response Updates

**Endpoint:** `GET /auth/me`

**Current Response:**
```json
{
  "userId": "uuid",
  "chainKey": "USER00000042",
  "displayName": "Alice",
  "position": 42,
  "status": "active",
  "wastedTicketsCount": 1
}
```

**New Response:**
```json
{
  "userId": "uuid",
  "chainKey": "USER00000042",
  "displayName": "Alice",
  "position": 42,
  "status": "active",
  "membershipTier": "candidate",
  "promotedToPermanentAt": null,
  "wastedTicketsCount": 1,
  "nextTicketDuration": "12 hours",
  "depth": 1,
  "isPermanent": false
}
```

**Endpoint:** `GET /tickets/me/active`

**New Response (includes variable duration):**
```json
{
  "ticketId": "uuid",
  "qrPayload": "base64...",
  "expiresAt": "2025-11-05T12:00:00Z",
  "timeRemaining": 43200000,
  "durationHours": 12,
  "attemptNumber": 2,
  "strikeCount": 1,
  "nextAttemptDuration": "6 hours"
}
```

---

### 4.2 Frontend UI Changes

**Dashboard Screen Updates:**

**File:** `frontend/private-app/lib/screens/dashboard_screen.dart`

**Add Membership Badge:**
```dart
Widget _buildMembershipBadge(User user) {
  final isPermanent = user.membershipTier == 'permanent';

  return Container(
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: isPermanent ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isPermanent ? Colors.green : Colors.orange,
        width: 1,
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isPermanent ? Icons.verified : Icons.hourglass_empty,
          color: isPermanent ? Colors.green : Colors.orange,
          size: 16,
        ),
        SizedBox(width: 4),
        Text(
          isPermanent ? 'PERMANENT' : 'CANDIDATE',
          style: TextStyle(
            color: isPermanent ? Colors.green : Colors.orange,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}
```

**Update Ticket Banner with Variable Time:**
```dart
Widget _buildActiveTicketBanner(Ticket ticket) {
  final hoursRemaining = ticket.timeRemaining ~/ 3600000;
  final isUrgent = hoursRemaining <= 6;

  return Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: isUrgent ? Colors.red.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isUrgent ? Colors.red : Colors.blue,
        width: 2,
      ),
    ),
    child: Column(
      children: [
        Row(
          children: [
            Icon(
              isUrgent ? Icons.warning : Icons.timer,
              color: isUrgent ? Colors.red : Colors.blue,
            ),
            SizedBox(width: 8),
            Text(
              'Attempt ${ticket.attemptNumber}/3',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          'Time Remaining: ${hoursRemaining}h ${(ticket.timeRemaining % 3600000) ~/ 60000}m',
          style: TextStyle(
            fontSize: 18,
            color: isUrgent ? Colors.red : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (ticket.nextAttemptDuration != null) ...[
          SizedBox(height: 4),
          Text(
            'Next attempt: ${ticket.nextAttemptDuration}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ],
    ),
  );
}
```

---

## 📚 Phase 5: Documentation Updates

### 5.1 Files to Update

| Document | Changes Needed |
|----------|----------------|
| `README.md` | Update rules explanation |
| `USER_FLOWS.md` | Add depth-2 promotion flow |
| `API_SPECIFICATION.md` | Update response schemas |
| `DATABASE_SCHEMA.md` | Add new columns |
| `MVP_REQUIREMENTS.md` | Update feature descriptions |
| `TESTING_SUMMARY.md` | Update test counts |

### 5.2 Create New User-Facing Documentation

**File:** `docs/USER_GUIDE_3_STRIKE_RULE.md`

```markdown
# The 3-Strike Rule - User Guide

## How Membership Works

### Two Tiers of Membership

1. **Candidate** (Probationary)
   - You start here when someone invites you
   - You must prove yourself by successfully inviting someone
   - You have 3 chances to invite someone who also succeeds

2. **Permanent** (Verified)
   - Achieved when your invitee successfully invites someone (depth-2)
   - Your position in the chain is secured
   - You can still lose your position if you later get 3 strikes

### How to Become Permanent

```
You register (Candidate)
  ↓
You invite Alice (still Candidate)
  ↓
Alice invites Bob (YOU BECOME PERMANENT! ✅)
```

### The Decreasing Time Window

Each time your invitee fails, you lose time:

- **Attempt 1:** 24 hours (full day)
- **Attempt 2:** 12 hours (half day)
- **Attempt 3:** 6 hours (last chance!)

### What Happens When You Fail

If you waste all 3 attempts:
1. You are removed from the chain
2. The ticket goes back to the last **permanent** member before you
3. That person gets a "Chain Savior" opportunity

## Examples

[Add visual examples with diagrams]
```

---

## 🔄 Migration & Rollback Strategy

### Migration Plan

**Timing:** During low-traffic period (2-4 AM)

**Steps:**
1. Deploy backend with new code (backward compatible)
2. Run database migration script
3. Deploy frontend with new UI
4. Monitor for 24 hours
5. If stable, mark migration complete

**Rollback Plan:**

If issues detected within 24 hours:

```sql
-- Rollback script V007
ALTER TABLE users
DROP COLUMN IF EXISTS membership_tier,
DROP COLUMN IF EXISTS promoted_to_permanent_at,
DROP COLUMN IF EXISTS invitee_depth;

DROP INDEX IF EXISTS idx_users_membership_tier;
DROP INDEX IF EXISTS idx_users_invitee_depth;
```

Deploy previous version of backend/frontend.

---

## 📊 Success Metrics

### Implementation Complete When:

- [ ] All database migrations successful
- [ ] All new methods implemented
- [ ] All integration tests passing (rewritten)
- [ ] Frontend displays candidate/permanent badges
- [ ] Variable time windows working (24h → 12h → 6h)
- [ ] Chain reversion to last permanent working
- [ ] Documentation updated
- [ ] Production deployment successful

### Validation Tests:

1. Create new user → Should be candidate
2. User's invitee invites someone → User becomes permanent
3. Waste 3 tickets → Time decreases (24→12→6)
4. Candidate fails → Ticket goes to last permanent
5. Permanent member gets ticket → "Chain Savior" badge awarded

---

## ⚠️ Risks & Mitigation

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Database migration fails | LOW | HIGH | Test on staging, have rollback ready |
| Existing users confused | MEDIUM | MEDIUM | Email announcement, in-app tutorial |
| Performance degradation | LOW | MEDIUM | Add indexes, test with load |
| Edge case bugs | MEDIUM | HIGH | Comprehensive integration tests |
| Frontend breaking changes | LOW | MEDIUM | Backward-compatible API |

---

## 📅 Implementation Timeline

### Day 1 (6-8 hours)
- [ ] Phase 1: Database schema changes
- [ ] Phase 2.1-2.2: Depth-2 detection + halving
- [ ] Test migration script on local DB

### Day 2 (6-8 hours)
- [ ] Phase 2.3-2.5: Last permanent + reversion logic
- [ ] Phase 3.1: Rewrite integration tests
- [ ] Local end-to-end testing

### Day 3 (4-6 hours)
- [ ] Phase 4: Frontend UI changes
- [ ] Phase 5: Documentation updates
- [ ] Staging deployment + validation
- [ ] Production deployment

**Total Estimated Time:** 16-22 hours (2-3 working days)

---

## 🎯 Next Steps

1. **Review this plan** - Get approval from stakeholders
2. **Create feature branch** - `feature/candidate-permanent-system`
3. **Start with Phase 1** - Database changes first
4. **Incremental commits** - Small, testable changes
5. **Continuous testing** - Run tests after each phase
6. **Staging deployment** - Validate before production
7. **Production deployment** - During low-traffic window
8. **Monitor metrics** - Watch for issues post-launch

---

**Ready to start implementation?**

Type `/implement phase1` to begin with database schema changes!
