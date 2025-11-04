# Flutter Dual Deployment Architecture - Public & Private Apps

**Date:** October 9, 2025
**Status:** Architecture Design
**Tech Stack:** Flutter + Dart (consistent across both apps)

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    The Chain Platform                        │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────────┐              ┌──────────────────┐    │
│  │  PUBLIC APP      │              │  PRIVATE APP     │    │
│  │  (Marketing)     │              │  (User Dashboard)│    │
│  ├──────────────────┤              ├──────────────────┤    │
│  │ - Landing page   │              │ - User profile   │    │
│  │ - Chain stats    │              │ - Generate tickets│   │
│  │ - How it works   │              │ - My chain       │    │
│  │ - Public metrics │              │ - Notifications  │    │
│  │ - Join waitlist  │              │ - Settings       │    │
│  └────────┬─────────┘              └────────┬─────────┘    │
│           │                                 │               │
│           │         ┌──────────────────┐   │               │
│           └────────►│  SHARED CORE     │◄──┘               │
│                     │  (API Client)    │                   │
│                     ├──────────────────┤                   │
│                     │ - Dio HTTP       │                   │
│                     │ - Models/DTOs    │                   │
│                     │ - Constants      │                   │
│                     │ - Utils          │                   │
│                     └────────┬─────────┘                   │
│                              │                              │
│                     ┌────────▼─────────┐                   │
│                     │  BACKEND API     │                   │
│                     │  (Spring Boot)   │                   │
│                     └──────────────────┘                   │
└─────────────────────────────────────────────────────────────┘
```

---

## Directory Structure

```
frontend/
├── public-app/                    # Public Flutter app (port 3000)
│   ├── lib/
│   │   ├── main.dart
│   │   ├── screens/
│   │   │   ├── landing_screen.dart
│   │   │   ├── stats_screen.dart
│   │   │   ├── how_it_works_screen.dart
│   │   │   └── join_screen.dart
│   │   ├── widgets/
│   │   │   ├── stat_card.dart
│   │   │   ├── chain_visualization.dart
│   │   │   └── footer.dart
│   │   └── config/
│   │       └── app_config.dart
│   ├── web/
│   ├── pubspec.yaml
│   ├── Dockerfile
│   └── README.md
│
├── private-app/                   # Private Flutter app (port 3001)
│   ├── lib/
│   │   ├── main.dart
│   │   ├── screens/
│   │   │   ├── login_screen.dart
│   │   │   ├── dashboard_screen.dart
│   │   │   ├── profile_screen.dart
│   │   │   ├── ticket_screen.dart
│   │   │   ├── my_chain_screen.dart
│   │   │   └── settings_screen.dart
│   │   ├── widgets/
│   │   │   ├── ticket_card.dart
│   │   │   ├── qr_scanner.dart
│   │   │   ├── user_avatar.dart
│   │   │   └── chain_tree.dart
│   │   ├── providers/
│   │   │   ├── auth_provider.dart
│   │   │   ├── user_provider.dart
│   │   │   └── ticket_provider.dart
│   │   └── config/
│   │       └── app_config.dart
│   ├── web/
│   ├── pubspec.yaml
│   ├── Dockerfile
│   └── README.md
│
└── shared/                        # Shared package
    ├── lib/
    │   ├── api/
    │   │   ├── api_client.dart
    │   │   ├── auth_api.dart
    │   │   ├── user_api.dart
    │   │   ├── ticket_api.dart
    │   │   └── chain_api.dart
    │   ├── models/
    │   │   ├── user.dart
    │   │   ├── ticket.dart
    │   │   ├── chain_stats.dart
    │   │   └── auth_response.dart
    │   ├── constants/
    │   │   ├── api_constants.dart
    │   │   └── app_constants.dart
    │   └── utils/
    │       ├── jwt_helper.dart
    │       ├── storage_helper.dart
    │       └── device_info_helper.dart
    ├── pubspec.yaml
    └── README.md
```

---

## App Specifications

### Public App (Marketing/Landing)

**Purpose:** Attract users, show platform value
**Port:** 3000
**Auth Required:** No
**Deployment:** Public-facing web

**Features:**
- Landing page with value proposition
- Live chain statistics
- How it works explanation
- Chain visualization (anonymized)
- Join waitlist / Get invitation
- FAQ section
- Contact/Support

**Backend API Calls:**
- `GET /api/chain/stats` - Public statistics
- `GET /api/auth/health` - Health check
- Future: `POST /api/waitlist` - Join waitlist

---

### Private App (User Dashboard)

**Purpose:** User management, ticket generation, chain tracking
**Port:** 3001
**Auth Required:** Yes (JWT)
**Deployment:** Authenticated users only

**Features:**
- Device-based authentication
- User dashboard with stats
- Generate invitation tickets
- QR code generation/scanning
- My chain visualization
- Profile management
- Notifications
- Settings

**Backend API Calls:**
- `POST /api/auth/login` - Login
- `POST /api/auth/register` - Register
- `POST /api/auth/refresh` - Token refresh
- `GET /api/users/me` - User profile
- `GET /api/users/me/chain` - My chain
- `POST /api/tickets/generate` - Generate ticket
- `GET /api/tickets/{id}` - Ticket details
- `GET /api/chain/stats` - Statistics

---

## Shared Package

### Purpose
- Single source of truth for API communication
- Consistent models across both apps
- Reduce code duplication
- Easy to maintain and update

### Contents

#### 1. API Client (`api_client.dart`)
```dart
class ApiClient {
  final Dio _dio;
  final String baseUrl;

  ApiClient({required this.baseUrl}) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ));

    _dio.interceptors.add(LogInterceptor());
  }

  // Public methods (no auth required)
  Future<ChainStats> getChainStats();
  Future<String> getHealth();

  // Private methods (auth required)
  Future<AuthResponse> login(String deviceId, String fingerprint);
  Future<AuthResponse> register(RegisterRequest request);
  Future<AuthResponse> refreshToken(String refreshToken);
  Future<UserProfile> getUserProfile(String token);
  Future<List<UserChain>> getUserChain(String token);
  Future<Ticket> generateTicket(String token);
}
```

#### 2. Models
```dart
// user.dart
class User {
  final String userId;
  final String chainKey;
  final String displayName;
  final int position;
  final String? parentId;
  final String? activeChildId;
  final String status;
  final int wastedTicketsCount;
  final DateTime createdAt;
}

// ticket.dart
class Ticket {
  final String ticketId;
  final String ticketCode;
  final String ownerId;
  final String status;
  final DateTime issuedAt;
  final DateTime expiresAt;
  final String signature;
}

// chain_stats.dart
class ChainStats {
  final int totalUsers;
  final int activeUsers;
  final int totalTickets;
  final int activeTickets;
  final int chainLength;
}

// auth_response.dart
class AuthResponse {
  final String userId;
  final String chainKey;
  final String displayName;
  final int position;
  final TokenInfo tokens;
}

class TokenInfo {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
}
```

#### 3. Constants
```dart
class ApiConstants {
  // Can be overridden by environment
  static const String defaultBaseUrl = 'http://localhost:8080/api';

  // Endpoints
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authRefresh = '/auth/refresh';
  static const String usersMe = '/users/me';
  static const String usersMeChain = '/users/me/chain';
  static const String ticketsGenerate = '/tickets/generate';
  static const String chainStats = '/chain/stats';
}

class AppConstants {
  static const String appName = 'The Chain';
  static const int ticketExpiryHours = 24;
  static const int maxWastedTickets = 3;
}
```

---

## Docker Configuration

### Public App Dockerfile
```dockerfile
# frontend/public-app/Dockerfile
FROM debian:latest AS build-env

# Install Flutter dependencies
RUN apt-get update && apt-get install -y \
    curl git wget unzip libgconf-2-4 gdb libstdc++6 \
    libglu1-mesa fonts-droid-fallback lib32stdc++6 python3 \
    sed

# Clone Flutter
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter

ENV PATH="/usr/local/flutter/bin:${PATH}"

# Enable Flutter web
RUN flutter channel stable
RUN flutter upgrade
RUN flutter config --enable-web

# Set working directory
WORKDIR /app

# Copy shared package first
COPY ../shared /shared
WORKDIR /shared
RUN flutter pub get

# Copy public app
WORKDIR /app
COPY pubspec.yaml .
COPY pubspec.lock .
RUN flutter pub get

# Copy source code
COPY . .

# Build web app
RUN flutter build web --release --web-renderer canvaskit

# Runtime stage
FROM nginx:alpine
COPY --from=build-env /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 3000
CMD ["nginx", "-g", "daemon off;"]
```

### Private App Dockerfile
```dockerfile
# frontend/private-app/Dockerfile
FROM debian:latest AS build-env

# Install Flutter dependencies
RUN apt-get update && apt-get install -y \
    curl git wget unzip libgconf-2-4 gdb libstdc++6 \
    libglu1-mesa fonts-droid-fallback lib32stdc++6 python3 \
    sed

# Clone Flutter
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter

ENV PATH="/usr/local/flutter/bin:${PATH}"

# Enable Flutter web
RUN flutter channel stable
RUN flutter upgrade
RUN flutter config --enable-web

# Set working directory
WORKDIR /app

# Copy shared package first
COPY ../shared /shared
WORKDIR /shared
RUN flutter pub get

# Copy private app
WORKDIR /app
COPY pubspec.yaml .
COPY pubspec.lock .
RUN flutter pub get

# Copy source code
COPY . .

# Build web app with auth
RUN flutter build web --release --web-renderer canvaskit

# Runtime stage
FROM nginx:alpine
COPY --from=build-env /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 3001
CMD ["nginx", "-g", "daemon off;"]
```

### Docker Compose Configuration
```yaml
# docker-compose.yml (update)
services:
  # ... existing services (postgres, redis, backend)

  # Public Flutter App
  public-app:
    build:
      context: ./frontend/public-app
      dockerfile: Dockerfile
    container_name: chain-public-app
    ports:
      - "3000:3000"
    environment:
      - API_BASE_URL=http://backend:8080/api
    depends_on:
      - backend
    networks:
      - chain-network

  # Private Flutter App
  private-app:
    build:
      context: ./frontend/private-app
      dockerfile: Dockerfile
    container_name: chain-private-app
    ports:
      - "3001:3001"
    environment:
      - API_BASE_URL=http://backend:8080/api
    depends_on:
      - backend
    networks:
      - chain-network

networks:
  chain-network:
    driver: bridge
```

---

## Implementation Plan

### Phase 1: Setup Shared Package (1-2 hours)
1. Create `frontend/shared` directory
2. Initialize Flutter package with `flutter create --template=package shared`
3. Implement API client with Dio
4. Create all model classes with JSON serialization
5. Add constants and utilities
6. Document API usage

### Phase 2: Create Public App (2-3 hours)
1. Create `frontend/public-app` directory
2. Initialize Flutter web app
3. Add shared package dependency
4. Implement landing page
5. Implement stats page with real API
6. Add chain visualization
7. Create Dockerfile and nginx config
8. Test locally

### Phase 3: Create Private App (3-4 hours)
1. Create `frontend/private-app` directory
2. Initialize Flutter web app
3. Add shared package dependency
4. Implement authentication flow
5. Implement dashboard with user stats
6. Implement ticket generation/QR
7. Implement "My Chain" view
8. Add state management (Riverpod)
9. Create Dockerfile and nginx config
10. Test locally

### Phase 4: Docker Integration (1 hour)
1. Update docker-compose.yml
2. Test both apps with backend
3. Verify API communication
4. Test end-to-end flows

### Phase 5: Polish & Deploy (1-2 hours)
1. Error handling
2. Loading states
3. Responsive design
4. Documentation
5. Deploy to staging

---

## Design Principles

### 1. Consistency
- Same Flutter/Dart version across both apps
- Shared design system (colors, fonts, spacing)
- Consistent API error handling
- Same state management pattern

### 2. Modularity
- Shared package for common code
- Clean separation of public/private concerns
- Reusable widgets in both apps

### 3. Scalability
- Easy to add new features
- Simple to update shared code
- Docker for consistent deployment

### 4. Security
- JWT tokens only in private app
- Secure storage for sensitive data
- Public app has no auth state

---

## Technology Stack

### Both Apps
- **Framework:** Flutter (latest stable)
- **Language:** Dart 3.0+
- **HTTP Client:** Dio
- **State Management:** Riverpod
- **Router:** GoRouter
- **Storage:** flutter_secure_storage (private), shared_preferences (public)
- **QR:** qr_flutter, mobile_scanner (private app only)

### Deployment
- **Container:** Docker
- **Web Server:** Nginx
- **Orchestration:** Docker Compose

---

## API Usage Patterns

### Public App (No Auth)
```dart
// Get stats for landing page
final stats = await apiClient.getChainStats();
setState(() {
  totalUsers = stats.totalUsers;
  chainLength = stats.chainLength;
});
```

### Private App (With Auth)
```dart
// Login
final authResponse = await apiClient.login(deviceId, fingerprint);
await secureStorage.write(
  key: 'accessToken',
  value: authResponse.tokens.accessToken,
);

// Get user profile (authenticated)
final token = await secureStorage.read(key: 'accessToken');
final profile = await apiClient.getUserProfile(token);

// Auto-refresh on 401
dio.interceptors.add(InterceptorsWrapper(
  onError: (error, handler) async {
    if (error.response?.statusCode == 401) {
      // Refresh token
      final newToken = await apiClient.refreshToken(refreshToken);
      // Retry request
    }
  },
));
```

---

## Success Criteria

✅ Both apps compile and run independently
✅ Both apps share the same API client
✅ Both apps can call backend successfully
✅ Public app shows real-time stats
✅ Private app supports full authentication
✅ Both apps containerized with Docker
✅ docker-compose brings up entire stack
✅ Design is consistent across both apps
✅ Code is well-documented

---

## Next Steps

**Immediate:**
1. Create directory structure
2. Initialize shared package
3. Implement API client

**Short Term:**
4. Build public app MVP
5. Build private app MVP
6. Docker configuration

**Future:**
7. Mobile apps (Android/iOS)
8. Progressive Web App features
9. Offline support
10. Real-time WebSocket updates

---

**Document Version:** 1.0
**Last Updated:** October 9, 2025
**Status:** Ready for Implementation
**Estimated Time:** 8-12 hours total
