### 1 — Overview

Frontend is implemented with **Flutter (Dart)** to provide a single shared codebase for **Android, iOS, and Web** (PWA-capable). Backend remains **Java Spring Boot** (HTTP REST + WebSocket), with PostgreSQL and Redis. This architecture prioritizes consistent UX, performance, and developer velocity.

---

### 2 — High-level Components

* **Flutter Client (single repo)**

  * Platforms: Android (APK/AAB), iOS (IPA), Web (static + PWA)
  * Architecture: Presentation (widgets) → State (Riverpod / Bloc) → Domain → Data (API clients)
  * Plugins: camera/QR, local storage (secure), geolocation (opt-in), push notifications.

* **Backend Services (Spring Boot microservices)**

  * Auth Service (JWT + refresh tokens)
  * Ticket Service (generate/validate tickets, signed payloads)
  * Chain Service (attachment graph, history)
  * Stats/Analytics Service (aggregate metrics, snapshots)
  * Notification Service (FCM / APNs)
  * Gateway/API Gateway & Rate Limiting

* **Data Stores**

  * PostgreSQL — primary relational store (users, tickets, attachments, history)
  * Redis — caching, ephemeral ticket state, distributed locks, rate limit counters
  * S3 (or equivalent) — static assets, backups, generated QR images (if needed)

* **Realtime**

  * WebSocket (Spring WebSocket / STOMP or Socket.IO compatible) for live chain stats & updates
  * Fallback: Server-Sent Events (SSE) for web clients if required

* **Infrastructure & DevOps**

  * Docker + Kubernetes (EKS/GKE) or managed container service
  * CI/CD: GitHub Actions / GitLab CI for build/test; Fastlane / Codemagic / Bitrise / EAS for mobile store pipelines
  * Monitoring: Prometheus + Grafana + Loki (logs)
  * Sentry (errors, crash reporting)

---

### 3 — Frontend Architecture (Flutter specifics)

* **Project Structure**

  * `lib/`: feature-based folders (tickets/, chain/, auth/, stats/, settings/)
  * `lib/core/`: shared utilities, models, services, network client
  * `lib/ui/`: theme, common widgets, adaptive layouts
  * `lib/main.dart`: platform bootstrap with flavor configs (dev/stage/prod)

* **State Management**

  * **Riverpod** (recommended) or **Bloc** — for testable, scalable state management
  * Persist critical small state (chain_key, JWT) in secure storage (flutter_secure_storage)

* **Networking**

  * REST for CRUD actions (ticket create/claim, user create)
  * WebSocket for live stats and ticket countdowns (low-latency updates)
  * Use a typed API client (e.g., `retrofit_generator` or `chopper`) for maintainability

* **Platform Integrations**

  * QR Scanner: `mobile_scanner` / `qr_code_scanner`
  * Secure Storage: `flutter_secure_storage`
  * Geo: `geolocator` (permission prompts + coarse location option)
  * Notifications: `firebase_messaging` (FCM) and APNs bridge for iOS

* **Web Considerations**

  * Responsive layouts with `LayoutBuilder` / `MediaQuery`
  * Avoid plugins that lack web support or provide graceful degradation
  * PWA manifest + service worker for installability and offline cache of static assets

---

### 4 — Security & Privacy

* **Ticket signing:** Server signs ticket payloads (HMAC or asymmetric signature). Client validates signature server-side when claiming. Do not trust client-only signature checks.
* **Authentication:** JWT (short-lived) + refresh token flows stored securely. Social login optional (Apple/Google) for frictionless adoption.
* **Geo privacy:** Location is **optional**; store only coarse location (city/region) unless explicit consent for fine-grained coords. Support data deletion requests.
* **GDPR/CCPA:** Data export and deletion endpoints, clear consent UI, data retention policy.
* **Rate-limiting & abuse protection:** per-user and per-IP limits on ticket generation/claims.

---

### 5 — Data Model (summary)

* **User**: id (uuid), chain_key, display_name, created_at, parent_id, location_coarse, metadata
* **Ticket**: id (uuid), owner_id, issued_at, expires_at, status (issued/used/expired/returned), signed_payload
* **Attachment**: id, parent_id, child_id, timestamp, ticket_id
* **StatsSnapshot**: timestamp, total_users, active_tickets, wasted_tickets_count, geo_distribution

---

### 6 — API Contracts (high-level)

* `POST /api/tickets/generate` → {ticket_id, qr_payload, expires_at}
* `POST /api/tickets/claim` → {ticket_id, claimant_metadata} → issues chain_key, returns user info
* `GET /api/chain/stats` → {total_users, growth_rate, geo_summary} (cached + realtime overrides)
* `WS /ws/updates` → pushes events: ticket_expired, new_attachment, stats_update

(Full OpenAPI spec generated in API Contract doc.)

---

### 7 — CI/CD & Release Strategy

* **Branches:** `main` (production), `staging`, feature branches. PR-based CI.
* **Mobile Build Pipelines:** Codemagic / Bitrise or GitHub Actions + Fastlane for signing and store uploads. Use separate app IDs/flavors for staging and prod.
* **Web Deployment:** Build via `flutter build web`, deploy to CDN (Cloudflare Pages / S3+CloudFront). PWA manifest included.
* **Rollouts:** Staged rollout on Play Store and phased release on App Store to monitor stability.

---

### 8 — Monitoring & SLOs

* Track: uptime, ticket claim latency, DB performance, WebSocket connection rate, erroneous ticket claims.
* SLO examples: 99.9% API availability, average ticket claim latency < 300ms, <1% failed ticket validations.

---

### 9 — Developer Tooling & Testing

* Unit tests for Dart logic, widget tests for critical screens, integration tests using `flutter_driver` / `integration_test`.
* Backend: unit + integration tests, contract tests for APIs.
* E2E: Scripted flows for ticket generation → claim → stats propagation.

---

### 10 — Notes & Trade-offs

* Flutter improves time-to-market and ensures identical UX across platforms; however, some native integrations (e.g., low-level camera/advanced background tasks) may require platform channels.
* Web performance for very large visualizations should use efficient rendering (Canvas/CustomPainter) or offload heavy computations to the backend.
