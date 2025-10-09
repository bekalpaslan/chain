# The Chain - Shared Package

Shared API client, models, and utilities for The Chain platform.

## Features

- **API Client**: Dio-based HTTP client with automatic token refresh and error handling
- **Models**: JSON-serializable data models for all API entities
- **Constants**: Centralized API endpoints and app constants
- **Utils**: Device info, storage helpers for tokens and preferences

## Usage

Add to your Flutter app's `pubspec.yaml`:

```yaml
dependencies:
  thechain_shared:
    path: ../shared
```

## API Client Example

```dart
import 'package:thechain_shared/thechain_shared.dart';

// Initialize API client
final apiClient = ApiClient(baseUrl: 'http://localhost:8080');

// Public endpoint (no auth)
final stats = await apiClient.getChainStats();

// Login
final authResponse = await apiClient.login(deviceId, fingerprint);
await StorageHelper.saveAccessToken(authResponse.tokens.accessToken);
await StorageHelper.saveRefreshToken(authResponse.tokens.refreshToken);

// Authenticated endpoint
final profile = await apiClient.getUserProfile();
final chain = await apiClient.getUserChain();
```

## Models

- `User`: User profile and chain information
- `Ticket`: Invitation ticket details
- `ChainStats`: Platform-wide statistics
- `AuthResponse`: Authentication response with tokens
- `UserChainResponse`: User chain node information

## Code Generation

After modifying models, run:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```
