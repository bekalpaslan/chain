# The Chain - Component Specifications

**Project**: The Chain Social Network
**Designer**: ui-designer agent
**Task ID**: TASK-UI-001
**Last Updated**: 2025-10-10

---

## Component Library

### 1. Ticket Card

**Purpose**: Display ticket information in list/grid views

**Anatomy**
```
┌───────────────────────────────────┐
│ [Status Badge]    [Ticket Code]   │ ← Header
│                                   │
│ Expires in 18h 42m                │ ← Countdown
│ Attempt #1 of 3                   │ ← Metadata
│                                   │
│ ┌─────────┐                       │
│ │  QR     │    [Share] [View]     │ ← QR + Actions
│ │  Code   │                       │
│ └─────────┘                       │
│                                   │
│ Position: 12,453 • Created: 2h ago│ ← Footer
└───────────────────────────────────┘
```

**Variants**
- `variant`: "active" | "used" | "expired" | "cancelled"
- `size`: "compact" | "default" | "expanded"

**States**
- Default
- Hover (desktop): Elevation shadow-sm → shadow-md
- Active (pressed): Scale 0.98
- Disabled: Opacity 0.5

**Props (Flutter)**
```dart
TicketCard({
  required String ticketCode,
  required TicketStatus status,
  required DateTime expiresAt,
  required int attemptNumber,
  required int position,
  String? qrCodeUrl,
  String? message,
  VoidCallback? onShare,
  VoidCallback? onView,
  VoidCallback? onCancel,
})
```

**Styling**
- Border: 1px solid gray-300
- Border-radius: 12px (radius-lg)
- Padding: 16px on mobile, 20px on desktop
- Gap between elements: 12px (space-3)
- Background: white
- Shadow: shadow-sm

**Status Badge Mapping**
| Status    | Color           | Icon | Label    |
|-----------|-----------------|------|----------|
| ACTIVE    | status-active   | ●    | Active   |
| USED      | status-used     | ○    | Used     |
| EXPIRED   | status-expired  | ✕    | Expired  |
| CANCELLED | status-cancelled| ⊘    | Cancelled|

---

### 2. Status Badge

**Purpose**: Indicate ticket status with color + icon

**Anatomy**
```
┌─────────────┐
│ ● ACTIVE    │
└─────────────┘
```

**Variants**
- `status`: "active" | "used" | "expired" | "cancelled"
- `size`: "sm" | "md" | "lg"

**Styling**
```css
.status-badge {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 4px 12px;
  border-radius: 16px; /* radius-full */
  font-size: 0.875rem; /* text-sm */
  font-weight: 500; /* medium */
}

.status-badge--active {
  background: color-mix(in srgb, var(--status-active) 10%, white);
  color: var(--status-active);
}

.status-badge--used {
  background: var(--gray-100);
  color: var(--gray-700);
}

.status-badge--expired {
  background: color-mix(in srgb, var(--status-expired) 10%, white);
  color: var(--status-expired);
}
```

**Accessibility**
- Icon is decorative (aria-hidden="true")
- Status text is readable by screen readers
- Minimum contrast ratio: 4.5:1

---

### 3. Countdown Timer

**Purpose**: Display time remaining until ticket expiration

**Anatomy**
```
Expires in 18h 42m
```

**Behavior**
- Update frequency:
  - < 1 hour: Every second
  - 1-24 hours: Every minute
  - > 24 hours: Every hour
- Color changes:
  - > 24 hours: gray-700
  - 2-24 hours: gray-900
  - < 2 hours: status-expired (red)
  - Expired: "Expired" (gray-500)

**Format Examples**
- 72 hours: "Expires in 3d"
- 25 hours: "Expires in 1d 1h"
- 5 hours: "Expires in 5h"
- 90 minutes: "Expires in 1h 30m"
- 45 seconds: "Expires in 45s"
- Past expiration: "Expired 2h ago"

**Props**
```dart
CountdownTimer({
  required DateTime expiresAt,
  TextStyle? style,
  bool showIcon = false,
})
```

**Styling**
- Font-size: text-sm (14px)
- Font-weight: medium (500)
- Icon (optional): Clock icon, 16x16px, aligned left

---

### 4. Button

**Purpose**: Primary interactive element

**Variants**

**Primary**
```
┌─────────────────┐
│  Create Ticket  │
└─────────────────┘
```
- Background: primary-600
- Text: white
- Hover: primary-700
- Active: primary-800

**Secondary**
```
┌─────────────────┐
│  Cancel         │
└─────────────────┘
```
- Background: white
- Border: 1px solid gray-300
- Text: gray-700
- Hover: gray-50
- Active: gray-100

**Destructive**
```
┌─────────────────┐
│  Delete Ticket  │
└─────────────────┘
```
- Background: status-expired (red)
- Text: white
- Hover: darker red
- Active: even darker red

**Ghost**
```
┌─────────────────┐
│  View Details   │
└─────────────────┘
```
- Background: transparent
- Text: primary-600
- Hover: primary-50
- Active: primary-100

**Icon-only**
```
┌───┐
│ ⋮ │
└───┘
```
- Square: 44x44px minimum
- Padding: 12px
- ARIA label required

**Sizes**
| Size | Height | Padding (H) | Font Size |
|------|--------|-------------|-----------|
| sm   | 32px   | 12px        | text-sm   |
| md   | 40px   | 16px        | text-base |
| lg   | 48px   | 20px        | text-lg   |

**States**
- Default
- Hover: Brightness +5%
- Focus: 2px outline, primary-600
- Active/Pressed: Transform translateY(1px)
- Disabled: Opacity 0.5, cursor not-allowed
- Loading: Spinner icon, text hidden

**Props**
```dart
Button({
  required VoidCallback? onPressed,
  required Widget child,
  ButtonVariant variant = ButtonVariant.primary,
  ButtonSize size = ButtonSize.md,
  bool isLoading = false,
  IconData? icon,
  bool fullWidth = false,
})
```

---

### 5. QR Code Display

**Purpose**: Show scannable QR code for ticket

**Anatomy**
```
┌─────────────┐
│             │
│  QR Code    │ ← Generated image
│  Image      │
│             │
└─────────────┘
  #XYZABC123    ← Ticket code below
```

**Sizes**
- Small: 128x128px (list view)
- Medium: 200x200px (card view)
- Large: 300x300px (detail view, share view)

**Styling**
- Background: white
- Padding: 16px around QR code
- Border: 1px solid gray-200
- Border-radius: 8px (radius-md)
- QR code foreground: gray-900
- QR code background: white
- Error correction: Medium (15%)

**Interaction**
- Tap to enlarge (mobile)
- Right-click → Save image (desktop)
- Long-press → Share (mobile)

**Accessibility**
- Alt text: "QR code for ticket {ticketCode}"
- Ticket code visible as text below QR for manual entry

---

### 6. Chain Node (SVG Component)

**Purpose**: Represent a user in chain visualization

**Anatomy**
```
┌─────────────┐
│   @alice    │ ← Username
│   #123456   │ ← Chain key
└──────┬──────┘
       │
```

**Variants**
- `nodeType`: "genesis" | "parent" | "self" | "child" | "wasted"
- `size`: "sm" | "md" | "lg"

**Styling by Type**
| Type    | Border Color    | Background     | Text Color |
|---------|-----------------|----------------|------------|
| genesis | gold (#FFD700)  | gray-50        | gray-900   |
| parent  | chain-parent    | purple tint    | purple-900 |
| self    | chain-self      | blue highlight | white      |
| child   | chain-child     | green tint     | green-900  |
| wasted  | chain-wasted    | red tint       | red-900    |

**Self Node (Highlighted)**
- Border: 3px solid primary-600
- Background: primary-600
- Text: white
- Shadow: shadow-lg

**Props**
```dart
ChainNode({
  required String username,
  required String chainKey,
  required NodeType nodeType,
  int? descendantCount,
  VoidCallback? onTap,
})
```

---

### 7. Input Field

**Purpose**: Text input for forms

**Anatomy**
```
Label *
┌─────────────────────────────┐
│ Placeholder text            │
└─────────────────────────────┘
Helper text or error message
```

**States**

**Default**
- Border: 1px solid gray-300
- Background: white
- Text: gray-900
- Placeholder: gray-400

**Focus**
- Border: 2px solid primary-600
- Outline: 0 0 0 3px rgba(37, 99, 235, 0.1)
- Placeholder: gray-500

**Error**
- Border: 2px solid status-expired
- Label/helper text: status-expired
- Icon: Error icon (!) in red

**Disabled**
- Background: gray-100
- Border: gray-200
- Text: gray-500
- Cursor: not-allowed

**Success**
- Border: 2px solid status-active
- Icon: Check mark (✓) in green

**Styling**
- Height: 44px (touch-friendly)
- Border-radius: 8px (radius-md)
- Padding: 12px 16px
- Font-size: text-base (16px to prevent zoom on mobile)
- Font-family: font-body

**Props**
```dart
InputField({
  required String label,
  String? placeholder,
  String? helperText,
  String? errorText,
  bool required = false,
  bool disabled = false,
  TextInputType keyboardType = TextInputType.text,
  TextEditingController? controller,
  ValueChanged<String>? onChanged,
  int? maxLength,
})
```

---

### 8. Filter Chip

**Purpose**: Quick filter selection

**Anatomy**
```
┌────────┐  ┌──────────┐  ┌──────────┐
│ All ▾  │  │ Active   │  │ Expired  │
└────────┘  └──────────┘  └──────────┘
```

**States**

**Unselected**
- Background: white
- Border: 1px solid gray-300
- Text: gray-700

**Selected**
- Background: primary-600
- Border: 1px solid primary-600
- Text: white

**Hover (unselected)**
- Background: gray-50
- Border: 1px solid gray-400

**Hover (selected)**
- Background: primary-700

**Styling**
- Height: 36px
- Padding: 8px 16px
- Border-radius: 18px (radius-full)
- Font-size: text-sm
- Font-weight: medium (500)
- Gap between chips: 8px

**With Dropdown (All ▾)**
- Chevron icon: 16x16px
- Opens dropdown menu below

---

### 9. Modal/Dialog

**Purpose**: Overlay for focused tasks

**Anatomy**
```
Overlay (backdrop)
┌─────────────────────────────────┐
│  Title                     [✕]  │ ← Header
├─────────────────────────────────┤
│                                 │
│  Content area                   │ ← Body
│                                 │
├─────────────────────────────────┤
│  [Cancel]      [Confirm]        │ ← Footer (actions)
└─────────────────────────────────┘
```

**Backdrop**
- Background: rgba(0, 0, 0, 0.5)
- Click to close (optional)
- Blur: backdrop-filter: blur(4px) (if supported)

**Modal Container**
- Background: white
- Border-radius: 16px (radius-xl)
- Shadow: shadow-xl
- Max-width: 500px on desktop
- Full-screen on mobile (< 640px)
- Padding: 24px

**Animation**
- Enter: Fade in + scale from 0.95 → 1.0 (250ms)
- Exit: Fade out + scale to 0.95 (200ms)

**Accessibility**
- Focus trap: Tab cycles within modal
- Escape key closes modal
- Focus returns to trigger element on close
- aria-modal="true"
- aria-labelledby points to title

**Mobile Variant: Bottom Sheet**
- Slides up from bottom
- Rounded top corners only
- Drag handle at top
- Swipe down to dismiss

---

### 10. Table (Desktop)

**Purpose**: Display ticket data in rows/columns

**Anatomy**
```
┌───────┬────────────┬──────────┬─────────┐
│Status │ Ticket Code│ Expires  │ Actions │ ← Header
├───────┼────────────┼──────────┼─────────┤
│● ACTIVE│ #XYZABC123│ 18h 42m  │ [⋮]     │ ← Row
├───────┼────────────┼──────────┼─────────┤
│○ USED │ #PREV456  │ Oct 8    │ [⋮]     │
└───────┴────────────┴──────────┴─────────┘
```

**Header**
- Background: gray-50
- Border-bottom: 2px solid gray-200
- Text: text-xs, uppercase, gray-600, font-semibold
- Padding: 12px 16px
- Sticky on scroll

**Rows**
- Border-bottom: 1px solid gray-200
- Padding: 16px
- Hover: Background gray-50
- Clickable rows: Cursor pointer

**Cells**
- Vertical alignment: middle
- Text: text-sm, gray-900
- Overflow: Truncate with ellipsis

**Sortable Columns**
- Arrow icon (↑ / ↓) on hover
- Active sort column: Bold text + arrow

**Responsive**
- Hide less important columns on smaller screens
- Use horizontal scroll with sticky first column

---

## Design Tokens Reference

All components reference tokens from `design-system.md`:
- Colors: `--chain-primary-600`, `--status-active`, etc.
- Spacing: `--space-4`, `--space-6`, etc.
- Typography: `--text-sm`, `--font-medium`, etc.
- Shadows: `--shadow-md`, `--shadow-lg`, etc.
- Radius: `--radius-md`, `--radius-lg`, etc.

---

## Component Implementation Priority

1. **Phase 1** (MVP):
   - Button
   - Input Field
   - Ticket Card
   - Status Badge
   - Countdown Timer
   - QR Code Display

2. **Phase 2**:
   - Modal/Dialog
   - Filter Chip
   - Table
   - Chain Node

3. **Phase 3** (Polish):
   - Toast notifications
   - Loading skeletons
   - Empty states
   - Error boundaries

---

## Testing Checklist per Component

- [ ] Desktop rendering (1280px)
- [ ] Tablet rendering (768px)
- [ ] Mobile rendering (375px)
- [ ] Keyboard navigation
- [ ] Screen reader compatibility
- [ ] Color contrast (WCAG AA)
- [ ] Touch target sizes (44x44px)
- [ ] Dark mode variant (future)
- [ ] Right-to-left (RTL) support (future)

---

## Next Steps

- Implement components in Flutter using `flutter_hooks` and `riverpod`
- Create Storybook/Widgetbook for component showcase
- Write unit tests for component logic
- Conduct WCAG audit (see `accessibility-checklist.md`)
