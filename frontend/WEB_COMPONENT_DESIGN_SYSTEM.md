# The Chain - Web Component Design System
**Version:** 1.0
**Date:** October 12, 2025
**Status:** Active
**Design Philosophy:** Dark Mystique with Glass Morphism

---

## 🎨 Design System Overview

The Chain's web interface uses a **Dark Mystique** aesthetic combining:
- **Glass morphism** for depth and modern elegance
- **Gradient overlays** for visual hierarchy
- **Smooth animations** for engagement
- **High contrast** for accessibility
- **Responsive layouts** for all screen sizes

### Core Design Principles
1. **Clarity First** - Information hierarchy is paramount
2. **Emotional Connection** - Visual states convey meaning
3. **Performance** - Lightweight, fast rendering
4. **Accessibility** - WCAG 2.1 AA compliance minimum
5. **Progressive Enhancement** - Works without JavaScript

---

## 🌐 Web-Specific Considerations

### Responsive Breakpoints
```css
/* Mobile First Approach */
xs: 0px - 599px      /* Mobile portrait */
sm: 600px - 959px    /* Mobile landscape, small tablets */
md: 960px - 1279px   /* Tablets, small desktops */
lg: 1280px - 1919px  /* Desktops */
xl: 1920px+          /* Large desktops */
```

### Browser Compatibility
- **Target**: Chrome 90+, Firefox 88+, Safari 14+, Edge 90+
- **Progressive Enhancement**: Core functionality works on older browsers
- **Polyfills**: CSS backdrop-filter fallback for Safari < 14

### Performance Targets
- **First Contentful Paint**: < 1.5s
- **Time to Interactive**: < 3.0s
- **Cumulative Layout Shift**: < 0.1
- **Largest Contentful Paint**: < 2.5s

---

## 🎨 Color System

### Primary Palette
```css
--void-black: #0A0A0F;          /* Deep background */
--shadow-dark: #111827;         /* Card backgrounds */
--mystic-violet: #7C3AED;       /* Primary accent, user highlights */
--mystic-violet-dark: #5B21B6;  /* Darker violet */
--emerald: #10B981;             /* Success, TIP status */
--emerald-dark: #059669;        /* Darker emerald */
--amber: #F59E0B;               /* Warning, pending states */
--amber-dark: #D97706;          /* Darker amber */
--error-red: #EF4444;           /* Errors, wasted tickets */
--error-red-dark: #DC2626;      /* Darker red */
--ghost-cyan: #00D4FF;          /* Subtle accents */
--genesis-gold: #FFD700;        /* Genesis user */
--genesis-gold-dark: #FFA500;   /* Darker gold */
```

### Grayscale Palette
```css
--gray-50: #F9FAFB;
--gray-100: #F3F4F6;
--gray-200: #E5E7EB;
--gray-300: #D1D5DB;
--gray-400: #9CA3AF;
--gray-500: #6B7280;
--gray-600: #4B5563;
--gray-700: #374151;
--gray-800: #1F2937;
--gray-900: #111827;
```

### Semantic Colors
```css
--color-success: var(--emerald);
--color-warning: var(--amber);
--color-error: var(--error-red);
--color-info: var(--ghost-cyan);
--color-primary: var(--mystic-violet);
```

### Glass Morphism
```css
--glass-bg: rgba(31, 41, 55, 0.6);        /* Base glass */
--glass-border: rgba(255, 255, 255, 0.1); /* Subtle border */
--glass-highlight: rgba(255, 255, 255, 0.05); /* Inner highlight */
```

---

## 📐 Typography

### Font Stack
```css
--font-primary: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI',
                Roboto, 'Helvetica Neue', Arial, sans-serif;
--font-mono: 'SF Mono', 'Monaco', 'Cascadia Code', 'Roboto Mono',
             Courier, monospace;
```

### Type Scale
```css
--text-xs: 0.75rem;      /* 12px - Captions, timestamps */
--text-sm: 0.875rem;     /* 14px - Secondary text */
--text-base: 1rem;       /* 16px - Body text */
--text-lg: 1.125rem;     /* 18px - Subheadings */
--text-xl: 1.25rem;      /* 20px - Card titles */
--text-2xl: 1.5rem;      /* 24px - Section headers */
--text-3xl: 1.875rem;    /* 30px - Page titles */
--text-4xl: 2.25rem;     /* 36px - Hero text */
--text-5xl: 3rem;        /* 48px - Marketing hero */
```

### Font Weights
```css
--font-normal: 400;
--font-medium: 500;
--font-semibold: 600;
--font-bold: 700;
--font-extrabold: 800;
```

### Line Heights
```css
--leading-tight: 1.25;    /* Headlines */
--leading-snug: 1.375;    /* Subheadings */
--leading-normal: 1.5;    /* Body text */
--leading-relaxed: 1.625; /* Long-form content */
```

---

## 🧩 Core Web Components

### 1. **Button Component**

#### Variants
```css
/* Primary Button - CTA actions */
.btn-primary {
  background: linear-gradient(135deg, #7C3AED 0%, #5B21B6 100%);
  color: white;
  border: none;
  box-shadow: 0 4px 12px rgba(124, 58, 237, 0.4);
}
.btn-primary:hover {
  box-shadow: 0 6px 16px rgba(124, 58, 237, 0.6);
  transform: translateY(-2px);
}

/* Secondary Button - Secondary actions */
.btn-secondary {
  background: var(--glass-bg);
  color: white;
  border: 1px solid var(--glass-border);
  backdrop-filter: blur(10px);
}
.btn-secondary:hover {
  background: rgba(31, 41, 55, 0.8);
  border-color: rgba(255, 255, 255, 0.2);
}

/* Ghost Button - Tertiary actions */
.btn-ghost {
  background: transparent;
  color: rgba(255, 255, 255, 0.8);
  border: 1px solid transparent;
}
.btn-ghost:hover {
  background: rgba(255, 255, 255, 0.05);
  color: white;
}

/* Danger Button - Destructive actions */
.btn-danger {
  background: linear-gradient(135deg, #EF4444 0%, #DC2626 100%);
  color: white;
  border: none;
}
```

#### Sizes
```css
.btn-sm {
  padding: 0.5rem 1rem;
  font-size: 0.875rem;
  border-radius: 0.5rem;
}

.btn-md {
  padding: 0.75rem 1.5rem;
  font-size: 1rem;
  border-radius: 0.75rem;
}

.btn-lg {
  padding: 1rem 2rem;
  font-size: 1.125rem;
  border-radius: 1rem;
}
```

#### States
```css
.btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  pointer-events: none;
}

.btn:focus-visible {
  outline: 2px solid var(--mystic-violet);
  outline-offset: 2px;
}

.btn:active {
  transform: scale(0.98);
}
```

---

### 2. **Input Component**

```css
.input {
  background: var(--glass-bg);
  border: 1px solid var(--glass-border);
  border-radius: 0.75rem;
  padding: 0.75rem 1rem;
  color: white;
  font-size: 1rem;
  backdrop-filter: blur(10px);
  transition: all 0.2s ease;
}

.input::placeholder {
  color: rgba(255, 255, 255, 0.4);
}

.input:focus {
  outline: none;
  border-color: var(--mystic-violet);
  box-shadow: 0 0 0 3px rgba(124, 58, 237, 0.1);
}

.input:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.input.error {
  border-color: var(--error-red);
}

.input.success {
  border-color: var(--emerald);
}
```

---

### 3. **Card Component**

```css
.card {
  background: var(--glass-bg);
  border: 1px solid var(--glass-border);
  border-radius: 1.25rem;
  padding: 1.5rem;
  backdrop-filter: blur(10px);
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
}

.card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.2);
}

/* Card with gradient border */
.card-gradient {
  position: relative;
  background: var(--shadow-dark);
  border: 2px solid transparent;
  background-clip: padding-box;
}

.card-gradient::before {
  content: '';
  position: absolute;
  inset: 0;
  border-radius: 1.25rem;
  padding: 2px;
  background: linear-gradient(135deg, #7C3AED, #10B981);
  -webkit-mask:
    linear-gradient(#fff 0 0) content-box,
    linear-gradient(#fff 0 0);
  mask:
    linear-gradient(#fff 0 0) content-box,
    linear-gradient(#fff 0 0);
  -webkit-mask-composite: xor;
  mask-composite: exclude;
}
```

---

### 4. **Badge Component**

```css
.badge {
  display: inline-flex;
  align-items: center;
  padding: 0.25rem 0.75rem;
  border-radius: 9999px;
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.badge-success {
  background: rgba(16, 185, 129, 0.2);
  color: #10B981;
  border: 1px solid rgba(16, 185, 129, 0.3);
}

.badge-warning {
  background: rgba(245, 158, 11, 0.2);
  color: #F59E0B;
  border: 1px solid rgba(245, 158, 11, 0.3);
}

.badge-error {
  background: rgba(239, 68, 68, 0.2);
  color: #EF4444;
  border: 1px solid rgba(239, 68, 68, 0.3);
}

.badge-primary {
  background: rgba(124, 58, 237, 0.2);
  color: #7C3AED;
  border: 1px solid rgba(124, 58, 237, 0.3);
}

.badge-you {
  background: linear-gradient(135deg, #7C3AED, #5B21B6);
  color: white;
  border: none;
  box-shadow: 0 2px 8px rgba(124, 58, 237, 0.4);
}
```

---

### 5. **Avatar Component**

```css
.avatar {
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  overflow: hidden;
  font-weight: 700;
  color: white;
}

.avatar-sm {
  width: 2rem;
  height: 2rem;
  font-size: 0.875rem;
}

.avatar-md {
  width: 3rem;
  height: 3rem;
  font-size: 1.125rem;
}

.avatar-lg {
  width: 4rem;
  height: 4rem;
  font-size: 1.5rem;
}

.avatar-default {
  background: linear-gradient(135deg, #4B5563, #374151);
}

.avatar-primary {
  background: linear-gradient(135deg, #7C3AED, #5B21B6);
  box-shadow: 0 4px 12px rgba(124, 58, 237, 0.4);
}

.avatar-genesis {
  background: linear-gradient(135deg, #FFD700, #FFA500);
  box-shadow: 0 4px 12px rgba(255, 215, 0, 0.4);
}

.avatar-tip {
  background: linear-gradient(135deg, #10B981, #059669);
  box-shadow: 0 4px 12px rgba(16, 185, 129, 0.4);
  animation: pulse-glow 2s ease-in-out infinite;
}

@keyframes pulse-glow {
  0%, 100% {
    box-shadow: 0 4px 12px rgba(16, 185, 129, 0.4);
  }
  50% {
    box-shadow: 0 6px 20px rgba(16, 185, 129, 0.7);
  }
}
```

---

### 6. **Status Indicator**

```css
.status-indicator {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.status-dot {
  width: 0.5rem;
  height: 0.5rem;
  border-radius: 50%;
  animation: pulse-dot 2s ease-in-out infinite;
}

.status-dot-active {
  background: #10B981;
  box-shadow: 0 0 8px rgba(16, 185, 129, 0.5);
}

.status-dot-pending {
  background: #F59E0B;
  box-shadow: 0 0 8px rgba(245, 158, 11, 0.5);
}

.status-dot-inactive {
  background: #6B7280;
  box-shadow: none;
  animation: none;
}

@keyframes pulse-dot {
  0%, 100% {
    opacity: 1;
  }
  50% {
    opacity: 0.6;
  }
}
```

---

### 7. **QR Code Display**

```css
.qr-container {
  background: white;
  padding: 1.5rem;
  border-radius: 1rem;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.3);
  display: inline-flex;
  flex-direction: column;
  align-items: center;
  gap: 1rem;
}

.qr-code {
  width: 256px;
  height: 256px;
  border: 4px solid var(--void-black);
  border-radius: 0.5rem;
}

.qr-label {
  color: var(--void-black);
  font-weight: 600;
  font-size: 0.875rem;
  text-align: center;
}

.qr-timer {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 1rem;
  background: rgba(245, 158, 11, 0.1);
  border: 1px solid rgba(245, 158, 11, 0.3);
  border-radius: 9999px;
  color: #F59E0B;
  font-weight: 600;
  font-size: 0.875rem;
}
```

---

### 8. **Chain Visualization Components**

#### Chain Link Connector
```css
.chain-link {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 2rem;
  position: relative;
}

.chain-link::before {
  content: '';
  position: absolute;
  width: 2px;
  height: 100%;
  background: linear-gradient(
    to bottom,
    rgba(124, 58, 237, 0.5) 0%,
    rgba(124, 58, 237, 0.2) 50%,
    rgba(124, 58, 237, 0) 100%
  );
}

.chain-link-icon {
  color: rgba(255, 255, 255, 0.3);
  font-size: 1rem;
}
```

#### Ellipsis Indicator
```css
.chain-ellipsis {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 1rem;
  gap: 0.25rem;
}

.chain-ellipsis-dot {
  width: 0.375rem;
  height: 0.375rem;
  background: rgba(255, 255, 255, 0.3);
  border-radius: 50%;
}

.chain-ellipsis-label {
  font-size: 0.75rem;
  color: rgba(255, 255, 255, 0.5);
  font-weight: 500;
  margin-top: 0.5rem;
}
```

---

## 🎭 Animation System

### Transitions
```css
/* Standard transition */
.transition {
  transition: all 0.2s ease-out;
}

/* Color transition */
.transition-colors {
  transition: color 0.2s ease-out, background-color 0.2s ease-out, border-color 0.2s ease-out;
}

/* Transform transition */
.transition-transform {
  transition: transform 0.2s ease-out;
}
```

### Keyframe Animations
```css
/* Gentle breathing pulse */
@keyframes breathe {
  0%, 100% {
    opacity: 1;
    transform: scale(1);
  }
  50% {
    opacity: 0.9;
    transform: scale(1.02);
  }
}

/* Shimmer effect */
@keyframes shimmer {
  0% {
    background-position: -200% center;
  }
  100% {
    background-position: 200% center;
  }
}

.shimmer {
  background: linear-gradient(
    90deg,
    transparent 0%,
    rgba(255, 255, 255, 0.1) 50%,
    transparent 100%
  );
  background-size: 200% 100%;
  animation: shimmer 2s linear infinite;
}

/* Fade in */
@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* Slide in from bottom */
@keyframes slideInUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
```

### Motion Preferences
```css
@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

---

## ♿ Accessibility

### Focus Management
```css
/* Custom focus ring */
:focus-visible {
  outline: 2px solid var(--mystic-violet);
  outline-offset: 2px;
  border-radius: 0.25rem;
}

/* Skip to main content link */
.skip-to-main {
  position: absolute;
  top: -40px;
  left: 0;
  background: var(--mystic-violet);
  color: white;
  padding: 0.5rem 1rem;
  text-decoration: none;
  border-radius: 0 0 0.5rem 0;
  z-index: 9999;
}

.skip-to-main:focus {
  top: 0;
}
```

### ARIA Patterns
```html
<!-- Button with loading state -->
<button aria-busy="true" aria-label="Generating invitation ticket">
  <span aria-hidden="true">Loading...</span>
</button>

<!-- Status indicator -->
<div role="status" aria-live="polite" aria-atomic="true">
  Ticket expires in 23 hours
</div>

<!-- Card with expandable details -->
<div role="button" aria-expanded="false" aria-controls="card-details" tabindex="0">
  <!-- Card content -->
</div>
```

### Color Contrast
- **Normal text**: Minimum 4.5:1 contrast ratio
- **Large text (18pt+)**: Minimum 3:1 contrast ratio
- **UI components**: Minimum 3:1 contrast ratio

---

## 📱 Responsive Patterns

### Mobile-First Grid
```css
.container {
  width: 100%;
  padding: 0 1rem;
  margin: 0 auto;
}

@media (min-width: 640px) {
  .container {
    max-width: 640px;
  }
}

@media (min-width: 768px) {
  .container {
    max-width: 768px;
    padding: 0 2rem;
  }
}

@media (min-width: 1024px) {
  .container {
    max-width: 1024px;
  }
}

@media (min-width: 1280px) {
  .container {
    max-width: 1280px;
  }
}
```

### Stack Layout (Mobile)
```css
.stack {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

@media (min-width: 768px) {
  .stack-md-row {
    flex-direction: row;
  }
}
```

### Responsive Typography
```css
.heading-responsive {
  font-size: clamp(1.5rem, 4vw, 3rem);
  line-height: 1.2;
}

.text-responsive {
  font-size: clamp(0.875rem, 2vw, 1rem);
  line-height: 1.6;
}
```

---

## 🎯 Component Usage Examples

### Example 1: Hero Section (Public App)
```html
<section class="hero">
  <div class="container">
    <h1 class="heading-responsive">Join The Chain</h1>
    <p class="text-responsive text-gray-400">
      A global experiment in human connection
    </p>
    <div class="chain-stats">
      <div class="stat-card">
        <span class="stat-number">1,247</span>
        <span class="stat-label">Members</span>
      </div>
      <div class="stat-card">
        <span class="stat-number">89</span>
        <span class="stat-label">Countries</span>
      </div>
    </div>
  </div>
</section>
```

### Example 2: Person Card List (Private App)
```html
<div class="chain-view">
  <!-- Genesis User -->
  <div class="card person-card genesis">
    <div class="avatar avatar-lg avatar-genesis">A</div>
    <div class="person-info">
      <h3>Alpaslan</h3>
      <span class="chain-key">ABCD1234</span>
      <div class="badge badge-genesis">🌱 GENESIS</div>
    </div>
  </div>

  <!-- Chain link -->
  <div class="chain-link">
    <span class="chain-link-icon">↓</span>
  </div>

  <!-- Current user -->
  <div class="card person-card current-user">
    <div class="avatar avatar-lg avatar-primary">J</div>
    <div class="person-info">
      <h3>John Doe</h3>
      <span class="chain-key">EFGH5678</span>
      <div class="status-indicator">
        <span class="status-dot status-dot-active"></span>
        <span>Active</span>
      </div>
    </div>
    <div class="badge badge-you">YOU</div>
  </div>
</div>
```

### Example 3: Ticket Generation (Private App)
```html
<div class="ticket-generator">
  <h2>Generate Your Invitation</h2>
  <p>Share this QR code with one person to invite them to The Chain</p>

  <div class="qr-container">
    <img src="/qr/abc123.png" alt="Invitation QR Code" class="qr-code" />
    <span class="qr-label">Scan to Join</span>
    <div class="qr-timer">
      <span>⏰</span>
      <span>Expires in 23h 45m</span>
    </div>
  </div>

  <div class="actions">
    <button class="btn-primary btn-lg">Download QR Code</button>
    <button class="btn-secondary btn-lg">Share Link</button>
  </div>
</div>
```

---

## 🚀 Implementation Roadmap

### Phase 1: Core Components (Week 1)
- [ ] Button variants and states
- [ ] Input fields and validation states
- [ ] Card component with glass morphism
- [ ] Avatar component with variants
- [ ] Badge component
- [ ] Typography system

### Phase 2: Chain-Specific Components (Week 2)
- [ ] Person card variants (8 types)
- [ ] Chain link connector
- [ ] Ellipsis indicator
- [ ] QR code display
- [ ] Status indicators
- [ ] Ticket timer

### Phase 3: Layout & Navigation (Week 3)
- [ ] Responsive grid system
- [ ] Navigation bar
- [ ] Sidebar (if needed)
- [ ] Footer
- [ ] Modal/Dialog
- [ ] Toast notifications

### Phase 4: Advanced Features (Week 4)
- [ ] Animations and transitions
- [ ] Loading states
- [ ] Error states
- [ ] Empty states
- [ ] Skeleton screens
- [ ] Progress indicators

---

## 📚 Resources

### Design Tools
- **Figma**: Component library and prototypes
- **CSS Variables**: For easy theming
- **PostCSS**: For vendor prefixing
- **SASS/SCSS**: For advanced styling (optional)

### Testing
- **Accessibility**: axe DevTools, WAVE
- **Responsive**: BrowserStack, Responsively
- **Performance**: Lighthouse, WebPageTest
- **Cross-browser**: Sauce Labs

### Documentation
- [Flutter for Web](https://flutter.dev/web)
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [Material Design](https://material.io/design)
- [MDN Web Docs](https://developer.mozilla.org/)

---

## 📝 Notes

### Flutter Web Considerations
1. **CSS Compatibility**: Flutter web generates its own CSS - custom styling may conflict
2. **Performance**: Flutter web apps can be large initially (~2MB gzip)
3. **SEO**: Limited SEO capabilities - consider SSR for public pages
4. **Accessibility**: Flutter web accessibility is improving but requires extra attention

### Recommended Approach
- **Public App**: Consider HTML/CSS/JavaScript for better SEO and performance
- **Private App**: Flutter web is excellent for rich, authenticated experiences
- **Shared Components**: Use design tokens that work across both approaches

---

**Last Updated**: October 12, 2025
**Maintained By**: UI Designer Hat (Orchestrator)
**Status**: Living Document - Update as components evolve
