# The Chain - Design System Foundation

**Project**: The Chain Social Network
**Designer**: ui-designer agent
**Task ID**: TASK-UI-001
**Last Updated**: 2025-10-10

## Overview

The Chain is an invite-only social network built on a blockchain-inspired chain of invitations. Each user receives time-limited tickets to invite others, creating a traceable lineage. The design system prioritizes clarity, trust, and scarcity.

---

## Color Palette

### Primary Colors
```
--chain-primary-600: #2563EB    // Primary blue - CTAs, links
--chain-primary-700: #1D4ED8    // Hover state
--chain-primary-800: #1E40AF    // Active state
--chain-primary-50:  #EFF6FF    // Light backgrounds
```

### Semantic Colors

**Status Colors** (Ticket Status)
```
--status-active:    #10B981    // Green - Active tickets
--status-used:      #6B7280    // Gray - Used tickets
--status-expired:   #EF4444    // Red - Expired tickets
--status-cancelled: #F59E0B    // Amber - Cancelled tickets
```

**Chain Hierarchy**
```
--chain-parent:     #8B5CF6    // Purple - Parent node
--chain-self:       #2563EB    // Blue - Current user
--chain-child:      #10B981    // Green - Active child
--chain-wasted:     #EF4444    // Red - Wasted connections
```

### Neutral Colors
```
--gray-50:   #F9FAFB
--gray-100:  #F3F4F6
--gray-200:  #E5E7EB
--gray-300:  #D1D5DB
--gray-500:  #6B7280
--gray-700:  #374151
--gray-900:  #111827
```

### Background & Surface
```
--bg-primary:    #FFFFFF
--bg-secondary:  #F9FAFB
--bg-tertiary:   #F3F4F6
--surface-elevated: #FFFFFF (with shadow)
```

---

## Typography

### Font Families
```css
--font-display: 'Inter', -apple-system, system-ui, sans-serif;
--font-body:    'Inter', -apple-system, system-ui, sans-serif;
--font-mono:    'JetBrains Mono', 'SF Mono', monospace;
```

### Type Scale (rem-based, 16px root)
```
--text-xs:   0.75rem / 12px   // Line height: 1rem
--text-sm:   0.875rem / 14px  // Line height: 1.25rem
--text-base: 1rem / 16px      // Line height: 1.5rem
--text-lg:   1.125rem / 18px  // Line height: 1.75rem
--text-xl:   1.25rem / 20px   // Line height: 1.75rem
--text-2xl:  1.5rem / 24px    // Line height: 2rem
--text-3xl:  1.875rem / 30px  // Line height: 2.25rem
--text-4xl:  2.25rem / 36px   // Line height: 2.5rem
```

### Font Weights
```
--font-normal:   400
--font-medium:   500
--font-semibold: 600
--font-bold:     700
```

### Usage
- **Headings**: Semibold (600), gray-900
- **Body text**: Normal (400), gray-700
- **Labels**: Medium (500), gray-600
- **Chain keys/codes**: Mono, medium (500)

---

## Spacing System

**8px base unit**
```
--space-1:  0.25rem / 4px
--space-2:  0.5rem / 8px
--space-3:  0.75rem / 12px
--space-4:  1rem / 16px
--space-5:  1.25rem / 20px
--space-6:  1.5rem / 24px
--space-8:  2rem / 32px
--space-10: 2.5rem / 40px
--space-12: 3rem / 48px
--space-16: 4rem / 64px
```

**Layout**
- Component padding: 16px (space-4) on mobile, 24px (space-6) on desktop
- Stack spacing (vertical): 16px (space-4) default, 24px (space-6) for sections
- Grid gap: 16px (space-4) on mobile, 24px (space-6) on desktop

---

## Border Radius
```
--radius-sm:   0.25rem / 4px   // Badges, tags
--radius-md:   0.5rem / 8px    // Buttons, inputs
--radius-lg:   0.75rem / 12px  // Cards
--radius-xl:   1rem / 16px     // Modals, elevated panels
--radius-full: 9999px          // Pills, avatars
```

---

## Shadows

```css
--shadow-sm:  0 1px 2px 0 rgba(0, 0, 0, 0.05);
--shadow-md:  0 4px 6px -1px rgba(0, 0, 0, 0.1),
              0 2px 4px -1px rgba(0, 0, 0, 0.06);
--shadow-lg:  0 10px 15px -3px rgba(0, 0, 0, 0.1),
              0 4px 6px -2px rgba(0, 0, 0, 0.05);
--shadow-xl:  0 20px 25px -5px rgba(0, 0, 0, 0.1),
              0 10px 10px -5px rgba(0, 0, 0, 0.04);
```

**Usage**
- Cards: shadow-sm
- Dropdowns: shadow-lg
- Modals: shadow-xl
- Elevated panels: shadow-md

---

## Component States

### Interactive Elements

**Default**
- Border: 1px solid gray-300
- Background: white
- Text: gray-700

**Hover**
- Border: 1px solid primary-600
- Background: primary-50 (light) or primary-700 (filled buttons)
- Cursor: pointer

**Focus**
- Outline: 2px solid primary-600
- Outline-offset: 2px
- Box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1)

**Active/Pressed**
- Background: primary-800 (filled) or primary-100 (light)
- Transform: translateY(1px) (subtle)

**Disabled**
- Opacity: 0.5
- Cursor: not-allowed
- Pointer-events: none

---

## Responsive Breakpoints

```css
--screen-sm:  640px   // Mobile landscape
--screen-md:  768px   // Tablet portrait
--screen-lg:  1024px  // Tablet landscape / small desktop
--screen-xl:  1280px  // Desktop
--screen-2xl: 1536px  // Large desktop
```

**Mobile-first approach**: Design for 375px width, scale up.

---

## Accessibility Standards

### WCAG 2.1 AA Compliance

**Color Contrast**
- Normal text (< 18px): 4.5:1 minimum
- Large text (≥ 18px): 3:1 minimum
- UI components: 3:1 minimum

**Touch Targets**
- Minimum size: 44x44px
- Spacing: 8px minimum between targets

**Focus Indicators**
- Visible outline: 2px minimum
- Color: primary-600
- Never remove focus styles

**Keyboard Navigation**
- All interactive elements must be keyboard accessible
- Logical tab order
- Skip links for main content

**Screen Readers**
- Semantic HTML (nav, main, article, section)
- ARIA labels for icon-only buttons
- ARIA live regions for dynamic content
- Alt text for all meaningful images

---

## Animation & Transitions

```css
--transition-fast:   150ms cubic-bezier(0.4, 0, 0.2, 1);
--transition-base:   250ms cubic-bezier(0.4, 0, 0.2, 1);
--transition-slow:   350ms cubic-bezier(0.4, 0, 0.2, 1);
```

**Usage**
- Hover states: transition-fast
- Modals/drawers: transition-base
- Page transitions: transition-slow

**Respect prefers-reduced-motion**
```css
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```

---

## Design Principles

1. **Scarcity & Value**: Tickets are time-limited. Use countdown timers, urgency indicators.
2. **Transparency**: Chain lineage is visible. Show parent→self→child clearly.
3. **Trust**: QR codes, signatures, cryptographic payload visible when needed.
4. **Simplicity**: Minimal UI, focus on core actions (generate ticket, claim, view chain).
5. **Mobile-first**: Primary device is mobile. Desktop is secondary.

---

## Next Steps

- See `dashboard-wireframes.md` for layout specifications
- See `components-spec.md` for individual component definitions
- See `accessibility-checklist.md` for verification
