# 🗺️ Implementation Roadmap - Next Steps

**Last Updated:** 2025-10-30
**Status:** Ready to implement
**Owner:** Next agent/session

---

## 📋 Overview

This document outlines the exact sequence of tasks to complete next. Follow these in order.

---

## 🎯 Phase 1: Remove Public App & Make Dashboard Public (NEXT)

> **📋 Implementation Guide:** Use **[PHASE1_CHECKLIST.md](PHASE1_CHECKLIST.md)** to track progress

### Objective
Remove the separate public-app service and make the private-app dashboard accessible to unauthenticated users with limited functionality.

### Current Architecture
```
┌─────────────────┐     ┌─────────────────┐
│   Public App    │     │   Private App   │
│   (Port 3000)   │     │   (Port 3001)   │
│                 │     │                 │
│ - Chain stats   │     │ - Login only    │
│ - No auth       │     │ - Full features │
└─────────────────┘     └─────────────────┘
```

### Target Architecture
```
┌─────────────────────────────────────┐
│       Private App (Port 3001)       │
│                                     │
│  ┌──────────────┐  ┌──────────────┐│
│  │ Public View  │  │  Auth View   ││
│  │              │  │              ││
│  │ - Dashboard  │  │ - Dashboard  ││
│  │ - Stats only │  │ - Full feat. ││
│  │ - No FAB     │  │ - FAB shown  ││
│  │ - Login CTA  │  │ - Settings   ││
│  └──────────────┘  └──────────────┘│
└─────────────────────────────────────┘
```

### Tasks

#### Task 1.1: Update Docker Configuration
**File:** `docker-compose.yml`

**Action:** Remove public-app service
```yaml
# DELETE THIS ENTIRE SECTION:
  public-app:
    build:
      context: ./frontend/public-app
      dockerfile: Dockerfile
    container_name: chain-public-app
    ports:
      - "3000:80"
    networks:
      - chain-network
```

**Result:** Only private-app will be exposed (port 3001 becomes the main entry point)

---

#### Task 1.2: Update Nginx Configuration (Private App)
**File:** `frontend/private-app/nginx.conf`

**Current:**
```nginx
# Current config (basic)
```

**Action:** Add proper routing for SPA
```nginx
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;

    # SPA routing - all routes go to index.html
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

**Why:** Ensures Flutter web routes work correctly (e.g., `/login`, `/dashboard`, `/ticket`)

---

#### Task 1.3: Make Dashboard Accessible to Unauthenticated Users
**File:** `frontend/private-app/lib/main.dart`

**Current:**
```dart
home: const AuthCheckPage(), // Redirects to login if not authenticated
```

**New:**
```dart
home: const DashboardScreen(), // Always show dashboard

// Remove AuthCheckPage redirect logic
// Let DashboardScreen handle auth state internally
```

**File:** `frontend/private-app/lib/widgets/auth_guard.dart`

**Action:** Create new `OptionalAuthGuard` widget
```dart
/// Guard that allows access but shows limited functionality when not authenticated
class OptionalAuthGuard extends ConsumerWidget {
  final Widget child;
  final String routeName;

  const OptionalAuthGuard({
    super.key,
    required this.child,
    required this.routeName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Don't redirect, just pass through
    // Child widget handles auth state display
    return child;
  }
}
```

---

#### Task 1.4: Update Dashboard to Show Limited/Full View
**File:** `frontend/private-app/lib/screens/dashboard_screen.dart`

**Action:** Add authentication state detection
```dart
// At the top of build method:
@override
Widget build(BuildContext context) {
  final userAsync = ref.watch(currentUserProvider);
  final isAuthenticated = userAsync.hasValue && userAsync.value != null;

  return Scaffold(
    body: isAuthenticated
      ? _buildAuthenticatedDashboard()  // Full features
      : _buildPublicDashboard(),        // Limited features
  );
}

Widget _buildPublicDashboard() {
  return CustomScrollView(
    slivers: [
      // Hero welcome section (guest mode)
      _buildPublicWelcome(),

      // Chain statistics (read-only)
      _buildSmartStatsGrid(),

      // Call-to-action: "Join The Chain"
      _buildJoinCTA(),

      // Optional: Chain visualization (public view)
      _buildChainVisualization(publicMode: true),
    ],
  );
}

Widget _buildPublicWelcome() {
  return SliverToBoxAdapter(
    child: Container(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          Text('The Chain', style: TextStyle(fontSize: 48)),
          Text('A global social experiment'),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/login'),
            child: Text('Join The Chain'),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/login'),
            child: Text('Already a member? Sign In'),
          ),
        ],
      ),
    ),
  );
}

Widget _buildAuthenticatedDashboard() {
  // Current full dashboard implementation
  // Includes: FAB, ticket banner, all features
}
```

**Hide These for Unauthenticated Users:**
- ❌ FAB button (View Ticket)
- ❌ Active ticket banner
- ❌ Settings icon
- ❌ Profile icon
- ❌ Notifications icon

**Show These for Unauthenticated Users:**
- ✅ Chain statistics
- ✅ "Join The Chain" CTA button
- ✅ "Sign In" button
- ✅ Chain visualization (if public)
- ✅ Global stats dashboard

---

#### Task 1.5: Update Main App Routes
**File:** `frontend/private-app/lib/main.dart`

**Action:** Update route protection
```dart
routes: {
  '/login': (context) => const LoginScreen(),
  '/register': (context) => const RegisterScreen(), // NEW

  // Dashboard accessible to all (handles auth internally)
  '/dashboard': (context) => const DashboardScreen(),
  '/': (context) => const DashboardScreen(),

  // Protected routes (require auth)
  '/ticket': (context) => const AuthGuard(
    routeName: '/ticket',
    child: TicketViewScreen(),
  ),
  '/settings': (context) => const AuthGuard(
    routeName: '/settings',
    child: SettingsScreen(),
  ),
  // ... other protected routes
},
```

---

#### Task 1.6: Clean Up & Test
**Actions:**
1. Delete `frontend/public-app/` directory entirely
2. Update `.gitignore` if needed
3. Rebuild Docker containers
4. Test unauthenticated access to dashboard
5. Test authenticated access (full features)

**Test Checklist:**
- [ ] Navigate to http://localhost:3001 without login
- [ ] See dashboard with stats (no FAB, no ticket banner)
- [ ] Click "Join The Chain" → goes to registration
- [ ] Click "Sign In" → goes to login
- [ ] Login successfully → see full dashboard
- [ ] See FAB button after login
- [ ] See ticket banner after login (if has active ticket)

---

## 🎯 Phase 2: Registration Flow (AFTER Phase 1)

### Objective
Implement ticket scanning and user registration flow.

### Tasks

#### Task 2.1: Create Registration Screen
**File:** `frontend/private-app/lib/screens/register_screen.dart`

**Features:**
- Scan QR code (using mobile_scanner package)
- OR paste deep link
- Validate ticket with backend
- Show ticket holder info (inviter)
- Collect user details:
  - Display name (required)
  - Email (optional)
  - Password (optional if device fingerprint available)
- Submit registration

**API Flow:**
```
1. User scans QR code
2. Extract ticket ID from QR data
3. GET /tickets/{ticketId} - Validate ticket
4. Show inviter info: "Join through [Name] (#position)"
5. User fills form
6. POST /auth/register - Create user with ticket
7. Auto-login (receive JWT)
8. Navigate to dashboard (authenticated)
```

---

#### Task 2.2: Update Backend Registration Endpoint
**File:** `backend/src/main/java/com/thechain/controller/AuthController.java`

**Verify these fields are supported:**
```java
POST /auth/register
{
  "ticketId": "uuid",           // Required
  "displayName": "string",      // Required
  "email": "string",            // Optional
  "password": "string",         // Optional (if using device auth)
  "deviceId": "string",         // Required for fingerprint auth
  "deviceFingerprint": "string" // Required for fingerprint auth
}
```

**Response:**
```json
{
  "userId": "uuid",
  "chainKey": "SEED00000001",
  "position": 51,
  "accessToken": "jwt...",
  "refreshToken": "jwt...",
  "user": {
    "id": "uuid",
    "displayName": "Bob",
    "position": 51,
    "parentId": "uuid"
  }
}
```

---

#### Task 2.3: Add QR Scanner Widget
**File:** `frontend/private-app/lib/widgets/qr_scanner_widget.dart`

**Implementation:**
```dart
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerWidget extends StatefulWidget {
  final Function(String ticketId) onScanned;

  @override
  Widget build(BuildContext context) {
    return MobileScanner(
      onDetect: (capture) {
        final List<Barcode> barcodes = capture.barcodes;
        for (final barcode in barcodes) {
          // Parse ticket ID from QR data
          final ticketId = _parseTicketId(barcode.rawValue);
          if (ticketId != null) {
            widget.onScanned(ticketId);
          }
        }
      },
    );
  }
}
```

---

## 🎯 Phase 3: Statistics Flow (AFTER Phase 2)

### Objective
Show comprehensive chain statistics on the public dashboard.

### Tasks

#### Task 3.1: Create Statistics Widgets
**Files to create:**
- `frontend/private-app/lib/widgets/stats/global_stats_card.dart`
- `frontend/private-app/lib/widgets/stats/growth_chart_widget.dart`
- `frontend/private-app/lib/widgets/stats/geography_map_widget.dart`

**Display:**
- Total users in chain
- Active tickets count
- Growth rate (24h, 7d, 30d)
- Countries represented
- Latest joins (real-time)

---

#### Task 3.2: Add Statistics API Endpoints (Backend)
**File:** `backend/src/main/java/com/thechain/controller/ChainController.java`

**Verify/add these endpoints:**
```java
GET /api/v1/chain/stats            // Global stats
GET /api/v1/chain/growth           // Growth over time
GET /api/v1/chain/geography        // Geographic distribution
GET /api/v1/chain/recent-joins     // Latest users (public)
```

---

#### Task 3.3: Real-Time Updates (Optional)
**File:** `frontend/private-app/lib/services/websocket_service.dart`

**Connect to WebSocket for live updates:**
- New user joins
- Statistics changes
- Chain growth milestones

---

## 🎯 Phase 4: Admin Notification Endpoints (AFTER Phase 3)

### Objective
Implement admin endpoints for sending notifications to users.

### Tasks

#### Task 4.1: Create Notification Endpoints
**File:** `backend/src/main/java/com/thechain/controller/AdminController.java`

**Endpoints to create:**
```java
POST /api/v1/admin/notifications/send          // Send to specific users
POST /api/v1/admin/notifications/broadcast     // Send to all users
POST /api/v1/admin/notifications/scheduled     // Schedule notification
GET  /api/v1/admin/notifications/history       // View sent notifications
```

---

#### Task 4.2: Notification Service Implementation
**File:** `backend/src/main/java/com/thechain/service/NotificationService.java`

**Support these channels:**
- Push notifications (FCM/APNs)
- Email notifications
- In-app notifications

---

#### Task 4.3: Admin Dashboard (Frontend)
**File:** `frontend/private-app/lib/screens/admin/notification_center.dart`

**Features:**
- Compose notification
- Select recipients (all/specific users/positions)
- Preview notification
- Schedule send time
- View delivery status

---

## 📊 Implementation Order Summary

```
Phase 1: Remove Public App          [IMMEDIATE - Next Session]
  ├── 1.1 Docker cleanup
  ├── 1.2 Nginx config
  ├── 1.3 Remove AuthCheckPage
  ├── 1.4 Dashboard dual-mode
  ├── 1.5 Route updates
  └── 1.6 Testing

Phase 2: Registration Flow          [After Phase 1]
  ├── 2.1 Registration screen
  ├── 2.2 Backend validation
  └── 2.3 QR scanner

Phase 3: Statistics Flow            [After Phase 2]
  ├── 3.1 Stats widgets
  ├── 3.2 Stats endpoints
  └── 3.3 Real-time updates

Phase 4: Admin Notifications        [After Phase 3]
  ├── 4.1 Admin endpoints
  ├── 4.2 Notification service
  └── 4.3 Admin UI
```

---

## 🔧 Before Starting

**Read these first:**
1. [CLAUDE_START_HERE.md](CLAUDE_START_HERE.md) - Critical context
2. [KNOWN_ISSUES.md](KNOWN_ISSUES.md) - Password & ticket issues
3. This file (you're reading it!)

**Verify system state:**
```bash
# All services running?
docker-compose ps

# Backend healthy?
curl http://localhost:8080/api/v1/actuator/health

# Can access private app?
curl http://localhost:3001
```

---

## 📝 Notes for Implementation

### Phase 1 Considerations
- **Don't break existing functionality** - authenticated users should see no change
- **Gradual degradation** - unauthenticated users see limited features, not errors
- **Mobile-first** - design for small screens first
- **Performance** - public dashboard should load fast (no auth required)

### Phase 2 Considerations
- **Security** - validate tickets server-side, don't trust client
- **UX** - make scanning/joining seamless (1-2 taps)
- **Error handling** - expired/used tickets show clear messages
- **Device fingerprinting** - works across sessions on same device

### Phase 3 Considerations
- **Caching** - stats can be cached (1-5 min) for performance
- **Real-time is optional** - polling every 5-10s acceptable for MVP
- **Public data only** - no private user info in public stats

### Phase 4 Considerations
- **Admin authentication** - requires special admin role
- **Rate limiting** - prevent notification spam
- **Opt-out** - users can disable notifications
- **Delivery tracking** - track opens/clicks

---

## ✅ Success Criteria

### Phase 1 Complete When:
- [ ] Public-app directory deleted
- [ ] docker-compose.yml updated
- [ ] Dashboard accessible without login at http://localhost:3001
- [ ] Unauthenticated users see stats + CTA
- [ ] Authenticated users see full dashboard
- [ ] No broken links or errors
- [ ] All tests passing

### Phase 2 Complete When:
- [ ] QR scanner works on mobile
- [ ] Deep link pasting works
- [ ] Registration creates user + auto-logins
- [ ] New user automatically has ticket
- [ ] User appears in chain at correct position

### Phase 3 Complete When:
- [ ] All stats display correctly
- [ ] Stats update in real-time (or near real-time)
- [ ] Geography visualization works
- [ ] Growth charts render

### Phase 4 Complete When:
- [ ] Admin can send notifications
- [ ] Users receive notifications
- [ ] Delivery tracking works
- [ ] Scheduled notifications execute

---

## 🚨 Blockers & Dependencies

### Phase 1:
- **None** - Can start immediately

### Phase 2:
- **Depends on:** Phase 1 complete
- **Needs:** Backend `/auth/register` endpoint working
- **Needs:** `mobile_scanner` package added to pubspec.yaml

### Phase 3:
- **Depends on:** Phase 2 complete (for new user testing)
- **Needs:** Stats endpoints implemented on backend
- **Optional:** WebSocket service for real-time

### Phase 4:
- **Depends on:** Phase 3 complete
- **Needs:** Admin authentication system
- **Needs:** FCM/APNs credentials for push notifications
- **Needs:** SMTP configuration for emails

---

## 📞 Questions to Clarify (If Any)

Before starting, ensure you understand:
- [ ] Should public dashboard show chain visualization?
- [ ] What stats are safe to show publicly?
- [ ] Should registration require email immediately?
- [ ] Is device fingerprint auth sufficient for MVP?
- [ ] What notification channels are priority? (push/email/in-app)

---

**Ready to implement Phase 1!** 🚀

Next agent should start with Task 1.1 and work sequentially through Phase 1.
