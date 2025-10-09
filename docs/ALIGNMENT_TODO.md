# Code Alignment TODO - Simplified User Model

## Summary
User entity has been simplified to use UUID-based parent-child relationships instead of position-based tracking.

## Completed Changes ✅

### 1. User.java (DO NOT MODIFY)
- Uses `parentId` and `activeChildId` (UUID) instead of `inviterPosition`/`inviteePosition` (Integer)
- Field `associatedWith` instead of `belongsTo`
- Removed fields: `isGuest`, `realName`, `avatarEmoji`, `lastActiveAt`, all location fields, phone fields, country/display name change tracking
- New field: `wastedChildIds` (List<UUID>) - stored relationally in Invitations table
- Comment: "TO-CLAUDE: Find a way to store this in DB relationally" → Solution: Use InvitationRepository.findWastedChildIdsByParentId()

### 2. RemovalReason Enum ✅
- Created enum with single value: `WASTED`
- Located: `backend/src/main/java/com/thechain/entity/RemovalReason.java`

### 3. RegisterRequest.java ✅
- Removed location fields: `shareLocation`, `latitude`, `longitude`

### 4. Invitation.java ✅
- Updated to use `parentId` and `childId` (UUID) instead of `inviterPosition`/`inviteePosition`
- Updated indexes accordingly

### 5. InvitationRepository.java ✅
- Updated all methods to use `parentId`/`childId` instead of positions
- Added method: `findWastedChildIdsByParentId()` - returns List<UUID> of removed children
- This provides relational storage for User.wastedChildIds

### 6. UserRepository.java ✅
- Fixed query: `belongsTo` → `associatedWith`

### 7. TicketService.java ✅
- Added import: `RemovalReason`
- Updated `removeUserFromChain()`:
  - Uses `parentId` instead of `inviterPosition`
  - Uses `setActiveChildId(null)` instead of `setInviteePosition(null)`
  - Uses `RemovalReason.WASTED.name()`

## Remaining Work 🔧

### 8. ChainService.java ❌
**Location:** `backend/src/main/java/com/thechain/service/ChainService.java`

**Errors to fix:**
- Line 58, 60: `getInviteePosition()` → use `activeChildId` and check Invitations table
- Line 91, 92: `getInviterPosition()` → use `parentId`
- Line 97, 98: `getInviteePosition()` → use `activeChildId`
- Line 170: `findByInviteePosition()` → `findByChildId()`
- Line 178, 179: `getInviterPosition()` → `getParentId()`
- Line 196: `setInviteePosition(null)` → `setActiveChildId(null)`
- Line 235: `getInviteePosition()` → `getActiveChildId()`
- Line 284: `getAvatarEmoji()` → Remove (field doesn't exist anymore)

**Methods that need rewriting:**
1. `getCurrentTip()` - Find user with highest position where `activeChildId == null`
2. `getVisibleUsers()` - Use `parentId` and `activeChildId` for lookups
3. All methods using position-based navigation

### 9. AuthService.java ❌
**Location:** `backend/src/main/java/com/thechain/service/AuthService.java`

**Errors to fix:**
- Line 62: `getInviteePosition()` → `getActiveChildId()`
- Line 83: `setInviteePosition()` → `setActiveChildId()`

**Updates needed:**
```java
// OLD:
if (parent.getInviteePosition() != null) {
    throw new BusinessException(...);
}

// NEW:
if (parent.getActiveChildId() != null) {
    throw new BusinessException(...);
}

// OLD:
parent.setInviteePosition(newUser.getPosition());

// NEW:
parent.setActiveChildId(newUser.getId());
```

### 10. Integration Tests ❌
**Location:** `backend/src/test/java/com/thechain/integration/`

**Files affected:**
- `ChainReversionIntegrationTest.java` - Heavily uses position-based relationships
- `JwtAuthenticationIntegrationTest.java` - Line 359 uses `inviteePosition`
- `TicketExpirationIntegrationTest.java` - Line 125 uses `inviteePosition`

**Required changes:**
1. Replace all `inviterPosition`/`inviteePosition` with `parentId`/`activeChildId`
2. Update Invitation.builder() calls to use new field names
3. Update assertions to check activeChildId instead of positions

### 11. Unit Tests ❌
**Location:** `backend/src/test/java/com/thechain/entity/UserTest.java`

**Required changes:**
- Update all tests to use simplified User model
- Remove tests for deleted fields
- Add tests for activeChildId and wastedChildIds retrieval

## Database Migration Required ⚠️

The V2 migration needs to be updated to match the new model:

### Tables to Update:
1. **users** table:
   - Rename: `inviter_position` → remove
   - Rename: `invitee_position` → remove
   - Add: `active_child_id` UUID column
   - Remove columns: `is_guest`, `real_name`, `avatar_emoji`, `last_active_at`, location fields, phone fields, country change tracking

2. **invitations** table:
   - Rename: `inviter_position` → `parent_id` (UUID)
   - Rename: `invitee_position` → `child_id` (UUID)
   - Update indexes

## Key Architectural Changes

### Parent-Child Relationship Model:

**OLD (Position-based):**
```
User {
  inviterPosition: Integer  // Position of parent
  inviteePosition: Integer  // Position of active child
}
```

**NEW (UUID-based):**
```
User {
  parentId: UUID           // Direct reference to parent
  activeChildId: UUID      // Direct reference to active child
  wastedChildIds: List<UUID> // Computed from Invitations table
}

Invitation {
  parentId: UUID
  childId: UUID
  status: ACTIVE | REMOVED | REVERTED
}
```

### Benefits of New Model:
1. ✅ Simpler lookups (UUID primary key instead of position index)
2. ✅ No need to maintain position-based indexes
3. ✅ Direct parent-child navigation
4. ✅ Relational storage of wasted children via Invitations table
5. ✅ Better data integrity with foreign key constraints

### WastedChildIds Retrieval:
```java
// In any service that needs wastedChildIds:
List<UUID> wastedChildIds = invitationRepository.findWastedChildIdsByParentId(user.getId());
user.setWastedChildIds(wastedChildIds); // If needed for DTOs
```

## Testing Strategy

After fixes are complete:
1. Run unit tests: `mvn test -Dtest="*Test"`
2. Run integration tests: `mvn test -Dtest="*IntegrationTest"`
3. Manual QA of chain mechanics
4. Verify 3-strike removal still works
5. Verify chain reversion logic

## Documentation Updates Needed

1. **IMPLEMENTATION_STATUS.md**:
   - Document simplified User model
   - Update entity relationship diagrams
   - Note removal of position-based tracking

2. **ANALYSIS_CURRENT_STATUS.md**:
   - Update User attributes section
   - Document parent-child UUID model
   - Update visibility logic (±1 still works, just uses UUIDs)

3. **API Documentation**:
   - Update response DTOs to use `activeChildId` instead of `inviteePosition`
   - Update request DTOs if needed

## Next Steps

1. Fix ChainService.java
2. Fix AuthService.java
3. Update integration tests
4. Update unit tests
5. Update V2 database migration
6. Run full test suite
7. Update documentation
8. Commit changes per logical unit

---
Generated: October 9, 2025
Status: In Progress - Services need updating
