# Person Card Design System for The Chain

## Visual Hierarchy & Card Types

### 1. 🌱 **Genesis Card** (Position #1)
**Purpose**: The original seed member who started The Chain
```
Visual Design:
- Background: Gold gradient (#FFD700 → #FFA500)
- Border: 2px solid gold with shimmer effect
- Icon: 🌱 Seed icon in top-left corner
- Avatar: Gold ring with white center
- Text: "Genesis" label below name
- Animation: Subtle golden pulse (slow, dignified)
- Shadow: Warm gold glow

Status Indicator: Gold dot
Special Badge: "THE BEGINNING" in small caps
```

### 2. ✅ **Active Member Card** (Regular members)
**Purpose**: Standard members who have joined and can see the chain
```
Visual Design:
- Background: Dark gradient (#1F2937 → #111827) with 60% opacity
- Border: 1px solid white at 10% opacity
- Avatar: Gray gradient (#4B5563 → #374151)
- Text: White name, gray chain key
- Animation: None (static)
- Shadow: Subtle black shadow

Status Indicator: Green dot (#10B981)
Position Badge: Gray background (#374151)
```

### 3. ⭐ **Current User Card** (YOU)
**Purpose**: Highlight the logged-in user's position
```
Visual Design:
- Background: Purple gradient (#7C3AED → #5B21B6) at 20% opacity
- Border: 1.5px solid purple (#7C3AED) at 50% opacity
- Avatar: Purple gradient with white text
- Text: White name with slight glow
- Animation: Gentle pulse (breathing effect)
- Shadow: Purple glow (#7C3AED at 30% opacity)

Status Indicator: Purple dot
Special Badge: "YOU" in white on purple background
```

### 4. ⚡ **TIP Card** (Active chain holder)
**Purpose**: The only person who can currently invite someone new
```
Visual Design:
- Background: Emerald gradient (#10B981 → #059669)
- Border: 2px solid with animated color shift (emerald → cyan)
- Avatar: Emerald with pulsing outer glow
- Text: White with high contrast
- Animation:
  - Pulse animation (scale 1.0 → 1.05)
  - Glow animation (opacity 0.3 → 0.6)
  - Background chain pattern animation
- Shadow: Emerald glow with high spread

Status Indicator: Lightning bolt ⚡
Special Badges:
  - "TIP" badge with flash icon
  - "Can Invite" sublabel
  - Send icon (→) in corner
```

### 5. ⏳ **Pending Card** (Invitation sent, not joined)
**Purpose**: Someone who received an invitation but hasn't joined yet
```
Visual Design:
- Background: Amber gradient (#F59E0B → #D97706) at 15% opacity
- Border: 1.5px dashed amber
- Avatar: Amber gradient with clock icon overlay
- Text: White name, "Invitation Sent" status
- Animation: Gentle fade in/out of border
- Shadow: Amber glow (subtle)

Status Indicator: Clock icon ⏰
Timer Display: "23h remaining" countdown
```

### 6. 👻 **Ghost Card** (Empty slot)
**Purpose**: Placeholder for the next potential member
```
Visual Design:
- Background: Transparent with heavy blur
- Border: 1px dashed gray at 30% opacity
- Avatar: Question mark (?) in gray circle
- Text: "Waiting for invitation..." in gray
- Animation: Shimmer effect across the card
- Shadow: None

Status Indicator: Ghost emoji 👻
No position number shown
```

### 7. 🚫 **Wasted Card** (Expired invitation)
**Purpose**: Show where an invitation expired unused
```
Visual Design:
- Background: Red gradient (#EF4444 → #DC2626) at 10% opacity
- Border: 1px solid red at 30% opacity
- Avatar: Red with X overlay
- Text: "Invitation Expired" in red-tinted gray
- Animation: None (static, dead)
- Shadow: None

Status Indicator: Red X
Timestamp: When it expired
```

### 8. 🎯 **Milestone Cards** (Special positions)
**Purpose**: Celebrate significant chain positions
```
Examples: #100, #1000, #10000

Visual Design:
- Background: Gradient matching milestone tier
  - #100: Silver (#C0C0C0 → #A8A8A8)
  - #1000: Gold (#FFD700 → #FFA500)
  - #10000: Platinum (#E5E4E2 → #C9C0BB)
- Border: 2px solid with matching metal color
- Avatar: Special milestone badge
- Animation: Sparkle effect
- Shadow: Metallic sheen

Special Badge: "MILESTONE" with number
```

## Interaction States

### Hover Effects
- **Active/Genesis/Milestone**: Slight scale (1.02x) + brighten
- **Current User**: Increase glow intensity
- **TIP**: Speed up pulse animation
- **Pending**: Show full countdown timer
- **Ghost**: Show "Waiting for TIP to invite"
- **Wasted**: Show expiration details

### Click Effects
- **All cards**: Ripple effect from click point
- **Active cards**: Show quick stats tooltip
- **TIP**: Option to generate invitation
- **Pending**: Show invitation details
- **Wasted**: Show what went wrong

## Spacing & Layout

### Card Dimensions
```
Width: 100% (max-width: 400px)
Height: Auto (min-height: 100px)
Padding: 16px all sides (24px for special cards)
Border Radius: 16px (20px for TIP/Genesis)
```

### Internal Layout
```
[Avatar(64px)] [16px gap] [Content(flex)] [Badge(if any)]
```

## Color Palette

### Primary Colors
- **Deep Void** (Background): #0A0A0F
- **Shadow Dark** (Card BG): #111827
- **Mystic Violet** (User): #7C3AED
- **Emerald** (TIP/Active): #10B981
- **Amber** (Pending): #F59E0B
- **Error Red** (Wasted): #EF4444
- **Ghost Cyan** (Accents): #00D4FF
- **Gold** (Genesis): #FFD700

### Status Colors
- **Active**: Green (#10B981)
- **Pending**: Amber (#F59E0B)
- **Wasted**: Red (#EF4444)
- **Ghost**: Gray (#6B7280)
- **Seed/Genesis**: Gold (#FFD700)

## Animation Timing

### Pulse Animations
- **Current User**: 2s ease-in-out (subtle)
- **TIP**: 2s ease-in-out (prominent)
- **Genesis**: 3s ease-in-out (slow, dignified)

### Transitions
- **Hover**: 200ms ease-out
- **Click**: 100ms ease-in
- **State Change**: 300ms ease-in-out

## Accessibility

### Focus States
- **Keyboard Focus**: 2px outline with 2px offset
- **Screen Reader**: Descriptive labels for all states
- **High Contrast Mode**: Increase border width, ensure 4.5:1 minimum contrast

### Motion Preferences
- **Reduced Motion**: Disable pulse/glow animations
- **Prefers Contrast**: Increase opacity values

## Component Composition

```dart
// Base card structure
Card(
  decoration: [gradient/blur/border based on type],
  child: Row(
    Avatar(type-specific),
    Content(
      Name,
      ChainKey,
      StatusIndicator,
    ),
    Badges(if applicable),
  ),
)
```

## Usage Examples

### Chain of 5 (All visible)
```
🌱 Genesis (#1) - Gold glow
↓
✅ Active (#2) - Standard gray
↓
⭐ YOU (#3) - Purple pulse
↓
⚡ TIP (#4) - Emerald glow, can invite
↓
👻 Ghost (#5) - Blurred, waiting
```

### Chain of 100 (Compressed view)
```
🌱 Genesis (#1)
⋮ [Ellipsis - 34 members]
✅ Active (#36)
↓
⭐ YOU (#37)
↓
✅ Active (#38)
⋮ [Ellipsis - 61 members]
⚡ TIP (#100)
```

## Implementation Priority

1. **Phase 1**: Current User, Active, TIP, Ghost (Core experience)
2. **Phase 2**: Genesis, Pending (Enhanced states)
3. **Phase 3**: Wasted, Milestones (Edge cases)

## Future Enhancements

- **Profile Pictures**: Real avatars when available
- **Activity Indicators**: Show recent activity
- **Connection Strength**: Visual indicator of relationship
- **Achievement Badges**: Special accomplishments
- **Theme Variations**: Light mode support