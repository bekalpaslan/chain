# Flutter Project Structure for The Chain

**Version:** 1.0
**Date:** October 9, 2025
**Status:** Strategic Planning Document
**Owner:** Mobile Development Team

---

## Executive Summary

This document defines the Flutter project structure for The Chain, optimizing for code reuse across platforms, maintainability, and team collaboration. The architecture uses a **shared package** pattern with **dual apps** (public and private).

### Key Principles

1. **90%+ Code Reuse:** Single codebase for all platforms
2. **Clear Separation:** Shared business logic, platform-specific UI
3. **Dependency Injection:** Riverpod for state management
4. **Feature-First Organization:** Group by feature, not layer
5. **Testability:** Every component is unit-testable

---

## Table of Contents

1. [Project Layout](#project-layout)
2. [Shared Package Structure](#shared-package-structure)
3. [App-Specific Structure](#app-specific-structure)
4. [Dependency Management](#dependency-management)
5. [State Management Strategy](#state-management-strategy)
6. [Code Examples](#code-examples)

---

## Project Layout

### High-Level Structure

```
ticketz/
├── frontend/
│   ├── shared/              # Shared package (90% of code)
│   │   ├── lib/
│   │   ├── test/
│   │   └── pubspec.yaml
│   ├── public-app/          # Public app (port 3000)
│   │   ├── lib/
│   │   ├── test/
│   │   ├── web/
│   │   ├── android/
│   │   ├── ios/
│   │   ├── Dockerfile
│   │   └── pubspec.yaml
│   └── private-app/         # Private app (port 3001)
│       ├── lib/
│       ├── test/
│       ├── web/
│       ├── android/
│       ├── ios/
│       ├── Dockerfile
│       └── pubspec.yaml
├── backend/                 # Spring Boot API
└── docs/                    # Documentation
```

---

## Shared Package Structure

### Complete Directory Tree

```
frontend/shared/
├── lib/
│   ├── api/                      # API Client Layer
│   │   ├── api_client.dart       # Dio HTTP client with interceptors
│   │   └── api_exceptions.dart   # Custom exceptions
│   │
│   ├── models/                   # Data Models (JSON serializable)
│   │   ├── user.dart
│   │   ├── user.g.dart           # Generated JSON code
│   │   ├── ticket.dart
│   │   ├── ticket.g.dart
│   │   ├── chain_stats.dart
│   │   ├── chain_stats.g.dart
│   │   ├── auth_response.dart
│   │   ├── auth_response.g.dart
│   │   └── user_chain_response.dart
│   │
│   ├── repositories/             # Data Layer (Repository Pattern)
│   │   ├── auth_repository.dart
│   │   ├── ticket_repository.dart
│   │   ├── user_repository.dart
│   │   └── chain_repository.dart
│   │
│   ├── providers/                # Riverpod State Providers
│   │   ├── auth_provider.dart
│   │   ├── ticket_provider.dart
│   │   ├── user_provider.dart
│   │   └── connectivity_provider.dart
│   │
│   ├── services/                 # Business Logic Services
│   │   ├── sync_service.dart     # Offline sync
│   │   ├── notification_service.dart
│   │   └── analytics_service.dart
│   │
│   ├── database/                 # Local Database (SQLite)
│   │   ├── app_database.dart     # Database instance
│   │   ├── daos/
│   │   │   ├── ticket_dao.dart
│   │   │   └── user_dao.dart
│   │   └── migrations/
│   │       └── migration_v1.dart
│   │
│   ├── constants/                # App Constants
│   │   ├── api_constants.dart
│   │   └── app_constants.dart
│   │
│   ├── utils/                    # Utility Functions
│   │   ├── storage_helper.dart   # Secure storage wrapper
│   │   ├── device_info_helper.dart
│   │   └── date_utils.dart
│   │
│   ├── theme/                    # UI Theme
│   │   ├── dark_mystique_theme.dart
│   │   └── text_styles.dart
│   │
│   ├── widgets/                  # Reusable UI Components
│   │   ├── mystique_button.dart
│   │   ├── mystique_card.dart
│   │   ├── mystique_text_field.dart
│   │   ├── qr_code_display.dart
│   │   └── loading_indicator.dart
│   │
│   ├── screens/                  # Shared Screens (90% reusable)
│   │   ├── mystique_login_screen.dart
│   │   ├── mystique_stats_screen.dart
│   │   └── ticket_list_screen.dart
│   │
│   ├── platform/                 # Platform-Specific Implementations
│   │   ├── qr_scanner_interface.dart
│   │   ├── web/
│   │   │   ├── qr_scanner_web.dart
│   │   │   └── share_web.dart
│   │   ├── mobile/
│   │   │   ├── qr_scanner_mobile.dart
│   │   │   └── share_mobile.dart
│   │   └── desktop/
│   │       └── window_manager_desktop.dart
│   │
│   └── thechain_shared.dart      # Package exports
│
├── test/                         # Unit Tests
│   ├── api/
│   │   └── api_client_test.dart
│   ├── models/
│   │   ├── user_test.dart
│   │   └── ticket_test.dart
│   ├── repositories/
│   │   └── ticket_repository_test.dart
│   └── providers/
│       └── auth_provider_test.dart
│
└── pubspec.yaml                  # Package dependencies
```

---

### Detailed File Descriptions

#### 1. API Layer (`lib/api/`)

**api_client.dart** - HTTP client with automatic token refresh
```dart
import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../models/auth_response.dart';
import '../utils/storage_helper.dart';

class ApiClient {
  late final Dio _dio;
  final String baseUrl;

  ApiClient({String? baseUrl})
      : baseUrl = baseUrl ?? ApiConstants.defaultBaseUrl {
    _dio = Dio(BaseOptions(
      baseUrl: this.baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
    ));

    // Interceptors: Logging, Auth, Error Handling
    _dio.interceptors.add(LogInterceptor(requestBody: true));
    _dio.interceptors.add(_authInterceptor());
    _dio.interceptors.add(_errorInterceptor());
  }

  Interceptor _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await StorageHelper.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        // Handle 401: Refresh token
        if (error.response?.statusCode == 401) {
          final newTokens = await _refreshToken();
          if (newTokens != null) {
            // Retry original request
            error.requestOptions.headers['Authorization'] = 'Bearer ${newTokens.tokens.accessToken}';
            final response = await _dio.fetch(error.requestOptions);
            return handler.resolve(response);
          }
        }
        handler.next(error);
      },
    );
  }

  // ... API methods (login, register, generateTicket, etc.)
}
```

---

#### 2. Models (`lib/models/`)

**user.dart** - User data model with JSON serialization
```dart
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String chainKey;
  final int position;
  final String displayName;
  final String? email;
  final String? parentId;
  final int? inviterPosition;
  final int? inviteePosition;
  final int wastedTicketsCount;
  final int totalTicketsGenerated;
  final DateTime createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.chainKey,
    required this.position,
    required this.displayName,
    this.email,
    this.parentId,
    this.inviterPosition,
    this.inviteePosition,
    this.wastedTicketsCount = 0,
    this.totalTicketsGenerated = 0,
    required this.createdAt,
    this.updatedAt,
  });

  // JSON serialization (auto-generated)
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  // CopyWith for immutability
  User copyWith({
    String? displayName,
    String? email,
    int? wastedTicketsCount,
    // ... other fields
  }) {
    return User(
      id: id,
      chainKey: chainKey,
      position: position,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      // ... other fields
      createdAt: createdAt,
    );
  }
}
```

**Generate JSON code:**
```bash
cd frontend/shared
flutter pub run build_runner build --delete-conflicting-outputs
```

---

#### 3. Repositories (`lib/repositories/`)

**ticket_repository.dart** - Data access abstraction
```dart
import '../api/api_client.dart';
import '../database/daos/ticket_dao.dart';
import '../models/ticket.dart';
import '../services/sync_service.dart';

abstract class TicketRepository {
  Future<List<Ticket>> getMyTickets();
  Future<Ticket> generateTicket({String? message});
  Future<Ticket> getTicketById(String id);
}

class TicketRepositoryImpl implements TicketRepository {
  final ApiClient _apiClient;
  final TicketDao _ticketDao;
  final SyncService _syncService;

  TicketRepositoryImpl(this._apiClient, this._ticketDao, this._syncService);

  @override
  Future<Ticket> generateTicket({String? message}) async {
    // Create locally first (optimistic)
    final localTicket = await _ticketDao.createTicket(
      ownerId: currentUser.id,
      message: message,
      syncStatus: SyncStatus.pendingSync,
    );

    // Queue for server sync
    _syncService.enqueueTicketCreate(localTicket.id, message);

    return localTicket;
  }

  @override
  Future<List<Ticket>> getMyTickets() async {
    // Return local data immediately
    final localTickets = await _ticketDao.getTickets();

    // Refresh from server in background (don't await)
    _refreshFromServer();

    return localTickets;
  }

  Future<void> _refreshFromServer() async {
    try {
      final serverTickets = await _apiClient.getMyTickets();
      await _ticketDao.upsertAll(serverTickets);
    } catch (e) {
      // Silent failure, local data still available
    }
  }
}
```

---

#### 4. Providers (`lib/providers/`)

**auth_provider.dart** - Riverpod state management
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../repositories/auth_repository.dart';

// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.read(apiClientProvider),
    ref.read(storageProvider),
  );
});

// Current user state
final currentUserProvider = StateNotifierProvider<CurrentUserNotifier, AsyncValue<User?>>((ref) {
  return CurrentUserNotifier(ref.read(authRepositoryProvider));
});

class CurrentUserNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthRepository _authRepository;

  CurrentUserNotifier(this._authRepository) : super(const AsyncValue.loading()) {
    _loadUser();
  }

  Future<void> _loadUser() async {
    state = const AsyncValue.loading();
    try {
      final user = await _authRepository.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authRepository.login(email, password);
      state = AsyncValue.data(user);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    state = const AsyncValue.data(null);
  }
}
```

**Usage in UI:**
```dart
class ProfileScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(currentUserProvider);

    return userState.when(
      data: (user) {
        if (user == null) {
          return LoginScreen();
        }
        return ProfileView(user: user);
      },
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => ErrorWidget(error),
    );
  }
}
```

---

#### 5. Database (`lib/database/`)

**app_database.dart** - SQLite database setup
```dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'daos/ticket_dao.dart';
import 'daos/user_dao.dart';

class AppDatabase {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'thechain.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    // Create tickets table
    await db.execute('''
      CREATE TABLE tickets (
        id TEXT PRIMARY KEY,
        local_id TEXT UNIQUE,
        owner_id TEXT NOT NULL,
        ticket_code TEXT,
        qr_payload TEXT,
        issued_at INTEGER NOT NULL,
        expires_at INTEGER NOT NULL,
        status TEXT NOT NULL,
        sync_status TEXT NOT NULL,
        version INTEGER DEFAULT 1
      )
    ''');

    // Create users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        chain_key TEXT UNIQUE,
        position INTEGER,
        display_name TEXT NOT NULL,
        email TEXT,
        sync_status TEXT NOT NULL,
        version INTEGER DEFAULT 1
      )
    ''');

    // Create sync_queue table
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        action_type TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        payload TEXT NOT NULL,
        status TEXT NOT NULL,
        retry_count INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL
      )
    ''');
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle migrations
    if (oldVersion < 2) {
      // Add new column, etc.
    }
  }
}
```

**ticket_dao.dart** - Data Access Object for tickets
```dart
import 'package:sqflite/sqflite.dart';
import '../app_database.dart';
import '../../models/ticket.dart';

class TicketDao {
  Future<List<Ticket>> getTickets() async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tickets',
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => Ticket.fromJson(map)).toList();
  }

  Future<void> insertTicket(Ticket ticket) async {
    final db = await AppDatabase.database;
    await db.insert(
      'tickets',
      ticket.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> upsertAll(List<Ticket> tickets) async {
    final db = await AppDatabase.database;
    final batch = db.batch();
    for (final ticket in tickets) {
      batch.insert('tickets', ticket.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<void> deleteTicket(String id) async {
    final db = await AppDatabase.database;
    await db.delete('tickets', where: 'id = ?', whereArgs: [id]);
  }
}
```

---

#### 6. Platform Abstractions (`lib/platform/`)

**qr_scanner_interface.dart** - Abstract interface
```dart
abstract class QrScannerService {
  Future<String?> scanQR();
}
```

**mobile/qr_scanner_mobile.dart** - Mobile implementation
```dart
import 'package:mobile_scanner/mobile_scanner.dart';
import '../qr_scanner_interface.dart';

class QrScannerMobile implements QrScannerService {
  @override
  Future<String?> scanQR() async {
    // Navigate to QR scanner screen (mobile_scanner package)
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => QrScannerScreen(),
      ),
    );
    return result;
  }
}

class QrScannerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MobileScanner(
        onDetect: (capture) {
          final barcode = capture.barcodes.first;
          Navigator.pop(context, barcode.rawValue);
        },
      ),
    );
  }
}
```

**web/qr_scanner_web.dart** - Web fallback
```dart
import '../qr_scanner_interface.dart';

class QrScannerWeb implements QrScannerService {
  @override
  Future<String?> scanQR() async {
    // Show manual entry dialog (camera unreliable on web)
    return await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter Invite Code'),
          content: TextField(
            decoration: InputDecoration(hintText: '6-digit code'),
            onSubmitted: (value) => Navigator.pop(context, value),
          ),
        );
      },
    );
  }
}
```

**Factory:**
```dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class PlatformFactory {
  static QrScannerService createQrScanner() {
    if (kIsWeb) {
      return QrScannerWeb();
    } else if (Platform.isAndroid || Platform.isIOS) {
      return QrScannerMobile();
    } else {
      return QrScannerDesktop();
    }
  }
}
```

---

## App-Specific Structure

### Public App (`frontend/public-app/`)

```
public-app/
├── lib/
│   ├── main.dart             # Entry point
│   ├── app.dart              # App widget, routing
│   ├── pages/
│   │   ├── landing_page.dart
│   │   ├── stats_page.dart
│   │   └── invite_entry_page.dart
│   └── config/
│       └── routes.dart       # GoRouter configuration
├── web/
│   ├── index.html
│   ├── manifest.json
│   └── favicon.png
├── android/
├── ios/
├── test/
└── pubspec.yaml
```

**main.dart:**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thechain_shared/thechain_shared.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ProviderScope(
      child: PublicApp(),
    ),
  );
}
```

**app.dart:**
```dart
import 'package:flutter/material.dart';
import 'package:thechain_shared/theme/dark_mystique_theme.dart';
import 'config/routes.dart';

class PublicApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'The Chain',
      theme: DarkMystiqueTheme.theme,
      routerConfig: router,
    );
  }
}
```

**config/routes.dart:**
```dart
import 'package:go_router/go_router.dart';
import '../pages/landing_page.dart';
import '../pages/stats_page.dart';
import '../pages/invite_entry_page.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => LandingPage(),
    ),
    GoRoute(
      path: '/stats',
      builder: (context, state) => StatsPage(),
    ),
    GoRoute(
      path: '/invite/:code',
      builder: (context, state) {
        final code = state.pathParameters['code']!;
        return InviteEntryPage(inviteCode: code);
      },
    ),
  ],
);
```

---

### Private App (`frontend/private-app/`)

```
private-app/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── pages/
│   │   ├── login_page.dart
│   │   ├── dashboard_page.dart
│   │   ├── ticket_generation_page.dart
│   │   ├── qr_scanner_page.dart
│   │   └── profile_page.dart
│   └── config/
│       └── routes.dart
├── web/
├── android/
├── ios/
├── test/
└── pubspec.yaml
```

**routes.dart (with auth guard):**
```dart
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thechain_shared/providers/auth_provider.dart';
import '../pages/login_page.dart';
import '../pages/dashboard_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(currentUserProvider);

  return GoRouter(
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isLoginRoute = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoginRoute) {
        return '/login';
      }
      if (isLoggedIn && isLoginRoute) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginPage(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => DashboardPage(),
      ),
      GoRoute(
        path: '/tickets/generate',
        builder: (context, state) => TicketGenerationPage(),
      ),
      GoRoute(
        path: '/scan',
        builder: (context, state) => QrScannerPage(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => ProfilePage(),
      ),
    ],
  );
});
```

---

## Dependency Management

### Shared Package (`pubspec.yaml`)

```yaml
name: thechain_shared
description: Shared API client, models, and utilities for The Chain
version: 0.0.1

environment:
  sdk: ^3.9.2
  flutter: ">=1.17.0"

dependencies:
  flutter:
    sdk: flutter

  # HTTP & API
  dio: ^5.4.0
  json_annotation: ^4.8.1

  # Storage
  flutter_secure_storage: ^9.0.0
  shared_preferences: ^2.2.2
  sqflite: ^2.3.0

  # Device Info
  device_info_plus: ^10.0.1
  crypto: ^3.0.3

  # State Management
  flutter_riverpod: ^2.4.9

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.8
  json_serializable: ^6.7.1
  flutter_lints: ^5.0.0
```

---

### Public App (`pubspec.yaml`)

```yaml
name: thechain_public
description: The Chain public app
version: 1.0.0+1

environment:
  sdk: ^3.9.2

dependencies:
  flutter:
    sdk: flutter

  # Shared package
  thechain_shared:
    path: ../shared

  # Routing
  go_router: ^13.0.0

  # UI
  qr_flutter: ^4.1.0  # QR display

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```

---

### Private App (`pubspec.yaml`)

```yaml
name: thechain_private
description: The Chain private app
version: 1.0.0+1

environment:
  sdk: ^3.9.2

dependencies:
  flutter:
    sdk: flutter

  # Shared package
  thechain_shared:
    path: ../shared

  # Routing
  go_router: ^13.0.0

  # Platform-specific features
  mobile_scanner: ^4.0.1       # QR scanning (mobile)
  local_auth: ^2.1.7           # Biometric auth
  firebase_messaging: ^14.7.10 # Push notifications

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```

---

## State Management Strategy

### Riverpod Architecture

```
┌─────────────────────────────────────────────────┐
│                  UI Layer                        │
│  ConsumerWidget / ConsumerStatefulWidget        │
└─────────────────┬───────────────────────────────┘
                  │ ref.watch / ref.read
                  ▼
┌─────────────────────────────────────────────────┐
│             Provider Layer                       │
│  StateNotifierProvider, FutureProvider, etc.    │
└─────────────────┬───────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────┐
│           Repository Layer                       │
│  Business Logic + Data Access                   │
└─────────────────┬───────────────────────────────┘
                  │
           ┌──────┴──────┐
           ▼             ▼
    ┌──────────┐  ┌──────────┐
    │ API      │  │ Local DB │
    │ Client   │  │ (SQLite) │
    └──────────┘  └──────────┘
```

### Provider Examples

#### 1. Simple State Provider
```dart
final counterProvider = StateProvider<int>((ref) => 0);

// Usage
Text('Count: ${ref.watch(counterProvider)}')
ElevatedButton(
  onPressed: () => ref.read(counterProvider.notifier).state++,
  child: Text('Increment'),
)
```

#### 2. FutureProvider (Async Data)
```dart
final chainStatsProvider = FutureProvider<ChainStats>((ref) async {
  final apiClient = ref.read(apiClientProvider);
  return await apiClient.getChainStats();
});

// Usage
final stats = ref.watch(chainStatsProvider);
stats.when(
  data: (data) => Text('Users: ${data.totalUsers}'),
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => Text('Error: $err'),
)
```

#### 3. StateNotifierProvider (Complex State)
```dart
class TicketsNotifier extends StateNotifier<AsyncValue<List<Ticket>>> {
  final TicketRepository _repository;

  TicketsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadTickets();
  }

  Future<void> loadTickets() async {
    state = const AsyncValue.loading();
    try {
      final tickets = await _repository.getMyTickets();
      state = AsyncValue.data(tickets);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> generateTicket({String? message}) async {
    try {
      final newTicket = await _repository.generateTicket(message: message);
      state = AsyncValue.data([...?state.value, newTicket]);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }
}

final ticketsProvider = StateNotifierProvider<TicketsNotifier, AsyncValue<List<Ticket>>>((ref) {
  return TicketsNotifier(ref.read(ticketRepositoryProvider));
});
```

---

## Code Examples

### Complete Feature: Ticket Generation

#### 1. Model (`shared/lib/models/ticket.dart`)
```dart
import 'package:json_annotation/json_annotation.dart';

part 'ticket.g.dart';

@JsonSerializable()
class Ticket {
  final String id;
  final String ownerId;
  final String? ticketCode;
  final String? qrPayload;
  final DateTime issuedAt;
  final DateTime expiresAt;
  final TicketStatus status;

  Ticket({
    required this.id,
    required this.ownerId,
    this.ticketCode,
    this.qrPayload,
    required this.issuedAt,
    required this.expiresAt,
    required this.status,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) => _$TicketFromJson(json);
  Map<String, dynamic> toJson() => _$TicketToJson(this);
}

enum TicketStatus {
  @JsonValue('ACTIVE')
  active,
  @JsonValue('USED')
  used,
  @JsonValue('EXPIRED')
  expired,
}
```

#### 2. Repository (`shared/lib/repositories/ticket_repository.dart`)
```dart
abstract class TicketRepository {
  Future<Ticket> generateTicket({String? message});
}

class TicketRepositoryImpl implements TicketRepository {
  final ApiClient _apiClient;
  final TicketDao _ticketDao;

  TicketRepositoryImpl(this._apiClient, this._ticketDao);

  @override
  Future<Ticket> generateTicket({String? message}) async {
    final ticket = await _apiClient.generateTicket(message: message);
    await _ticketDao.insertTicket(ticket);
    return ticket;
  }
}
```

#### 3. Provider (`shared/lib/providers/ticket_provider.dart`)
```dart
final ticketRepositoryProvider = Provider<TicketRepository>((ref) {
  return TicketRepositoryImpl(
    ref.read(apiClientProvider),
    ref.read(ticketDaoProvider),
  );
});

final ticketsProvider = StateNotifierProvider<TicketsNotifier, AsyncValue<List<Ticket>>>((ref) {
  return TicketsNotifier(ref.read(ticketRepositoryProvider));
});
```

#### 4. UI Screen (`private-app/lib/pages/ticket_generation_page.dart`)
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thechain_shared/providers/ticket_provider.dart';
import 'package:thechain_shared/widgets/mystique_button.dart';

class TicketGenerationPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsState = ref.watch(ticketsProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Generate Ticket')),
      body: Column(
        children: [
          ticketsState.when(
            data: (tickets) {
              final activeTicket = tickets.firstWhere(
                (t) => t.status == TicketStatus.active,
                orElse: () => null,
              );

              if (activeTicket != null) {
                return QRCodeDisplay(ticket: activeTicket);
              }

              return MystiqueButton(
                label: 'Generate Invitation Ticket',
                onPressed: () {
                  ref.read(ticketsProvider.notifier).generateTicket();
                },
              );
            },
            loading: () => CircularProgressIndicator(),
            error: (err, stack) => Text('Error: $err'),
          ),
        ],
      ),
    );
  }
}
```

---

## Build & Development Commands

### Development
```bash
# Run public app on web
cd frontend/public-app
flutter run -d chrome

# Run private app on Android
cd frontend/private-app
flutter run -d <device-id>

# Hot reload is automatic
```

### Code Generation
```bash
# Generate JSON serialization code
cd frontend/shared
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-generates on file save)
flutter pub run build_runner watch
```

### Testing
```bash
# Run all tests
flutter test

# Run specific test
flutter test test/repositories/ticket_repository_test.dart

# Coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Production Build
```bash
# Web
flutter build web --release

# Android
flutter build apk --release --split-per-abi

# iOS
flutter build ios --release
```

---

## Appendix: Import Best Practices

### Avoid Relative Imports
```dart
// ❌ Bad: Relative import
import '../../models/user.dart';

// ✅ Good: Package import
import 'package:thechain_shared/models/user.dart';
```

### Export Barrel Files
```dart
// shared/lib/thechain_shared.dart
library thechain_shared;

export 'api/api_client.dart';
export 'models/user.dart';
export 'models/ticket.dart';
export 'providers/auth_provider.dart';
export 'theme/dark_mystique_theme.dart';
export 'widgets/mystique_button.dart';

// Usage in apps
import 'package:thechain_shared/thechain_shared.dart';
```

---

**Generated by Claude Code - Mobile Development Team**
**Last Updated:** October 9, 2025
