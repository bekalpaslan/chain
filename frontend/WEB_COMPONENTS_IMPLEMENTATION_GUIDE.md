# Web Components Implementation Guide
**For The Chain Project**
**Version:** 1.0
**Date:** October 12, 2025

---

## 🎯 Purpose

This guide provides **practical, ready-to-use code** for implementing The Chain's web components. Use this alongside the [WEB_COMPONENT_DESIGN_SYSTEM.md](WEB_COMPONENT_DESIGN_SYSTEM.md) for design specifications.

---

## 🛠️ Setup

### 1. CSS Reset & Base Styles

Create `frontend/public-app/web/css/base.css`:

```css
/* ============================================
   MODERN CSS RESET
   ============================================ */

*, *::before, *::after {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

html {
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-rendering: optimizeLegibility;
}

body {
  font-family: var(--font-primary);
  background-color: var(--void-black);
  color: white;
  line-height: var(--leading-normal);
  min-height: 100vh;
}

/* ============================================
   CSS VARIABLES
   ============================================ */

:root {
  /* Colors */
  --void-black: #0A0A0F;
  --shadow-dark: #111827;
  --mystic-violet: #7C3AED;
  --mystic-violet-dark: #5B21B6;
  --emerald: #10B981;
  --emerald-dark: #059669;
  --amber: #F59E0B;
  --amber-dark: #D97706;
  --error-red: #EF4444;
  --error-red-dark: #DC2626;
  --ghost-cyan: #00D4FF;
  --genesis-gold: #FFD700;
  --genesis-gold-dark: #FFA500;

  /* Grayscale */
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

  /* Glass morphism */
  --glass-bg: rgba(31, 41, 55, 0.6);
  --glass-border: rgba(255, 255, 255, 0.1);
  --glass-highlight: rgba(255, 255, 255, 0.05);

  /* Typography */
  --font-primary: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI',
                  Roboto, 'Helvetica Neue', Arial, sans-serif;
  --font-mono: 'SF Mono', 'Monaco', 'Cascadia Code', 'Roboto Mono',
               Courier, monospace;

  /* Type scale */
  --text-xs: 0.75rem;
  --text-sm: 0.875rem;
  --text-base: 1rem;
  --text-lg: 1.125rem;
  --text-xl: 1.25rem;
  --text-2xl: 1.5rem;
  --text-3xl: 1.875rem;
  --text-4xl: 2.25rem;

  /* Font weights */
  --font-normal: 400;
  --font-medium: 500;
  --font-semibold: 600;
  --font-bold: 700;

  /* Line heights */
  --leading-tight: 1.25;
  --leading-snug: 1.375;
  --leading-normal: 1.5;
  --leading-relaxed: 1.625;

  /* Spacing */
  --spacing-1: 0.25rem;
  --spacing-2: 0.5rem;
  --spacing-3: 0.75rem;
  --spacing-4: 1rem;
  --spacing-5: 1.25rem;
  --spacing-6: 1.5rem;
  --spacing-8: 2rem;
  --spacing-10: 2.5rem;
  --spacing-12: 3rem;
  --spacing-16: 4rem;

  /* Border radius */
  --radius-sm: 0.5rem;
  --radius-md: 0.75rem;
  --radius-lg: 1rem;
  --radius-xl: 1.25rem;
  --radius-full: 9999px;

  /* Shadows */
  --shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.05);
  --shadow-md: 0 4px 6px rgba(0, 0, 0, 0.1);
  --shadow-lg: 0 8px 16px rgba(0, 0, 0, 0.2);
  --shadow-xl: 0 12px 24px rgba(0, 0, 0, 0.3);

  /* Transitions */
  --transition-fast: 100ms ease-in-out;
  --transition-base: 200ms ease-in-out;
  --transition-slow: 300ms ease-in-out;
}

/* ============================================
   UTILITY CLASSES
   ============================================ */

.container {
  width: 100%;
  padding: 0 var(--spacing-4);
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
    padding: 0 var(--spacing-8);
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

/* Accessibility */
.sr-only {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border-width: 0;
}

.skip-to-main {
  position: absolute;
  top: -40px;
  left: 0;
  background: var(--mystic-violet);
  color: white;
  padding: var(--spacing-2) var(--spacing-4);
  text-decoration: none;
  border-radius: 0 0 var(--radius-sm) 0;
  z-index: 9999;
  font-weight: var(--font-semibold);
}

.skip-to-main:focus {
  top: 0;
}

/* Focus styles */
:focus-visible {
  outline: 2px solid var(--mystic-violet);
  outline-offset: 2px;
}

/* Reduced motion */
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

## 🧩 Component Library

### 1. Button Component

Create `frontend/shared/web/components/button.css`:

```css
/* ============================================
   BUTTON COMPONENT
   ============================================ */

.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: var(--spacing-2);
  font-weight: var(--font-semibold);
  border: none;
  cursor: pointer;
  transition: all var(--transition-base);
  text-decoration: none;
  font-family: var(--font-primary);
  white-space: nowrap;
}

/* Sizes */
.btn-sm {
  padding: var(--spacing-2) var(--spacing-4);
  font-size: var(--text-sm);
  border-radius: var(--radius-sm);
}

.btn-md {
  padding: var(--spacing-3) var(--spacing-6);
  font-size: var(--text-base);
  border-radius: var(--radius-md);
}

.btn-lg {
  padding: var(--spacing-4) var(--spacing-8);
  font-size: var(--text-lg);
  border-radius: var(--radius-lg);
}

/* Variants */
.btn-primary {
  background: linear-gradient(135deg, var(--mystic-violet) 0%, var(--mystic-violet-dark) 100%);
  color: white;
  box-shadow: 0 4px 12px rgba(124, 58, 237, 0.4);
}

.btn-primary:hover:not(:disabled) {
  box-shadow: 0 6px 16px rgba(124, 58, 237, 0.6);
  transform: translateY(-2px);
}

.btn-primary:active:not(:disabled) {
  transform: translateY(0);
}

.btn-secondary {
  background: var(--glass-bg);
  color: white;
  border: 1px solid var(--glass-border);
  backdrop-filter: blur(10px);
}

.btn-secondary:hover:not(:disabled) {
  background: rgba(31, 41, 55, 0.8);
  border-color: rgba(255, 255, 255, 0.2);
}

.btn-ghost {
  background: transparent;
  color: rgba(255, 255, 255, 0.8);
  border: 1px solid transparent;
}

.btn-ghost:hover:not(:disabled) {
  background: rgba(255, 255, 255, 0.05);
  color: white;
}

.btn-danger {
  background: linear-gradient(135deg, var(--error-red) 0%, var(--error-red-dark) 100%);
  color: white;
}

.btn-danger:hover:not(:disabled) {
  box-shadow: 0 6px 16px rgba(239, 68, 68, 0.6);
  transform: translateY(-2px);
}

/* States */
.btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  pointer-events: none;
}

.btn:focus-visible {
  outline: 2px solid var(--mystic-violet);
  outline-offset: 2px;
}

.btn-loading {
  position: relative;
  color: transparent;
  pointer-events: none;
}

.btn-loading::after {
  content: '';
  position: absolute;
  width: 16px;
  height: 16px;
  top: 50%;
  left: 50%;
  margin-left: -8px;
  margin-top: -8px;
  border: 2px solid white;
  border-radius: 50%;
  border-top-color: transparent;
  animation: spin 0.6s linear infinite;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}
```

**HTML Examples:**

```html
<!-- Primary button -->
<button class="btn btn-primary btn-md">Generate Ticket</button>

<!-- Secondary button -->
<button class="btn btn-secondary btn-md">Cancel</button>

<!-- Ghost button -->
<button class="btn btn-ghost btn-sm">Learn More</button>

<!-- Danger button -->
<button class="btn btn-danger btn-md">Delete Account</button>

<!-- Disabled button -->
<button class="btn btn-primary btn-md" disabled>Processing...</button>

<!-- Loading button -->
<button class="btn btn-primary btn-md btn-loading">Loading</button>

<!-- Button with icon -->
<button class="btn btn-primary btn-lg">
  <svg width="20" height="20" viewBox="0 0 20 20" fill="currentColor">
    <path d="M10 5v10m5-5H5"/>
  </svg>
  Create Invitation
</button>
```

---

### 2. Input Component

Create `frontend/shared/web/components/input.css`:

```css
/* ============================================
   INPUT COMPONENT
   ============================================ */

.form-group {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-2);
}

.form-label {
  font-size: var(--text-sm);
  font-weight: var(--font-medium);
  color: rgba(255, 255, 255, 0.9);
}

.form-label-required::after {
  content: '*';
  color: var(--error-red);
  margin-left: var(--spacing-1);
}

.input {
  background: var(--glass-bg);
  border: 1px solid var(--glass-border);
  border-radius: var(--radius-md);
  padding: var(--spacing-3) var(--spacing-4);
  color: white;
  font-size: var(--text-base);
  font-family: var(--font-primary);
  backdrop-filter: blur(10px);
  transition: all var(--transition-base);
  width: 100%;
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
  background: rgba(31, 41, 55, 0.3);
}

/* States */
.input.error {
  border-color: var(--error-red);
}

.input.error:focus {
  box-shadow: 0 0 0 3px rgba(239, 68, 68, 0.1);
}

.input.success {
  border-color: var(--emerald);
}

.input.success:focus {
  box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.1);
}

/* Help text */
.form-help {
  font-size: var(--text-sm);
  color: rgba(255, 255, 255, 0.6);
}

.form-error {
  font-size: var(--text-sm);
  color: var(--error-red);
  display: flex;
  align-items: center;
  gap: var(--spacing-1);
}

.form-success {
  font-size: var(--text-sm);
  color: var(--emerald);
  display: flex;
  align-items: center;
  gap: var(--spacing-1);
}

/* Input with icon */
.input-group {
  position: relative;
  display: flex;
  align-items: center;
}

.input-icon {
  position: absolute;
  left: var(--spacing-4);
  color: rgba(255, 255, 255, 0.5);
  pointer-events: none;
}

.input-group .input {
  padding-left: var(--spacing-10);
}
```

**HTML Examples:**

```html
<!-- Basic input -->
<div class="form-group">
  <label for="email" class="form-label form-label-required">Email</label>
  <input
    type="email"
    id="email"
    class="input"
    placeholder="you@example.com"
    required
  />
  <span class="form-help">We'll never share your email</span>
</div>

<!-- Input with error -->
<div class="form-group">
  <label for="password" class="form-label">Password</label>
  <input
    type="password"
    id="password"
    class="input error"
    placeholder="Enter password"
  />
  <span class="form-error">
    <svg width="16" height="16" fill="currentColor" viewBox="0 0 20 20">
      <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z"/>
    </svg>
    Password must be at least 8 characters
  </span>
</div>

<!-- Input with icon -->
<div class="form-group">
  <label for="search" class="form-label">Search</label>
  <div class="input-group">
    <svg class="input-icon" width="20" height="20" fill="currentColor" viewBox="0 0 20 20">
      <path fill-rule="evenodd" d="M8 4a4 4 0 100 8 4 4 0 000-8zM2 8a6 6 0 1110.89 3.476l4.817 4.817a1 1 0 01-1.414 1.414l-4.816-4.816A6 6 0 012 8z"/>
    </svg>
    <input
      type="text"
      id="search"
      class="input"
      placeholder="Search members..."
    />
  </div>
</div>
```

---

### 3. Person Card Component

Create `frontend/private-app/web/components/person-card.css`:

```css
/* ============================================
   PERSON CARD COMPONENT
   ============================================ */

.person-card {
  display: flex;
  align-items: center;
  gap: var(--spacing-5);
  padding: var(--spacing-6);
  border-radius: var(--radius-xl);
  backdrop-filter: blur(10px);
  transition: all var(--transition-slow);
  max-width: 400px;
}

.person-card:hover {
  transform: translateY(-2px);
}

/* Card variants */
.person-card-default {
  background: linear-gradient(
    135deg,
    rgba(31, 41, 55, 0.6) 0%,
    rgba(17, 24, 39, 0.4) 100%
  );
  border: 1px solid var(--glass-border);
  box-shadow: var(--shadow-md);
}

.person-card-current {
  background: linear-gradient(
    135deg,
    rgba(124, 58, 237, 0.2) 0%,
    rgba(91, 33, 182, 0.15) 100%
  );
  border: 1.5px solid rgba(124, 58, 237, 0.5);
  box-shadow: 0 4px 20px rgba(124, 58, 237, 0.3);
  animation: breathe 3s ease-in-out infinite;
}

.person-card-tip {
  background: linear-gradient(
    135deg,
    var(--emerald) 0%,
    var(--emerald-dark) 100%
  );
  border: 2px solid var(--emerald);
  box-shadow: 0 6px 24px rgba(16, 185, 129, 0.5);
  animation: pulse-glow 2s ease-in-out infinite;
}

.person-card-genesis {
  background: linear-gradient(
    135deg,
    rgba(255, 215, 0, 0.3) 0%,
    rgba(255, 165, 0, 0.2) 100%
  );
  border: 2px solid var(--genesis-gold);
  box-shadow: 0 6px 24px rgba(255, 215, 0, 0.4);
}

.person-card-pending {
  background: linear-gradient(
    135deg,
    rgba(245, 158, 11, 0.15) 0%,
    rgba(217, 119, 6, 0.1) 100%
  );
  border: 1.5px dashed var(--amber);
  box-shadow: 0 4px 16px rgba(245, 158, 11, 0.2);
  animation: border-pulse 2s ease-in-out infinite;
}

.person-card-ghost {
  background: rgba(31, 41, 55, 0.3);
  border: 1px dashed rgba(255, 255, 255, 0.3);
  opacity: 0.6;
}

/* Avatar */
.person-avatar {
  width: 64px;
  height: 64px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: var(--text-2xl);
  font-weight: var(--font-bold);
  color: white;
  flex-shrink: 0;
}

.person-avatar-default {
  background: linear-gradient(135deg, var(--gray-600), var(--gray-700));
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
}

.person-avatar-current {
  background: linear-gradient(135deg, var(--mystic-violet), var(--mystic-violet-dark));
  box-shadow: 0 4px 15px rgba(124, 58, 237, 0.4);
}

.person-avatar-tip {
  background: linear-gradient(135deg, var(--emerald), var(--emerald-dark));
  box-shadow: 0 4px 15px rgba(16, 185, 129, 0.4);
}

.person-avatar-genesis {
  background: linear-gradient(135deg, var(--genesis-gold), var(--genesis-gold-dark));
  box-shadow: 0 4px 15px rgba(255, 215, 0, 0.4);
}

/* Content */
.person-content {
  flex: 1;
  min-width: 0;
}

.person-name {
  font-size: var(--text-xl);
  font-weight: var(--font-semibold);
  color: white;
  margin-bottom: var(--spacing-2);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.person-meta {
  display: flex;
  align-items: center;
  gap: var(--spacing-2);
  flex-wrap: wrap;
}

.person-position {
  display: inline-flex;
  align-items: center;
  padding: var(--spacing-1) var(--spacing-3);
  background: var(--gray-700);
  border-radius: var(--radius-full);
  font-size: var(--text-sm);
  font-weight: var(--font-semibold);
  color: white;
}

.person-card-current .person-position {
  background: var(--mystic-violet);
}

.person-chain-key {
  font-size: var(--text-sm);
  font-weight: var(--font-medium);
  color: rgba(255, 255, 255, 0.6);
  font-family: var(--font-mono);
}

/* Status indicator */
.person-status {
  display: flex;
  align-items: center;
  gap: var(--spacing-2);
  margin-top: var(--spacing-2);
  font-size: var(--text-sm);
  color: rgba(255, 255, 255, 0.7);
}

.status-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  animation: pulse-dot 2s ease-in-out infinite;
}

.status-dot-active {
  background: var(--emerald);
  box-shadow: 0 0 8px rgba(16, 185, 129, 0.5);
}

.status-dot-pending {
  background: var(--amber);
  box-shadow: 0 0 8px rgba(245, 158, 11, 0.5);
}

.status-dot-inactive {
  background: var(--gray-500);
  animation: none;
}

/* Badges */
.person-badges {
  display: flex;
  gap: var(--spacing-2);
  flex-shrink: 0;
}

.person-badge {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: var(--spacing-2) var(--spacing-3);
  border-radius: var(--radius-full);
  font-size: 11px;
  font-weight: var(--font-bold);
  letter-spacing: 0.05em;
  text-transform: uppercase;
  white-space: nowrap;
}

.person-badge-you {
  background: linear-gradient(135deg, var(--mystic-violet), var(--mystic-violet-dark));
  color: white;
  box-shadow: 0 2px 8px rgba(124, 58, 237, 0.4);
}

.person-badge-tip {
  background: linear-gradient(135deg, var(--emerald), var(--emerald-dark));
  color: white;
  box-shadow: 0 2px 8px rgba(16, 185, 129, 0.4);
}

.person-badge-genesis {
  background: linear-gradient(135deg, var(--genesis-gold), var(--genesis-gold-dark));
  color: var(--void-black);
  box-shadow: 0 2px 8px rgba(255, 215, 0, 0.4);
}

/* Animations */
@keyframes breathe {
  0%, 100% {
    opacity: 1;
    transform: scale(1);
  }
  50% {
    opacity: 0.95;
    transform: scale(1.01);
  }
}

@keyframes pulse-glow {
  0%, 100% {
    box-shadow: 0 6px 24px rgba(16, 185, 129, 0.5);
  }
  50% {
    box-shadow: 0 8px 32px rgba(16, 185, 129, 0.7);
  }
}

@keyframes pulse-dot {
  0%, 100% {
    opacity: 1;
  }
  50% {
    opacity: 0.6;
  }
}

@keyframes border-pulse {
  0%, 100% {
    border-color: var(--amber);
  }
  50% {
    border-color: rgba(245, 158, 11, 0.5);
  }
}

/* Responsive */
@media (max-width: 640px) {
  .person-card {
    padding: var(--spacing-4);
    gap: var(--spacing-4);
  }

  .person-avatar {
    width: 48px;
    height: 48px;
    font-size: var(--text-xl);
  }

  .person-name {
    font-size: var(--text-lg);
  }
}
```

**HTML Examples:**

```html
<!-- Default member card -->
<div class="person-card person-card-default">
  <div class="person-avatar person-avatar-default">J</div>
  <div class="person-content">
    <div class="person-name">John Doe</div>
    <div class="person-meta">
      <span class="person-position">#42</span>
      <span class="person-chain-key">ABCD1234</span>
    </div>
    <div class="person-status">
      <span class="status-dot status-dot-active"></span>
      <span>Active</span>
    </div>
  </div>
</div>

<!-- Current user card -->
<div class="person-card person-card-current">
  <div class="person-avatar person-avatar-current">Y</div>
  <div class="person-content">
    <div class="person-name">You</div>
    <div class="person-meta">
      <span class="person-position">#43</span>
      <span class="person-chain-key">EFGH5678</span>
    </div>
    <div class="person-status">
      <span class="status-dot status-dot-active"></span>
      <span>Active</span>
    </div>
  </div>
  <div class="person-badges">
    <span class="person-badge person-badge-you">YOU</span>
  </div>
</div>

<!-- TIP card (can invite) -->
<div class="person-card person-card-tip">
  <div class="person-avatar person-avatar-tip">A</div>
  <div class="person-content">
    <div class="person-name">Alice Smith</div>
    <div class="person-meta">
      <span class="person-position">#44</span>
      <span class="person-chain-key">IJKL9012</span>
    </div>
    <div class="person-status">
      <span class="status-dot status-dot-active"></span>
      <span>Can Invite</span>
    </div>
  </div>
  <div class="person-badges">
    <span class="person-badge person-badge-tip">⚡ TIP</span>
  </div>
</div>

<!-- Genesis card (first member) -->
<div class="person-card person-card-genesis">
  <div class="person-avatar person-avatar-genesis">A</div>
  <div class="person-content">
    <div class="person-name">Alpaslan</div>
    <div class="person-meta">
      <span class="person-position">#1</span>
      <span class="person-chain-key">SEED0000</span>
    </div>
    <div class="person-status">
      <span class="status-dot status-dot-active"></span>
      <span>Seed User</span>
    </div>
  </div>
  <div class="person-badges">
    <span class="person-badge person-badge-genesis">🌱 GENESIS</span>
  </div>
</div>

<!-- Pending invitation card -->
<div class="person-card person-card-pending">
  <div class="person-avatar person-avatar-default">?</div>
  <div class="person-content">
    <div class="person-name">Pending Invitation</div>
    <div class="person-meta">
      <span class="person-position">#45</span>
    </div>
    <div class="person-status">
      <span class="status-dot status-dot-pending"></span>
      <span>Expires in 18h</span>
    </div>
  </div>
</div>
```

---

### 4. Chain Visualization Components

Create `frontend/shared/web/components/chain-visual.css`:

```css
/* ============================================
   CHAIN VISUALIZATION
   ============================================ */

.chain-view {
  display: flex;
  flex-direction: column;
  gap: 0;
  max-width: 600px;
  margin: 0 auto;
  padding: var(--spacing-4);
}

/* Chain link connector */
.chain-link {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 32px;
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
  font-size: var(--text-base);
  z-index: 1;
  background: var(--void-black);
  padding: 0 var(--spacing-2);
}

/* Ellipsis indicator (for compressed view) */
.chain-ellipsis {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: var(--spacing-4);
  gap: var(--spacing-1);
}

.chain-ellipsis-dots {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-1);
}

.chain-ellipsis-dot {
  width: 6px;
  height: 6px;
  background: rgba(255, 255, 255, 0.3);
  border-radius: 50%;
}

.chain-ellipsis-label {
  font-size: var(--text-xs);
  color: rgba(255, 255, 255, 0.5);
  font-weight: var(--font-medium);
  margin-top: var(--spacing-2);
}

/* Responsive */
@media (max-width: 640px) {
  .chain-view {
    padding: var(--spacing-2);
  }
}
```

**HTML Example:**

```html
<div class="chain-view">
  <!-- Genesis -->
  <div class="person-card person-card-genesis">
    <!-- ... genesis card content ... -->
  </div>

  <!-- Link -->
  <div class="chain-link">
    <span class="chain-link-icon">↓</span>
  </div>

  <!-- Ellipsis (collapsed members) -->
  <div class="chain-ellipsis">
    <div class="chain-ellipsis-dots">
      <div class="chain-ellipsis-dot"></div>
      <div class="chain-ellipsis-dot"></div>
      <div class="chain-ellipsis-dot"></div>
    </div>
    <span class="chain-ellipsis-label">15 members</span>
  </div>

  <!-- Link -->
  <div class="chain-link">
    <span class="chain-link-icon">↓</span>
  </div>

  <!-- Current user -->
  <div class="person-card person-card-current">
    <!-- ... current user card content ... -->
  </div>

  <!-- Link -->
  <div class="chain-link">
    <span class="chain-link-icon">↓</span>
  </div>

  <!-- TIP -->
  <div class="person-card person-card-tip">
    <!-- ... TIP card content ... -->
  </div>
</div>
```

---

## 🚀 Quick Start

### 1. Add to HTML

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>The Chain</title>

  <!-- Google Fonts (Inter) -->
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">

  <!-- Base styles -->
  <link rel="stylesheet" href="/css/base.css">

  <!-- Component styles -->
  <link rel="stylesheet" href="/css/components/button.css">
  <link rel="stylesheet" href="/css/components/input.css">
  <link rel="stylesheet" href="/css/components/person-card.css">
  <link rel="stylesheet" href="/css/components/chain-visual.css">
</head>
<body>
  <!-- Skip to main content for accessibility -->
  <a href="#main" class="skip-to-main">Skip to main content</a>

  <!-- Main content -->
  <main id="main" class="container">
    <!-- Your content here -->
  </main>
</body>
</html>
```

---

## 📚 Next Steps

1. **Test Components**: Build a component showcase page
2. **JavaScript Interactions**: Add dynamic behaviors
3. **API Integration**: Connect to backend endpoints
4. **State Management**: Consider Riverpod or simple vanilla JS
5. **Testing**: Accessibility and cross-browser testing

---

**Last Updated**: October 12, 2025
**Maintained By**: UI Designer Hat (Orchestrator)
