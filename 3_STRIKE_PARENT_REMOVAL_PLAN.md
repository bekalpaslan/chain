# 3-Strike Parent Removal System - Implementation Plan

## Executive Summary

The current implementation is **missing a critical business rule**: Parents should be removed after **3 of their children fail** (get removed from the chain). This document outlines the complete implementation plan.

---

## Current vs. Correct Understanding

### ❌ Current (Incorrect) Implementation:
- User wasted 3 tickets → User removed
- Only tracks individual's own ticket failures
- No cascading removal based on children's failures

### ✅ Correct Business Rule:
- **User's 3 children fail** → User removed
- Failures cascade upward through parent chain
- Chain Savior badge awarded when parent recovers after child failures

---

## Complete Scenario Walkthrough

### Example: A → B → C → D → E → F

```
Step 1: Initial Chain Building
├─ A (seed) invites B ✅
├─ B invites C ✅
└─ Chain: A → B → C

Step 2: C Fails (Strike 1 for B)
├─ C wastes 3 tickets → C REMOVED
├─ Chain reverts to B (B becomes tip)
├─ B.wastedChildIds = [C]
└─ Chain: A → B (C removed)

Step 3: B invites D
├─ B invites D ✅
└─ Chain: A → B → D

Step 4: D Fails (Strike 2 for B)
├─ D wastes 3 tickets → D REMOVED
├─ Chain reverts to B (B becomes tip again)
├─ B.wastedChildIds = [C, D]
└─ Chain: A → B (C, D removed)

Step 5: B invites E
├─ B invites E ✅
└─ Chain: A → B → E

Step 6: E Fails (Strike 3 for B) → B IS REMOVED!
├─ E wastes 3 tickets → E REMOVED
├─ B.wastedChildIds = [C, D, E]
├─ B has 3 wasted children → B IS REMOVED
├─ Chain reverts to A (A becomes tip)
├─ A.wastedChildIds = [B]
└─ Chain: A (B, C, D, E all removed)

Step 7: A Saves the Chain! 🏆
├─ A invites F ✅
├─ F successfully joins
├─ A receives CHAIN SAVIOR badge
│  └─ Reason: A recovered from B's removal, prevented chain death
└─ Chain: A → F
```

---

## Data Model

### User Entity
```java
class User {
    UUID id;
    UUID parentId;                    // Direct parent reference
    UUID activeChildId;               // Current active child

    // Transient field - computed from Invitations table
    List<UUID> wastedChildIds;        // Children who were removed

    // NOT used for parent removal
    Integer wastedTicketsCount;       // User's own wasted tickets (for individual removal)
}
```

### Invitation Entity (Relational Storage)
```java
class Invitation {
    UUID id;
    UUID parentId;
    UUID childId;
    UUID ticketId;
    InvitationStatus status;          // ACTIVE | REMOVED | REVERTED
    Instant invitedAt;
    Instant acceptedAt;
}
```

### Removal Tracking
```sql
-- Get wasted children for a parent
SELECT child_id
FROM invitations
WHERE parent_id = ? AND status = 'REMOVED'

-- Count: 0-2 children failed = warning
-- Count: 3 children failed = parent removed
```

---

## Implementation Plan

### Phase 1: Repository Updates ✅ (DONE)

**InvitationRepository.java**
```java
@Query("SELECT i.childId FROM Invitation i WHERE i.parentId = :parentId AND i.status = 'REMOVED'")
List<UUID> findWastedChildIdsByParentId(@Param("parentId") UUID parentId);
```

### Phase 2: ChainService - Add Parent Removal Check

**Method 1: Check for 3-Strike Parent Removal**
```java
/**
 * Check if parent should be removed due to 3 failed children
 * Called when a child is removed from the chain
 *
 * Business Rule: If a user's 3 children are removed → user is removed
 * This creates a cascading removal effect up the chain
 */
@Transactional
public void checkParentRemovalFor3Strikes(UUID removedChildId) {
    // Find the invitation record for the removed child
    invitationRepository.findByChildId(removedChildId)
        .ifPresent(invitation -> {
            UUID parentId = invitation.getParentId();

            // Count how many children this parent has wasted
            List<UUID> wastedChildren = invitationRepository
                .findWastedChildIdsByParentId(parentId);

            if (wastedChildren.size() >= 3) {
                // Parent has 3 wasted children → REMOVE PARENT
                userRepository.findById(parentId).ifPresent(parent -> {
                    log.warn("Parent {} has 3 failed children - REMOVING FROM CHAIN",
                             parent.getChainKey());

                    // Mark parent as removed
                    parent.setStatus("removed");
                    parent.setRemovalReason(RemovalReason.WASTED.name());
                    parent.setRemovedAt(Instant.now());
                    userRepository.save(parent);

                    // Update parent's invitation to REMOVED status
                    invitationRepository.findByChildId(parentId)
                        .ifPresent(parentInvitation -> {
                            parentInvitation.setStatus(InvitationStatus.REMOVED);
                            invitationRepository.save(parentInvitation);
                        });

                    // Chain reverts to grandparent
                    if (parent.getParentId() != null) {
                        userRepository.findById(parent.getParentId())
                            .ifPresent(grandparent -> {
                                grandparent.setActiveChildId(null);
                                userRepository.save(grandparent);

                                log.info("Chain reverted to grandparent {} after parent removal",
                                         grandparent.getChainKey());
                            });
                    }

                    // RECURSIVE: Check if grandparent should also be removed
                    // (grandparent might now have 3 failed children including this parent)
                    if (parent.getParentId() != null) {
                        checkParentRemovalFor3Strikes(parentId);
                    }
                });
            } else {
                log.info("Parent has {} failed children (warning: {}/3)",
                         wastedChildren.size(), wastedChildren.size());
            }
        });
}
```

**Method 2: Fix Chain Savior Badge Logic**
```java
/**
 * Check if user should earn Chain Savior badge
 * Called after successful invitation of a NEW child
 *
 * Chain Savior Badge Criteria:
 * - User's previous child(ren) were removed from chain
 * - User successfully invited someone new after reversion
 * - This stops the chain from dying/regressing further
 *
 * Example: A's child B is removed. A invites F successfully → A gets badge
 */
@Transactional
public void checkAndAwardChainSaviorBadge(User user) {
    if (user.getActiveChildId() != null) {
        // Get list of this user's removed children
        List<UUID> wastedChildren = invitationRepository
            .findWastedChildIdsByParentId(user.getId());

        if (!wastedChildren.isEmpty()) {
            // User had failed children but recovered by inviting someone new
            // This is a "chain save" - prevented further regression

            Map<String, Object> context = new HashMap<>();
            context.put("collapse_depth", wastedChildren.size());
            context.put("removed_children_count", wastedChildren.size());

            awardBadge(user.getId(), Badge.CHAIN_SAVIOR, context);

            log.info("🏆 CHAIN SAVIOR badge awarded to {} after recovering from {} failed children",
                     user.getChainKey(), wastedChildren.size());
        }
    }
}
```

### Phase 3: TicketService - Integrate Parent Removal Check

**Update removeUserFromChain() method**
```java
private void removeUserFromChain(User user) {
    UUID parentId = user.getParentId();
    Integer userPosition = user.getPosition();

    // 1. Mark user as removed
    user.setStatus("removed");
    user.setRemovedAt(Instant.now());
    user.setRemovalReason(RemovalReason.WASTED.name());
    user.setWastedTicketsCount(0);
    userRepository.save(user);

    // 2. Update invitation status to REMOVED
    invitationRepository.findByChildId(user.getId())
        .ifPresent(invitation -> {
            invitation.setStatus(InvitationStatus.REMOVED);
            invitationRepository.save(invitation);
        });

    // 3. If user has a parent, trigger chain reversion
    if (parentId != null) {
        userRepository.findById(parentId).ifPresent(parent -> {
            // Clear parent's activeChildId (they lost their child)
            parent.setActiveChildId(null);
            userRepository.save(parent);

            log.info("Chain reverted: Parent {} lost child at position {}",
                     parent.getChainKey(), userPosition);
        });

        // 4. CHECK IF PARENT SHOULD BE REMOVED (3-strike rule)
        chainService.checkParentRemovalFor3Strikes(user.getId());
    }

    log.info("User {} at position {} removed from chain", user.getChainKey(), userPosition);
}
```

### Phase 4: AuthService - Award Chain Savior Badge

**Update register() method**
```java
@Transactional
public AuthResponse register(RegisterRequest request) {
    // ... existing registration logic ...

    // Update parent's activeChildId
    parent.setActiveChildId(newUser.getId());
    userRepository.save(parent);

    // Mark ticket as used
    ticket.setStatus(Ticket.TicketStatus.USED);
    ticket.setUsedAt(now);
    ticket.setClaimedBy(newUser.getId());
    ticket.setClaimedAt(now);
    ticketRepository.save(ticket);

    // Create invitation record
    Invitation invitation = Invitation.builder()
            .parentId(parent.getId())
            .childId(newUser.getId())
            .ticketId(ticket.getId())
            .status(InvitationStatus.ACTIVE)
            .acceptedAt(Instant.now())
            .build();
    invitationRepository.save(invitation);

    // ✨ NEW: Check if parent deserves Chain Savior badge
    chainService.checkAndAwardChainSaviorBadge(parent);

    log.info("New user registered: {} at position {}", newUser.getChainKey(), newUser.getPosition());

    // ... return tokens ...
}
```

---

## Cascading Removal Examples

### Example 1: Single Parent Removal
```
Before:
A → B → C → D → E
    ├─ C removed (strike 1)
    ├─ D removed (strike 2)
    └─ E removed (strike 3)

After E removed:
├─ B has 3 wasted children [C, D, E]
├─ B is REMOVED
└─ Chain: A (tip)

If A invites F:
└─ A receives CHAIN SAVIOR badge
```

### Example 2: Cascading Multi-Level Removal
```
Before:
A → B → C → D → E → F → G

Sequence:
1. C fails → B.wastedChildren = [C]
2. D fails → B.wastedChildren = [C, D]
3. E fails → B.wastedChildren = [C, D, E] → B REMOVED
4. Now A.wastedChildren = [B]
5. F fails → A would need 2 more failures to be removed
```

### Example 3: Chain Death Prevention
```
Scenario: Seed's child fails
A (seed) → B → C → D
           ├─ C removed
           ├─ D removed
           └─ E removed (B has 3 strikes)

Result:
├─ B is REMOVED
├─ A.wastedChildren = [B]
├─ A invites F → SUCCESS
└─ A receives CHAIN SAVIOR badge (saved from death)
```

---

## Edge Cases & Handling

### 1. Seed User Protection
```java
// In checkParentRemovalFor3Strikes()
if ("seed".equals(parent.getStatus())) {
    log.warn("Seed user {} has 3 failed children but cannot be removed",
             parent.getChainKey());
    // Seed is immortal - log warning but don't remove
    return;
}
```

### 2. Rapid Cascading Removal
```java
// Recursive call handles cascading
checkParentRemovalFor3Strikes(parentId);
// This will check grandparent, great-grandparent, etc.
```

### 3. Badge Award Timing
- Award badge AFTER new child successfully joins
- Not when parent becomes tip (too early)
- Only if parent had previous failures

### 4. Multiple Badge Awards
```java
// In awardBadge() - check if already awarded
if (userBadgeRepository.existsByUserIdAndBadgeType(userId, badgeType)) {
    log.info("Badge {} already awarded to user {}", badgeType, userId);
    return; // Don't award twice
}
```

---

## Testing Strategy

### Unit Tests Required

**ChainServiceTest.java**
```java
@Test
void parentRemoval_After3FailedChildren_RemovesParent()

@Test
void parentRemoval_CascadesUpToGrandparent()

@Test
void parentRemoval_SeedIsImmune()

@Test
void chainSaviorBadge_AwardedAfterRecovery()

@Test
void chainSaviorBadge_NotAwardedWithoutFailures()
```

### Integration Tests Required

**ParentRemovalIntegrationTest.java**
```java
@Test
void completeFlow_3ChildrenFail_ParentRemoved_ChainReverts()

@Test
void completeFlow_ParentRecovery_ChainSaviorAwarded()

@Test
void cascadingRemoval_MultipleGenerations()
```

### Manual Test Scenarios
1. Create chain: A → B → C
2. Remove C (B has 1 strike)
3. B invites D, remove D (B has 2 strikes)
4. B invites E, remove E (B has 3 strikes → B removed)
5. Verify A becomes tip
6. A invites F
7. Verify A receives Chain Savior badge

---

## Database Queries for Debugging

### Check Parent's Wasted Children
```sql
SELECT u.display_name as parent,
       u2.display_name as child,
       i.status
FROM users u
JOIN invitations i ON i.parent_id = u.id
JOIN users u2 ON u2.id = i.child_id
WHERE u.id = ?
ORDER BY i.invited_at;
```

### Count Wasted Children
```sql
SELECT u.display_name,
       COUNT(CASE WHEN i.status = 'REMOVED' THEN 1 END) as wasted_children
FROM users u
LEFT JOIN invitations i ON i.parent_id = u.id
GROUP BY u.id, u.display_name
HAVING COUNT(CASE WHEN i.status = 'REMOVED' THEN 1 END) > 0;
```

### Find Users At Risk (2 strikes)
```sql
SELECT u.chain_key, u.display_name,
       COUNT(*) as failed_children_count
FROM users u
JOIN invitations i ON i.parent_id = u.id
WHERE i.status = 'REMOVED'
  AND u.status = 'active'
GROUP BY u.id
HAVING COUNT(*) = 2;
```

---

## Rollout Plan

### Step 1: Update ChainService ✅
- Add `checkParentRemovalFor3Strikes()` method
- Fix `checkAndAwardChainSaviorBadge()` method
- Add proper logging

### Step 2: Update TicketService ✅
- Call parent removal check in `removeUserFromChain()`
- Ensure invitation status updated to REMOVED

### Step 3: Update AuthService ✅
- Call badge check in `register()` after successful join
- Create invitation record with proper status

### Step 4: Add Tests ✅
- Unit tests for ChainService methods
- Integration tests for complete flows
- Edge case testing (seed, cascading, etc.)

### Step 5: Update Documentation ✅
- Update IMPLEMENTATION_STATUS.md
- Update ANALYSIS_CURRENT_STATUS.md
- Add this plan to docs/

### Step 6: Deploy & Monitor 🚀
- Deploy to staging
- Monitor parent removal events
- Monitor badge awards
- Check for cascade issues

---

## Success Metrics

### After Implementation:
✅ Parents removed after 3 child failures
✅ Chain reversion works correctly
✅ Chain Savior badges awarded appropriately
✅ Cascading removal functions properly
✅ Seed user protected from removal
✅ No infinite loops in cascading
✅ All tests passing

---

## Dependencies & Prerequisites

### Required First:
1. ✅ InvitationRepository.findWastedChildIdsByParentId() (DONE)
2. ✅ RemovalReason enum (DONE)
3. ✅ User.activeChildId field (DONE)
4. ⏳ ChainService alignment fixes (IN PROGRESS)
5. ⏳ AuthService alignment fixes (IN PROGRESS)

### Can Implement After:
- Badge system fully functional
- Notification system for warnings (2 strikes)
- Admin dashboard for monitoring
- Analytics for removal patterns

---

## Questions & Decisions

### Q1: What happens if seed's 3 children fail?
**A:** Seed cannot be removed. Log warning. Seed gets infinite chances.

### Q2: Should we notify users at 1 or 2 strikes?
**A:** Yes - send warning notifications:
- Strike 1: "⚠️ Your child was removed. 2 more failures = removal"
- Strike 2: "🚨 2 children failed. 1 more = removal from chain"

### Q3: Can removed parents rejoin?
**A:** No - removal is permanent. They can view chain as observers.

### Q4: Badge awarded every time or just once?
**A:** Just once. Check `userBadgeRepository.exists()` before awarding.

### Q5: What if grandparent is already removed?
**A:** Cascade stops. Chain regresses to first active ancestor.

---

## Next Steps

1. **Review this plan** with team ✅
2. **Implement ChainService updates** (checkParentRemovalFor3Strikes)
3. **Update TicketService** (call parent check)
4. **Update AuthService** (award badge)
5. **Write comprehensive tests**
6. **Update documentation**
7. **Deploy and monitor**

---

**Generated:** October 9, 2025
**Status:** Plan Complete - Ready for Implementation
**Priority:** HIGH - Critical Business Rule Missing
**Estimated Effort:** 4-6 hours (code + tests + docs)
