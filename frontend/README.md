# The Chain - Frontend Architecture

Flutter-based dual deployment architecture with shared core library.

## Structure

```
frontend/
├── shared/          # Shared API client, models, and utilities (Flutter package)
├── public-app/      # Public marketing site (Flutter web app, port 3000)
└── private-app/     # Private user dashboard (Flutter web app, port 3001)
```

## Packages

### 1. Shared Package (`shared/`)

Common code used by both apps.

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

### 2. Public App (`public-app/`)

**Purpose:** Public marketing site showing chain statistics

**Port:** 3000

**Features:**
- Landing page with real-time stats
- No authentication required
- Calls `/chain/stats` endpoint

**Run:**
```bash
cd public-app
flutter run -d chrome
```

### 3. Private App (`private-app/`)

**Purpose:** Authenticated user dashboard

**Port:** 3001

**Features:**
- Device-based login
- User profile and chain management
- Ticket generation
- Protected routes requiring JWT

**Run:**
```bash
cd private-app
flutter run -d chrome
```

## Development

**Install dependencies for all packages:**
```bash
cd shared && flutter pub get
cd ../public-app && flutter pub get
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
- Public App: http://localhost:3000
- Private App: http://localhost:3001
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
2. **Separation of Concerns:** Public vs Private functionality
3. **Consistent Tech Stack:** Same libraries across both apps
4. **Docker Ready:** Both apps fully containerized

## Documentation

See [docs/FLUTTER_IMPLEMENTATION_COMPLETE.md](../docs/FLUTTER_IMPLEMENTATION_COMPLETE.md) for comprehensive implementation details.
