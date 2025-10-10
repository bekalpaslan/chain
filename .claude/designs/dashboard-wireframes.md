# The Chain - Dashboard Wireframes

**Project**: The Chain Social Network
**Designer**: ui-designer agent
**Task ID**: TASK-UI-001
**Last Updated**: 2025-10-10

---

## Screen Overview

The dashboard consists of three primary views:
1. **Ticket List** - View all your tickets (active, used, expired)
2. **Chain View** - Visualize your position in the chain
3. **Profile** - User statistics and settings

---

## 1. Ticket List View (Primary Dashboard)

### Mobile Layout (< 768px)

```
┌─────────────────────────────────────┐
│  ☰  The Chain         [Profile 👤]  │ ← Header (sticky)
├─────────────────────────────────────┤
│                                     │
│  My Tickets                    [+]  │ ← Title + Create button
│                                     │
│  ┌─ Filters ──────────────────┐   │
│  │ [All ▾] [Active] [Expired]  │   │ ← Filter chips
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐  │
│  │ ● ACTIVE       #XYZABC123    │  │ ← Status badge + Code
│  │                              │  │
│  │ Expires in 18h 42m           │  │ ← Countdown timer
│  │ Attempt #1 of 3              │  │
│  │                              │  │
│  │ ┌────────────┐               │  │
│  │ │  QR Code   │    [Share]    │  │ ← QR + Actions
│  │ │   Image    │    [View]     │  │
│  │ └────────────┘               │  │
│  │                              │  │
│  │ Position: 12,453             │  │ ← Metadata
│  │ Created: 2h ago              │  │
│  └─────────────────────────────┘  │
│                                     │
│  ┌─────────────────────────────┐  │
│  │ ○ USED         #PREVIOUS456  │  │
│  │                              │  │
│  │ Used by @alice               │  │
│  │ Claimed: Oct 8, 2025         │  │
│  │                              │  │
│  │ [View Chain]                 │  │
│  └─────────────────────────────┘  │
│                                     │
│  ┌─────────────────────────────┐  │
│  │ ✕ EXPIRED      #OLDTICKET789 │  │
│  │                              │  │
│  │ Expired: Oct 5, 2025         │  │
│  │ Attempt #3 - Wasted          │  │
│  │                              │  │
│  │ [Delete]                     │  │
│  └─────────────────────────────┘  │
│                                     │
└─────────────────────────────────────┘
```

### Desktop Layout (≥ 1024px)

```
┌──────────────────────────────────────────────────────────────────┐
│  The Chain                    [Chain] [Tickets] [Profile 👤]      │
├────────────┬─────────────────────────────────────────────────────┤
│            │                                                      │
│ Sidebar    │  My Tickets                              [+ Create] │
│            │                                                      │
│ ┌────────┐ │  Filters: [All ▾] [Active] [Used] [Expired]         │
│ │ Stats  │ │                                                      │
│ │        │ │  ┌──────────┬──────────────────────────────────────┐│
│ │ Active │ │  │ Status   │ Ticket Code    │ Expires  │ Actions ││
│ │   3    │ │  ├──────────┼──────────────────────────────────────┤│
│ │        │ │  │ ● ACTIVE │ #XYZABC123     │ 18h 42m  │ [QR][≡] ││
│ │ Used   │ │  │          │ Position 12453 │          │         ││
│ │   12   │ │  ├──────────┼──────────────────────────────────────┤│
│ │        │ │  │ ● ACTIVE │ #DEFGHI456     │ 2d 4h    │ [QR][≡] ││
│ │ Wasted │ │  │          │ Position 12454 │          │         ││
│ │   1    │ │  ├──────────┼──────────────────────────────────────┤│
│ └────────┘ │  │ ○ USED   │ #PREVIOUS789   │ Oct 8    │ [View]  ││
│            │  │          │ Claimed by @alice         │         ││
│ [Chain]    │  ├──────────┼──────────────────────────────────────┤│
│ [Settings] │  │ ✕ EXPIRED│ #OLDTICKET111  │ Oct 5    │ [Delete]││
│            │  │          │ Attempt #3     │          │         ││
│            │  └──────────┴──────────────────────────────────────┘│
│            │                                                      │
│            │  [← Prev]  Page 1 of 3  [Next →]                   │
└────────────┴─────────────────────────────────────────────────────┘
```

---

## 2. Ticket Detail View (Modal/Drawer)

### Mobile (Bottom Sheet)

```
┌─────────────────────────────────────┐
│           Ticket Details       [✕]  │
├─────────────────────────────────────┤
│                                     │
│      ┌────────────────────┐         │
│      │                    │         │
│      │     QR Code        │         │ ← Large QR code
│      │     Image          │         │
│      │                    │         │
│      └────────────────────┘         │
│                                     │
│  Ticket Code                        │
│  #XYZABC123              [Copy]     │
│                                     │
│  Status                             │
│  ● ACTIVE - Expires in 18h 42m      │
│                                     │
│  Position in Chain                  │
│  12,453                             │
│                                     │
│  Attempt Number                     │
│  1 of 3                             │
│                                     │
│  Created                            │
│  Oct 10, 2025 at 2:34 PM            │
│                                     │
│  Signature (Cryptographic)          │
│  ┌─────────────────────────────┐   │
│  │ eyJhbGciOiJIUzUxMiJ9...      │   │ ← Monospace, scrollable
│  │ [View Full] [Verify]         │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │      [Share Ticket]          │   │ ← Primary CTA
│  └─────────────────────────────┘   │
│                                     │
│  [Cancel Ticket]                    │ ← Destructive action
│                                     │
└─────────────────────────────────────┘
```

---

## 3. Chain Visualization View

### Mobile (Vertical Tree)

```
┌─────────────────────────────────────┐
│  ← Back    Chain View               │
├─────────────────────────────────────┤
│                                     │
│         Your Chain Lineage          │
│                                     │
│            ┌─────────┐              │
│            │  SEED   │              │ ← Genesis/Root
│            │ #000001 │              │
│            └────┬────┘              │
│                 │                   │
│            ┌────▼────┐              │
│            │ @alice  │              │ ← Parent
│            │ #123456 │              │
│            └────┬────┘              │
│                 │                   │
│       ╔═════════▼═════════╗         │
│       ║       YOU         ║         │ ← Current user (highlighted)
│       ║    @username      ║         │
│       ║    #789012        ║         │
│       ╚═════════╤═════════╝         │
│                 │                   │
│            ┌────▼────┐              │
│            │  @bob   │              │ ← Active child
│            │ #345678 │              │
│            └─────────┘              │
│                                     │
│  ─────────────────────────────      │
│                                     │
│  Stats                              │
│  Total descendants: 42              │
│  Active descendants: 38             │
│  Wasted invitations: 1              │
│  Your position: 12,453              │
│                                     │
│  [View Full Chain]                  │
│  [Download Chain Data]              │
│                                     │
└─────────────────────────────────────┘
```

### Desktop (Horizontal Tree - SVG)

```
┌──────────────────────────────────────────────────────────────────┐
│  The Chain                    [Chain] [Tickets] [Profile]        │
├──────────────────────────────────────────────────────────────────┤
│                                                                   │
│  Your Chain Lineage                            [Zoom] [Download] │
│                                                                   │
│  ┌────┐      ┌────┐      ╔══════╗      ┌────┐      ┌────┐       │
│  │SEED│──────│@alice──────║ YOU  ║──────│@bob│──────│@charlie   │
│  │#001│      │#1234│      ║#7890 ║      │#345│      │#6789│     │
│  └────┘      └────┘      ╚══════╝      └─┬──┘      └────┘       │
│                                           │                       │
│                                        ┌──▼──┐                   │
│                                        │@dave│                   │
│                                        │#9012│                   │
│                                        └─────┘                   │
│                                                                   │
│  ─────────────────────────────────────────────────────────────   │
│                                                                   │
│  Chain Statistics                                                │
│                                                                   │
│  ┌─────────────┐  ┌──────────────┐  ┌─────────────┐             │
│  │ Your Pos    │  │ Descendants  │  │ Wasted      │             │
│  │  12,453     │  │     42       │  │    1        │             │
│  └─────────────┘  └──────────────┘  └─────────────┘             │
│                                                                   │
└──────────────────────────────────────────────────────────────────┘
```

---

## 4. Create Ticket Flow

### Step 1: Initiate

```
┌─────────────────────────────────────┐
│     Create New Ticket          [✕]  │
├─────────────────────────────────────┤
│                                     │
│  You can generate a new ticket      │
│  to invite someone to The Chain.    │
│                                     │
│  Duration                           │
│  ┌─────────────────────────────┐   │
│  │ 24 hours ▾                  │   │ ← Dropdown
│  └─────────────────────────────┘   │
│  Options: 6h, 12h, 24h, 48h, 72h    │
│                                     │
│  Optional Message                   │
│  ┌─────────────────────────────┐   │
│  │ Welcome to The Chain!       │   │ ← Text input
│  └─────────────────────────────┘   │
│  (Max 100 characters)               │
│                                     │
│  ⚠ Ticket Limits                    │
│  You have 2 attempts remaining.     │
│  If this ticket expires unused,     │
│  you'll have 1 attempt left.        │
│                                     │
│  ┌─────────────────────────────┐   │
│  │    [Generate Ticket]         │   │ ← Primary CTA
│  └─────────────────────────────┘   │
│                                     │
│  [Cancel]                           │
└─────────────────────────────────────┘
```

### Step 2: Success

```
┌─────────────────────────────────────┐
│     Ticket Created! ✓          [✕]  │
├─────────────────────────────────────┤
│                                     │
│      ┌────────────────────┐         │
│      │                    │         │
│      │     QR Code        │         │
│      │                    │         │
│      └────────────────────┘         │
│                                     │
│  #XYZABC123              [Copy]     │
│                                     │
│  Expires in 24h 0m                  │
│  Created: Oct 10, 2025 3:15 PM      │
│                                     │
│  ┌─────────────────────────────┐   │
│  │      [Share Ticket]          │   │ ← Share via native share API
│  └─────────────────────────────┘   │
│                                     │
│  [Download QR Code]                 │
│  [Copy Link]                        │
│  [View Ticket Details]              │
│                                     │
└─────────────────────────────────────┘
```

---

## 5. Empty States

### No Tickets Yet

```
┌─────────────────────────────────────┐
│  My Tickets                         │
├─────────────────────────────────────┤
│                                     │
│          ┌───────────┐              │
│          │   📋      │              │ ← Illustration/icon
│          └───────────┘              │
│                                     │
│     No tickets yet                  │
│                                     │
│  You haven't generated any          │
│  invitation tickets yet.            │
│                                     │
│  ┌─────────────────────────────┐   │
│  │   [Create Your First Ticket] │   │
│  └─────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘
```

---

## 6. Filter Panel (Desktop Sidebar)

```
┌─────────────────────┐
│  Filters            │
├─────────────────────┤
│                     │
│ Status              │
│ ☑ Active  (3)       │
│ ☑ Used    (12)      │
│ ☐ Expired (2)       │
│ ☐ Cancelled (0)     │
│                     │
│ Date Range          │
│ ┌─────────────────┐ │
│ │ Last 7 days  ▾  │ │
│ └─────────────────┘ │
│                     │
│ Attempt Number      │
│ ○ All               │
│ ○ First attempt     │
│ ○ 2nd attempt       │
│ ○ Final attempt     │
│                     │
│ [Apply] [Clear]     │
│                     │
└─────────────────────┘
```

---

## Responsive Behavior

### Breakpoint Transitions

**Mobile → Tablet (640px - 768px)**
- Ticket cards: 1 column → 2 columns
- Filter chips remain horizontal scroll

**Tablet → Desktop (768px - 1024px)**
- Introduce sidebar navigation
- Ticket cards: 2 columns → table layout
- Filters move to permanent sidebar

**Desktop → Large Desktop (1024px+)**
- Max content width: 1280px (centered)
- Add chain visualization sidebar on right

---

## Interaction Patterns

### Card Hover (Desktop)
- Elevation: shadow-sm → shadow-md
- Border: gray-300 → primary-600
- Transition: 150ms ease

### Card Tap (Mobile)
- Scale: 1 → 0.98
- Opacity: 1 → 0.95
- Opens detail modal

### Filter Selection
- Immediate filtering (no "Apply" button on mobile)
- Show count of results: "Showing 3 active tickets"

### Countdown Timers
- Update every second for tickets < 1 hour remaining
- Update every minute for tickets 1-24 hours
- Update every hour for tickets > 24 hours
- Red text when < 2 hours remaining

---

## Accessibility Notes

- Ticket status uses both color AND icon (●/○/✕) for colorblind users
- Skip link: "Skip to ticket list"
- Filter controls are `<fieldset>` with `<legend>`
- Sort controls announce changes to screen readers
- QR codes have alt text with ticket code
- Focus trap in modals
- Escape key closes modals

---

## Next Steps

- See `components-spec.md` for detailed component anatomy
- See `design-system.md` for colors, spacing, typography
- Implement in Flutter using `flutter_dashboard_ui` package
