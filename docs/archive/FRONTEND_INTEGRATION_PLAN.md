# Frontend Integration Plan - Connecting to Production Backend

**Date:** October 9, 2025
**Status:** Planning
**Priority:** HIGH - Frontend currently uses mock data

---

## Executive Summary

The frontend (HTML/JS) currently uses **localStorage mock authentication** and **mock data**. This plan outlines the integration with the production Spring Boot backend API to enable real authentication, ticket management, and chain functionality.

---

## Current State Analysis

### Frontend Structure
```
frontend/
├── index.html       # Public landing page
├── login.html       # Login/Registration page (MOCK AUTH)
├── home.html        # User dashboard (MOCK DATA)
├── auth.js          # Mock authentication system
├── login.js         # Login page logic
├── home.js          # Home page logic with API calls
└── styles.css       # Shared styles
```

### Current API Integration
- **API Base URL**: `http://localhost:8080/api/v1` (configured in home.js)
- **Current Status**: Partial - only `/chain/stats` endpoint called, falls back to mock data
- **Authentication**: Mock localStorage-based (NOT connected to backend)
- **Data Storage**: All data in localStorage (temporary)

---

## Backend API Endpoints Available

### Authentication (`/api/auth`)
| Method | Endpoint | Description | Request Body | Response |
|--------|----------|-------------|--------------|----------|
| POST | `/api/auth/register` | Register new user | RegisterRequest | AuthResponse |
| POST | `/api/auth/login` | Login with device | `{deviceId, fingerprint}` | AuthResponse |
| GET | `/api/auth/health` | Health check | - | String |

### Tickets (`/api/tickets`)
| Method | Endpoint | Description | Auth Required | Response |
|--------|----------|-------------|---------------|----------|
| POST | `/api/tickets/generate` | Generate new ticket | ✅ Yes | TicketResponse |
| GET | `/api/tickets/{ticketId}` | Get ticket details | ✅ Yes | TicketResponse |

### Chain (`/api/chain`)
| Method | Endpoint | Description | Auth Required | Response |
|--------|----------|-------------|---------------|----------|
| GET | `/api/chain/stats` | Get chain statistics | ❌ No | ChainStats |

---

## Integration Plan - Phase 1 (Core Functionality)

### 1. Authentication Integration ⭐ **HIGH PRIORITY**

#### Backend DTOs (Already Implemented)
```java
RegisterRequest {
    UUID ticketId;
    String ticketSignature;
    String displayName;
    String deviceId;
    String deviceFingerprint;
}

AuthResponse {
    UUID userId;
    String displayName;
    Integer position;
    UUID parentId;
    Tokens tokens {
        String accessToken;
        String refreshToken;
    }
}
```

#### Frontend Updates Needed

**File: `auth.js`**
- Replace mock authentication with real API calls
- Store JWT tokens in localStorage (or httpOnly cookies)
- Implement token refresh logic
- Add device fingerprinting logic

**Changes:**
```javascript
// OLD: Mock authentication
function login(email, password) {
    const users = getMockUsers();
    const user = users.find(u => u.email === email && u.password === password);
    // ...localStorage mock
}

// NEW: Real API authentication
async function login(deviceId, deviceFingerprint) {
    const response = await fetch(`${API_BASE_URL}/auth/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ deviceId, deviceFingerprint })
    });

    if (!response.ok) {
        throw new Error('Login failed');
    }

    const authResponse = await response.json();

    // Store tokens
    localStorage.setItem('accessToken', authResponse.tokens.accessToken);
    localStorage.setItem('refreshToken', authResponse.tokens.refreshToken);
    localStorage.setItem('userId', authResponse.userId);

    return authResponse;
}
```

**File: `login.js`**
- Update registration to use `RegisterRequest` format
- Add device fingerprinting (use library like `fingerprintjs2`)
- Handle ticket validation
- Update UI to show registration flow

---

### 2. Ticket Management Integration

#### Frontend Updates Needed

**File: `home.js`**

**Current (Mock):**
```javascript
function generateTicket() {
    const ticket = {
        ticketCode: `TICKET-${Date.now()}`,
        ownerId: currentUser.id,
        status: 'active',
        expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString()
    };
    // Save to localStorage
}
```

**New (Real API):**
```javascript
async function generateTicket() {
    const response = await authenticatedFetch(`${API_BASE_URL}/tickets/generate`, {
        method: 'POST'
    });

    if (!response.ok) {
        const error = await response.json();
        alert(error.message); // e.g., "User already has an active invitee"
        return;
    }

    const ticket = await response.json();
    displayTicket(ticket);
}

// Add authenticated fetch wrapper
async function authenticatedFetch(url, options = {}) {
    const token = localStorage.getItem('accessToken');

    options.headers = {
        ...options.headers,
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
    };

    const response = await fetch(url, options);

    // Handle 401 - token expired
    if (response.status === 401) {
        await refreshToken();
        // Retry request
        return authenticatedFetch(url, options);
    }

    return response;
}
```

---

### 3. Chain Stats Integration (Already Partially Done)

**File: `home.js` (Line ~250)**

Current code already calls `/api/chain/stats` but falls back to mock data. Just need to:
- Remove fallback mock data (force real API)
- Handle error cases properly
- Add loading states

---

## Integration Plan - Phase 2 (Enhanced Features)

### 4. Add Missing Endpoints

These endpoints are needed by the frontend but **don't exist yet** in backend:

| Endpoint | Purpose | Priority |
|----------|---------|----------|
| `GET /api/users/me` | Get current user profile | HIGH |
| `GET /api/users/me/chain` | Get my invited users | HIGH |
| `POST /api/tickets/{id}/cancel` | Cancel active ticket | MEDIUM |
| `GET /api/chain/visible-users` | Get users for chain visualization | MEDIUM |
| `GET /api/users/me/badges` | Get user's badges | LOW |

**Recommendation:** Implement these in backend first, then integrate.

---

### 5. WebSocket Integration (Future)

For real-time updates:
- Ticket expiration notifications
- Chain growth updates
- Badge awards
- Parent removal notifications (3-strike)

**Backend has:** Spring WebSocket configured
**Frontend needs:** WebSocket client implementation

---

## Technical Implementation Details

### Device Fingerprinting

**Library:** `fingerprintjs2` or `@fingerprintjs/fingerprintjs`

**Install:**
```html
<script src="https://cdn.jsdelivr.net/npm/@fingerprintjs/fingerprintjs@3/dist/fp.min.js"></script>
```

**Usage:**
```javascript
async function getDeviceFingerprint() {
    const fp = await FingerprintJS.load();
    const result = await fp.get();
    return result.visitorId;
}
```

### JWT Token Management

**Storage Options:**
1. **localStorage** (current approach) - Simple but vulnerable to XSS
2. **httpOnly cookies** (recommended) - More secure
3. **sessionStorage** - Clears on tab close

**Token Refresh Flow:**
```javascript
async function refreshToken() {
    const refreshToken = localStorage.getItem('refreshToken');

    const response = await fetch(`${API_BASE_URL}/auth/refresh`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ refreshToken })
    });

    const { accessToken, refreshToken: newRefreshToken } = await response.json();

    localStorage.setItem('accessToken', accessToken);
    localStorage.setItem('refreshToken', newRefreshToken);
}
```

**Note:** Backend needs `/auth/refresh` endpoint implementation.

---

## CORS Configuration

Backend already has CORS configured for `http://localhost:3000`:

```java
@Bean
public WebMvcConfigurer corsConfigurer() {
    return new WebMvcConfigurer() {
        @Override
        public void addCorsMappings(CorsRegistry registry) {
            registry.addMapping("/**")
                    .allowedOrigins("http://localhost:3000")
                    .allowedMethods("GET", "POST", "PUT", "DELETE");
        }
    };
}
```

✅ **No changes needed** - Frontend can call backend directly.

---

## Testing Strategy

### 1. Development Testing
- Start backend: `cd backend && mvn spring-boot:run`
- Start frontend: `cd frontend && python -m http.server 3000`
- Test registration flow with real ticket
- Test login with device credentials
- Verify JWT tokens work

### 2. Integration Testing
- Test token refresh
- Test expired ticket handling
- Test duplicate device detection
- Test ticket generation limits

### 3. Error Handling
- Network failures
- API errors (401, 403, 404, 500)
- Token expiration
- Ticket validation errors

---

## Migration Steps (Recommended Order)

### Step 1: Prepare Backend (Optional)
- [ ] Add `/api/users/me` endpoint
- [ ] Add `/api/users/me/chain` endpoint
- [ ] Add `/api/auth/refresh` endpoint
- [ ] Test all endpoints with Postman

### Step 2: Frontend Core Integration
- [ ] Add device fingerprinting library
- [ ] Update `auth.js` to call real `/auth/login` and `/auth/register`
- [ ] Implement JWT token storage and management
- [ ] Add `authenticatedFetch()` wrapper function
- [ ] Update `home.js` to use real ticket generation API

### Step 3: Remove Mock Data
- [ ] Remove mock users from `auth.js`
- [ ] Remove localStorage mock data
- [ ] Remove fallback mock stats in `home.js`
- [ ] Update UI to handle loading/error states

### Step 4: Testing
- [ ] Test full registration flow
- [ ] Test login flow
- [ ] Test ticket generation
- [ ] Test chain stats display
- [ ] Test token refresh

### Step 5: Error Handling & UX
- [ ] Add loading spinners
- [ ] Add error messages
- [ ] Add retry logic
- [ ] Add offline detection

---

## File Changes Summary

| File | Changes | Complexity |
|------|---------|------------|
| `auth.js` | Replace mock auth with real API | 🔴 High |
| `login.js` | Add fingerprinting, update forms | 🟡 Medium |
| `home.js` | Update ticket API calls, remove mocks | 🟡 Medium |
| `index.html` | Add fingerprint library | 🟢 Low |
| `login.html` | Update form fields | 🟢 Low |
| `home.html` | Add loading states | 🟢 Low |

---

## Known Issues & Considerations

### 1. Device-Based Authentication
Backend uses `deviceId` + `deviceFingerprint` instead of email/password. Frontend needs adjustment:
- Generate stable deviceId (localStorage)
- Compute fingerprint on every login
- Update UI to explain device-based login

### 2. Ticket-Based Registration
Registration requires invitation ticket. Frontend needs:
- Ticket input field
- Ticket validation before registration
- Clear error messages

### 3. Parent Limit
Backend enforces "one active child per parent" rule. Frontend should:
- Disable ticket generation if user already has active child
- Show clear message explaining why

### 4. 3-Strike Parent Removal
New feature! Frontend could show:
- Warning badges for parents with 2 strikes
- Notification when parent is removed
- Chain Savior badge display

---

## Next Steps

### Immediate (This Week)
1. ✅ Document current state (this file)
2. Decide on authentication flow (email vs device-based)
3. Add missing backend endpoints (`/users/me`, `/users/me/chain`)
4. Implement device fingerprinting in frontend
5. Test end-to-end registration flow

### Short Term (Next Week)
1. Migrate all API calls from mock to real
2. Implement error handling
3. Add loading states
4. Test with multiple users

### Future Enhancements
1. WebSocket for real-time updates
2. Chain visualization
3. Badge display
4. Notification system
5. Mobile app integration

---

## Success Criteria

Frontend integration is complete when:
- ✅ Users can register with invitation tickets
- ✅ Users can login with device credentials
- ✅ JWT tokens are stored and used for authenticated requests
- ✅ Ticket generation works through API
- ✅ Chain stats display real data
- ✅ All mock data is removed
- ✅ Error handling is comprehensive
- ✅ UI shows loading states

---

**Document Version:** 1.0
**Last Updated:** October 9, 2025
**Status:** Planning Complete - Ready for Implementation
