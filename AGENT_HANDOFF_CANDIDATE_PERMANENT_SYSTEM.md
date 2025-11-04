# 🤖 Agent Handoff: Candidate/Permanent Member System Implementation

**Created:** November 4, 2025
**Status:** 🟡 Ready for Implementation
**Priority:** HIGH - Core Game Mechanics Change
**Estimated Effort:** 19-24 hours (2-3 working days)

---

## 📌 Quick Start for New Agent

**If you're picking this up, start here:**

1. ✅ **Read this entire document first** (10 min read)
2. ✅ **Review the detailed plan:** `docs/CANDIDATE_PERMANENT_IMPLEMENTATION_PLAN.md`
3. ✅ **Start with Phase 1:** Database schema changes
4. ✅ **Test incrementally:** Run tests after each phase
5. ✅ **Ask questions:** If anything is unclear, ask the user before proceeding

**Your first command should be:**
```bash
# Verify current system state
cd backend
mvn test -Dtest=TicketExpirationIntegrationTest
```

If tests pass (they should: 26/26), you're ready to start.

---

## 🎯 Mission Statement

**Objective:** Transform the 3-strike ticket system from a simple "hot potato" model to a sophisticated "probation period" model with candidate and permanent member tiers.

**Why This Matters:** The current implementation doesn't match the product owner's true vision. The new system creates better game psychology with escalating stakes and clear progression.

**Success Criteria:**
- [ ] Users start as "candidates" and must prove themselves
- [ ] Users become "permanent" when their invitee successfully invites someone (depth-2)
- [ ] Strike penalties have decreasing time windows (24h → 12h → 6h)
- [ ] Failed candidates revert to last permanent member (not just parent)
- [ ] All tests pass (will need rewriting)
- [ ] Frontend shows candidate/permanent status clearly

---

## 📊 Current State Analysis

### What's Implemented Now (❌ Wrong System)

**Architecture:** "Hot Potato" Model
```
Everyone is equal, everyone gets 3 tries at 24 hours each
User → Ticket expires (24h) → Strike 1 → New ticket (24h)
User → Ticket expires (24h) → Strike 2 → New ticket (24h)
User → Ticket expires (24h) → Strike 3 → REMOVED
→ Ticket returns to parent (regardless of parent's status)
```

**Key Characteristics:**
- ✅ Everyone has same status ("active")
- ✅ All tickets expire after 24 hours (constant)
- ✅ Ticket always returns to immediate parent
- ✅ No concept of "proving yourself"
- ✅ No permanent membership tier

**Files Implementing Current System:**
- `backend/src/main/java/com/thechain/service/TicketService.java`
  - `expireTicket()` - Lines 195-279
  - `createTicketForUser()` - Lines 79-115
- `backend/src/main/java/com/thechain/service/ChainService.java`
  - `checkParentRemovalFor3Strikes()` - Lines 214-267
- `backend/src/main/java/com/thechain/entity/User.java`
  - `status` field: "active", "removed", "seed"
  - `wastedTicketsCount` field (INTEGER)

**Test Coverage:**
- ✅ 26/26 integration tests passing
- Files: `TicketExpirationIntegrationTest.java`, `ChainReversionIntegrationTest.java`

---

## 🎯 Desired State (✅ Correct System)

### What Should Be Implemented

**Architecture:** "Probation Period" Model
```
Two-tier membership with escalating stakes

New User (Candidate)
  ↓
Ticket #1 (24h) → Success: Invitee joins (still candidate)
  ↓
Invitee's Ticket → Success: Invitee invites someone
  ↓
PROMOTED TO PERMANENT ✅ (depth-2 achieved)

Failure Path:
Ticket #1 (24h) expires → Strike 1 → New ticket (12h)
Ticket #2 (12h) expires → Strike 2 → New ticket (6h)
Ticket #3 (6h) expires → Strike 3 → REMOVED
→ Ticket returns to LAST PERMANENT MEMBER (may skip multiple candidates)
```

**Key Characteristics:**
- ✅ Two membership tiers: "candidate" (probationary) and "permanent" (verified)
- ✅ Variable ticket duration: 24h → 12h → 6h (halving rule)
- ✅ Promotion trigger: Depth-2 achievement (your invitee invites someone)
- ✅ Smart reversion: Ticket goes to last permanent member, not just parent
- ✅ Selective ticketing: Only candidates (and reactivated permanents) get tickets

---

## 🔍 The Gap: What Needs to Change

### Critical Differences Summary

| Feature | Current ❌ | Desired ✅ | Impact |
|---------|-----------|-----------|---------|
| **Membership Status** | Single tier (active) | Two-tier (candidate/permanent) | HIGH - Core concept |
| **Ticket Duration** | Always 24h | 24h → 12h → 6h | HIGH - Game mechanics |
| **Promotion System** | None | Depth-2 detection | HIGH - Progression |
| **Reversion Logic** | To parent | To last permanent | HIGH - Chain health |
| **Ticketing Rules** | Everyone gets tickets | Only candidates + tip | MEDIUM - System behavior |

### Files That Need Changes

#### 🔴 Critical Changes (Must Modify)

1. **Database Schema**
   - File: `backend/src/main/resources/db/migration/V007__add_membership_tier.sql` (NEW)
   - Change: Add `membership_tier`, `promoted_to_permanent_at` columns
   - Effort: 1-2 hours

2. **User Entity**
   - File: `backend/src/main/java/com/thechain/entity/User.java`
   - Change: Add fields for membership tier
   - Effort: 30 min

3. **TicketService**
   - File: `backend/src/main/java/com/thechain/service/TicketService.java`
   - Changes:
     - Add `calculateExpirationTime()` method (halving rule)
     - Update `expireTicket()` to revert to last permanent
     - Update `createTicketForUser()` to check tier eligibility
   - Effort: 3-4 hours

4. **ChainService**
   - File: `backend/src/main/java/com/thechain/service/ChainService.java`
   - Changes:
     - Add `checkAndPromoteToPermament()` method (depth-2 detection)
     - Add `findLastPermanentMember()` method (walk up chain)
   - Effort: 3-4 hours

5. **Integration Tests**
   - File: `backend/src/test/java/com/thechain/integration/CandidatePermanentIntegrationTest.java` (NEW)
   - File: `backend/src/test/java/com/thechain/integration/TicketExpirationIntegrationTest.java` (MODIFY)
   - Change: Rewrite tests for new system
   - Effort: 4-5 hours

#### 🟡 Important Changes (Should Modify)

6. **API Responses**
   - Files: DTOs in `backend/src/main/java/com/thechain/dto/`
   - Change: Add `membershipTier` field to responses
   - Effort: 1-2 hours

7. **Frontend Dashboard**
   - File: `frontend/private-app/lib/screens/dashboard_screen.dart`
   - Change: Display candidate/permanent badges
   - Effort: 2-3 hours

8. **Frontend Ticket Banner**
   - File: `frontend/private-app/lib/widgets/ticket/active_ticket_banner.dart`
   - Change: Show variable time windows and attempt number
   - Effort: 1-2 hours

#### 🟢 Nice-to-Have Changes

9. **Documentation**
   - Files: All `docs/*.md` files
   - Change: Update to reflect new system
   - Effort: 2-3 hours

---

## 🗺️ Implementation Plan Overview

**Full details in:** `docs/CANDIDATE_PERMANENT_IMPLEMENTATION_PLAN.md`

### Phase 1: Database Schema (3-4 hours) 🔴 START HERE

**Goal:** Add membership tier tracking to database

**Tasks:**
1. Create migration script `V007__add_membership_tier.sql`
2. Add columns: `membership_tier`, `promoted_to_permanent_at`, `invitee_depth`
3. Add indexes for performance
4. Grandfather existing users as "permanent"
5. Test migration on local database

**Deliverables:**
- [ ] Migration SQL file created
- [ ] User entity updated with new fields
- [ ] Migration tested locally
- [ ] Rollback procedure documented

**Testing:**
```bash
cd backend
# Apply migration
mvn flyway:migrate

# Verify schema
psql -U chain_user -d chaindb -c "\d users"

# Check existing users are grandfathered
psql -U chain_user -d chaindb -c "SELECT chain_key, status, membership_tier FROM users LIMIT 10;"
```

**Success Criteria:**
- All existing "active" users have `membership_tier = 'permanent'`
- New columns exist and are indexed
- No data loss
- All existing tests still pass

---

### Phase 2: Core Business Logic (8-10 hours)

**Goal:** Implement the three core algorithms

#### 2.1 Depth-2 Detection (2-3 hours)

**New Method:** `ChainService.checkAndPromoteToPermament(UUID userId)`

**Algorithm:**
```java
1. Get user (must be candidate)
2. Check if user has activeChildId (must have invited someone)
3. Get child user
4. Check if child has activeChildId (depth-2!)
5. If yes → Promote user to permanent
6. Award "Chain Builder" badge
7. Return true
```

**When to call:**
- After every successful registration
- After ticket is used
- Periodically via scheduler (optional)

**Test Scenario:**
```java
// Bob invites Charlie, Charlie invites Diana
Bob (candidate) → Charlie (candidate) → Diana (candidate)
Call: checkAndPromoteToPermament(Bob.id)
Result: Bob becomes permanent ✅
```

---

#### 2.2 Halving Time Window (1 hour)

**New Method:** `TicketService.calculateExpirationTime(User owner)`

**Algorithm:**
```java
int strikeCount = owner.getWastedTicketsCount();
int hours = switch(strikeCount) {
    case 0 -> 24;  // First attempt
    case 1 -> 12;  // Second attempt (halved)
    case 2 -> 6;   // Final attempt (quartered)
    default -> 6;  // Fallback
};
return Instant.now().plusSeconds(hours * 3600L);
```

**Test Scenario:**
```java
User alice = createCandidate();
Ticket t1 = createTicket(alice); // Should be 24h
expireTicket(t1);
Ticket t2 = createTicket(alice); // Should be 12h
expireTicket(t2);
Ticket t3 = createTicket(alice); // Should be 6h
```

---

#### 2.3 Find Last Permanent Member (2-3 hours)

**New Method:** `ChainService.findLastPermanentMember(UUID startingUserId)`

**Algorithm:**
```java
1. Start with current user
2. While user is not permanent/seed:
   3. Get parent
   4. If parent is permanent/seed → return parent
   5. Move to parent, repeat
6. If reached top without finding → return seed as fallback
```

**Test Scenario:**
```java
Chain: Seed (P) → Alice (P) → Bob (C) → Charlie (C) → Diana (C)

findLastPermanentMember(Diana.id) → Should return Alice
findLastPermanentMember(Charlie.id) → Should return Alice
findLastPermanentMember(Bob.id) → Should return Alice
findLastPermanentMember(Alice.id) → Should return Alice (self)
```

---

#### 2.4 Update Reversion Logic (2-3 hours)

**Modify:** `TicketService.expireTicket(UUID ticketId)`

**Current flow:**
```java
if (wastedTicketsCount >= 3) {
    removeUserFromChain(owner);
    // Ticket returns to parent
    createTicketForUser(owner.getParentId());
}
```

**New flow:**
```java
if (wastedTicketsCount >= 3) {
    removeUserFromChain(owner);

    // Find last permanent member
    User lastPermanent = chainService.findLastPermanentMember(owner.getId());

    // Clear their activeChildId
    lastPermanent.setActiveChildId(null);

    // Give them a new ticket
    createTicketForUser(lastPermanent.getId());

    // Award Chain Savior badge
    chainService.checkAndAwardChainSaviorBadge(lastPermanent);
}
```

---

### Phase 3: Testing (4-5 hours)

**Goal:** Ensure new system works correctly

**New Test File:** `CandidatePermanentIntegrationTest.java`

**Test Cases:**
1. ✅ New user starts as candidate
2. ✅ Candidate with depth-1 stays candidate
3. ✅ Candidate with depth-2 becomes permanent
4. ✅ Ticket halving: 24h → 12h → 6h
5. ✅ Failed candidate reverts to last permanent
6. ✅ Walk up multiple candidates to find permanent
7. ✅ Grandfathered users are permanent
8. ✅ Chain Savior badge awarded correctly

**How to run:**
```bash
cd backend
mvn test -Dtest=CandidatePermanentIntegrationTest
mvn test -Dtest=TicketExpirationIntegrationTest
mvn test  # Run all tests
```

---

### Phase 4: Frontend (4-5 hours)

**Goal:** Show candidate/permanent status to users

**Changes Needed:**

1. **Dashboard Badge**
   ```dart
   Widget _buildMembershipBadge(User user) {
     return Container(
       child: Row(
         children: [
           Icon(isPermanent ? Icons.verified : Icons.hourglass_empty),
           Text(isPermanent ? 'PERMANENT' : 'CANDIDATE'),
         ],
       ),
     );
   }
   ```

2. **Variable Time Display**
   ```dart
   Text('Time Remaining: ${ticket.timeRemaining}')
   Text('Attempt ${ticket.attemptNumber}/3')
   if (ticket.nextAttemptDuration != null)
     Text('Next attempt: ${ticket.nextAttemptDuration}')
   ```

---

### Phase 5: Documentation (2-3 hours)

**Goal:** Update all docs to match new system

**Files to Update:**
- [ ] `README.md` - Update rules section
- [ ] `docs/USER_FLOWS.md` - Add depth-2 promotion flow
- [ ] `docs/API_SPECIFICATION.md` - Update response schemas
- [ ] `docs/DATABASE_SCHEMA.md` - Document new columns
- [ ] `docs/MVP_REQUIREMENTS.md` - Update feature descriptions
- [ ] `docs/TESTING_SUMMARY.md` - Update test counts

---

## 🚀 Getting Started: Step-by-Step

### Prerequisites

1. ✅ Java 17+ installed
2. ✅ Maven installed
3. ✅ PostgreSQL running (Docker or local)
4. ✅ Backend tests passing (26/26)
5. ✅ Git working tree clean

### Step 1: Verify Current State (5 min)

```bash
# Check you're in project root
pwd
# Should show: .../ticketz

# Verify backend tests pass
cd backend
mvn test -Dtest=TicketExpirationIntegrationTest
# Should show: Tests run: 6, Failures: 0, Errors: 0, Skipped: 0

# Check git status
git status
# Should be clean or only documentation changes
```

### Step 2: Create Feature Branch (2 min)

```bash
git checkout -b feature/candidate-permanent-system
git push -u origin feature/candidate-permanent-system
```

### Step 3: Start Phase 1 - Database Schema (3-4 hours)

**Task 3.1: Create Migration Script**

```bash
# Create migration file
touch backend/src/main/resources/db/migration/V007__add_membership_tier.sql
```

**Copy this content into V007__add_membership_tier.sql:**

```sql
-- Migration V007: Add membership tier system
-- Date: November 4, 2025
-- Purpose: Support candidate/permanent member distinction

-- Add new columns
ALTER TABLE users
ADD COLUMN membership_tier VARCHAR(20) DEFAULT 'candidate',
ADD COLUMN promoted_to_permanent_at TIMESTAMP WITH TIME ZONE,
ADD COLUMN invitee_depth INTEGER DEFAULT 0;

-- Add indexes
CREATE INDEX idx_users_membership_tier ON users(membership_tier);
CREATE INDEX idx_users_invitee_depth ON users(invitee_depth);

-- Grandfather existing active users as permanent
UPDATE users
SET membership_tier = 'permanent',
    promoted_to_permanent_at = created_at,
    invitee_depth = CASE
        WHEN active_child_id IS NULL THEN 0
        ELSE 2  -- Assume existing users with children are depth-2
    END
WHERE status = 'active';

-- Seed user is always permanent
UPDATE users
SET membership_tier = 'permanent',
    promoted_to_permanent_at = created_at,
    invitee_depth = 2
WHERE status = 'seed';

-- Removed users get NULL membership_tier
UPDATE users
SET membership_tier = NULL
WHERE status = 'removed';

-- Add constraints
ALTER TABLE users
ADD CONSTRAINT check_membership_tier
CHECK (membership_tier IN ('candidate', 'permanent') OR membership_tier IS NULL);

-- Add comments
COMMENT ON COLUMN users.membership_tier IS
'Membership tier: candidate (probationary), permanent (verified depth-2), NULL (removed)';

COMMENT ON COLUMN users.promoted_to_permanent_at IS
'Timestamp when user achieved permanent status by reaching depth-2';

COMMENT ON COLUMN users.invitee_depth IS
'Depth of invitee chain: 0=no child, 1=has child, 2=has grandchild (triggers promotion)';
```

**Task 3.2: Update User Entity**

Edit `backend/src/main/java/com/thechain/entity/User.java`

Add these fields after the existing fields:

```java
@Column(name = "membership_tier")
private String membershipTier = "candidate";

@Column(name = "promoted_to_permanent_at")
private Instant promotedToPermanentAt;

@Column(name = "invitee_depth")
private Integer inviteeDepth = 0;

// Add getters and setters
public String getMembershipTier() {
    return membershipTier;
}

public void setMembershipTier(String membershipTier) {
    this.membershipTier = membershipTier;
}

public Instant getPromotedToPermanentAt() {
    return promotedToPermanentAt;
}

public void setPromotedToPermanentAt(Instant promotedToPermanentAt) {
    this.promotedToPermanentAt = promotedToPermanentAt;
}

public Integer getInviteeDepth() {
    return inviteeDepth;
}

public void setInviteeDepth(Integer inviteeDepth) {
    this.inviteeDepth = inviteeDepth;
}
```

**Task 3.3: Test Migration**

```bash
cd backend

# Run migration
mvn flyway:migrate

# Verify columns exist
psql -U chain_user -d chaindb -c "\d users" | grep membership

# Check grandfathering worked
psql -U chain_user -d chaindb -c "
  SELECT chain_key, status, membership_tier, promoted_to_permanent_at
  FROM users
  LIMIT 10;
"

# Run tests to ensure nothing broke
mvn test -Dtest=TicketExpirationIntegrationTest
```

**Expected Result:**
- ✅ Migration runs successfully
- ✅ New columns exist
- ✅ Existing users have `membership_tier = 'permanent'`
- ✅ All tests still pass

**If something fails:**
```bash
# Rollback
psql -U chain_user -d chaindb -c "
  ALTER TABLE users
  DROP COLUMN IF EXISTS membership_tier,
  DROP COLUMN IF EXISTS promoted_to_permanent_at,
  DROP COLUMN IF EXISTS invitee_depth;
"
```

**Task 3.4: Commit Phase 1**

```bash
git add .
git commit -m "feat: add membership tier database schema (Phase 1)

- Add membership_tier column (candidate/permanent)
- Add promoted_to_permanent_at timestamp
- Add invitee_depth for quick lookups
- Grandfather existing users as permanent
- Add indexes for performance

Part of candidate/permanent member system implementation.
See: AGENT_HANDOFF_CANDIDATE_PERMANENT_SYSTEM.md"

git push origin feature/candidate-permanent-system
```

✅ **Phase 1 Complete!** Move to Phase 2.

---

### Step 4: Continue with Phase 2 (8-10 hours)

See `docs/CANDIDATE_PERMANENT_IMPLEMENTATION_PLAN.md` for detailed Phase 2 instructions.

**Quick checklist:**
- [ ] Implement `ChainService.checkAndPromoteToPermament()`
- [ ] Implement `TicketService.calculateExpirationTime()`
- [ ] Implement `ChainService.findLastPermanentMember()`
- [ ] Update `TicketService.expireTicket()`
- [ ] Update `TicketService.createTicketForUser()`

**Commit after each major method:**
```bash
git add .
git commit -m "feat: implement depth-2 detection (Phase 2.1)"
git push
```

---

## 🧪 Testing Strategy

### Test After Each Phase

Don't wait until the end! Test incrementally:

```bash
# After Phase 1 (Schema)
mvn test  # All existing tests should still pass

# After Phase 2.1 (Depth-2)
mvn test -Dtest=CandidatePermanentIntegrationTest::candidate_InviteeInvitesSomeone_BecomesPermament

# After Phase 2.2 (Halving)
mvn test -Dtest=CandidatePermanentIntegrationTest::ticket_HalvingRule_24h_12h_6h

# After Phase 2.3 (Last Permanent)
mvn test -Dtest=CandidatePermanentIntegrationTest::findLastPermanent_SkipsMultipleCandidates

# After all of Phase 2
mvn test -Dtest=CandidatePermanentIntegrationTest

# Final validation
mvn test  # All tests pass
```

### Manual Testing Checklist

Once backend is complete:

1. **Create new user** → Check they're candidate
2. **User invites someone** → User still candidate
3. **Invitee invites someone** → Original user becomes permanent ✅
4. **Candidate wastes ticket #1** → Gets 12h ticket
5. **Candidate wastes ticket #2** → Gets 6h ticket
6. **Candidate wastes ticket #3** → Removed, ticket goes to last permanent
7. **Check frontend** → Candidate/permanent badges display correctly

---

## ⚠️ Common Pitfalls & Solutions

### Pitfall 1: Forgetting to Update Both User and Invitation

**Problem:** User is promoted but invitation status not updated

**Solution:** Always update both:
```java
user.setMembershipTier("permanent");
userRepository.save(user);

// Also update invitation if needed
invitationRepository.findByChildId(user.getId())
    .ifPresent(invitation -> {
        invitation.setMetadata("promoted_at", Instant.now());
        invitationRepository.save(invitation);
    });
```

---

### Pitfall 2: Infinite Loop in findLastPermanentMember

**Problem:** Chain has circular reference (shouldn't happen but...)

**Solution:** Add MAX_STEPS safety limit:
```java
int steps = 0;
final int MAX_STEPS = 1000;
while (current.getParentId() != null && steps < MAX_STEPS) {
    // ... walk up chain
    steps++;
}
if (steps >= MAX_STEPS) {
    throw new BusinessException("CHAIN_WALK_EXCEEDED", "Chain walk exceeded max depth");
}
```

---

### Pitfall 3: Not Handling Grandfathered Users

**Problem:** Existing users break because they're suddenly candidates

**Solution:** Migration script handles this:
```sql
-- Grandfather existing active users
UPDATE users
SET membership_tier = 'permanent',
    promoted_to_permanent_at = created_at
WHERE status = 'active';
```

---

### Pitfall 4: Frontend Shows Wrong Time

**Problem:** Frontend displays 24h but ticket actually has 6h

**Solution:** Use `timeRemaining` from API, not hardcoded duration:
```dart
final hoursRemaining = ticket.timeRemaining ~/ 3600000;
Text('$hoursRemaining hours remaining')
```

---

## 🔄 Rollback Procedures

### If You Need to Rollback

**Before committing to main:**
```bash
# Discard all changes
git reset --hard origin/main

# Or rollback specific file
git checkout origin/main -- backend/src/main/java/com/thechain/service/TicketService.java
```

**After deploying to production:**

1. **Database Rollback:**
```sql
-- Run rollback script
ALTER TABLE users
DROP COLUMN IF EXISTS membership_tier,
DROP COLUMN IF EXISTS promoted_to_permanent_at,
DROP COLUMN IF EXISTS invitee_depth;

DROP INDEX IF EXISTS idx_users_membership_tier;
DROP INDEX IF EXISTS idx_users_invitee_depth;
```

2. **Code Rollback:**
```bash
git revert <commit-hash>
git push
```

3. **Deploy previous version**

---

## 📊 Progress Tracking

### Phase Completion Checklist

**Phase 1: Database Schema**
- [ ] Migration script created
- [ ] User entity updated
- [ ] Migration tested locally
- [ ] Existing tests pass
- [ ] Committed to feature branch

**Phase 2: Core Logic**
- [ ] Depth-2 detection implemented
- [ ] Halving time window implemented
- [ ] Find last permanent implemented
- [ ] Reversion logic updated
- [ ] Ticket creation rules updated
- [ ] Unit tests written
- [ ] Committed to feature branch

**Phase 3: Testing**
- [ ] Integration tests rewritten
- [ ] All new tests passing
- [ ] Manual testing completed
- [ ] Edge cases validated
- [ ] Committed to feature branch

**Phase 4: Frontend**
- [ ] Membership badges added
- [ ] Variable time display added
- [ ] Attempt counter added
- [ ] UI tested manually
- [ ] Committed to feature branch

**Phase 5: Documentation**
- [ ] README updated
- [ ] API spec updated
- [ ] User flows updated
- [ ] Database schema docs updated
- [ ] Committed to feature branch

**Final Steps**
- [ ] All tests passing
- [ ] Code review completed
- [ ] Merge to main
- [ ] Deploy to staging
- [ ] Staging validation
- [ ] Deploy to production
- [ ] Monitor for 24 hours

---

## 🆘 When to Ask for Help

**Stop and ask the user if:**

1. ❓ Any test fails that you can't fix within 30 minutes
2. ❓ You find a design decision that seems wrong
3. ❓ You discover a missing requirement
4. ❓ You need clarification on business logic
5. ❓ You encounter data that doesn't match expectations
6. ❓ You're about to make a breaking change not in the plan

**Don't:**
- ❌ Assume requirements not in this document
- ❌ Skip tests because "they'll probably pass"
- ❌ Make major architectural changes without asking
- ❌ Deploy to production without staging validation

---

## 📚 Reference Documents

**Required Reading:**
1. ✅ **This document** (you're reading it) - Start here
2. ✅ `docs/CANDIDATE_PERMANENT_IMPLEMENTATION_PLAN.md` - Detailed specs
3. ✅ `docs/DATABASE_SCHEMA.md` - Current schema reference
4. ✅ `docs/API_SPECIFICATION.md` - Current API contracts

**Helpful Context:**
- `docs/USER_FLOWS.md` - Current user flows
- `docs/TESTING_SUMMARY.md` - Current test status
- `CLAUDE_START_HERE.md` - Project context
- `README.md` - Project overview

**Code References:**
- `backend/src/main/java/com/thechain/service/TicketService.java` - Current ticket logic
- `backend/src/main/java/com/thechain/service/ChainService.java` - Current chain logic
- `backend/src/test/java/com/thechain/integration/TicketExpirationIntegrationTest.java` - Current tests

---

## 🎯 Success Metrics

### How to Know You're Done

**Technical Success:**
- [ ] All integration tests pass (will be ~30 tests after rewrite)
- [ ] No compilation errors
- [ ] No regression in existing functionality
- [ ] New features work as specified

**Functional Success:**
- [ ] New users start as candidates ✅
- [ ] Users promoted at depth-2 ✅
- [ ] Ticket time decreases (24h → 12h → 6h) ✅
- [ ] Failed candidates revert to last permanent ✅
- [ ] Frontend shows correct status ✅

**Performance Success:**
- [ ] All tests run in < 2 minutes
- [ ] Migration completes in < 1 minute
- [ ] No N+1 query issues
- [ ] Indexes improve query speed

---

## 💡 Pro Tips for Implementation

### Tip 1: Work in Small Commits

**Good:**
```bash
git commit -m "feat: add membership_tier column to users table"
git commit -m "feat: implement depth-2 detection logic"
git commit -m "test: add integration test for candidate promotion"
```

**Bad:**
```bash
git commit -m "feat: implement entire candidate/permanent system"
```

### Tip 2: Test One Thing at a Time

Don't implement all of Phase 2 then test. Instead:
```
Implement method → Write test → Run test → Fix issues → Commit → Next method
```

### Tip 3: Use Descriptive Logs

```java
log.info("🎉 User {} PROMOTED to PERMANENT (depth-2 achieved at position {})",
         user.getChainKey(), user.getPosition());

log.warn("⚠️ Candidate {} failed (strike {}/3), reverting to last permanent {}",
         candidate.getChainKey(), candidate.getWastedTicketsCount(), lastPermanent.getChainKey());
```

This makes debugging much easier!

### Tip 4: Keep a Testing Log

Create a file `IMPLEMENTATION_LOG.md` and track:
```markdown
## Nov 4, 2025 - 10:00 AM
- Started Phase 1
- Created migration script
- Issue: Flyway couldn't connect (fixed: wrong DB name)
- Status: Migration successful ✅

## Nov 4, 2025 - 11:30 AM
- Started Phase 2.1
- Implemented checkAndPromoteToPermament()
- Test passed ✅
- Committed: abc123f
```

---

## 🚀 Ready to Start?

**Your first commands:**

```bash
# 1. Verify environment
cd backend
mvn test -Dtest=TicketExpirationIntegrationTest
# Should pass: 6/6 tests

# 2. Create feature branch
git checkout -b feature/candidate-permanent-system

# 3. Start Phase 1
touch backend/src/main/resources/db/migration/V007__add_membership_tier.sql

# 4. Open the migration file and copy content from Step 3 above
code backend/src/main/resources/db/migration/V007__add_membership_tier.sql
```

---

## 📞 Contact & Questions

**If you're a human developer:**
- Ask the product owner for clarification
- Reference this document and the detailed plan

**If you're an AI agent:**
- Ask the user for clarification before making assumptions
- Reference line numbers from this document when asking questions
- Provide specific code snippets when asking for approval

---

**Last Updated:** November 4, 2025
**Document Version:** 1.0
**Status:** ✅ Ready for implementation

**Good luck! You've got this! 🚀**

---

## 📋 Quick Reference Card

**Print this section for quick reference:**

```
┌─────────────────────────────────────────────────────────┐
│  CANDIDATE/PERMANENT SYSTEM - QUICK REFERENCE           │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  🎯 GOAL: Two-tier membership with progression         │
│                                                         │
│  KEY CHANGES:                                           │
│  1. New status: candidate → permanent                  │
│  2. Promotion: depth-2 (your invitee invites)         │
│  3. Time: 24h → 12h → 6h (halving)                    │
│  4. Revert: To last permanent (not just parent)       │
│                                                         │
│  PHASES:                                                │
│  ✅ Phase 1: Database (3-4h)                           │
│  ✅ Phase 2: Logic (8-10h)                             │
│  ✅ Phase 3: Tests (4-5h)                              │
│  ✅ Phase 4: Frontend (4-5h)                           │
│  ✅ Phase 5: Docs (2-3h)                               │
│                                                         │
│  START: Step 3 - Create V007 migration                │
│  DOCS: CANDIDATE_PERMANENT_IMPLEMENTATION_PLAN.md     │
│                                                         │
│  ⚠️ BEFORE ASKING:                                     │
│  - Check this doc first                                │
│  - Check detailed plan                                 │
│  - Check existing code                                 │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

**Now go build something amazing! 🎨**
