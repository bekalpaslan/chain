# MVP Requirements

## Overview

This document defines the **Minimum Viable Product** (MVP) scope for The Chain, prioritizing features essential for launch while deferring nice-to-have functionality to future releases.

**MVP Goal:** Launch a functional, viral-ready social chain experience that validates core mechanics and user engagement.

**Target Launch:** Month 6 (per project plan)

---

## 1. MVP Feature Prioritization

### Priority Levels

- **P0 (Critical):** Must have for MVP launch. System won't work without it.
- **P1 (High):** Important for good UX but can be simplified or mocked.
- **P2 (Medium):** Nice to have, defer to post-MVP.
- **P3 (Low):** Future enhancement, not needed for validation.

---

## 2. Feature Breakdown

### 2.1 Authentication & User Management

| Feature | Priority | MVP Scope | Notes |
|---------|----------|-----------|-------|
| Device-based registration | **P0** | ✅ Full implementation | Core authentication method |
| JWT token auth | **P0** | ✅ Access + refresh tokens | Required for API security |
| Display name (optional) | **P0** | ✅ With "Anonymous #N" default | User identity |
| Chain Key generation | **P0** | ✅ Auto-generated unique ID | Immutable identifier |
| Profile view | **P1** | ✅ Basic profile screen | Show chain key, stats |
| Profile editing | **P1** | ✅ Change display name only | Location toggle deferred to P1.5 |
| Multi-device support | **P2** | ❌ Defer to v1.1 | Single device per user for MVP |
| Account deletion | **P2** | ❌ Defer to v1.1 | Manual support process for MVP |
| Social login (Apple/Google) | **P3** | ❌ Defer to v2.0 | Device-based auth sufficient |

**MVP Scope:**
- Device fingerprinting on registration
- Single device per user (no device switching)
- Basic profile with chain key and stats
- Display name can be updated
- No account deletion UI (support handles manually)

---

### 2.2 Ticket System

| Feature | Priority | MVP Scope | Notes |
|---------|----------|-----------|-------|
| Generate ticket (QR + deep link) | **P0** | ✅ Full implementation | Core viral mechanism |
| 24-hour expiration | **P0** | ✅ Server-side enforcement | Core game mechanic |
| Ticket validation | **P0** | ✅ Signature verification | Security critical |
| One-time use enforcement | **P0** | ✅ Database constraint | Prevent double claims |
| QR code generation | **P0** | ✅ Server-side with CDN | Or client-side library |
| Deep link handling | **P0** | ✅ iOS + Android + Web | Universal links |
| Ticket expiration notification | **P1** | ✅ Push notification | User awareness |
| Ticket countdown timer | **P1** | ✅ Live countdown | Creates urgency |
| Wasted ticket tracking | **P1** | ✅ Count visible in profile | Transparency feature |
| Cancel ticket manually | **P2** | ❌ Defer to v1.1 | Let them expire naturally |
| Custom ticket message | **P2** | ❌ Defer to v1.2 | Plain tickets for MVP |
| Ticket generation cooldown | **P2** | ⚠️ Basic (10 min after waste) | Full abuse protection in v1.1 |

**MVP Scope:**
- One ticket per user (replaces previous if unused)
- QR code with deep link
- 24-hour countdown visible
- Push notification on expiration
- Basic cooldown after waste
- No custom messages or styling

---

### 2.3 Chain & Attachment

| Feature | Priority | MVP Scope | Notes |
|---------|----------|-----------|-------|
| Parent-child relationships | **P0** | ✅ Full implementation | Core data model |
| Sequential position numbering | **P0** | ✅ Auto-increment | Chain ordering |
| Attachment history | **P0** | ✅ Database records | Audit trail |
| Single seed user | **P0** | ✅ Admin-created | Chain origin |
| View own lineage (parent/child) | **P1** | ✅ Basic view | Show direct connections |
| View ancestors (up to seed) | **P2** | ❌ Defer to v1.2 | Simplified lineage for MVP |
| View descendants (full tree) | **P2** | ❌ Defer to v1.2 | Not critical for MVP |
| Search users in chain | **P2** | ❌ Defer to v1.2 | Browse only for MVP |
| Interactive chain tree | **P3** | ❌ Defer to v2.0 | Complex visualization |

**MVP Scope:**
- Simple parent → you → child view
- No full tree navigation
- No search functionality
- Admin manually creates seed user

---

### 2.4 Statistics & Analytics

| Feature | Priority | MVP Scope | Notes |
|---------|----------|-----------|-------|
| Global chain stats | **P0** | ✅ Total users, active tickets | Core metrics |
| Real-time updates (WebSocket) | **P1** | ✅ Stats + live feed | Creates excitement |
| Recent attachments feed | **P1** | ✅ Last 20 joins | Social proof |
| Geographic distribution | **P1** | ⚠️ Country-level only | Simple heatmap |
| Personal stats (tickets, position) | **P1** | ✅ Basic stats screen | User engagement |
| Growth rate chart | **P2** | ❌ Defer to v1.2 | Simple number for MVP |
| Interactive world map | **P2** | ❌ Defer to v1.2 | List of countries instead |
| Chain milestones | **P3** | ❌ Defer to v2.0 | Gamification |
| Leaderboards | **P3** | ❌ Defer to v2.0 | Not in initial concept |

**MVP Scope:**
- Global stats: total users, active tickets, wasted tickets
- Simple country list (no map)
- Live feed of recent joins
- Personal stats: position, wasted tickets, parent/child
- No charts or graphs

---

### 2.5 Location & Privacy

| Feature | Priority | MVP Scope | Notes |
|---------|----------|-----------|-------|
| Optional location sharing | **P1** | ✅ Opt-in on registration | Privacy consideration |
| Coarse location (city-level) | **P1** | ✅ City + country only | Privacy by design |
| Location in stats | **P1** | ✅ Country flags in feed | Visualize spread |
| Change location setting | **P2** | ❌ Defer to v1.1 | Set once at registration |
| Exact coordinates | **P3** | ❌ Never implement | Privacy risk |

**MVP Scope:**
- Optional: Share city + country on registration
- Cannot be changed after registration (for MVP)
- Display country flags in stats
- No map visualization

---

### 2.6 Notifications

| Feature | Priority | MVP Scope | Notes |
|---------|----------|-----------|-------|
| Push notification setup | **P1** | ✅ FCM + APNs | User engagement |
| Ticket expired | **P1** | ✅ Push notification | Important event |
| Child joined through you | **P1** | ✅ Push notification | Celebration moment |
| In-app notification center | **P2** | ❌ Defer to v1.2 | Just push for MVP |
| Email notifications | **P3** | ❌ No email in MVP | No email collection |
| Custom notification preferences | **P3** | ❌ Defer to v1.2 | All on by default |

**MVP Scope:**
- Push notifications only (no email)
- Two types: ticket expired, child joined
- Cannot customize (all enabled)
- No notification history

---

### 2.7 UI/UX

| Feature | Priority | MVP Scope | Notes |
|---------|----------|-----------|-------|
| Mobile app (iOS + Android) | **P0** | ✅ Flutter native | Primary platform |
| Web version (PWA) | **P1** | ✅ Flutter web | Accessibility |
| Onboarding tutorial | **P1** | ⚠️ Simple overlay | 3-step walkthrough |
| Dark mode | **P2** | ❌ Defer to v1.1 | Light mode only |
| Multiple languages | **P2** | ❌ Defer to v1.2 | English only for MVP |
| Accessibility features | **P2** | ⚠️ Basic support | Screen reader labels |
| Animations & transitions | **P2** | ⚠️ Minimal | Celebration on attachment |
| Tablet optimization | **P3** | ❌ Defer to v1.2 | Phone-first |

**MVP Scope:**
- Mobile-first design (Flutter)
- Web version functional but not optimized
- Simple onboarding (3 screens)
- Light mode only
- English only
- Basic accessibility
- Minimal animations (attachment celebration only)

---

### 2.8 Security & Abuse Prevention

| Feature | Priority | MVP Scope | Notes |
|---------|----------|-----------|-------|
| Device fingerprinting | **P0** | ✅ Full implementation | Multi-account prevention |
| Ticket signature verification | **P0** | ✅ Server-side signing | Security critical |
| Rate limiting | **P0** | ✅ Basic limits | DoS prevention |
| JWT token security | **P0** | ✅ Access + refresh | Auth security |
| Same-device self-claim block | **P1** | ✅ Prevent obvious abuse | Easy to implement |
| IP-based correlation | **P1** | ⚠️ Log only, no enforcement | Monitor for patterns |
| Multi-account detection | **P2** | ⚠️ Detection only, no auto-ban | Manual review |
| Bot detection | **P2** | ⚠️ Basic heuristics | Log suspicious activity |
| CAPTCHA | **P3** | ❌ Defer unless needed | Avoid friction |
| Advanced fraud detection | **P3** | ❌ Defer to v2.0 | ML-based |

**MVP Scope:**
- Device fingerprinting implemented
- Tickets server-signed and validated
- Basic rate limiting (per user + per IP)
- Block same-device ticket claims
- Log suspicious patterns (no auto-ban)
- Manual admin review for abuse

---

### 2.9 Admin & Operations

| Feature | Priority | MVP Scope | Notes |
|---------|----------|-----------|-------|
| Seed user creation script | **P0** | ✅ One-time script | Chain initialization |
| Database migrations | **P0** | ✅ Flyway/Liquibase | Schema versioning |
| Health check endpoints | **P0** | ✅ /health, /ready | Kubernetes liveness |
| Basic logging | **P0** | ✅ Structured logs | Debugging |
| Error tracking (Sentry) | **P1** | ✅ Crash reporting | Production monitoring |
| Metrics & monitoring | **P1** | ✅ Prometheus + Grafana | System health |
| Admin dashboard | **P2** | ❌ Defer to v1.1 | Use DB directly |
| User moderation tools | **P2** | ⚠️ Database scripts only | Manual SQL queries |
| Analytics dashboard | **P3** | ❌ Defer to v1.2 | Query DB for now |

**MVP Scope:**
- Basic operational tools
- Monitoring and alerting
- No admin UI (database access for emergencies)
- Seed user created manually via script

---

## 3. MVP User Stories

### Must-Have User Stories (P0)

1. **As a new user**, I can scan a QR code and join the chain.
2. **As a user**, I can generate my own invitation ticket.
3. **As a user**, I can see a countdown timer on my ticket.
4. **As a user**, I see my position in the chain after joining.
5. **As a user**, I can view global chain statistics.
6. **As a user**, I receive a notification when my ticket expires.
7. **As a user**, I receive a notification when someone joins through me.
8. **As a user**, I can see who invited me (parent).
9. **As a user**, I can see who I invited (child, if any).

### Should-Have User Stories (P1)

10. **As a user**, I can choose my display name or stay anonymous.
11. **As a user**, I can see a live feed of recent joins.
12. **As a user**, I can optionally share my location (city).
13. **As a user**, I can see which countries are represented in the chain.
14. **As a user**, I can see how many tickets I've wasted.

---

## 4. MVP Non-Functional Requirements

### 4.1 Performance

| Metric | Target | Critical? |
|--------|--------|-----------|
| API response time (P95) | < 500ms | ✅ Yes |
| Ticket validation | < 200ms | ✅ Yes |
| WebSocket connection latency | < 100ms | ⚠️ Best effort |
| App startup time | < 3s | ⚠️ Best effort |
| Database query time | < 100ms | ✅ Yes |

### 4.2 Scalability

| Metric | MVP Target | Post-MVP |
|--------|-----------|----------|
| Concurrent users | 10,000 | 100,000+ |
| Total users | 100,000 | 1,000,000+ |
| API requests/sec | 1,000 | 10,000+ |
| WebSocket connections | 5,000 | 50,000+ |
| Database size | 10 GB | 100 GB+ |

**MVP Scaling Strategy:**
- Single-region deployment
- Horizontal scaling (multiple app instances)
- Database read replicas for stats queries
- Redis for caching and rate limiting

### 4.3 Reliability

| Metric | Target |
|--------|--------|
| Uptime SLA | 99.5% (3.6h downtime/month) |
| Recovery Time Objective (RTO) | < 1 hour |
| Recovery Point Objective (RPO) | < 15 minutes |
| Error rate | < 0.5% |

### 4.4 Security

- All P0 security features implemented (see section 2.8)
- HTTPS/TLS enforced
- Secrets in vault (not code)
- Rate limiting active
- Security audit before launch

---

## 5. MVP Tech Stack

### 5.1 Frontend (Mobile & Web)

| Component | Technology | Rationale |
|-----------|-----------|-----------|
| Framework | **Flutter 3.x** | Single codebase for iOS, Android, Web |
| State Management | **Riverpod 2.x** | Testable, scalable |
| Networking | **Dio** | HTTP client with interceptors |
| WebSocket | **web_socket_channel** | Real-time updates |
| QR Scanner | **mobile_scanner** | Camera-based scanning |
| QR Generator | **qr_flutter** | Client-side QR generation |
| Secure Storage | **flutter_secure_storage** | Token storage |
| Notifications | **firebase_messaging** | Push notifications |
| Location | **geolocator** | Optional geo data |

### 5.2 Backend (Services)

| Component | Technology | Rationale |
|-----------|-----------|-----------|
| Framework | **Spring Boot 3.x** | Mature, scalable Java |
| Language | **Java 17+** | LTS version |
| API Gateway | **Spring Cloud Gateway** | Routing, rate limiting |
| Auth | **Spring Security + JWT** | Industry standard |
| WebSocket | **Spring WebSocket (STOMP)** | Real-time messaging |
| Database | **PostgreSQL 15** | Relational integrity |
| Cache/Session | **Redis 7** | Fast, persistent |
| Build Tool | **Maven** | Dependency management |

### 5.3 Infrastructure

| Component | Technology | Rationale |
|-----------|-----------|-----------|
| Container | **Docker** | Consistent environments |
| Orchestration | **Kubernetes (EKS/GKE)** | Auto-scaling, resilience |
| CI/CD | **GitHub Actions** | Integrated with repo |
| Mobile CI | **Codemagic / Fastlane** | Automated app builds |
| Monitoring | **Prometheus + Grafana** | Metrics visualization |
| Logging | **Loki + Grafana** | Centralized logs |
| Error Tracking | **Sentry** | Crash reporting |
| CDN | **CloudFlare / CloudFront** | QR code images |
| Cloud Provider | **AWS or GCP** | Managed services |

---

## 6. MVP Scope Summary

### ✅ IN SCOPE

**Core Features:**
- Device-based registration via invitation ticket
- QR code + deep link ticket generation
- 24-hour ticket expiration with countdown
- One-time ticket use (first claim wins)
- Sequential chain positions
- Parent → You → Child lineage view
- Global stats (total users, active tickets, countries)
- Real-time live feed of recent joins
- Push notifications (ticket expired, child joined)
- Optional location sharing (city + country)
- Basic profile with chain key and stats

**Platforms:**
- iOS native app (Flutter)
- Android native app (Flutter)
- Web PWA (Flutter web, functional but not optimized)

**Tech:**
- Spring Boot backend
- PostgreSQL + Redis
- JWT authentication
- WebSocket real-time updates
- Docker + Kubernetes
- Basic monitoring

### ❌ OUT OF SCOPE (Post-MVP)

**Deferred to v1.1-1.2:**
- Account deletion UI
- Multi-device support
- Cancel ticket manually
- Edit location settings
- Full chain tree navigation
- User search
- Admin dashboard
- Dark mode
- Multiple languages
- Advanced abuse detection

**Deferred to v2.0+:**
- Social login (Apple/Google/Google)
- Custom ticket messages
- Chain milestones & events
- Leaderboards
- Interactive visualizations
- Email notifications
- In-app chat
- Tokenization / blockchain

---

## 7. MVP Launch Checklist

### Development
- [ ] All P0 features implemented and tested
- [ ] All P1 features implemented and tested
- [ ] Unit test coverage > 70%
- [ ] Integration tests for critical paths
- [ ] Load testing completed (10K concurrent users)

### Security
- [ ] Security audit completed
- [ ] Penetration testing passed
- [ ] OWASP Top 10 reviewed
- [ ] Rate limiting configured and tested
- [ ] Secrets rotated (production)

### Legal & Compliance
- [ ] Terms of Service published
- [ ] Privacy Policy published (GDPR compliant)
- [ ] App Store / Play Store metadata ready
- [ ] Cookie consent (web) implemented

### Operations
- [ ] Production environment provisioned
- [ ] Database backups automated
- [ ] Monitoring dashboards configured
- [ ] Alerts configured (PagerDuty / OpsGenie)
- [ ] Incident response plan documented
- [ ] Seed user created

### Marketing
- [ ] Landing page live
- [ ] Social media accounts created
- [ ] Launch announcement prepared
- [ ] Influencer partnerships confirmed
- [ ] App Store screenshots & videos ready

### App Store Submission
- [ ] iOS app submitted to App Store
- [ ] Android app submitted to Play Store
- [ ] Web PWA deployed
- [ ] Deep links configured (Universal Links / App Links)

---

## 8. Success Criteria (Post-Launch)

**Week 1 (Immediate):**
- [ ] 1,000 users registered
- [ ] < 5% error rate
- [ ] 99%+ uptime
- [ ] Average ticket usage rate > 50%

**Month 1 (Early Growth):**
- [ ] 10,000 users registered
- [ ] Users from 10+ countries
- [ ] Average session time > 2 minutes
- [ ] 30-day retention > 20%

**Month 3 (Validation):**
- [ ] 100,000 users registered
- [ ] Chain continuity maintained (no breaks)
- [ ] Viral coefficient > 1.0 (each user invites 1+ successfully)
- [ ] App Store rating > 4.0

**Pivot Criteria:**
If by Month 3:
- < 10,000 users: Investigate marketing or UX issues
- Viral coefficient < 0.5: Core concept not resonating, rethink mechanics
- 30-day retention < 10%: Engagement problem, add features or gamification

---

## 9. Post-MVP Roadmap (High-Level)

**v1.1 (Month 7-8):**
- Multi-device support
- Account deletion UI
- Cancel ticket manually
- Admin dashboard (basic)
- Dark mode

**v1.2 (Month 9-10):**
- Full chain tree navigation
- User search
- Growth rate charts
- Multiple languages (top 5)
- Custom ticket messages

**v2.0 (Month 12+):**
- Social login options
- Interactive world map
- Chain milestones & events
- In-app chat (optional)
- Advanced analytics dashboard
- Tokenization / NFTs (if desired)

---

**Document Version:** 1.0
**Last Updated:** 2025-10-08
**Status:** Ready for development kickoff
