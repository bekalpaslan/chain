# API Specification

## Overview

This document defines the REST API and WebSocket contracts for The Chain backend services.

**Base URL (Development):** `http://localhost:8080/api/v1`
**Base URL (Production):** `https://api.thechain.app/v1`

**Authentication:** Bearer JWT tokens in `Authorization` header
**Content-Type:** `application/json`
**WebSocket:** `ws://localhost:8080/ws` (dev) | `wss://api.thechain.app/ws` (prod)

---

## Authentication & User Management

### POST /auth/register
Register a new user (requires valid ticket).

**Request:**
```json
{
  "ticketId": "uuid",
  "ticketSignature": "base64-encoded-signature",
  "displayName": "string (optional, 3-50 chars)",
  "shareLocation": false,
  "location": {
    "latitude": 40.7128,
    "longitude": -74.0060
  }
}
```

**Response (201 Created):**
```json
{
  "userId": "uuid",
  "chainKey": "unique-immutable-id",
  "displayName": "Anonymous #1234",
  "position": 42,
  "parentId": "uuid",
  "parentDisplayName": "Alice",
  "createdAt": "2025-10-08T12:34:56Z",
  "tokens": {
    "accessToken": "jwt...",
    "refreshToken": "jwt...",
    "expiresIn": 3600
  }
}
```

**Errors:**
- `400` - Invalid ticket, expired ticket, or ticket already used
- `409` - User already exists (detected by device fingerprint)
- `429` - Rate limit exceeded

---

### POST /auth/login
Login existing user (device-based authentication).

**Request:**
```json
{
  "deviceId": "unique-device-identifier",
  "deviceFingerprint": "hash-of-device-info"
}
```

**Response (200 OK):**
```json
{
  "userId": "uuid",
  "chainKey": "unique-id",
  "tokens": {
    "accessToken": "jwt...",
    "refreshToken": "jwt...",
    "expiresIn": 3600
  }
}
```

---

### POST /auth/refresh
Refresh access token.

**Request:**
```json
{
  "refreshToken": "jwt..."
}
```

**Response (200 OK):**
```json
{
  "accessToken": "jwt...",
  "expiresIn": 3600
}
```

---

### GET /auth/me
Get current user information.

**Headers:** `Authorization: Bearer {token}`

**Response (200 OK):**
```json
{
  "userId": "uuid",
  "chainKey": "unique-id",
  "displayName": "Alice",
  "position": 42,
  "parentId": "uuid",
  "childId": "uuid or null",
  "createdAt": "2025-10-08T12:34:56Z",
  "ticketStatus": {
    "hasActiveTicket": true,
    "ticketId": "uuid",
    "expiresAt": "2025-10-09T12:34:56Z"
  },
  "stats": {
    "wastedTickets": 2,
    "successfulAttachment": true
  }
}
```

---

## Ticket Management

### POST /tickets/generate
Generate a new invitation ticket (one per user, replaces previous unused ticket).

**Headers:** `Authorization: Bearer {token}`

**Request:**
```json
{
  "message": "string (optional, max 100 chars)"
}
```

**Response (201 Created):**
```json
{
  "ticketId": "uuid",
  "qrPayload": "base64-encoded-signed-data",
  "qrCodeUrl": "https://cdn.thechain.app/qr/{ticketId}.png",
  "deepLink": "thechain://join?t={encoded-ticket-data}",
  "signature": "base64-signature",
  "issuedAt": "2025-10-08T12:34:56Z",
  "expiresAt": "2025-10-09T12:34:56Z",
  "status": "active"
}
```

**Errors:**
- `409` - User already has an active ticket or already attached someone
- `429` - Rate limit (max 1 ticket per 10 minutes after returns)

---

### GET /tickets/{ticketId}
Get ticket details (for validation before claiming).

**Request Parameters:**
- `ticketId` (path): UUID of the ticket

**Response (200 OK):**
```json
{
  "ticketId": "uuid",
  "issuerId": "uuid",
  "issuerDisplayName": "Alice",
  "issuerPosition": 42,
  "issuedAt": "2025-10-08T12:34:56Z",
  "expiresAt": "2025-10-09T12:34:56Z",
  "status": "active",
  "timeRemaining": 82800,
  "message": "Join my chain!"
}
```

**Errors:**
- `404` - Ticket not found
- `410` - Ticket expired or already used

---

### GET /tickets/my
Get current user's ticket.

**Headers:** `Authorization: Bearer {token}`

**Response (200 OK):**
```json
{
  "ticketId": "uuid",
  "qrPayload": "base64...",
  "qrCodeUrl": "https://cdn.thechain.app/qr/{ticketId}.png",
  "deepLink": "thechain://join?t=...",
  "issuedAt": "2025-10-08T12:34:56Z",
  "expiresAt": "2025-10-09T12:34:56Z",
  "status": "active",
  "timeRemaining": 82800
}
```

**Errors:**
- `404` - No active ticket

---

### DELETE /tickets/my
Cancel current ticket (returns it early, counts as wasted).

**Headers:** `Authorization: Bearer {token}`

**Response (204 No Content)**

---

## Chain & Statistics

### GET /chain/stats
Get global chain statistics.

**Response (200 OK):**
```json
{
  "totalUsers": 123456,
  "activeTickets": 8901,
  "chainStartDate": "2025-10-01T00:00:00Z",
  "averageGrowthRate": 245.5,
  "totalWastedTickets": 4567,
  "wasteRate": 3.7,
  "countries": 89,
  "lastUpdate": "2025-10-08T12:34:56Z",
  "recentAttachments": [
    {
      "childPosition": 123456,
      "displayName": "Anonymous #5678",
      "timestamp": "2025-10-08T12:34:00Z",
      "country": "US"
    }
  ]
}
```

---

### GET /chain/tree
Get chain tree structure (paginated).

**Query Parameters:**
- `startPosition` (optional): Starting position in chain
- `limit` (optional, default 50, max 500): Number of nodes
- `depth` (optional, default 1, max 3): Tree depth

**Response (200 OK):**
```json
{
  "nodes": [
    {
      "userId": "uuid",
      "chainKey": "unique-id",
      "position": 1,
      "displayName": "The Seeder",
      "createdAt": "2025-10-01T00:00:00Z",
      "country": "US",
      "hasChild": true,
      "wastedTickets": 0
    }
  ],
  "totalNodes": 123456,
  "nextCursor": "position-50"
}
```

---

### GET /chain/user/{chainKey}
Get user's position and lineage in the chain.

**Response (200 OK):**
```json
{
  "userId": "uuid",
  "chainKey": "unique-id",
  "position": 42,
  "displayName": "Alice",
  "createdAt": "2025-10-05T10:00:00Z",
  "parent": {
    "chainKey": "parent-id",
    "displayName": "Bob",
    "position": 41
  },
  "child": {
    "chainKey": "child-id",
    "displayName": "Charlie",
    "position": 43,
    "attachedAt": "2025-10-06T14:30:00Z"
  },
  "ancestors": [
    {"chainKey": "seed-id", "position": 1, "displayName": "The Seeder"}
  ],
  "descendants": [
    {"chainKey": "child-id", "position": 43, "displayName": "Charlie"}
  ],
  "stats": {
    "wastedTickets": 2,
    "totalTicketsGenerated": 3,
    "successfulAttachment": true,
    "daysInChain": 3
  }
}
```

---

### GET /chain/geo
Get geographic distribution.

**Response (200 OK):**
```json
{
  "countries": [
    {
      "code": "US",
      "name": "United States",
      "userCount": 45678,
      "percentage": 37.0
    }
  ],
  "cities": [
    {
      "name": "New York",
      "country": "US",
      "userCount": 3456,
      "coordinates": {"lat": 40.7128, "lon": -74.0060}
    }
  ],
  "heatmapData": [
    {"lat": 40.7128, "lon": -74.0060, "weight": 3456}
  ]
}
```

---

## User Profile

### PUT /users/me
Update current user profile.

**Headers:** `Authorization: Bearer {token}`

**Request:**
```json
{
  "displayName": "string (3-50 chars)",
  "shareLocation": false
}
```

**Response (200 OK):**
```json
{
  "userId": "uuid",
  "displayName": "NewName",
  "shareLocation": false,
  "updatedAt": "2025-10-08T12:34:56Z"
}
```

---

### DELETE /users/me
Delete user account (marks as deleted, preserves chain continuity).

**Headers:** `Authorization: Bearer {token}`

**Response (204 No Content)**

**Note:** User shown as "[Deleted User]" in chain, position preserved.

---

## WebSocket Events

### Connection
```
WS /ws
Headers: Authorization: Bearer {token}
```

### Client → Server Events

**Subscribe to chain updates:**
```json
{
  "type": "subscribe",
  "channel": "chain.stats"
}
```

**Subscribe to personal updates:**
```json
{
  "type": "subscribe",
  "channel": "user.tickets"
}
```

### Server → Client Events

**New attachment:**
```json
{
  "type": "chain.attachment",
  "data": {
    "childPosition": 123457,
    "parentPosition": 123456,
    "displayName": "Anonymous #8901",
    "timestamp": "2025-10-08T12:34:56Z",
    "country": "DE"
  }
}
```

**Stats update:**
```json
{
  "type": "chain.stats",
  "data": {
    "totalUsers": 123457,
    "activeTickets": 8902,
    "lastUpdate": "2025-10-08T12:34:56Z"
  }
}
```

**Ticket expired:**
```json
{
  "type": "user.ticket.expired",
  "data": {
    "ticketId": "uuid",
    "expiredAt": "2025-10-09T12:34:56Z",
    "wastedTicketsTotal": 3
  }
}
```

**Ticket used:**
```json
{
  "type": "user.ticket.used",
  "data": {
    "ticketId": "uuid",
    "childId": "uuid",
    "childDisplayName": "Charlie",
    "childPosition": 123457,
    "usedAt": "2025-10-08T12:34:56Z"
  }
}
```

---

## Error Response Format

All errors follow this format:

```json
{
  "error": {
    "code": "TICKET_EXPIRED",
    "message": "The ticket has expired and can no longer be used",
    "details": {
      "ticketId": "uuid",
      "expiredAt": "2025-10-09T12:34:56Z"
    },
    "timestamp": "2025-10-08T12:34:56Z",
    "requestId": "uuid"
  }
}
```

### Error Codes

- `INVALID_TICKET` - Ticket signature invalid or ticket not found
- `TICKET_EXPIRED` - Ticket past expiration time
- `TICKET_USED` - Ticket already claimed
- `DUPLICATE_USER` - User already registered
- `RATE_LIMIT_EXCEEDED` - Too many requests
- `UNAUTHORIZED` - Invalid or missing token
- `FORBIDDEN` - Action not allowed
- `NOT_FOUND` - Resource not found
- `VALIDATION_ERROR` - Request data validation failed

---

## Rate Limits

| Endpoint | Limit |
|----------|-------|
| POST /auth/register | 3 per device per day |
| POST /tickets/generate | 1 per 10 minutes per user |
| GET /chain/* | 100 per minute per user |
| POST /auth/refresh | 10 per hour per token |

**Rate limit headers:**
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 87
X-RateLimit-Reset: 1696780800
```

---

## Versioning

API version included in URL path: `/api/v1/`

Breaking changes will increment version number. Non-breaking changes are backwards compatible.
