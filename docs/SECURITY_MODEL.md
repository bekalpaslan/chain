# Security Model

## Overview

This document outlines the security architecture, authentication mechanisms, and abuse prevention strategies for The Chain.

---

## 1. Authentication & Authorization

### 1.1 Device-Based Authentication

**Primary Authentication Method:**
- Users authenticate via device fingerprinting (no email/password required)
- Reduces friction while maintaining reasonable security
- Suitable for single-device, mobile-first use case

**Device Fingerprint Components:**
```javascript
{
  "deviceId": "unique-hardware-id",  // iOS: identifierForVendor, Android: ANDROID_ID
  "fingerprint": "hash-of-metadata",  // Browser: Canvas + WebGL fingerprint
  "os": "iOS 17.2",
  "model": "iPhone 14 Pro",
  "appVersion": "1.0.0"
}
```

**Security Considerations:**
- Device fingerprints stored as salted hashes
- Multiple logins from same device allowed (but monitored)
- Lost device recovery requires support intervention

### 1.2 JWT Token Architecture

**Access Token (Short-lived):**
```json
{
  "userId": "uuid",
  "chainKey": "ABCD1234EFGH",
  "deviceId": "device-hash",
  "iat": 1696780800,
  "exp": 1696784400,    // 1 hour expiry
  "iss": "thechain-auth",
  "aud": "thechain-api"
}
```

**Refresh Token (Long-lived):**
```json
{
  "userId": "uuid",
  "deviceId": "device-hash",
  "tokenId": "uuid",    // Stored in database for revocation
  "iat": 1696780800,
  "exp": 1699372800,    // 30 days expiry
  "iss": "thechain-auth"
}
```

**Token Security:**
- Access tokens: RSA-256 signed, stored in memory only
- Refresh tokens: RSA-256 signed, stored in secure storage (Keychain/KeyStore)
- Tokens can be revoked server-side via blacklist
- Automatic rotation on refresh

### 1.3 Session Management

**Concurrent Sessions:**
- Users can have multiple active sessions (e.g., phone + tablet)
- Each device gets separate refresh token
- Max 3 active devices per user (configurable)

**Session Termination:**
- Manual logout: Revoke specific refresh token
- Logout all devices: Revoke all user's refresh tokens
- Account deletion: Revoke all tokens + blacklist user ID

---

## 2. Ticket Security

### 2.1 Ticket Signature & Validation

**Ticket Payload Structure:**
```json
{
  "ticketId": "uuid",
  "ownerId": "uuid",
  "issuedAt": 1696780800,
  "expiresAt": 1696867200,
  "nonce": "random-32-bytes"
}
```

**Server Signing Process:**
1. Generate ticket with unique nonce
2. Create JSON payload
3. Sign with server's private key (RSA-2048 or Ed25519)
4. Encode as Base64
5. Embed in QR code as: `thechain://join?t={base64-signed-payload}`

**Client Validation Process:**
1. Scan QR code / parse deep link
2. Extract signed payload
3. Send to server: `GET /tickets/{ticketId}`
4. Server validates signature with public key
5. Check expiration, usage status
6. Return validation result

**Security Properties:**
- Tickets cannot be forged (server-side signing)
- Tickets cannot be reused (one-time claim tracked in DB)
- Tickets cannot be extended (expiration embedded in signed payload)
- Replay attacks prevented by nonce + database state check

### 2.2 QR Code Security

**Threat: Screenshot Sharing**
- **Mitigation:** Each ticket is single-use, first claim wins
- **Detection:** Log all claim attempts (success + failures)
- **Monitoring:** Flag users with >3 failed claim attempts

**Threat: QR Code Interception**
- **Mitigation:** Deep links use HTTPS with certificate pinning
- **User Education:** Warning in UI about sharing tickets

**Threat: Mass Distribution**
- **Mitigation:**
  - IP-based rate limiting on ticket validation
  - Require device fingerprint on registration
  - Flag suspicious patterns (same IP, many claims)

---

## 3. Abuse Prevention

### 3.1 Multi-Account Detection

**Primary Defense: Device Fingerprinting**

**Desktop/Web:**
```javascript
// Browser fingerprint includes:
{
  canvas: canvasFingerprint(),
  webgl: webglFingerprint(),
  fonts: installedFonts(),
  plugins: browserPlugins(),
  screen: screenResolution(),
  timezone: userTimezone(),
  language: navigatorLanguages()
}
```

**Mobile:**
```javascript
// Native device identifiers:
{
  ios: {
    identifierForVendor: "iOS UUID",
    // NOT using IDFA (requires consent)
  },
  android: {
    androidId: "ANDROID_ID",
    // NOT using GAID (can be reset)
  }
}
```

**Detection Strategy:**
1. Store device fingerprint hash on registration
2. Track fingerprint → user_id mappings in Redis
3. Alert if same fingerprint registers >1 account in 30 days
4. Manual review for suspected multi-accounts

**Limitations:**
- Fingerprints can change (OS updates, browser changes)
- VPNs/VMs make detection harder
- Balance between security and false positives

### 3.2 Bot Prevention

**Registration Endpoint Protection:**
- CAPTCHA on suspicious requests (optional, avoid friction)
- Rate limiting: Max 3 registration attempts per IP per day
- Behavioral analysis: Track time-to-register (too fast = bot)

**Ticket Generation Rate Limiting:**
- 1 ticket per user (enforced in DB)
- After ticket expires/cancelled: 10-minute cooldown
- Max 5 wasted tickets per user before manual review

**API Rate Limiting:**
| Endpoint | Per User | Per IP | Window |
|----------|----------|--------|--------|
| POST /auth/register | 3 | 10 | 24h |
| POST /tickets/generate | 1 | 5 | 10m |
| GET /chain/stats | 100 | 1000 | 1m |
| GET /chain/tree | 50 | 200 | 1m |

**Bot Detection Signals:**
- No WebSocket connection (real users maintain WS)
- No UI interaction events (bots only hit API)
- Linear request patterns (no human variance)
- Unusually fast actions (scan → register < 2 seconds)

### 3.3 Sybil Attack Prevention

**Threat Model:**
- Attacker creates many fake accounts
- Uses each to generate tickets
- Claims own tickets in circular pattern
- Artificially inflates chain position

**Mitigations:**

1. **Same-Device Self-Claim Detection**
   - Track device fingerprint on registration
   - Block ticket claims from same device that generated it
   - Redis key: `ticket:{ticketId}:owner_fingerprint`

2. **IP-Based Correlation**
   - Track IP address on registration and claim
   - Flag if ticket generator and claimer share IP
   - Allow exceptions for NAT/corporate networks

3. **Time-Based Analysis**
   - Flag rapid claim patterns (ticket generated → claimed < 30 seconds)
   - Flag users who repeatedly generate tickets but never successfully attach

4. **Social Graph Analysis**
   - Detect isolated clusters (subgraphs with no external connections)
   - Flag users whose descendants have no subsequent attachments

5. **Manual Review Queue**
   - Suspicious accounts flagged for admin review
   - Admins can suspend/delete fake accounts
   - Preserve chain continuity (mark as [Deleted User])

### 3.4 Denial of Service (DoS) Protection

**Application Layer:**
- Rate limiting per IP and per user (see table above)
- Request size limits (max 10KB for POST bodies)
- Connection limits (max 100 WS connections per IP)

**Infrastructure Layer:**
- CloudFlare or AWS Shield for DDoS protection
- Auto-scaling for traffic spikes
- Circuit breakers on external dependencies

**Database Protection:**
- Connection pooling (max 20 connections per service instance)
- Query timeout enforcement (5 seconds max)
- Read replicas for heavy read operations

---

## 4. Data Privacy & GDPR Compliance

### 4.1 Personal Data Classification

| Data Type | Category | Retention | User Control |
|-----------|----------|-----------|--------------|
| Device ID | Pseudonymous | Account lifetime | Cannot delete (needed for auth) |
| Display Name | Personal | Account lifetime | Can change anytime |
| Location (coarse) | Personal | Account lifetime | Can disable sharing |
| Chain Key | Pseudonymous | Permanent | Cannot change (immutable ID) |
| IP Address | Personal | 90 days (logs) | Automatic deletion |
| Ticket QR codes | System | 30 days | Automatic deletion |

### 4.2 User Rights (GDPR)

**Right to Access:**
- API endpoint: `GET /users/me/data-export`
- Returns JSON with all user data
- Includes chain history, tickets, activity logs

**Right to Erasure (Right to be Forgotten):**
- API endpoint: `DELETE /users/me`
- Soft delete: `deleted_at` timestamp set
- Display name → "[Deleted User]"
- Location data → NULL
- Device ID → hashed + salted
- Chain position preserved (cannot break chain continuity)
- **Limitation:** Chain Key and position remain (pseudonymous, necessary for system integrity)

**Right to Rectification:**
- Users can update display name anytime
- Location sharing can be toggled on/off

**Right to Data Portability:**
- JSON export includes all user data in machine-readable format

**Right to Object:**
- Users can opt-out of location sharing
- Users can opt-out of push notifications

### 4.3 Data Minimization

**What We Collect:**
- Display name (optional, defaulted)
- Device fingerprint (for authentication)
- Location (optional, coarse only)
- Timestamp of actions (registration, ticket generation)

**What We DON'T Collect:**
- Email address
- Phone number
- Exact GPS coordinates (only city-level if opted-in)
- Payment information (app is free)
- Biometric data
- Social media profiles (no OAuth integrations in MVP)

### 4.4 Consent Management

**On Registration:**
```
"By joining, you agree to our Terms of Service
and Privacy Policy."

[Checkbox required]

"Optional: Share my city with the chain"
[Toggle: Off by default]
```

**Consent Withdrawal:**
- Location sharing can be disabled in settings
- Account can be deleted anytime

---

## 5. Infrastructure Security

### 5.1 Network Security

**HTTPS Everywhere:**
- TLS 1.3 for all API traffic
- Certificate pinning in mobile apps
- WebSocket over TLS (wss://)

**API Gateway:**
- Centralized entry point for all services
- Request/response validation
- Rate limiting and throttling
- IP whitelisting for admin endpoints

**Firewall Rules:**
```
# Production
- Allow: HTTPS (443) from anywhere
- Allow: WSS (443) from anywhere
- Deny: Direct database access from internet
- Deny: SSH from internet (VPN only)

# Internal
- Services communicate via internal network
- mTLS between microservices (optional)
```

### 5.2 Database Security

**PostgreSQL:**
- Encrypted at rest (AES-256)
- Encrypted in transit (SSL/TLS)
- Separate read/write users with minimal permissions
- No database access from public internet
- Automated backups encrypted

**Redis:**
- AUTH password protection
- No persistence for sensitive data (tokens use short TTLs)
- Encrypted in transit (TLS)

**Access Control:**
```sql
-- Application user (limited permissions)
GRANT SELECT, INSERT, UPDATE ON users TO app_user;
GRANT SELECT, INSERT, UPDATE ON tickets TO app_user;
-- No DELETE permission (soft deletes only)

-- Read-only user (for analytics)
GRANT SELECT ON ALL TABLES TO readonly_user;

-- Admin user (full access, used only for migrations)
-- Credentials stored in vault, not in code
```

### 5.3 Secrets Management

**Never in Code:**
- Database passwords
- JWT signing keys
- API keys for external services

**Storage:**
- Development: `.env` files (not committed to git)
- Production: AWS Secrets Manager / HashiCorp Vault
- Rotation: Quarterly for production secrets

**Key Management:**
- JWT signing keys: RSA-2048 key pair
- Private key never leaves server
- Public key distributed to clients for verification
- Key rotation every 6 months

---

## 6. Monitoring & Incident Response

### 6.1 Security Monitoring

**Real-time Alerts:**
- Failed authentication attempts spike (>10/minute)
- Rate limit violations
- Unusual device fingerprint patterns
- Database slow queries or errors
- Service health check failures

**Log Analysis:**
- All API requests logged (exclude sensitive data)
- Authentication events logged
- Ticket generation/claim events logged
- Anomaly detection via log aggregation (ELK stack)

**Metrics to Track:**
- Failed login rate
- Ticket claim failure rate
- Multi-account detection flags
- API error rates by endpoint
- Response time P50/P95/P99

### 6.2 Incident Response Plan

**Severity Levels:**
- **Critical:** Data breach, service completely down
- **High:** Authentication bypass, API abuse ongoing
- **Medium:** Elevated error rates, partial outage
- **Low:** Individual user issues, minor bugs

**Response Workflow:**
1. **Detection:** Automated alert or user report
2. **Triage:** On-call engineer assesses severity
3. **Investigation:** Review logs, metrics, database state
4. **Containment:** Block malicious IPs, revoke compromised tokens
5. **Resolution:** Deploy fix or workaround
6. **Post-mortem:** Document incident, improve monitoring

**Data Breach Response:**
1. Immediately isolate affected systems
2. Notify legal/compliance team
3. Assess scope of breach (what data, how many users)
4. Notify affected users within 72 hours (GDPR requirement)
5. Offer remediation (password reset, account review)
6. Report to data protection authority if required

---

## 7. Secure Development Practices

### 7.1 Code Review & Testing

**Mandatory Reviews:**
- All code changes require 1+ reviewer approval
- Security-sensitive changes (auth, crypto) require 2+ approvals
- Automated checks: linting, dependency scanning

**Testing Requirements:**
- Unit tests for business logic
- Integration tests for API endpoints
- Security tests: SQL injection, XSS, CSRF (where applicable)
- Load testing before major releases

### 7.2 Dependency Management

**Regular Updates:**
- Weekly check for security patches
- Automated PR creation for minor updates (Dependabot)
- Monthly review of major version updates

**Vulnerability Scanning:**
- GitHub Security Alerts enabled
- Snyk or similar for dependency vulnerability scanning
- Reject dependencies with known critical CVEs

### 7.3 Secure Defaults

**Configuration:**
- Fail closed (deny by default)
- Minimal permissions granted
- Debug logs disabled in production
- Error messages don't leak sensitive info

**Example - Generic Error Response:**
```json
// Bad (leaks DB info):
{
  "error": "PostgreSQL error: duplicate key value violates unique constraint 'users_pkey'"
}

// Good (generic):
{
  "error": {
    "code": "REGISTRATION_FAILED",
    "message": "Unable to create account. Please try again."
  }
}
```

---

## 8. Mobile App Security (Flutter)

### 8.1 Secure Storage

**Sensitive Data:**
- JWT refresh tokens
- Device ID
- User ID

**Storage Mechanism:**
- iOS: Keychain (with kSecAttrAccessibleWhenUnlockedThisDeviceOnly)
- Android: EncryptedSharedPreferences (Android Keystore)
- Web: Browser secure storage (with limitations)

**Never Store:**
- Access tokens (keep in memory only)
- Unencrypted user credentials
- Full device fingerprint (store hash only)

### 8.2 Code Obfuscation

**Flutter Build Flags:**
```bash
flutter build apk --release --obfuscate --split-debug-info=./debug-info
flutter build ios --release --obfuscate --split-debug-info=./debug-info
```

**Protections:**
- Symbol names obfuscated
- Dead code elimination
- String encryption for sensitive constants

### 8.3 Certificate Pinning

**Prevent MITM Attacks:**
```dart
// Pin server's certificate in HTTP client
final client = HttpClient()
  ..badCertificateCallback = (cert, host, port) {
    return cert.sha256 == expectedCertHash;
  };
```

**Pin Rotation:**
- Pin backup certificates
- App update required when cert expires
- Grace period: Allow both old and new cert for 30 days

### 8.4 Jailbreak/Root Detection

**Optional (Trade-off):**
- Detect jailbroken/rooted devices
- Show warning but don't block (user education)
- Log for analytics (understand user base)

**Why Optional:**
- Many legitimate users root devices
- Detection can be bypassed
- Adds friction without strong security benefit

---

## 9. Future Security Enhancements

**Post-MVP Considerations:**

1. **Biometric Authentication**
   - Face ID / Touch ID for app unlock
   - Protects against lost/stolen devices

2. **End-to-End Encryption for Messages**
   - If adding chat features in future
   - Signal Protocol or similar

3. **Zero-Knowledge Proofs**
   - Prove ticket ownership without revealing ticket
   - Advanced cryptography for privacy

4. **Blockchain Integration (optional)**
   - Immutable record of chain attachments
   - Decentralized verification
   - Trade-off: Complexity, scalability, cost

5. **Multi-Factor Authentication**
   - SMS or email verification (if adding email/phone)
   - Time-based OTP for high-security actions

6. **Penetration Testing**
   - Annual external security audit
   - Bug bounty program for responsible disclosure

---

## 10. Security Checklist (Pre-Launch)

- [ ] All secrets stored in vault (not in code)
- [ ] HTTPS/TLS enforced on all endpoints
- [ ] JWT tokens properly signed and validated
- [ ] Rate limiting configured on all endpoints
- [ ] Device fingerprinting implemented and tested
- [ ] Multi-account detection rules active
- [ ] Database encrypted at rest and in transit
- [ ] Secure storage used for tokens in mobile app
- [ ] Certificate pinning implemented
- [ ] Error messages don't leak sensitive info
- [ ] GDPR data export/deletion endpoints working
- [ ] Privacy policy and ToS published
- [ ] Security monitoring and alerts configured
- [ ] Incident response plan documented
- [ ] Dependency vulnerability scanning active
- [ ] Code obfuscation enabled for mobile builds
- [ ] Backup and disaster recovery tested
- [ ] OWASP Top 10 vulnerabilities reviewed
- [ ] SQL injection testing passed
- [ ] XSS prevention confirmed (API-only, no HTML)
- [ ] CSRF not applicable (stateless JWT auth)

---

**Document Version:** 1.0
**Last Updated:** 2025-10-08
**Next Review:** Before MVP launch
