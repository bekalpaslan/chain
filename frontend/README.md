# The Chain - Frontend Architecture

Flutter-based unified application with shared core library.

## Structure

```
frontend/
├── shared/          # Shared API client, models, and utilities (Flutter package)
├── private-app/     # Main application (Flutter web app, port 3000)
└── demos/           # Demo components and prototypes
```

> **Note (December 2025):** The `public-app` was removed and consolidated into `private-app`.
> The private-app now serves as the main landing page with public stats visible to all users.
> Authenticated features are available after login.

## Packages

### 1. Shared Package (`shared/`)

Common code used by the main app.

**Contains:**
- API client (Dio-based with auto token refresh)
- JSON models (User, Ticket, ChainStats, AuthResponse)
- Device info and fingerprinting utilities
- Secure storage helpers
- API constants and endpoints

**Usage:**
```yaml
dependencies:
  thechain_shared:
    path: ../shared
```

### 2. Main App (`private-app/`)

**Purpose:** Unified application serving both public and authenticated users

**Port:** 3000

**Features:**
- Landing page with real-time chain statistics (public)
- Device-based login and registration
- User profile and chain management (authenticated)
- Ticket generation and QR codes (authenticated)
- Membership tier badges (candidate/permanent)

**Run:**
```bash
cd private-app
flutter run -d chrome
```

## Development

**Install dependencies:**
```bash
cd shared && flutter pub get
cd ../private-app && flutter pub get
```

**Regenerate models (after changes to shared/):**
```bash
cd shared
flutter pub run build_runner build --delete-conflicting-outputs
```

## Docker Deployment

**Build and run full stack:**
```bash
# From project root
docker-compose up --build
```

**Access:**
- Main App: http://localhost:3000
- Backend API: http://localhost:8080

## Tech Stack

- **Framework:** Flutter 3.35.5
- **Language:** Dart 3.9.2
- **HTTP Client:** Dio ^5.4.0
- **State Management:** Riverpod ^2.4.9
- **Routing:** GoRouter ^13.0.0
- **Storage:** flutter_secure_storage ^9.0.0
- **JSON:** json_serializable ^6.7.1

## Design Principles

1. **Shared Core:** Single source of truth for API logic
2. **Unified App:** Single app with public and authenticated sections
3. **Progressive Enhancement:** Public stats visible, login reveals more
4. **Docker Ready:** Fully containerized deployment

## Migration Notes

### December 2025: public-app Consolidation

The dual-app architecture (public-app + private-app) was consolidated into a single app:

| Before | After |
|--------|-------|
| `public-app` on port 3000 | Removed |
| `private-app` on port 3001 | `private-app` on port 3000 |

**Reason:** Simplified deployment and maintenance. The private-app now handles:
- Public landing page with chain stats (no auth required)
- Login/registration flows
- Authenticated dashboard and features

## Documentation

See [docs/guides/FLUTTER_IMPLEMENTATION_COMPLETE.md](../docs/guides/FLUTTER_IMPLEMENTATION_COMPLETE.md) for comprehensive implementation details.
