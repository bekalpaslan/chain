# API Versioning Strategy for The Chain

**Version:** 1.0
**Date:** October 9, 2025
**Status:** Strategic Planning Document
**Owner:** API Integration Team

---

## Executive Summary

This document defines The Chain's API versioning strategy to enable backward-compatible evolution while supporting multiple client versions (web, Android, iOS) with different release cycles.

### Key Decisions

| Decision | Rationale |
|----------|-----------|
| **URL-based versioning** | `/api/v1/`, `/api/v2/` - Explicit, cacheable, easy to test |
| **Semantic versioning** | Major.Minor.Patch (e.g., v1.2.3) - Industry standard |
| **Backward compatibility** | Non-breaking changes within major version |
| **Deprecation policy** | 6-month sunset period before removal |
| **Client compatibility matrix** | Track which client versions work with which API versions |

---

## Table of Contents

1. [Versioning Scheme](#versioning-scheme)
2. [Breaking vs Non-Breaking Changes](#breaking-vs-non-breaking-changes)
3. [Deprecation Policy](#deprecation-policy)
4. [Client Compatibility Matrix](#client-compatibility-matrix)
5. [API Evolution Examples](#api-evolution-examples)
6. [Implementation Guidelines](#implementation-guidelines)

---

## Versioning Scheme

### URL-Based Versioning (Chosen Approach)

**Format:** `https://api.thechain.app/v{major}/{resource}`

**Examples:**
```
https://api.thechain.app/v1/auth/login
https://api.thechain.app/v1/tickets/generate
https://api.thechain.app/v2/chain/stats  (future)
```

**Rationale:**
- ✅ **Explicit:** Version visible in URL, easy to debug
- ✅ **Cacheable:** Different versions are different URLs (CDN-friendly)
- ✅ **Testable:** Can test v1 and v2 side-by-side
- ✅ **Backward compatible:** Old clients continue working on v1
- ✅ **Standard:** Used by Stripe, Twitter, GitHub, Google

**Current Implementation:**
```yaml
# application.yml
server:
  servlet:
    context-path: /api/v1
```

All endpoints automatically prefixed with `/api/v1/`.

---

### Alternative Approaches (Rejected)

#### Header-Based Versioning
```
GET /auth/login HTTP/1.1
Accept: application/vnd.thechain.v1+json
```

**Rejected because:**
- ❌ Not cacheable (same URL, different responses)
- ❌ Harder to debug (version hidden in headers)
- ❌ Breaks browser testing (can't change headers in browser URL bar)

#### Query Parameter Versioning
```
GET /auth/login?version=1
```

**Rejected because:**
- ❌ Not RESTful (version is not a query parameter)
- ❌ Optional (clients might forget to include it)
- ❌ Ugly URLs

---

## Semantic Versioning

### Version Number Format

**Syntax:** `v{major}.{minor}.{patch}`

**Example:** `v1.2.3`
- **Major (1):** Breaking changes (incompatible with v0.x clients)
- **Minor (2):** New features (backward compatible)
- **Patch (3):** Bug fixes (backward compatible)

### Version Components

#### Major Version (Breaking Changes)
- Changes to existing endpoint contracts (remove/rename fields)
- Authentication scheme changes
- Error response format changes
- Rate limit changes (stricter limits)

**When to increment:**
- When old clients will break without code changes
- When migration requires client updates

**Examples:**
- `v1 → v2`: Changed ticket expiration from 24h to 12h (clients might cache old value)
- `v1 → v2`: Renamed `displayName` field to `username` (clients expect old field)

#### Minor Version (New Features)
- Add new endpoints
- Add new optional fields to requests
- Add new fields to responses
- New query parameters (optional)

**When to increment:**
- When adding functionality that doesn't break existing clients
- When old clients can ignore new features

**Examples:**
- `v1.0 → v1.1`: Added `/tickets/my/history` endpoint (old clients don't need it)
- `v1.1 → v1.2`: Added optional `timezone` field to registration (backward compatible)

#### Patch Version (Bug Fixes)
- Fix incorrect response data
- Performance improvements
- Security patches
- Documentation updates

**When to increment:**
- When fixing bugs without changing contracts
- When improving performance without API changes

**Examples:**
- `v1.2.0 → v1.2.1`: Fixed ticket expiration calculation bug
- `v1.2.1 → v1.2.2`: Improved database query performance (no API change)

---

## Breaking vs Non-Breaking Changes

### ✅ Non-Breaking Changes (Safe to Deploy)

#### Adding New Fields to Responses
**Before:**
```json
{
  "userId": "123",
  "displayName": "Alice"
}
```

**After (v1.1):**
```json
{
  "userId": "123",
  "displayName": "Alice",
  "email": "alice@example.com"  // NEW - clients ignore unknown fields
}
```

**Impact:** None - clients ignore unknown fields

---

#### Adding New Optional Request Parameters
**Before:**
```json
POST /tickets/generate
{
  "message": "Join my chain!"
}
```

**After (v1.1):**
```json
POST /tickets/generate
{
  "message": "Join my chain!",
  "expirationHours": 48  // NEW - optional, defaults to 24
}
```

**Impact:** None - backend provides default

---

#### Adding New Endpoints
**New in v1.1:**
```
GET /api/v1/tickets/my/history
```

**Impact:** None - old clients don't call it

---

#### Adding New Error Codes
**Before:**
```json
{
  "error": {
    "code": "TICKET_EXPIRED",
    "message": "..."
  }
}
```

**After (v1.1):**
```json
{
  "error": {
    "code": "TICKET_RATE_LIMITED",  // NEW error code
    "message": "..."
  }
}
```

**Impact:** Minimal - clients should have catch-all error handling

---

### ❌ Breaking Changes (Require New Major Version)

#### Removing Fields from Responses
**Before (v1):**
```json
{
  "userId": "123",
  "displayName": "Alice",
  "email": "alice@example.com"
}
```

**After (v2):**
```json
{
  "userId": "123",
  "displayName": "Alice"
  // email removed - BREAKING!
}
```

**Impact:** Clients expecting `email` will break

**Solution:** Deploy as `/api/v2/users/me`, keep v1 endpoint

---

#### Renaming Fields
**Before (v1):**
```json
{
  "displayName": "Alice"
}
```

**After (v2):**
```json
{
  "username": "Alice"  // Renamed from displayName - BREAKING!
}
```

**Impact:** Clients using `displayName` will break

**Solution:** In v2, support both fields (deprecated `displayName` until sunset)

---

#### Changing Field Types
**Before (v1):**
```json
{
  "position": 42  // integer
}
```

**After (v2):**
```json
{
  "position": "42"  // string - BREAKING!
}
```

**Impact:** Clients expecting integer will crash

---

#### Making Required Fields Optional (or vice versa)
**Before (v1):**
```json
POST /tickets/generate
{
  "message": "Join!"  // optional
}
```

**After (v2):**
```json
POST /tickets/generate
{
  "message": "Join!"  // NOW REQUIRED - BREAKING!
}
```

**Impact:** Old clients omitting `message` will get 400 errors

---

#### Changing Authentication Scheme
**Before (v1):**
```
Authorization: Bearer {jwt-token}
```

**After (v2):**
```
Authorization: ApiKey {api-key}  // BREAKING!
```

**Impact:** All clients break

---

## Deprecation Policy

### Timeline

```
Month 0: New version released (v2)
├─ v1 marked as deprecated (still works)
├─ Client warnings: "API v1 deprecated, migrate to v2 by [date]"
│
Month 1-3: Migration period
├─ Email notifications to developers
├─ Dashboard warnings
├─ Analytics tracking (which clients still on v1)
│
Month 6: Sunset date
├─ v1 returns 410 Gone status
├─ Response: "This API version has been retired. Migrate to v2."
└─ Documentation archived
```

### Deprecation Process

#### Step 1: Announce Deprecation (Day 1)
- **Email:** Send to all registered developers
- **API Response:** Add `Deprecation` header
```
Deprecation: true
Sunset: Sat, 1 Apr 2025 00:00:00 GMT
Link: <https://docs.thechain.app/migration/v1-to-v2>; rel="migration-guide"
```
- **Documentation:** Add banner to API docs
- **Dashboard:** Show warning to authenticated users

#### Step 2: Monitor Usage (Month 1-6)
- **Analytics:** Track API version usage
```sql
SELECT
  api_version,
  COUNT(*) as requests,
  COUNT(DISTINCT user_id) as unique_users
FROM api_logs
WHERE created_at > NOW() - INTERVAL '7 days'
GROUP BY api_version;
```

- **Dashboard:** Show migration progress
```
v1 Usage: 45% of requests (12,345 users)
v2 Usage: 55% of requests (23,456 users)

Target: < 5% on v1 before sunset
```

#### Step 3: Reach Out to Stragglers (Month 5)
- **Email:** Personal emails to users still on v1
- **Support:** Offer migration assistance
- **Extensions:** Grant 30-day extension if requested (on case-by-case basis)

#### Step 4: Sunset (Month 6)
- **Return 410 Gone:**
```json
HTTP/1.1 410 Gone
{
  "error": {
    "code": "API_VERSION_RETIRED",
    "message": "API v1 was retired on April 1, 2025. Please upgrade to v2.",
    "migrationGuide": "https://docs.thechain.app/migration/v1-to-v2"
  }
}
```

- **Redirect (optional):** For safe endpoints (GET only), redirect to v2
```
HTTP/1.1 308 Permanent Redirect
Location: /api/v2/chain/stats
```

---

## Client Compatibility Matrix

### Current State (Week 4)

| Client | Version | API Version | Status |
|--------|---------|-------------|--------|
| **Web Public** | 1.0.0 | v1 | ✅ Active |
| **Web Private** | 1.0.0 | v1 | ✅ Active |
| **Android** | 1.0.0 (not released) | v1 | 🚧 In Development |
| **iOS** | 1.0.0 (not released) | v1 | 🚧 In Development |

---

### Future State (v2 API Released)

| Client | Version | Min API | Max API | Notes |
|--------|---------|---------|---------|-------|
| **Web Public** | 1.0.0 | v1 | v1 | Legacy |
| **Web Public** | 2.0.0 | v2 | v2 | New features |
| **Web Private** | 1.5.0 | v1 | v2 | Hybrid (supports both) |
| **Android** | 1.0.0 | v1 | v1 | Released (no update required) |
| **Android** | 1.1.0 | v1 | v2 | Update available |
| **iOS** | 1.0.0 | v1 | v1 | Released |
| **iOS** | 1.1.0 | v2 | v2 | Requires v2 (breaking change) |

---

### Compatibility Testing Matrix

```
┌─────────────────────────────────────────────────┐
│  Client Version vs API Version Compatibility    │
├─────────────────────────────────────────────────┤
│                API v1      API v2      API v3   │
│  Web 1.0        ✅          ❌          ❌       │
│  Web 2.0        ✅          ✅          ❌       │
│  Web 3.0        ✅          ✅          ✅       │
│  Android 1.0    ✅          ❌          ❌       │
│  Android 1.1    ✅          ✅          ❌       │
│  iOS 1.0        ✅          ❌          ❌       │
│  iOS 2.0        ❌          ✅          ❌       │
└─────────────────────────────────────────────────┘
```

**Legend:**
- ✅ Fully compatible
- ⚠️ Partially compatible (some features unavailable)
- ❌ Incompatible

---

## API Evolution Examples

### Example 1: Adding Badge System (v1.1 - Non-Breaking)

#### New Endpoints
```
GET /api/v1/users/me/badges
POST /api/v1/badges/{badgeId}/claim
```

#### Updated Response (Backward Compatible)
**Before (v1.0):**
```json
GET /api/v1/users/me
{
  "userId": "123",
  "displayName": "Alice"
}
```

**After (v1.1):**
```json
GET /api/v1/users/me
{
  "userId": "123",
  "displayName": "Alice",
  "badges": [  // NEW FIELD - old clients ignore it
    {
      "badgeId": "chain-savior",
      "earnedAt": "2025-10-05T12:00:00Z"
    }
  ]
}
```

**Impact:** None - clients ignore unknown fields

**Deployment:**
- ✅ Deploy backend changes (add badge fields to User entity)
- ✅ Deploy API changes (add badges to response)
- ✅ Update API docs
- ⏳ Update clients at leisure (no urgency, backward compatible)

---

### Example 2: Changing Ticket Expiration Logic (v2.0 - Breaking)

#### Problem
- **v1:** Tickets expire after 24 hours (fixed)
- **v2:** Tickets use dynamic expiration based on chain rules (12h, 24h, 48h)

#### Breaking Changes
- Response field `expiresAt` calculation changes
- New field `expirationPolicy` added
- Old clients expecting 24h will be confused

#### Migration Strategy

**Phase 1: Deploy v2 API (Month 0)**
```
/api/v1/tickets/generate  -> Still returns 24h tickets
/api/v2/tickets/generate  -> Returns dynamic tickets
```

**v2 Response (New Format):**
```json
POST /api/v2/tickets/generate
{
  "ticketId": "abc-123",
  "expiresAt": "2025-10-10T12:00:00Z",
  "expirationPolicy": {
    "durationHours": 12,  // NEW
    "ruleVersion": 2       // NEW
  }
}
```

**Phase 2: Deprecate v1 (Month 0-6)**
- Add deprecation headers to v1 responses
- Email developers to migrate
- Update docs with migration guide

**Phase 3: Sunset v1 (Month 6)**
- v1 returns 410 Gone
- All clients must use v2

---

### Example 3: Adding Real-Time Updates (v1.2 - Non-Breaking)

#### New Feature: WebSocket Support

**New Endpoint:**
```
WS /api/v1/ws
```

**Client Connection:**
```javascript
const ws = new WebSocket('wss://api.thechain.app/v1/ws');
ws.send(JSON.stringify({
  type: 'subscribe',
  channel: 'chain.stats'
}));
```

**Impact:** None - old clients don't use WebSockets, continue polling REST API

**Deployment:**
- ✅ Deploy WebSocket server
- ✅ Update docs
- ⏳ Update clients to use WebSocket (optional optimization)

---

## Implementation Guidelines

### Backend (Spring Boot)

#### Versioning Controller Endpoints

**Option 1: Separate Controllers per Version**
```java
@RestController
@RequestMapping("/api/v1/tickets")
public class TicketControllerV1 {
    @PostMapping("/generate")
    public TicketResponse generateTicket() {
        // v1 logic: 24h expiration
    }
}

@RestController
@RequestMapping("/api/v2/tickets")
public class TicketControllerV2 {
    @PostMapping("/generate")
    public TicketResponseV2 generateTicket() {
        // v2 logic: dynamic expiration
    }
}
```

**Pros:**
- ✅ Clear separation of concerns
- ✅ Easy to test versions independently
- ✅ Easy to deprecate v1 (delete controller)

**Cons:**
- ❌ Code duplication (need to share logic in service layer)

---

**Option 2: Version Header in Same Controller**
```java
@RestController
@RequestMapping("/api/tickets")
public class TicketController {

    @PostMapping(value = "/generate", headers = "X-API-Version=1")
    public TicketResponse generateTicketV1() {
        // v1 logic
    }

    @PostMapping(value = "/generate", headers = "X-API-Version=2")
    public TicketResponseV2 generateTicketV2() {
        // v2 logic
    }
}
```

**Pros:**
- ✅ Single controller (less files)

**Cons:**
- ❌ Confusing routing logic
- ❌ Doesn't work with URL-based versioning

**Recommendation:** Use **Option 1** (separate controllers)

---

#### Shared Service Layer

```java
@Service
public class TicketService {

    public Ticket generateTicket(User user, int expirationHours) {
        // Shared logic for both v1 and v2
        Ticket ticket = new Ticket();
        ticket.setExpiresAt(LocalDateTime.now().plusHours(expirationHours));
        // ...
        return ticketRepository.save(ticket);
    }
}

// V1 Controller uses fixed 24h
ticketService.generateTicket(user, 24);

// V2 Controller uses dynamic hours from rules
int hours = chainRuleService.getCurrentExpirationHours();
ticketService.generateTicket(user, hours);
```

---

### Frontend (Flutter)

#### API Client Versioning

```dart
class ApiClient {
  final String baseUrl;
  final int apiVersion;

  ApiClient({
    String? baseUrl,
    this.apiVersion = 1,  // Default to v1
  }) : baseUrl = baseUrl ?? 'https://api.thechain.app';

  String _buildUrl(String endpoint) {
    return '$baseUrl/v$apiVersion$endpoint';
  }

  Future<Ticket> generateTicket() async {
    final url = _buildUrl('/tickets/generate');
    final response = await _dio.post(url);

    if (apiVersion == 1) {
      return TicketV1.fromJson(response.data);
    } else {
      return TicketV2.fromJson(response.data);
    }
  }
}
```

---

#### Multi-Version Support (Hybrid Clients)

```dart
class ApiClient {
  Future<Ticket> generateTicket() async {
    try {
      // Try v2 first
      return await _generateTicketV2();
    } catch (e) {
      if (e is ApiException && e.statusCode == 404) {
        // v2 not available, fallback to v1
        return await _generateTicketV1();
      }
      rethrow;
    }
  }

  Future<Ticket> _generateTicketV1() async {
    final response = await _dio.post('/api/v1/tickets/generate');
    return TicketV1.fromJson(response.data);
  }

  Future<Ticket> _generateTicketV2() async {
    final response = await _dio.post('/api/v2/tickets/generate');
    return TicketV2.fromJson(response.data);
  }
}
```

---

## Monitoring & Analytics

### Track API Version Usage

#### Backend Logging
```java
@Component
public class ApiVersionInterceptor implements HandlerInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest request,
                            HttpServletResponse response,
                            Object handler) {
        String version = extractVersionFromUrl(request.getRequestURI());

        // Log to analytics
        metricsService.recordApiCall(
            version,
            request.getMethod(),
            request.getRequestURI(),
            request.getHeader("User-Agent")
        );

        // Add deprecation header if v1
        if ("v1".equals(version) && isDeprecated(version)) {
            response.addHeader("Deprecation", "true");
            response.addHeader("Sunset", "Sat, 1 Apr 2025 00:00:00 GMT");
        }

        return true;
    }
}
```

#### Analytics Query
```sql
-- API version usage by client
SELECT
  api_version,
  user_agent,
  COUNT(*) as requests,
  COUNT(DISTINCT user_id) as unique_users
FROM api_logs
WHERE created_at > NOW() - INTERVAL '7 days'
GROUP BY api_version, user_agent
ORDER BY requests DESC;
```

**Example Output:**
```
api_version | user_agent                  | requests | unique_users
v1          | TheChainWeb/1.0             | 45,678   | 8,901
v1          | TheChainAndroid/1.0.2       | 23,456   | 5,678
v2          | TheChainWeb/2.0             | 67,890   | 12,345
v2          | TheChainAndroid/1.1.0       | 34,567   | 7,890
```

---

## Appendix: Version History

### v1.0.0 (October 2025) - Initial Release
- Authentication endpoints
- User management
- Ticket generation/validation
- Chain statistics
- WebSocket real-time updates

### v1.1.0 (November 2025) - Badge System
- **Added:** `GET /users/me/badges`
- **Added:** `POST /badges/{id}/claim`
- **Updated:** User response includes `badges` array

### v1.2.0 (December 2025) - Notifications
- **Added:** `GET /notifications`
- **Added:** `POST /notifications/preferences`
- **Updated:** Ticket response includes `notificationsSent` count

### v2.0.0 (January 2026) - Dynamic Chain Rules
- **Breaking:** Ticket expiration now dynamic (was fixed 24h)
- **Added:** `expirationPolicy` field to ticket responses
- **Added:** `GET /chain/rules/current`
- **Deprecated:** v1 API (6-month sunset period)

---

**Generated by Claude Code - API Integration Team**
**Last Updated:** October 9, 2025
