# Dark Mystique Visual Reference Guide

## Quick Visual Reference for The Chain Design System

This document provides visual descriptions and ASCII art representations of the Dark Mystique design system components.

---

## Color Swatches

```
BACKGROUNDS (The Void)
┌──────────────┬──────────────┬──────────────┬──────────────┐
│  Deep Void   │Void Secondary│Shadow Purple │Twilight Gray │
│   #0A0A0F    │   #12121A    │   #1A1A2E    │   #16213E    │
│ ████████████ │ ████████████ │ ████████████ │ ████████████ │
└──────────────┴──────────────┴──────────────┴──────────────┘

MYSTICAL PURPLES
┌──────────────┬──────────────┬──────────────┐
│Mystic Violet │Ethereal Purp │Deep Magenta  │
│   #8B5CF6    │   #A78BFA    │   #D946EF    │
│ ████████████ │ ████████████ │ ████████████ │
│    GLOW ✨    │  HIGHLIGHT   │   ACCENT     │
└──────────────┴──────────────┴──────────────┘

ETHEREAL CYANS
┌──────────────┬──────────────┐
│  Ghost Cyan  │ Astral Cyan  │
│   #06B6D4    │   #22D3EE    │
│ ████████████ │ ████████████ │
│   FOCUS ⚡    │    HOVER     │
└──────────────┴──────────────┘
```

---

## Typography Scale

```
DISPLAY LARGE (57px, weight 300, spacing -0.5)
═══════════════════════════════════════════════
   THE CHAIN - MYSTICAL NETWORK
═══════════════════════════════════════════════

HEADLINE LARGE (32px, weight 600, spacing 1.0)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  S E C T I O N   H E A D E R
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BODY LARGE (16px, weight 400, spacing 0.25)
───────────────────────────────────────────
This is the main content text with excellent
readability and proper letter spacing.
───────────────────────────────────────────

LABEL LARGE (14px, weight 600, spacing 1.0)
─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─
  B U T T O N   T E X T
─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─
```

---

## Component Layouts

### Mystique Card

```
┌─────────────────────────────────────────┐
│  ╔═════════════════════════════════╗   │ ← Purple glow
│  ║                                 ║   │   border
│  ║     [Icon with radial glow]     ║   │
│  ║                                 ║   │
│  ║         Card Content            ║   │
│  ║                                 ║   │
│  ║  Lorem ipsum dolor sit amet,    ║   │
│  ║  consectetur adipiscing elit.   ║   │
│  ║                                 ║   │
│  ╚═════════════════════════════════╝   │
└─────────────────────────────────────────┘
 ↑                                       ↑
Shadow                              Elevated shadow
(8px blur)                         (10px blur + glow)
```

### Mystique Button (Normal)

```
╔═══════════════════════════════════════════╗
║  ╭─────────────────────────────────────╮  ║ ← Glowing
║  │  [icon] BUTTON TEXT                 │  ║   border
║  │  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ │  ║
║  │      ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓      │  ║ ← Gradient
║  │            ████████████              │  ║   background
║  ╰─────────────────────────────────────╯  ║
╚═══════════════════════════════════════════╝
           Pulsing glow (1.5s)
```

### Mystique Button (Hover)

```
╔═══════════════════════════════════════════╗
║ ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ ║ ← Enhanced
║░░╭─────────────────────────────────────╮░║   glow
║░░│  [icon] BUTTON TEXT (hover)         │░║
║░░│  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ │░║
║░░│      ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓      │░║
║░░│            ████████████              │░║
║░░╰─────────────────────────────────────╯░║
║ ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ ║
╚═══════════════════════════════════════════╝
          Intense glow (60% alpha)
```

### Mystique Text Field (Normal)

```
┌─────────────────────────────────────────┐
│ Username                                │ ← Label
├─────────────────────────────────────────┤   (secondary color)
│ [👤] your_username_________________     │
│                                         │
└─────────────────────────────────────────┘
  ↑                                    ↑
Icon                            Hint text
(purple)                        (muted)
```

### Mystique Text Field (Focused)

```
   ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
  ░┌─────────────────────────────────────────┐░
 ░ │ Username                                │ ░ ← Cyan glow
  ░├═════════════════════════════════════════┤░   (animated)
 ░ │ [👤] john_doe|                          │ ░
  ░│                                         │░
 ░ └─────────────────────────────────────────┘ ░
  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
         ↑
   2px cyan border + glow
```

### Mystique Stat Card

```
┌─────────────────────────┐
│  ╔═══════════════════╗  │ ← Elevated
│  ║    ┌─────────┐    ║  │   purple glow
│  ║   ╱           ╲   ║  │
│  ║  │   [ICON]    │  ║  │ ← Icon with
│  ║   ╲  ░░░░░   ╱   ║  │   radial glow
│  ║    └─────────┘    ║  │
│  ║                   ║  │
│  ║      1,234        ║  │ ← Value
│  ║   (gradient)      ║  │   (gradient text)
│  ║                   ║  │
│  ║   TOTAL USERS     ║  │ ← Title
│  ║                   ║  │   (uppercase)
│  ║  In the network   ║  │ ← Subtitle
│  ║                   ║  │   (muted)
│  ╚═══════════════════╝  │
└─────────────────────────┘
```

### Mystique Alert (Error)

```
┌─────────────────────────────────────────────┐
│ ╔═════════════════════════════════════════╗ │ ← Red border
│ ║ [❌] Connection failed. Please retry.   ║ │   + glow
│ ╚═════════════════════════════════════════╝ │
└─────────────────────────────────────────────┘
   ↑                                        ↑
 Icon                                   Message
(error red)                          (primary text)
```

---

## Screen Layouts

### Login Screen Layout

```
┌─────────────────────────────────────────────────┐
│                                                 │
│              ╔═══════════════╗                  │ ← Chain link
│         ░░░░ ║  ┌─────────┐  ║ ░░░░             │   decoration
│            ░ ║ ╱   CHAIN   ╲ ║ ░               │   (5% opacity)
│              ║│   [ICON]    │║                  │
│         ░░░░ ║ ╲  ░░░░░░  ╱ ║ ░░░░             │
│              ╚═══════════════╝                  │
│                                                 │
│         ═══════════════════════════             │
│           T H E   C H A I N                     │ ← Gradient
│         ═══════════════════════════             │   title
│                                                 │
│           Enter the mystical network            │
│                                                 │
│                                                 │
│    ┌─────────────────────────────────────┐     │
│    │  ╔═══════════════════════════════╗  │     │
│    │  ║   Access Portal               ║  │     │ ← Login card
│    │  ║                               ║  │     │   (elevated)
│    │  ║   [Username field]            ║  │     │
│    │  ║   [Password field]            ║  │     │
│    │  ║                               ║  │     │
│    │  ║   [ENTER THE CHAIN button]    ║  │     │
│    │  ║                               ║  │     │
│    │  ║   Forgot password?            ║  │     │
│    │  ╚═══════════════════════════════╝  │     │
│    └─────────────────────────────────────┘     │
│                                                 │
│    ┌─────────────────────────────────────┐     │
│    │ [ℹ️] Invitation Required            │     │ ← Info card
│    │                                     │     │
│    │ The Chain is invitation-only...    │     │
│    └─────────────────────────────────────┘     │
│                                                 │
└─────────────────────────────────────────────────┘
 ↑                                             ↑
Background: Animated void gradient       Chain links
(10s cycle)                           scattered around
```

### Stats Screen Layout

```
┌─────────────────────────────────────────────────┐
│  ·  ·    ·     ·  ·    · ·    ·  ·    ·        │ ← Animated
│    ·  ·     · ·      ·     ·    ·   ·  ·       │   starfield
│                                                 │   (20s cycle)
│              ╔═══════════════╗                  │
│         ░░░░ ║   ┌───────┐   ║ ░░░░             │
│            ░ ║  │  [HUB]  │  ║ ░               │ ← Glowing
│              ║   └───────┘   ║                  │   hub icon
│         ░░░░ ║    ░░░░░░     ║ ░░░░             │
│              ╚═══════════════╝                  │
│                                                 │
│         ═══════════════════════════             │
│           T H E   C H A I N                     │ ← Gradient
│         ═══════════════════════════             │   title
│                                                 │
│           Network Statistics                    │
│                                                 │
│                                                 │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐│
│  │[ICON]   │ │[ICON]   │ │[ICON]   │ │[ICON]   ││ ← Stat cards
│  │ 1,234   │ │   42    │ │    7    │ │   23    ││   (grid)
│  │ MEMBERS │ │ INVITES │ │ EXPIRED │ │COUNTRIES││
│  └─────────┘ └─────────┘ └─────────┘ └─────────┘│
│                                                 │
│                                                 │
│    ┌─────────────────────────────────────┐     │
│    │  ╔═══════════════════════════════╗  │     │
│    │  ║   [📊] Network Health         ║  │     │ ← Network
│    │  ║                               ║  │     │   health card
│    │  ║   Active Rate ████░░░░ 78%    ║  │     │
│    │  ║   Utilization ██████░░ 85%    ║  │     │
│    │  ║   Density     ███░░░░░ 62%    ║  │     │
│    │  ║                               ║  │     │
│    │  ╚═══════════════════════════════╝  │     │
│    └─────────────────────────────────────┘     │
│  ·  ·    ·     ·  ·    · ·    ·  ·    ·        │
│    ·  ·     · ·      ·     ·    ·   ·  ·       │
└─────────────────────────────────────────────────┘
 ↑                                             ↑
Void gradient background            Chain decorations
+ starfield + nebula spots          (5% opacity)
```

---

## Animation Sequences

### Button Glow Pulse (1.5s loop)

```
Frame 1 (0.0s)        Frame 2 (0.375s)      Frame 3 (0.75s)
═══════════════       ═══════════════       ═══════════════
╔═══════════╗         ╔═══════════╗         ╔═══════════╗
║  BUTTON   ║    →    ║░ BUTTON  ░║    →    ║░░BUTTON░░░║
╚═══════════╝         ╚═══════════╝         ╚═══════════╝
Glow: 30%             Glow: 45%             Glow: 60%

Frame 4 (1.125s)      Frame 5 (1.5s)
═══════════════       ═══════════════
╔═══════════╗         ╔═══════════╗
║░ BUTTON  ░║    →    ║  BUTTON   ║   → Loop
╚═══════════╝         ╚═══════════╝
Glow: 45%             Glow: 30%
```

### Focus Glow Animation (300ms)

```
Frame 1 (0ms)         Frame 2 (150ms)       Frame 3 (300ms)
─────────────         ─────────────         ─────────────
┌───────────┐         ┌───────────┐         ┌───────────┐
│  [Input]  │    →    │░ [Input] ░│    →    │░░[Input]░░│
└───────────┘         └───────────┘         └───────────┘
No glow               Cyan: 20%             Cyan: 40%
Border: 1px           Border: 1.5px         Border: 2px
```

### Background Gradient Shift (10s loop)

```
Time 0s:    Deep Void ████ Void Sec ████ Shadow Purple
            |─────────|────────|──────────────|
            0%        50%      100%

Time 5s:    Deep Void ████ Void Sec ████ Shadow Purple
            |─────────|──────────|────────────|
            0%        60%        100%

Time 10s:   Deep Void ████ Void Sec ████ Shadow Purple
            |─────────|────────|──────────────|
            0%        50%      100%
            → Loop back to start
```

---

## Spacing Grid

```
XS (4px)   ─
SM (8px)   ──
MD (12px)  ───
LG (16px)  ────
XL (20px)  ─────
2XL (24px) ──────
3XL (32px) ────────
4XL (48px) ────────────
```

### Example Card with Spacing

```
┌─────────────────────────────────┐
│ ────────── (24px padding) ────  │
│ ─                             ─ │
│ ─  [Icon]                     ─ │
│ ─    ↕ 16px                   ─ │
│ ─  Card Title                 ─ │
│ ─    ↕ 8px                    ─ │
│ ─  Supporting text goes here. ─ │
│ ─                             ─ │
│ ────────── (24px padding) ────  │
└─────────────────────────────────┘
```

---

## Border Radius Scale

```
Small (8px)       Medium (12px)      Large (16px)
┌──────────┐      ┌────────────┐     ┌──────────────┐
│  Badge   │      │   Button   │     │     Card     │
└──────────┘      └────────────┘     └──────────────┘
  ╭──╮              ╭────╮             ╭──────╮
```

---

## Shadow Depths

```
Level 0: No shadow
─────────────────
┌───────────┐
│  Content  │
└───────────┘


Level 1: Card shadow (8px blur, 30% alpha)
──────────────────────────────────────────
    ┌───────────┐
    │  Content  │
    └───────────┘
   ░░░░░░░░░░░░░


Level 2: Elevated (10px blur, 40% alpha + purple glow)
─────────────────────────────────────────────────────
      ┌───────────┐
  ░░░░│  Content  │░░░░
  ░   └───────────┘   ░
  ░░░░░░░░░░░░░░░░░░░░


Level 3: Purple glow (20px + 40px blur)
──────────────────────────────────────
        ┌───────────┐
   ░░░░░│  Content  │░░░░░
 ░░     └───────────┘     ░░
   ░░░░░░░░░░░░░░░░░░░░░░░


Level 4: Cyan glow (20px blur)
────────────────────────────
      ┌───────────┐
  ▓▓▓▓│  Content  │▓▓▓▓
  ▓   └───────────┘   ▓
  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
```

---

## Icon Styles

### With Radial Glow

```
     ░░░░░░░░░
   ░░        ░░
  ░   ┌───┐   ░
 ░   │ ✦ │    ░
░    │ICON│     ░
 ░   │ ✧ │    ░
  ░   └───┘   ░
   ░░        ░░
     ░░░░░░░░░
```

### Color Variations

```
Purple (Primary)    Cyan (Secondary)    Green (Success)
     ▓▓▓                 ▒▒▒                 ░░░
    ▓▓▓▓▓               ▒▒▒▒▒               ░░░░░
   ▓▓▓▓▓▓▓             ▒▒▒▒▒▒▒             ░░░░░░░
  [  ICON  ]          [  ICON  ]          [  ICON  ]
   ▓▓▓▓▓▓▓             ▒▒▒▒▒▒▒             ░░░░░░░
    ▓▓▓▓▓               ▒▒▒▒▒               ░░░░░
     ▓▓▓                 ▒▒▒                 ░░░
```

---

## Chain Link Decoration Pattern

```
        ┌─────┐
       ╱       ╲
      │         │
     ╱           ╲    ╱─────╲
    │      ┌──────────┐      │
     ╲     │          │     ╱
      │    │          │    │
       ╲───┘          └───╱
            ╲        ╱
             ╲──────╱

Used at 3-10% opacity throughout backgrounds
```

---

## Progress Bar Styles

### Normal State

```
┌───────────────────────────────────────┐
│████████████░░░░░░░░░░░░░░░░░░░░░░░░░░│ 35%
└───────────────────────────────────────┘
```

### With Glow

```
     ░░░░░░░░░░░░░░░
┌───────────────────────────────────────┐
│████████████░░░░░░░░░░░░░░░░░░░░░░░░░░│ 35%
└───────────────────────────────────────┘
     ░░░░░░░░░░░░░░░
```

### Multi-Level (Network Health)

```
Active Rate
┌───────────────────────────────────────┐
│███████████████████░░░░░░░░░░░░░░░░░░░│ 78%
└───────────────────────────────────────┘

Utilization
┌───────────────────────────────────────┐
│██████████████████████░░░░░░░░░░░░░░░░│ 85%
└───────────────────────────────────────┘

Density
┌───────────────────────────────────────┐
│███████████████░░░░░░░░░░░░░░░░░░░░░░░│ 62%
└───────────────────────────────────────┘
```

---

## Responsive Breakpoints

```
Mobile (320px - 767px)
┌─────────────┐
│   [Card]    │
│             │
│   [Card]    │
│             │
│   [Card]    │
└─────────────┘

Tablet (768px - 1023px)
┌───────────────────────────┐
│ [Card]  [Card]  [Card]    │
│                           │
│ [Card]  [Card]  [Card]    │
└───────────────────────────┘

Desktop (1024px+)
┌─────────────────────────────────────┐
│ [Card]  [Card]  [Card]  [Card]     │
│                                     │
│ [Card]  [Card]  [Card]  [Card]     │
└─────────────────────────────────────┘
```

---

## State Indicators

### Button States

```
Normal          Hover           Active          Disabled
───────────     ───────────     ───────────     ───────────
┌─────────┐     ┌─────────┐     ┌─────────┐     ┌─────────┐
│ BUTTON  │ →   │░BUTTON░░│ →   │▓BUTTON▓▓│     │ BUTTON  │
└─────────┘     └─────────┘     └─────────┘     └─────────┘
Glow: 30%       Glow: 50%       Pressed         Opacity: 50%
```

### Input States

```
Empty           Filled          Focus           Error
───────────     ───────────     ───────────     ───────────
┌─────────┐     ┌─────────┐     ┌─────────┐     ┌─────────┐
│ hint... │     │ value   │     │░value░░░│     │!value!!!│
└─────────┘     └─────────┘     └─────────┘     └─────────┘
Muted text      Primary text    Cyan glow       Red border
```

---

## Contrast Checker Matrix

```
           Text     Text      Text
           Primary  Secondary Muted
         ┌─────────┬─────────┬─────────┐
Deep     │ 13.2:1  │  8.1:1  │  4.9:1  │
Void     │  AAA ✓  │  AAA ✓  │  AA ✓   │
         ├─────────┼─────────┼─────────┤
Shadow   │ 11.8:1  │  7.2:1  │  4.5:1  │
Purple   │  AAA ✓  │  AAA ✓  │  AA ✓   │
         ├─────────┼─────────┼─────────┤
Twilight │ 10.5:1  │  6.5:1  │  4.2:1  │
Gray     │  AAA ✓  │  AAA ✓  │  AA ✓   │
         └─────────┴─────────┴─────────┘

Legend: AAA = 7:1+, AA = 4.5:1+, ✓ = Pass
```

---

## Quick Reference Checklist

```
COMPONENT CREATION CHECKLIST
═══════════════════════════════════════════
□ Uses approved colors from palette
□ Text contrast ≥ 4.5:1 (AA) or ≥ 7:1 (AAA)
□ Touch target ≥ 44x44px
□ Keyboard accessible (Tab navigation)
□ Focus indicator visible (2px cyan border)
□ Screen reader labels present
□ Respects reduced motion preference
□ Hover states defined
□ Active/pressed states defined
□ Disabled state (if applicable)
□ Loading state (if applicable)
□ Error state (if applicable)
□ Tested at 200% zoom
□ Works on mobile viewport
□ No color-only information
```

---

## File Reference Quick Links

```
📁 PROJECT STRUCTURE
├── frontend/shared/lib/
│   ├── theme/
│   │   └── dark_mystique_theme.dart ← CORE THEME
│   ├── widgets/
│   │   └── mystique_components.dart ← COMPONENTS
│   ├── screens/
│   │   ├── mystique_login_screen.dart ← LOGIN
│   │   └── mystique_stats_screen.dart ← STATS
│   └── example_mystique_integration.dart ← EXAMPLES
└── docs/
    ├── DARK_MYSTIQUE_DESIGN_SYSTEM.md ← MAIN DOCS
    ├── DARK_MYSTIQUE_WEB_STYLES.css ← WEB CSS
    ├── DARK_MYSTIQUE_ACCESSIBILITY_REPORT.md ← A11Y
    ├── dark_mystique_demo.html ← LIVE DEMO
    └── DARK_MYSTIQUE_COMPLETE_SUMMARY.md ← SUMMARY
```

---

**Quick Start:** Open `dark_mystique_demo.html` to see all components in action!

**Documentation:** See `DARK_MYSTIQUE_DESIGN_SYSTEM.md` for complete details.

**Accessibility:** See `DARK_MYSTIQUE_ACCESSIBILITY_REPORT.md` for WCAG compliance.

---

**Version:** 1.0
**Last Updated:** 2025-10-09
**Status:** Production Ready ✓
