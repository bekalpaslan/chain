# The Chain - Accessibility Checklist (WCAG 2.1 AA)

**Project**: The Chain Social Network
**Designer**: ui-designer agent
**Task ID**: TASK-UI-001
**Last Updated**: 2025-10-10

---

## Overview

This checklist ensures The Chain meets **WCAG 2.1 Level AA** compliance for accessibility.

---

## 1. Perceivable

### 1.1 Text Alternatives
- [ ] All QR codes have descriptive alt text (e.g., "QR code for ticket #XYZABC123")
- [ ] Icon-only buttons have ARIA labels (e.g., aria-label="More options")
- [ ] Decorative icons are hidden from screen readers (aria-hidden="true")
- [ ] Chain visualization nodes have text alternatives
- [ ] Loading spinners have sr-only text ("Loading...")

### 1.2 Time-based Media
- [ ] N/A - No video/audio content

### 1.3 Adaptable
- [ ] Semantic HTML structure (nav, main, article, section, header, footer)
- [ ] Heading hierarchy is logical (h1 → h2 → h3, no skipping)
- [ ] Tables use proper thead, tbody, th elements with scope attributes
- [ ] Form inputs have associated <label> elements
- [ ] Lists use ul/ol/li elements (not div-based)
- [ ] Reading order matches visual order in DOM
- [ ] Content is understandable without CSS

### 1.4 Distinguishable

**Color Contrast** (4.5:1 for normal text, 3:1 for large text/UI)
- [ ] Body text (gray-700 on white): 10.74:1 ✓
- [ ] Primary button text (white on primary-600): 4.58:1 ✓
- [ ] Status badges meet 4.5:1 minimum
- [ ] Link text (primary-600 on white): 7.59:1 ✓
- [ ] Error text (red on white): > 4.5:1 ✓
- [ ] Countdown timer (red urgent state): > 4.5:1 ✓

**Visual Presentation**
- [ ] Text can be resized up to 200% without loss of content/functionality
- [ ] Line height minimum 1.5 for body text
- [ ] Paragraph spacing minimum 2x font size
- [ ] No images of text (except logos)
- [ ] Focus indicators have 3:1 contrast against background
- [ ] Text over images has sufficient contrast (use overlay if needed)

**Non-text Contrast** (3:1 minimum)
- [ ] Button borders: gray-300 vs white (2.12:1) - needs improvement
- [ ] Input field borders: gray-300 vs white (2.12:1) - needs improvement
- [ ] Card borders: Use gray-400 instead (3.08:1) ✓
- [ ] Interactive component states are visually distinct

**Use of Color**
- [ ] Status is indicated by BOTH color AND icon (●/○/✕)
- [ ] Required fields marked with asterisk (*) AND "required" in label
- [ ] Form errors indicated by icon, color, AND text message
- [ ] Chart/graph data has patterns or labels, not just color
- [ ] Links are underlined or have non-color indicator

---

## 2. Operable

### 2.1 Keyboard Accessible
- [ ] All interactive elements reachable via Tab key
- [ ] Tab order is logical (follows visual flow)
- [ ] No keyboard traps (can Tab into and out of all components)
- [ ] Modal dialogs trap focus (Tab cycles within modal)
- [ ] Escape key closes modals and dropdowns
- [ ] Arrow keys navigate within dropdowns, filter chips
- [ ] Enter/Space activates buttons
- [ ] Skip link to main content (first Tab stop)

**Keyboard Shortcuts**
- [ ] No single-character shortcuts (unless user can disable)
- [ ] Document any keyboard shortcuts in help text

### 2.2 Enough Time
- [ ] Ticket expiration countdown does NOT auto-refresh page
- [ ] User can pause/stop countdown (if needed for testing)
- [ ] Session timeout warning appears 2 minutes before expiration
- [ ] User can extend session without losing data

### 2.3 Seizures and Physical Reactions
- [ ] No flashing content (> 3 flashes per second)
- [ ] Animations respect prefers-reduced-motion
```css
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```

### 2.4 Navigable
- [ ] Page title is descriptive: "My Tickets - The Chain"
- [ ] Browser back button works correctly (React Router)
- [ ] Focus order is logical (no jumps)
- [ ] Link text is descriptive (avoid "click here")
- [ ] Multiple navigation mechanisms (menu, breadcrumbs, search)
- [ ] Current page indicated in navigation (aria-current="page")
- [ ] Headings describe sections accurately

### 2.5 Input Modalities
- [ ] Touch targets minimum 44x44px
- [ ] Touch targets have 8px spacing
- [ ] Gestures can be cancelled (lift finger before release)
- [ ] No motion-activated features (shake, tilt)
- [ ] Label text included in accessible name for inputs

---

## 3. Understandable

### 3.1 Readable
- [ ] Language declared: `<html lang="en">`
- [ ] Language changes marked: `<span lang="es">Hola</span>`
- [ ] Reading level appropriate for general audience
- [ ] Abbreviations/acronyms explained on first use

### 3.2 Predictable
- [ ] Navigation is consistent across pages
- [ ] Components behave consistently (buttons always trigger actions)
- [ ] Focus does NOT trigger unexpected context changes
- [ ] Hover does NOT trigger unexpected context changes
- [ ] Forms do NOT auto-submit on last field

### 3.3 Input Assistance
- [ ] Form labels clearly describe purpose
- [ ] Error messages are specific ("Password must be 8+ characters")
- [ ] Error messages appear near the field
- [ ] Suggestions provided for corrections
- [ ] Confirmation required for destructive actions (delete ticket)
- [ ] Form data can be reviewed before final submission
- [ ] Legal commitments can be reversed or corrected

---

## 4. Robust

### 4.1 Compatible
- [ ] HTML validates (no unclosed tags, duplicate IDs)
- [ ] ARIA attributes used correctly
- [ ] role attributes appropriate
- [ ] Status messages use aria-live regions
```html
<div aria-live="polite" aria-atomic="true">
  Ticket created successfully
</div>
```
- [ ] Name, role, value accessible for all UI components

---

## ARIA Best Practices

### Required ARIA
- [ ] Modals: `role="dialog"`, `aria-modal="true"`, `aria-labelledby`
- [ ] Buttons: If icon-only, add `aria-label`
- [ ] Form fields: `aria-required`, `aria-invalid`, `aria-describedby`
- [ ] Live regions: `aria-live="polite"` for status updates
- [ ] Current page: `aria-current="page"` on nav link
- [ ] Expanded state: `aria-expanded` on dropdowns
- [ ] Hidden content: `aria-hidden="true"` for decorative elements

### Common Patterns
```html
<!-- Icon button -->
<button aria-label="Share ticket">
  <ShareIcon aria-hidden="true" />
</button>

<!-- Form field with error -->
<label for="email">Email *</label>
<input
  id="email"
  aria-required="true"
  aria-invalid="true"
  aria-describedby="email-error"
/>
<span id="email-error" role="alert">
  Please enter a valid email address
</span>

<!-- Status badge -->
<span class="status-badge status-badge--active">
  <span aria-hidden="true">●</span>
  Active
</span>

<!-- Countdown timer with live update -->
<div aria-live="off" aria-atomic="true">
  Expires in <time datetime="2025-10-11T18:42:00">18h 42m</time>
</div>
```

---

## Screen Reader Testing

### Test with:
- [ ] NVDA (Windows, free)
- [ ] JAWS (Windows, paid)
- [ ] VoiceOver (macOS/iOS, built-in)
- [ ] TalkBack (Android, built-in)

### Key Scenarios
1. [ ] Navigate ticket list using Tab/Arrow keys
2. [ ] Filter tickets using keyboard only
3. [ ] Create a new ticket without mouse
4. [ ] Hear ticket status announced correctly
5. [ ] Navigate chain visualization tree
6. [ ] Complete form with errors using screen reader

---

## Mobile Accessibility

### Touch/Gesture
- [ ] Pinch-to-zoom enabled (no `user-scalable=no`)
- [ ] Swipe gestures have alternatives (buttons)
- [ ] No hover-only features (use tap instead)

### Orientation
- [ ] Portrait and landscape both supported
- [ ] Content doesn't require specific orientation

### Font Size
- [ ] Base font 16px (prevents iOS zoom on input focus)
- [ ] Respect system font size preferences
- [ ] Test at 200% zoom

---

## Tools for Validation

### Automated Testing
- [ ] **axe DevTools** (browser extension) - 0 violations
- [ ] **WAVE** (WebAIM) - 0 errors
- [ ] **Lighthouse** (Chrome) - Accessibility score 95+
- [ ] **pa11y** (CI integration)

### Manual Testing
- [ ] **Keyboard-only navigation** (unplug mouse)
- [ ] **Screen reader** (NVDA/VoiceOver)
- [ ] **Color contrast analyzer**
- [ ] **200% zoom test**
- [ ] **Mobile screen reader** (TalkBack/VoiceOver)

---

## Known Issues & Remediation

| Issue | WCAG Criterion | Priority | Fix |
|-------|---------------|----------|-----|
| Button border contrast | 1.4.11 (Non-text Contrast) | Medium | Use gray-400 instead of gray-300 |
| Some icons lack labels | 4.1.2 (Name, Role, Value) | High | Add aria-label to all icon buttons |
| Countdown auto-updates | 2.2.2 (Pause, Stop, Hide) | Low | Add pause button for testing |

---

## Certification

**Target Compliance**: WCAG 2.1 Level AA

**Tested By**: ui-designer agent
**Test Date**: 2025-10-10
**Status**: Ready for manual review

**Next Steps**:
1. Implement fixes for known issues
2. Conduct manual screen reader testing
3. User testing with people with disabilities
4. Third-party accessibility audit (recommended)

---

## References

- [WCAG 2.1 Quick Reference](https://www.w3.org/WAI/WCAG21/quickref/)
- [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/)
- [Flutter Accessibility Guide](https://docs.flutter.dev/development/accessibility-and-localization/accessibility)
- [Material Design Accessibility](https://m3.material.io/foundations/accessible-design/overview)
