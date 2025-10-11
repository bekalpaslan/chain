# Chain Visualization Scenarios & Logic

## Core Principle: Always Show 5 Members
- Current user in the CENTER (position 3) when possible
- 2 above, 2 below for context
- Ellipsis indicators for compressed sections

## Visualization Scenarios

### Scenario 1: Single User (Seed Only)
**Total Chain: 1 user**
```
Position 1: SEED (YOU) [Active/Green]
```
- No connections shown
- Special "Genesis" badge
- Message: "You are the beginning of The Chain"

### Scenario 2: Two Users
**Total Chain: 2 users**
```
Position 1: SEED [Active/Green]
     ↓
Position 2: YOU [Purple highlight]
```
- Simple parent-child relationship
- No ellipsis needed
- Direct connection line

### Scenario 3: Three Users
**Total Chain: 3 users**
```
Position 1: Grandparent [Active/Green]
     ↓
Position 2: Parent [Active/Green]
     ↓
Position 3: YOU [Purple highlight]
```
- Full chain visible
- No compression needed

### Scenario 4: Four Users
**Total Chain: 4 users**
```
Position 1: Great-grandparent [Active/Green]
     ↓
Position 2: Grandparent [Active/Green]
     ↓
Position 3: Parent [Active/Green]
     ↓
Position 4: YOU (TIP) [Emerald glow - Can invite]
```
- User is the TIP (can invite)
- Full chain visible

### Scenario 5: Five Users (Perfect Fit)
**Total Chain: 5 users**
**User Position: 3 (middle)**
```
Position 1: Grandparent [Active/Green]
     ↓
Position 2: Parent [Active/Green]
     ↓
Position 3: YOU [Purple highlight]
     ↓
Position 4: Child (TIP) [Emerald glow]
     ↓
Position 5: [Ghost - Waiting for invitation]
```
- Perfect 5-member window
- User centered
- Shows full context

### Scenario 6: Six to Eight Users
**Total Chain: 6-8 users**
**User Position: 4**
```
Position 2: [Active/Green]
     ↓
Position 3: Parent [Active/Green]
     ↓
Position 4: YOU [Purple highlight]
     ↓
Position 5: Child [Active/Green]
     ↓
Position 6: Grandchild (TIP) [Emerald glow]
```
- Adjust window to keep 5 visible
- May not be perfectly centered

### Scenario 7: Many Users (e.g., 100)
**Total Chain: 100 users**
**User Position: 37**
```
Position 1: Genesis [Seed badge]
     ⋮ (34 members)
Position 35: [Active/Green]
     ↓
Position 36: Parent [Active/Green]
     ↓
Position 37: YOU [Purple highlight]
     ↓
Position 38: Child [Active/Green]
     ↓
Position 39: Grandchild [Active/Green]
     ⋮ (60 members)
Position 100: Current TIP [Emerald glow]
```

### Scenario 8: Edge Cases

#### 8a: User Near Start (Position 2 of 100)
```
Position 1: Genesis [Seed badge]
     ↓
Position 2: YOU [Purple highlight]
     ↓
Position 3: Child [Active/Green]
     ↓
Position 4: Grandchild [Active/Green]
     ↓
Position 5: Great-grandchild [Active/Green]
     ⋮ (94 members)
Position 100: Current TIP [Emerald glow]
```

#### 8b: User Near End (Position 98 of 100)
```
Position 1: Genesis [Seed badge]
     ⋮ (94 members)
Position 96: [Active/Green]
     ↓
Position 97: Parent [Active/Green]
     ↓
Position 98: YOU [Purple highlight]
     ↓
Position 99: Child [Active/Green]
     ↓
Position 100: Grandchild (TIP) [Emerald glow]
```

#### 8c: User IS the TIP (Position 100 of 100)
```
Position 1: Genesis [Seed badge]
     ⋮ (95 members)
Position 97: [Active/Green]
     ↓
Position 98: Great-grandparent [Active/Green]
     ↓
Position 99: Grandparent [Active/Green]
     ↓
Position 100: YOU (TIP) [Purple + Emerald glow]
     ↓
[Ghost slot - Waiting for your invitation]
```

## Ellipsis Link Component Design

### Visual Design
```
     ⋮
[34 members]
     ⋮
```
- Dotted vertical line with fade gradient
- Centered count badge
- Semi-transparent background
- Subtle pulse animation
- Click to expand (future feature)

### Properties
- `memberCount`: Number of hidden members
- `isAbove`: Direction (above/below current view)
- `onTap`: Optional expansion handler

## Window Calculation Algorithm

```dart
List<ChainMember> calculateVisibleWindow(
  List<ChainMember> allMembers,
  int currentUserPosition,
  int totalChainLength,
) {
  const int WINDOW_SIZE = 5;

  // Special cases for small chains
  if (totalChainLength <= WINDOW_SIZE) {
    return allMembers;
  }

  // Calculate optimal window
  int startIdx, endIdx;

  // Try to center user (position 3 of 5)
  int idealStart = currentUserPosition - 2;
  int idealEnd = currentUserPosition + 2;

  // Adjust for boundaries
  if (idealStart < 1) {
    // User near beginning
    startIdx = 1;
    endIdx = WINDOW_SIZE;
  } else if (idealEnd > totalChainLength) {
    // User near end
    startIdx = totalChainLength - WINDOW_SIZE + 1;
    endIdx = totalChainLength;
  } else {
    // User in middle - perfect centering
    startIdx = idealStart;
    endIdx = idealEnd;
  }

  // Add ghost slot if viewing the tip
  if (endIdx == totalChainLength) {
    // Include ghost position after tip
    endIdx++;
  }

  return filterMembers(allMembers, startIdx, endIdx);
}
```

## Status Indicators

### Member Types & Colors
1. **Genesis/Seed** (Position 1)
   - Gold gradient border
   - Special "🌱" badge
   - "The Beginning" label

2. **Active Members**
   - Green status indicator
   - Standard card design
   - Show chain key

3. **Current User**
   - Purple gradient highlight
   - Pulse animation
   - "YOU" badge

4. **The TIP** (Last active)
   - Emerald green glow
   - Lightning bolt icon ⚡
   - "Can Invite" label
   - Special TipPersonCard widget

5. **Ghost Slot**
   - Blurred/transparent
   - Dashed border
   - "Waiting for invitation..."

6. **Pending** (Invited but not joined)
   - Yellow/amber glow
   - Clock icon ⏰
   - "Invitation sent" label

## Interaction Features

### Tappable Elements
1. **Ellipsis sections**: Show tooltip with range (e.g., "Members #3 to #36")
2. **Member cards**: View profile (future)
3. **TIP card**: Show invitation QR code
4. **Ghost slot**: Prompt to wait for tip's action

### Animations
1. **Entry**: Staggered fade-in from top
2. **Pulse**: Current user card
3. **Glow**: TIP member card
4. **Shimmer**: Ellipsis indicators

## Responsive Design

### Mobile (Default)
- Full width cards
- Vertical layout
- Touch-friendly tap targets

### Tablet/Desktop
- Max width: 600px
- Centered container
- Enhanced shadows

### Accessibility
- High contrast mode support
- Screen reader descriptions
- Keyboard navigation
- Focus indicators

## Implementation Priority

1. ✅ Basic 5-member window
2. 🔄 Ellipsis link widget
3. 🔄 Window calculation algorithm
4. 🔄 Special status cards (TIP, Ghost)
5. ⏳ Animations and transitions
6. ⏳ Interaction handlers
7. ⏳ Responsive breakpoints
8. ⏳ Accessibility features