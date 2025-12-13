# CORS Quick Reference

## TL;DR

✅ CORS is configured and ready to use
✅ Default frontend origins: `http://localhost:3000`, `http://localhost:3001`
✅ JWT authentication works with CORS
✅ All standard REST methods supported
✅ Comprehensive test suite with 30+ tests

## Quick Start

### Frontend (React/Flutter)
```javascript
// Axios configuration
const api = axios.create({
  baseURL: 'http://localhost:8080/api/v1',
  withCredentials: true, // Required for JWT!
});

// Add JWT token
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('accessToken');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});
```

### Environment Variables
```bash
# Development (default)
# No configuration needed - uses localhost:3000, localhost:3001

# Production
CORS_ALLOWED_ORIGINS=https://yourdomain.com,https://www.yourdomain.com
```

## Common Issues & Fixes

### ❌ "No Access-Control-Allow-Origin header"
**Fix:** Add your frontend URL to `application.yml`:
```yaml
cors:
  allowed-origins: http://localhost:3000,YOUR_URL_HERE
```
Or set environment variable:
```bash
export CORS_ALLOWED_ORIGINS=http://localhost:3000,http://your-url:port
```

### ❌ "Credentials flag is true, but origin is *"
**Fix:** Never use wildcard (`*`) with credentials. Use specific origins only.

### ❌ "Method not allowed"
**Fix:** Verify method is in allowed list: GET, POST, PUT, PATCH, DELETE, OPTIONS

### ❌ Preflight (OPTIONS) request fails
**Fix:** Ensure SecurityConfig allows OPTIONS:
```java
.requestMatchers(HttpMethod.OPTIONS, "/**").permitAll()
```

## Testing

```bash
# Run CORS tests (30+ comprehensive tests)
cd backend
mvn test -Dtest=CorsConfigurationTest

# Test with cURL
curl -X OPTIONS http://localhost:8080/api/v1/tickets \
  -H "Origin: http://localhost:3000" \
  -H "Access-Control-Request-Method: GET" \
  -v
```

## Key Files

- `backend/src/main/java/com/thechain/config/SecurityConfig.java` - CORS configuration
- `backend/src/main/resources/application.yml` - CORS properties
- `backend/src/main/resources/application-prod.yml` - Production profile
- `backend/src/test/java/com/thechain/config/CorsConfigurationTest.java` - Test suite (30+ tests)

## Production Checklist

- [ ] Set `CORS_ALLOWED_ORIGINS` environment variable
- [ ] Use HTTPS URLs only
- [ ] Remove development origins (localhost)
- [ ] Test with production frontend
- [ ] Activate production profile: `--spring.profiles.active=prod`
- [ ] Verify logs show correct origins

## Configuration

**Current Setup:**
- **Allowed Origins:** `http://localhost:3000`, `http://localhost:3001`
- **Allowed Methods:** GET, POST, PUT, PATCH, DELETE, OPTIONS
- **Allowed Headers:** All (`*`)
- **Exposed Headers:** Authorization, X-User-Id, X-Total-Count, Content-Type
- **Credentials:** Enabled (required for JWT)
- **Max Age:** 3600 seconds (1 hour preflight cache)

## Architecture

```
Frontend (localhost:3000)     Backend (localhost:8080)
       │                              │
       ├──► OPTIONS (preflight) ─────►│
       │◄─── CORS headers ────────────┤
       │                              │
       ├──► GET/POST (with JWT) ─────►│
       │◄─── Response + CORS ─────────┤
```

## Support

- **Full Tests:** Run `mvn test -Dtest=CorsConfigurationTest`
- **Test Results:** `backend/target/surefire-reports/`
- **Logs:** Check Spring Boot console output
- **Debug:** Set `logging.level.org.springframework.web.cors: DEBUG`

---

**Last Updated:** 2025-01-10
**Test Coverage:** 30+ scenarios ✅
**Production Ready:** Yes ✅
