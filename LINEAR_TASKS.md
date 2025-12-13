# The Chain - Linear Task Structure

## Project Overview
**Project:** The Chain (Social Network)
**Repository:** ticketz
**Status:** MVP Development

---

## COMPLETED TASKS (Mark as Done ✅)

### Epic: Phase 1 - Authentication & Infrastructure ✅
- [x] Database schema design (17 tables)
- [x] JPA entity mapping for all tables
- [x] Repository layer implementation
- [x] Service layer foundation
- [x] Health check endpoints
- [x] CORS configuration (localhost:3000/3001)
- [x] Flyway migration system setup

### Epic: Phase 2 - Core Chain Mechanics ✅
- [x] Position-based user relationships
- [x] ±1 visibility data model (parent/self/child)
- [x] Invitation tracking system
- [x] Badge system structure (Savior, Guardian, Legend)
- [x] Dynamic rule versioning (ChainRule entity)
- [x] Automatic ticket creation on registration

### Epic: Phase 3 - Business Logic ✅
- [x] JWT authentication (token generation/validation)
- [x] Hybrid login (Email/Password + Device Fingerprint)
- [x] Ticket expiration scheduler (60-second interval)
- [x] 3-strike removal logic with wastedTicketsCount
- [x] Chain reversion to last permanent member
- [x] Expiration warning notifications (12h, 1h)
- [x] Old ticket cleanup (90 days retention)

### Epic: Phase 4 - Membership Tier System ✅ (Nov 5, 2025)
- [x] Candidate/Permanent membership tiers
- [x] Variable expiration times (24h → 12h → 6h)
- [x] Automatic promotion detection (depth-2)
- [x] Smart chain reversion algorithm
- [x] Database migration V9 (membership_tier column)
- [x] Performance indexes V10

### Epic: Phase 5 - Flutter Apps ✅
- [x] Shared package with API client
- [x] Public app deployment (port 3000)
- [x] Private app deployment (port 3001)
- [x] Device fingerprinting for web login
- [x] Secure storage helpers

### Epic: Phase 6 - Testing ✅
- [x] 9 candidate/permanent integration tests
- [x] 26 integration tests passing
- [x] 33 authentication tests passing
- [x] 11 Flutter package tests passing

---

## PENDING TASKS (To Do 📋)

### Epic: Phase 1 - UI Consolidation (Priority: HIGH 🔴)
**Estimated:** 2-3 hours

- [ ] Delete frontend/public-app directory
- [ ] Update docker-compose.yml (remove public-app service)
- [ ] Update private-app nginx config for SPA routing
- [ ] Make dashboard accessible without login
- [ ] Implement public/auth dual view modes
- [ ] Update navigation for unauthenticated users

### Epic: Phase 2 - Registration Flow (Priority: HIGH 🔴)
**Estimated:** 4 hours

- [ ] QR code scanner implementation (mobile_scanner)
- [ ] Ticket validation UI
- [ ] User registration screen
- [ ] Inviter information display
- [ ] Ticket code input fallback
- [ ] Registration error handling

### Epic: Phase 3 - Statistics & Visualization (Priority: MEDIUM 🟡)
**Estimated:** 6 hours

- [ ] Statistics widgets component
- [ ] Growth charts (fl_chart)
- [ ] Geographic distribution visualization
- [ ] Real-time WebSocket updates (optional)
- [ ] Chain length display
- [ ] Recent joins feed

### Epic: Phase 4 - Notifications (Priority: MEDIUM 🟡)
**Estimated:** 8 hours

- [ ] Firebase Cloud Messaging setup (FCM)
- [ ] Apple Push Notification service (APNs)
- [ ] Email notifications (SMTP/SendGrid)
- [ ] In-app notification center
- [ ] Notification preferences UI
- [ ] Expiration reminder notifications

### Epic: Phase 5 - Badge System (Priority: LOW 🟢)
**Estimated:** 4 hours

- [ ] Badge awarding logic implementation
- [ ] Savior badge (1 chain save)
- [ ] Guardian badge (5+ chain saves)
- [ ] Legend badge (10+ chain saves)
- [ ] Badge display in user profiles
- [ ] Badge notification triggers

### Epic: Phase 6 - Social Auth & Polish (Priority: LOW 🟢)
**Estimated:** 6 hours

- [ ] Sign in with Apple
- [ ] Sign in with Google
- [ ] Guest mode implementation
- [ ] Display name change (30-day cooldown)
- [ ] Email verification flow
- [ ] Magic link login

### Epic: Admin Features (Priority: LOW 🟢)
**Estimated:** 8 hours

- [ ] Admin authentication system
- [ ] Chain health monitoring dashboard
- [ ] Rule management UI
- [ ] User moderation tools
- [ ] Analytics dashboards

### Epic: Testing Improvements (Priority: MEDIUM 🟡)
**Estimated:** 4 hours

- [ ] Fix UserTest context loading errors
- [ ] Complete AuthServiceTest (geocoding mock)
- [ ] Add visibility enforcement tests
- [ ] Load testing (1000+ concurrent users)
- [ ] End-to-end scenario tests

---

## BUG FIXES & TECHNICAL DEBT

### Bugs (Priority: HIGH 🔴)
- [ ] Fix membership tier badges not displaying in frontend
- [ ] Fix attempt counter UI on tickets
- [ ] Fix promotion status display on dashboard

### Technical Debt (Priority: MEDIUM 🟡)
- [ ] Remove legacy signature/payload fields from tickets
- [ ] Investigate attachments table usage
- [ ] Tighten CORS configuration for production
- [ ] Generate production JWT_SECRET
- [ ] Implement rate limiting

---

## MILESTONES

### Milestone 1: MVP Launch
**Target:** 12-13 hours of work
- Phase 1: UI Consolidation
- Phase 2: Registration Flow
- Phase 3: Statistics

### Milestone 2: Full Feature Set
**Target:** 22 hours additional
- Phase 4: Notifications
- Phase 5: Badge System
- Phase 6: Social Auth

### Milestone 3: Production Ready
**Target:** 12 hours additional
- Admin Features
- Testing Improvements
- Technical Debt Resolution

---

## LABELS TO CREATE

- `frontend` - Flutter/UI work
- `backend` - Java/Spring Boot work
- `infrastructure` - Docker/deployment
- `testing` - Test-related tasks
- `bug` - Bug fixes
- `tech-debt` - Technical debt
- `security` - Security-related
- `high-priority` - Critical path items
- `medium-priority` - Important but not blocking
- `low-priority` - Nice to have

---

## PROJECT STATS

| Metric | Value |
|--------|-------|
| Completed Tasks | 35+ |
| Pending Tasks | 40+ |
| Tests Passing | 70+ |
| Estimated MVP Hours | 12-13 |
| Estimated Full Feature Hours | 46+ |

---

*Generated: December 13, 2025*
*Source: Project documentation analysis*
