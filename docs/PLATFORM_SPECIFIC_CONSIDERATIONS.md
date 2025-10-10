# Platform-Specific Considerations for The Chain

**Version:** 1.0
**Date:** October 9, 2025
**Status:** Strategic Planning Document
**Owner:** Cross-Functional Team

---

## Executive Summary

This document details platform-specific implementation considerations, limitations, and workarounds for The Chain across web, mobile (Android/iOS), and future desktop platforms.

### Platform Priority

| Platform | Priority | MVP (Week 4) | Post-MVP | Rationale |
|----------|----------|--------------|----------|-----------|
| **Web** | P1 | ✅ Both apps | PWA enhancements | Zero friction, SEO, instant distribution |
| **Android** | P2 | ✅ Private app | Google Play release | 70% market share globally |
| **iOS** | P3 | ⏳ Week 5 | App Store release | Premium users, US/EU markets |
| **Desktop** | P4 | ❌ Not MVP | Month 3+ | Admin tools, power users |

---

## Table of Contents

1. [Web Platform](#web-platform)
2. [Android Platform](#android-platform)
3. [iOS Platform](#ios-platform)
4. [Desktop Platform (Future)](#desktop-platform-future)
5. [Feature Parity Matrix](#feature-parity-matrix)
6. [Cross-Platform Code Sharing](#cross-platform-code-sharing)

---

## Web Platform

### Overview

**Target Browsers:**
- Chrome 90+ (Chromium-based: Edge, Opera, Brave)
- Firefox 88+
- Safari 14+ (macOS, iOS)

**Build Output:**
- Static HTML/CSS/JS files
- Service worker (PWA)
- Hosted on Nginx

---

### Capabilities

#### ✅ Fully Supported

1. **Responsive Design**
   - Mobile viewports (320px - 480px)
   - Tablet viewports (768px - 1024px)
   - Desktop viewports (1280px+)

2. **Authentication**
   - JWT tokens in localStorage (encrypted)
   - Session management
   - Auto-login via stored tokens

3. **QR Code Display**
   - Canvas-based QR generation (qr_flutter package)
   - Download as PNG image
   - Share via Web Share API (mobile browsers)

4. **API Communication**
   - REST API calls (Dio HTTP client)
   - CORS-enabled backend
   - WebSocket for real-time updates

5. **Local Storage**
   - localStorage (5-10 MB limit)
   - IndexedDB (unlimited, browser-dependent)
   - Service Worker cache (PWA)

---

#### ⚠️ Limited Support

1. **QR Code Scanning**
   - **Problem:** Camera access via WebRTC is inconsistent
   - **Browser Support:**
     - Chrome (Android/Desktop): ✅ Good
     - Safari (iOS): ⚠️ Requires HTTPS, user permission
     - Firefox: ✅ Good
   - **Fallback:** Manual invite code entry (6-digit codes)

   **Implementation:**
   ```dart
   // lib/web/qr_scanner_web.dart
   import 'dart:html' as html;

   class QrScannerWeb {
     Future<String?> scanQR() async {
       try {
         // Attempt to use Web API for QR scanning
         final stream = await html.window.navigator.mediaDevices
             ?.getUserMedia({'video': true});

         if (stream == null) {
           throw UnsupportedError('Camera not available');
         }

         // Use jsQR library for scanning
         // ... scanning logic

       } catch (e) {
         // Fallback to manual entry
         return await _showManualEntryDialog();
       }
     }

     Future<String?> _showManualEntryDialog() async {
       // Show dialog with text input for invite code
       // Return code when user submits
     }
   }
   ```

2. **Push Notifications**
   - **Web Push:** Supported on Chrome/Firefox, limited on Safari
   - **Requires:** Service worker, user permission
   - **Limitations:**
     - No notifications when browser closed (Safari)
     - Varies by browser vendor
   - **Fallback:** Email notifications, in-app notification center

3. **Background Sync**
   - **Background Sync API:** Chrome only, experimental
   - **Fallback:** Periodic sync when app in foreground

4. **File System Access**
   - **File System Access API:** Chrome 86+, not in Firefox/Safari
   - **Fallback:** Download files via Blob URLs

---

#### ❌ Not Supported

1. **Biometric Authentication**
   - No fingerprint/Face ID on web
   - Alternative: Strong password + 2FA (future)

2. **Native Notifications**
   - Can't show OS-level notifications like mobile apps
   - Use Web Push (limited) or in-app banners

3. **Deep Linking**
   - No URL scheme (thechain://) on web
   - Use regular HTTPS URLs (thechain.app/invite/ABC123)

---

### Web-Specific Implementation

#### 1. Progressive Web App (PWA)

**manifest.json:**
```json
{
  "name": "The Chain",
  "short_name": "TheChain",
  "description": "Social ticketing chain network",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#0A0E27",
  "theme_color": "#6C63FF",
  "icons": [
    {
      "src": "/icons/icon-192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "/icons/icon-512.png",
      "sizes": "512x512",
      "type": "image/png"
    }
  ]
}
```

**Service Worker (sw.js):**
```javascript
// Cache strategy: Network-first, fallback to cache
self.addEventListener('fetch', (event) => {
  event.respondWith(
    fetch(event.request)
      .then((response) => {
        // Clone and cache successful responses
        const responseClone = response.clone();
        caches.open('chain-v1').then((cache) => {
          cache.put(event.request, responseClone);
        });
        return response;
      })
      .catch(() => {
        // Network failed, try cache
        return caches.match(event.request);
      })
  );
});
```

---

#### 2. Web Share API

```dart
// lib/web/share_web.dart
import 'dart:html' as html;

class ShareServiceWeb {
  Future<void> shareTicket(Ticket ticket) async {
    if (html.window.navigator.share != null) {
      // Use native Web Share API (mobile browsers)
      await html.window.navigator.share({
        'title': 'Join The Chain!',
        'text': 'Use my invite code: ${ticket.ticketCode}',
        'url': 'https://thechain.app/invite/${ticket.ticketCode}',
      });
    } else {
      // Fallback: Copy to clipboard
      await html.window.navigator.clipboard
          ?.writeText('https://thechain.app/invite/${ticket.ticketCode}');

      // Show snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Link copied to clipboard!')),
      );
    }
  }
}
```

---

#### 3. Responsive Layout

```dart
// lib/web/responsive_layout.dart
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return mobile; // Mobile layout
        } else if (constraints.maxWidth < 1200) {
          return tablet; // Tablet layout
        } else {
          return desktop; // Desktop layout
        }
      },
    );
  }
}

// Usage
ResponsiveLayout(
  mobile: MobileTicketList(),
  tablet: TabletTicketGrid(),
  desktop: DesktopTicketDashboard(),
)
```

---

### Web Performance Optimization

#### Bundle Size

**Target:** < 2 MB (before gzip), < 500 KB (after gzip)

**Optimization:**
1. **Code Splitting:** Lazy load routes
   ```dart
   routes: [
     GoRoute(
       path: '/tickets',
       builder: (context, state) {
         // Lazy load heavy pages
         return FutureBuilder(
           future: import('package:thechain/pages/tickets_page.dart'),
           builder: (context, snapshot) {
             if (snapshot.hasData) {
               return snapshot.data!.TicketsPage();
             }
             return CircularProgressIndicator();
           },
         );
       },
     ),
   ],
   ```

2. **Tree Shaking:** Remove unused code
   ```bash
   flutter build web --release --tree-shake-icons
   ```

3. **Image Optimization:** Use WebP format
   ```dart
   Image.network(
     'https://cdn.thechain.app/qr/${ticket.id}.webp',
     errorBuilder: (context, error, stackTrace) {
       // Fallback to PNG
       return Image.network('https://cdn.thechain.app/qr/${ticket.id}.png');
     },
   )
   ```

---

#### First Paint Optimization

**Target:** < 1.5 seconds on 4G

1. **Inline Critical CSS:** Above-the-fold styles in `<head>`
2. **Defer Non-Critical JS:** Load analytics, chat widgets later
3. **Preconnect to API:** DNS prefetch
   ```html
   <link rel="preconnect" href="https://api.thechain.app">
   <link rel="dns-prefetch" href="https://api.thechain.app">
   ```

4. **Skeleton Screens:** Show placeholders while loading
   ```dart
   FutureBuilder<ChainStats>(
     future: _fetchStats(),
     builder: (context, snapshot) {
       if (snapshot.connectionState == ConnectionState.waiting) {
         return SkeletonLoader(); // Animated placeholder
       }
       return StatsWidget(stats: snapshot.data!);
     },
   )
   ```

---

### Web Deployment

**Hosting:** Nginx (configured in docker-compose.yml)

**nginx.conf:**
```nginx
server {
    listen 3000;
    server_name localhost;

    root /usr/share/nginx/html;
    index index.html;

    # SPA routing: Always serve index.html
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Cache static assets (images, fonts, etc.)
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # No cache for index.html (to get updates immediately)
    location = /index.html {
        add_header Cache-Control "no-cache, no-store, must-revalidate";
    }

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # CORS (if API on different domain)
    add_header Access-Control-Allow-Origin "https://api.thechain.app" always;
}
```

---

## Android Platform

### Overview

**Minimum SDK:** Android 10 (API 29)
**Target SDK:** Android 14 (API 34)
**Distribution:** Google Play Store, APK direct download

**Market Share:** 70%+ globally (dominant in Asia, Africa, South America)

---

### Capabilities

#### ✅ Fully Supported (All Features)

1. **QR Code Scanning**
   - **Package:** `mobile_scanner: ^4.0.1`
   - **Camera Permission:** Automatically requested on first scan
   - **Performance:** < 1 second scan time

   **Implementation:**
   ```dart
   // lib/mobile/qr_scanner_mobile.dart
   import 'package:mobile_scanner/mobile_scanner.dart';

   class QrScannerMobile extends StatelessWidget {
     final Function(String) onScan;

     @override
     Widget build(BuildContext context) {
       return MobileScanner(
         onDetect: (capture) {
           final List<Barcode> barcodes = capture.barcodes;
           for (final barcode in barcodes) {
             if (barcode.rawValue != null) {
               onScan(barcode.rawValue!);
               break;
             }
           }
         },
       );
     }
   }
   ```

2. **Push Notifications**
   - **Service:** Firebase Cloud Messaging (FCM)
   - **Notification Channels:** Required for Android 8+

   **Setup:**
   ```yaml
   # pubspec.yaml
   dependencies:
     firebase_messaging: ^14.7.10
     firebase_core: ^2.24.2
   ```

   **Implementation:**
   ```dart
   // lib/mobile/notifications_service.dart
   import 'package:firebase_messaging/firebase_messaging.dart';

   class NotificationsService {
     final FirebaseMessaging _fcm = FirebaseMessaging.instance;

     Future<void> init() async {
       // Request permission
       NotificationSettings settings = await _fcm.requestPermission(
         alert: true,
         badge: true,
         sound: true,
       );

       if (settings.authorizationStatus == AuthorizationStatus.authorized) {
         // Get FCM token
         String? token = await _fcm.getToken();
         await _apiClient.registerDeviceToken(token);

         // Listen for messages
         FirebaseMessaging.onMessage.listen(_handleMessage);
         FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);
       }
     }

     void _handleMessage(RemoteMessage message) {
       // Show local notification
       _localNotifications.show(
         message.hashCode,
         message.notification?.title,
         message.notification?.body,
       );
     }
   }
   ```

3. **Biometric Authentication**
   - **Types:** Fingerprint, Face Unlock
   - **Package:** `local_auth: ^2.1.7`

   **Implementation:**
   ```dart
   import 'package:local_auth/local_auth.dart';

   class BiometricAuth {
     final LocalAuthentication _auth = LocalAuthentication();

     Future<bool> authenticate() async {
       try {
         final canCheck = await _auth.canCheckBiometrics;
         if (!canCheck) return false;

         return await _auth.authenticate(
           localizedReason: 'Authenticate to access The Chain',
           options: const AuthenticationOptions(
             stickyAuth: true,
             biometricOnly: true,
           ),
         );
       } catch (e) {
         return false;
       }
     }
   }
   ```

4. **Deep Linking**
   - **URL Scheme:** `thechain://invite/{code}`
   - **HTTP Links:** `https://thechain.app/invite/{code}`

   **AndroidManifest.xml:**
   ```xml
   <intent-filter>
       <action android:name="android.intent.action.VIEW" />
       <category android:name="android.intent.category.DEFAULT" />
       <category android:name="android.intent.category.BROWSABLE" />

       <!-- Custom scheme -->
       <data android:scheme="thechain" android:host="invite" />

       <!-- App Links (verified HTTPS) -->
       <data
           android:scheme="https"
           android:host="thechain.app"
           android:pathPrefix="/invite" />
   </intent-filter>
   ```

   **Flutter:**
   ```dart
   // lib/mobile/deep_linking.dart
   import 'package:app_links/app_links.dart';

   class DeepLinkingService {
     final _appLinks = AppLinks();

     void init() {
       // Handle app opened from link
       _appLinks.uriLinkStream.listen((uri) {
         if (uri.pathSegments.first == 'invite') {
           final code = uri.pathSegments[1];
           _navigateToInvite(code);
         }
       });
     }
   }
   ```

5. **Background Services**
   - **Sync Service:** Periodic sync even when app closed
   - **Package:** `workmanager: ^0.5.1`

   **Implementation:**
   ```dart
   import 'package:workmanager/workmanager.dart';

   void callbackDispatcher() {
     Workmanager().executeTask((task, inputData) async {
       // Sync pending actions
       await SyncService().syncAll();
       return true;
     });
   }

   void main() {
     WidgetsFlutterBinding.ensureInitialized();
     Workmanager().initialize(callbackDispatcher);
     Workmanager().registerPeriodicTask(
       'syncTask',
       'syncAction',
       frequency: Duration(hours: 1),
     );
     runApp(MyApp());
   }
   ```

---

### Android-Specific Configuration

#### build.gradle (app level)

```gradle
android {
    compileSdkVersion 34

    defaultConfig {
        applicationId "com.thechain.app"
        minSdkVersion 29
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"

        multiDexEnabled true
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
}
```

---

#### ProGuard Rules (proguard-rules.pro)

```proguard
# Keep API models (JSON serialization)
-keep class com.thechain.models.** { *; }

# Keep Dio HTTP client
-keep class io.flutter.plugins.** { *; }

# Keep Firebase
-keep class com.google.firebase.** { *; }
```

---

### Android Testing

#### Device Test Matrix

| Device | Android Version | Screen Size | Notes |
|--------|----------------|-------------|-------|
| Samsung Galaxy S21 | 13 | 6.2" (1080x2400) | High-end flagship |
| Google Pixel 6 | 14 | 6.4" (1080x2340) | Pure Android |
| OnePlus 9 | 13 | 6.55" (1080x2400) | OxygenOS skin |
| Xiaomi Redmi Note 10 | 11 | 6.43" (1080x2400) | Budget segment |
| Samsung Galaxy A52 | 12 | 6.5" (1080x2400) | Mid-range |

---

## iOS Platform

### Overview

**Minimum iOS:** 14.0
**Distribution:** Apple App Store (TestFlight for beta)

**Market Share:** 25-30% globally (dominant in US, UK, Japan)

---

### Capabilities

#### ✅ Fully Supported

1. **QR Code Scanning**
   - Same `mobile_scanner` package as Android
   - **Superior Camera:** Better low-light performance

2. **Push Notifications**
   - **Service:** Apple Push Notification service (APNs)
   - **Requires:** Apple Developer account ($99/year)

   **Setup:**
   ```dart
   // Same Firebase Messaging package, different backend config
   final apnsToken = await _fcm.getAPNSToken();
   ```

3. **Biometric Authentication**
   - **Face ID:** iPhone X+ (requires Face ID permission in Info.plist)
   - **Touch ID:** iPhone 5s - 8 (Home button devices)

   **Info.plist:**
   ```xml
   <key>NSFaceIDUsageDescription</key>
   <string>We use Face ID to secure your account</string>
   ```

4. **Deep Linking**
   - **Universal Links:** Verified HTTPS links
   - **Custom Scheme:** `thechain://`

   **Info.plist:**
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
       <dict>
           <key>CFBundleURLSchemes</key>
           <array>
               <string>thechain</string>
           </array>
       </dict>
   </array>
   ```

   **Associated Domains (Universal Links):**
   ```xml
   <key>com.apple.developer.associated-domains</key>
   <array>
       <string>applinks:thechain.app</string>
   </array>
   ```

   **Server (apple-app-site-association):**
   ```json
   {
     "applinks": {
       "apps": [],
       "details": [
         {
           "appID": "TEAMID.com.thechain.app",
           "paths": ["/invite/*"]
         }
       ]
     }
   }
   ```

---

### iOS-Specific Configuration

#### Info.plist Permissions

```xml
<!-- Camera for QR scanning -->
<key>NSCameraUsageDescription</key>
<string>We need camera access to scan QR codes</string>

<!-- Location (if sharing location) -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>Share your location to appear on the chain map</string>

<!-- Push notifications -->
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

---

#### Podfile Configuration

```ruby
platform :ios, '14.0'

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))

  # Firebase
  pod 'Firebase/Messaging'
  pod 'Firebase/Analytics'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)

    # Fix for iOS 14+ compatibility
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
    end
  end
end
```

---

### iOS App Store Requirements

#### 1. Privacy Nutrition Labels

**Required Disclosures:**
- **Data Collected:**
  - Email (for authentication)
  - Device ID (for fingerprinting)
  - Location (if user opts in)
- **Tracking:** None (we don't track across apps/websites)
- **Usage:** Account creation, fraud prevention

**Privacy Policy URL:** https://thechain.app/privacy

---

#### 2. App Review Guidelines Compliance

**Potential Issues:**
- **Guideline 2.1 (App Completeness):** Ensure app is fully functional during review
- **Guideline 4.0 (Design):** UI must be polished, no broken features
- **Guideline 5.1.1 (Privacy):** Clear privacy policy, user consent

**Mitigation:**
- Provide test account credentials in App Review notes
- Prepare demo video showing ticket flow
- Include clear onboarding explaining the chain concept

---

### iOS Testing

#### Device Test Matrix

| Device | iOS Version | Screen Size | Notes |
|--------|------------|-------------|-------|
| iPhone 14 Pro Max | 17.0 | 6.7" (1290x2796) | Latest flagship |
| iPhone 13 | 16.5 | 6.1" (1170x2532) | Current popular model |
| iPhone SE (2022) | 16.0 | 4.7" (750x1334) | Smallest screen |
| iPad Air | 16.5 | 10.9" (1640x2360) | Tablet support |

---

## Desktop Platform (Future)

### Overview

**Platforms:** Windows, macOS, Linux
**Timeline:** Month 3+ (not MVP)
**Use Cases:** Admin dashboard, power users, kiosk mode

---

### Capabilities

#### Windows

- **Distribution:** MSI installer, Microsoft Store
- **Features:**
  - System tray integration
  - Windows Hello (biometric)
  - File system access (export data)
  - Native notifications (Windows Notification Center)

#### macOS

- **Distribution:** DMG installer, Mac App Store
- **Features:**
  - Menu bar app
  - Touch ID
  - Sandboxed file access
  - Native notifications (Notification Center)

#### Linux

- **Distribution:** AppImage, Snap, Flatpak
- **Features:**
  - System tray integration (varies by DE)
  - File system access
  - D-Bus notifications

---

### Desktop-Specific Considerations

#### Window Management

```dart
// lib/desktop/window_manager.dart
import 'package:window_manager/window_manager.dart';

class DesktopWindowManager {
  Future<void> init() async {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = WindowOptions(
      size: Size(1200, 800),
      minimumSize: Size(800, 600),
      center: true,
      title: 'The Chain',
      titleBarStyle: TitleBarStyle.hidden, // Custom title bar
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
}
```

---

#### Native Menu Bar

```dart
// lib/desktop/menu_bar.dart
import 'package:menu_bar/menu_bar.dart';

Widget buildMenuBar() {
  return MenuBar(
    menus: [
      BarButton(
        text: const Text('File'),
        submenu: SubMenu(
          menuItems: [
            MenuButton(
              text: const Text('Generate Ticket'),
              onTap: () => _generateTicket(),
              shortcutText: 'Ctrl+N',
            ),
            MenuDivider(),
            MenuButton(
              text: const Text('Exit'),
              onTap: () => exit(0),
              shortcutText: 'Ctrl+Q',
            ),
          ],
        ),
      ),
    ],
  );
}
```

---

## Feature Parity Matrix

| Feature | Web | Android | iOS | Desktop |
|---------|-----|---------|-----|---------|
| **Authentication** | ✅ | ✅ | ✅ | ✅ |
| **JWT Storage** | localStorage | Secure Storage | Keychain | Secure Storage |
| **Ticket Generation** | ✅ | ✅ | ✅ | ✅ |
| **QR Display** | ✅ | ✅ | ✅ | ✅ |
| **QR Scanning** | ⚠️ Limited | ✅ | ✅ | ✅ |
| **Push Notifications** | ⚠️ Web Push | ✅ FCM | ✅ APNs | ✅ Native |
| **Biometric Auth** | ❌ | ✅ | ✅ | ✅ (Windows Hello) |
| **Offline Storage** | 5 MB (IndexedDB) | Unlimited (SQLite) | Unlimited (SQLite) | Unlimited (SQLite) |
| **Background Sync** | ⚠️ Limited | ✅ | ✅ | ✅ |
| **Deep Linking** | ✅ HTTPS | ✅ | ✅ Universal Links | ✅ Custom protocols |
| **File System** | ❌ | ✅ | ⚠️ Sandboxed | ✅ |
| **Camera Access** | ⚠️ WebRTC | ✅ | ✅ | ✅ |
| **Location** | ✅ | ✅ | ✅ | ✅ |
| **Share API** | ⚠️ Web Share | ✅ | ✅ | ✅ |
| **Auto-Update** | ✅ Instant | ⚠️ Manual (Store) | ⚠️ Manual (Store) | ✅ (custom updater) |

**Legend:**
- ✅ Fully supported
- ⚠️ Partially supported / Limited
- ❌ Not supported

---

## Cross-Platform Code Sharing

### Shared Code (90%)

```
lib/
├── models/              # 100% shared - Data models
├── api/                 # 100% shared - API client
├── repositories/        # 100% shared - Data layer
├── providers/           # 100% shared - Riverpod state
├── theme/               # 100% shared - Dark Mystique theme
├── widgets/             # 95% shared - Reusable components
└── screens/             # 80% shared - UI screens
```

---

### Platform-Specific Code (10%)

```
lib/
├── platform/
│   ├── web/
│   │   ├── qr_scanner_web.dart       # Manual entry fallback
│   │   ├── share_web.dart            # Web Share API
│   │   └── notifications_web.dart     # Web Push
│   ├── mobile/
│   │   ├── qr_scanner_mobile.dart    # mobile_scanner
│   │   ├── share_mobile.dart         # Native share
│   │   └── notifications_mobile.dart  # FCM/APNs
│   └── desktop/
│       ├── window_manager.dart       # Window controls
│       ├── menu_bar.dart             # Native menus
│       └── notifications_desktop.dart # Native notifications
```

---

### Platform Abstraction Pattern

```dart
// lib/services/qr_scanner_service.dart
abstract class QrScannerService {
  Future<String?> scanQR();
}

// lib/platform/qr_scanner_factory.dart
import 'qr_scanner_web.dart' if (dart.library.io) 'qr_scanner_mobile.dart';

class QrScannerFactory {
  static QrScannerService create() {
    if (kIsWeb) {
      return QrScannerWeb();
    } else if (Platform.isAndroid || Platform.isIOS) {
      return QrScannerMobile();
    } else {
      return QrScannerDesktop();
    }
  }
}

// Usage
final scanner = QrScannerFactory.create();
final code = await scanner.scanQR();
```

---

## Platform-Specific Build Commands

### Web
```bash
# Development
flutter run -d chrome

# Production build
flutter build web --release --web-renderer canvaskit
```

### Android
```bash
# Development
flutter run -d <device-id>

# Release APK
flutter build apk --release --split-per-abi

# App Bundle (for Play Store)
flutter build appbundle --release
```

### iOS
```bash
# Development
flutter run -d <device-id>

# Release IPA
flutter build ios --release
# Then archive in Xcode
```

### Desktop
```bash
# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release
```

---

## Appendix: Platform Testing Checklist

### Pre-Release Checklist

#### Web
- [ ] Test on Chrome, Firefox, Safari
- [ ] Test mobile viewports (320px, 768px, 1024px)
- [ ] Verify PWA installability
- [ ] Test offline mode (Service Worker)
- [ ] Lighthouse score > 90 (Performance, Accessibility, SEO)

#### Android
- [ ] Test on 5+ devices (various manufacturers)
- [ ] Test Android 10, 11, 12, 13, 14
- [ ] Verify camera permissions
- [ ] Test push notifications
- [ ] Test biometric auth (fingerprint)
- [ ] Verify deep linking (thechain://)
- [ ] Check APK size < 15 MB

#### iOS
- [ ] Test on iPhone 14, 13, SE
- [ ] Test iOS 14, 15, 16, 17
- [ ] Verify Face ID / Touch ID
- [ ] Test push notifications
- [ ] Verify Universal Links
- [ ] Submit to TestFlight
- [ ] App Store review readiness

#### Desktop (Future)
- [ ] Test on Windows 10, 11
- [ ] Test on macOS Monterey, Ventura
- [ ] Test on Ubuntu 22.04
- [ ] Verify window management
- [ ] Test system tray integration

---

**Generated by Claude Code - Cross-Functional Team**
**Last Updated:** October 9, 2025
