# The Chain

> 🚨 **AI ASSISTANTS: Start here → [CLAUDE_START_HERE.md](CLAUDE_START_HERE.md)** - Critical context and orchestrator system guide

> "Grow with solidarity and trust. A social experiment."

A viral social network where participants form a single, global chain by inviting one person each through time-limited QR code tickets.

## 🔗 Concept

The Chain is a minimalist social experience that combines social curiosity, viral dynamics, and collective accountability. A single chain connects everyone — starting from one seed — and every new participant must be attached through a one-time, time-limited invitation ticket.

## 🎯 Core Mechanics

- Each user generates **one shareable QR code ticket**
- Tickets expire after **24 hours**
- Unused tickets return to sender and are logged as "wasted attempts"
- All attachments are **publicly visible**
- Users receive a unique **Chain Key** upon joining

## 🏗️ Architecture

- **Frontend**: Flutter (iOS, Android, Web/PWA)
- **Backend**: Java Spring Boot microservices
- **Database**: PostgreSQL + Redis
- **Real-time**: WebSocket for live updates

## 📁 Project Structure

```
the-chain/
├── docs/                  # Project documentation
├── backend/              # Spring Boot microservices (coming soon)
├── mobile/               # Flutter application (coming soon)
└── infrastructure/       # Docker, K8s configs (coming soon)
```

## 📚 Documentation

**📖 [Complete Documentation Index](DOCS_INDEX.md)** - Organized guide to all documentation

### Essential Reading
- [Implementation Status](docs/IMPLEMENTATION_STATUS.md) - **PRIMARY REFERENCE** - Complete technical status (v2.4)
- [Deployment Status](DEPLOYMENT_STATUS.md) - Current deployment and access URLs
- [API Specification](docs/API_SPECIFICATION.md) - REST API endpoints and contracts
- [Hybrid Authentication](docs/HYBRID_AUTHENTICATION_IMPLEMENTATION.md) - Email/password + device fingerprint (33/33 tests passing)

### Quick Links
- [Project Definition](docs/PROJECT_DEFINITION.md) - Vision and concept
- [Database Schema](docs/DATABASE_SCHEMA.md) - Database structure and relationships
- [Security Model](docs/SECURITY_MODEL.md) - Security architecture
- [Testing Guide](docs/TESTING_GUIDE.md) - How to run tests
- [Flutter Implementation](docs/FLUTTER_IMPLEMENTATION_COMPLETE.md) - Flutter dual app guide

## 🚀 Getting Started

### Prerequisites
- Docker & Docker Compose
- Java 17+ (for backend development)
- Flutter SDK (for frontend development)

### Quick Start

```bash
# Clone the repository
git clone https://github.com/your-username/ticketz.git
cd ticketz

# Start the backend services
docker-compose up -d

# Access the applications
# - Backend API: http://localhost:8080
# - Public App: http://localhost:3000
# - Private App: http://localhost:3001
```

### Authentication

The Chain supports **hybrid authentication** with two flexible login methods:

1. **Email/Password** - Traditional login with BCrypt password hashing + optional device registration
2. **Device Fingerprint** - Passwordless, zero-friction login using SHA-256 device fingerprinting

**Test with seed user (Email/Password):**
```bash
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "alpaslan@alpaslan.com",
    "password": "alpaslan"
  }'
```

**Test with device fingerprint:**
```bash
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "deviceId": "web_489323232",
    "deviceFingerprint": "2d23d5f144c842a766b91e0853be834ea85143ff80ba5b6926ac64330a02bc2d"
  }'
```

See [Hybrid Authentication Documentation](docs/HYBRID_AUTHENTICATION_IMPLEMENTATION.md) for complete implementation details.

## 📊 Success Metrics

- Daily new attachments
- Ticket usage rate before expiration
- Chain continuity duration
- Geographic spread
- Retention rates

## 👥 Target Audience

Mobile-first users aged 16-40 who enjoy social experiments, gamification, and global participation.

## 📄 License

*To be determined*

---

**Current Status**: ✅ Backend Deployed | ✅ Flutter Public App Running | 🚀 Phase 3 in Progress

See [DEPLOYMENT_STATUS.md](DEPLOYMENT_STATUS.md) for detailed deployment information.

**Author**: Alpaslan Bek
**Last Updated**: October 9, 2025


1. Custom App Bar (dashboard_screen.dart:185)

  Location: Top of screen, collapsible

  Elements:
  - User Avatar - First letter of display name in a colored circle
  - Chain Position Badge - Shows #1, #2, etc. with special highlighting for top 100
  - Notifications Icon - Bell icon with red badge showing unread count
  - Settings Icon - Gear icon for app settings

  Purpose:
  - Quick identity confirmation (you know you're logged in)
  - Position awareness at a glance
  - Access to notifications and settings without scrolling
  - Parallax effect - Shrinks as you scroll, saving screen space

  ---
  2. Hero Welcome Section (hero_welcome_section.dart:1)

  Location: First content section

  Elements:
  - Time-based Greeting - "Good morning/afternoon/evening"
  - Display Name - Large, animated shimmer effect with gradient
  - Status Indicator - Green "Online" or gray "Away" dot based on last activity (< 5min = online)
  - Chain Key Card - Tappable card showing your unique identifier
    - Icon: Link symbol
    - Label: "Chain Key"
    - Value: Your chain key (e.g., "SEED00000001")
    - Action: Tap to copy to clipboard with haptic feedback
  - Position Card - Displays your position in the chain
    - Icon: Trophy (if top 100) or Timeline (if not)
    - Value: Your position number
    - Special styling: Gold gradient for top 100 users
  - Activity Status - Last activity timestamp
    - Shows "Active now", "Active 5m ago", etc.
    - Streak Indicator - Fire icon with "7 day streak" (gamification element)

  Purpose:
  - Personalization - Makes the app feel tailored to you
  - Identity reinforcement - Constant reminder of your chain position
  - Quick access to key info - Chain key is frequently needed for sharing
  - Status awareness - Let you know if you're still "active" in the system
  - Gamification - Streak encourages daily usage

  ---
  3. Critical Actions Area (critical_actions_area.dart:1)

  Location: Below hero section (only if there are critical actions)

  Elements:
  - Section Header - "Requires Attention" with pulsing priority icon
  - Action Count - Shows how many actions need attention
  - Action Cards (dynamic, one per critical action):
    - Icon - Pulsing, colored by action type
    - Title - e.g., "Ticket Expiring Soon"
    - Description - Details about the action
    - Countdown Timer - HH:MM:SS format (if time-sensitive)
    - Action Arrow - Indicates tappable/navigable

  Action Types & Colors:
  - Ticket Expiring (Amber) - Your invitation ticket will expire soon
  - Ticket Expired (Amber) - Your ticket expired without being used
  - Became Tip (Cyan) - You're now at the end of the chain
  - Chain Broken (Red) - Someone in your line was removed
  - Invite Accepted (Green) - Someone joined using your ticket
  - Invite Rejected (Red) - Your invitee was removed
  - Achievement Unlocked (Gold) - You earned a badge

  Purpose:
  - Urgency communication - Visual priority system prevents missing critical events
  - Action guidance - Direct users to what needs attention immediately
  - Countdown timers - Create FOMO (fear of missing out) to drive ticket usage
  - Gamification - Achievement notifications feel rewarding

  ---
  4. Smart Stats Grid (smart_stats_grid.dart:1)

  Location: Middle section

  Elements: 6 stat cards in a 2x3 or 3x2 grid (adaptive based on screen size)

  Stat Cards:
  1. Position (Mystic Violet → Ghost Cyan gradient)
    - Icon: Timeline
    - Value: Your position number (e.g., "#1")
    - Trend: Shows position change (+5, -3, etc.)
    - Purpose: Track your rank movement in the chain
  2. Total Invited (Emerald → Ghost Cyan gradient)
    - Icon: People outline
    - Value: Number of people you've invited
    - Sub-value: "X active" (how many are still in chain)
    - Purpose: Measure your contribution to chain growth
  3. Success Rate (Amber → Emerald gradient)
    - Icon: Trending up
    - Value: Percentage (e.g., "75%")
    - Progress bar: Visual representation
    - Purpose: Show how successful your invitations are
  4. Chain Health (Red → Mystic Violet gradient)
    - Icon: Heart outline
    - Value: Percentage representing chain stability
    - Progress bar: Visual health indicator
    - Purpose: Awareness of chain's overall health (prevents removals)
  5. Chain Length (Ghost Cyan → Mystic Violet gradient)
    - Icon: Link
    - Value: Total number of members
    - Sub-value: "members"
    - Purpose: Sense of collective accomplishment
  6. Wasted Tickets (Gray gradient)
    - Icon: Timer off
    - Value: Number of expired tickets
    - Sub-value: "tickets"
    - Purpose: Transparency about failures (3 = removal)

  Purpose:
  - Data transparency - Core principle of The Chain
  - Gamification - Stats encourage competition and engagement
  - Awareness - Health and wasted tickets prevent accidental removal
  - Tappable - Each card expands to show detailed history

  ---
  5. Interactive Chain Widget (interactive_chain_widget.dart:1)

  Location: Below stats grid

  Elements:
  - Section Title - "Your Chain"
  - Member Cards - Shows visible chain members (±1 visibility)
    - Avatar - Circular with position number
    - Display Name - Member's name
    - Chain Key - Member's unique ID
    - Status Color - Green (active), Yellow (pending), Red (removed), Cyan (tip), Gold (genesis)
    - "YOU" Badge - Highlights your own card

  Member Statuses:
  - Active (Green) - Normal member
  - Pending (Yellow) - Ticket issued but not used yet
  - Expired (Red) - Ticket expired
  - Removed (Red) - User removed from chain
  - Tip (Cyan) - Current end of chain
  - Genesis (Gold) - The seed user (position #1)
  - Milestone (Purple) - Position 100, 1000, etc.
  - Ghost (Gray) - Placeholder for invisible members

  Purpose:
  - ±1 Visibility enforcement - You can only see your parent and child
  - Social connection - See who invited you and who you invited
  - Status awareness - Know if your invitee is active or at risk
  - Context - Understand your place in the larger chain

  ---
  6. Activity Feed Section (activity_feed_section.dart:1)

  Location: Below chain widget

  Elements:
  - Section Title - "Recent Activity"
  - Activity Tiles - Chronological list of events
    - Icon - Colored by activity type
    - Title - Event description
    - Timestamp - "5m ago", "2h ago", etc.
    - Related User - If applicable
    - Load More Button - Infinite scroll trigger

  Activity Types:
  - New Member (Green) - Someone joined the chain
  - Invite Expired (Red) - A ticket expired
  - Chain Growth (Green) - Milestone reached
  - Milestone (Gold) - 100th, 1000th member, etc.
  - Ticket Generated (Violet) - New ticket created
  - Ticket Used (Green) - Ticket successfully used
  - Became Tip (Cyan) - User became chain end
  - Chain Reversion (Red) - Chain rolled back
  - Badge Earned (Gold) - Achievement unlocked

  Purpose:
  - Transparency - See all chain events in real-time
  - Engagement - Creates narrative around chain growth
  - Social proof - Show activity to encourage participation
  - History - Audit trail of all actions

  ---
  7. Achievements Section (achievements_section.dart:1)

  Location: Below activity feed (only if achievements exist)

  Elements:
  - Section Title - "Achievements"
  - Achievement Cards - Badge showcase
    - Icon - Badge symbol (star, trophy, etc.)
    - Name - Achievement name
    - Description - How it was earned
    - Rarity Badge - Common, Rare, Epic, Legendary
    - Progress Bar - For in-progress achievements
    - Earned Date - When unlocked

  Achievement Examples:
  - Chain Savior - Reactivated and succeeded after being made tip
  - Chain Guardian - Saved the chain 5+ times
  - Chain Legend - Saved the chain 10+ times

  Purpose:
  - Gamification - Reward system for engagement
  - Status symbol - Show accomplishments
  - Progress tracking - Motivate toward next achievement
  - Transparency - All users can see who has which badges

  ---
  8. Floating Action Button (FAB) (dashboard_screen.dart:382)

  Location: Bottom center, docked in navigation bar

  States:
  - No Active Ticket: Shows "Generate Ticket" with + icon
  - Has Active Ticket: Shows "View Ticket" with QR code icon

  Purpose:
  - Primary action - Most important user action is always visible
  - Context-aware - Changes based on ticket state
  - Accessibility - Large, easy-to-tap target
  - Always available - Fixed position regardless of scroll

  ---
  9. Bottom Navigation Bar (dashboard_screen.dart:395)

  Location: Bottom of screen

  Navigation Items:
  - Home (House icon) - Current screen (dashboard)
  - Chain (Timeline icon) - Full chain visualization
  - [FAB Space] - Notch for floating action button
  - Badges (Trophy icon) - Achievements screen
  - Profile (Person icon) - User settings and profile

  Purpose:
  - Quick navigation - Access key sections without scrolling
  - Context awareness - Highlighted current section
  - Standard pattern - Familiar mobile UX
  - Haptic feedback - Tactile response on tap

  ---
  10. Notification Badge Overlay (dashboard_screen.dart:452)

  Location: Top right, floating above content

  Elements:
  - Red badge - Shows count (e.g., "3 new")
  - Glowing effect - Box shadow draws attention
  - Non-interactive - Just visual indicator

  Purpose:
  - Attention grabber - Can't miss new notifications
  - Urgency - Red color indicates importance
  - Non-intrusive - Doesn't block content
