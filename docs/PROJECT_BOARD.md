# The Chain - Project Board
**Last Updated:** October 9, 2025
**Current Phase:** Week 4 - Frontend Integration & User Engagement
**Overall Progress:** 🟩🟩🟩🟩🟩🟩⬜⬜⬜⬜ 60% Complete

---

## 🎯 Active Sprint: Week 4 (Current)

### Sprint Goals
1. Unblock Flutter frontend by fixing CORS
2. Implement core notification system for user engagement
3. Enable badge gamification system

**Sprint Duration:** October 9-18, 2025 (2 weeks)
**Total Estimated Effort:** 18 hours
**Team Velocity:** ~9 hours/week

---

## 📋 PRIORITY 1: Enable Flutter Frontend with CORS ⚡ CRITICAL
**Status:** 🔴 BLOCKED → 🟡 IN PROGRESS
**Business Value:** 🔥🔥🔥🔥🔥 (5/5) - Unblocks all frontend work
**Technical Complexity:** ⭐ (1/5) - Simple configuration change
**Estimated Effort:** 1 hour
**Dependencies:** None
**Assigned Agents:** backend-architect, test-engineer

### Tasks
- [ ] **Task 1.1:** Update SecurityConfig with CORS bean configuration
  - File: `backend/src/main/java/com/thechain/config/SecurityConfig.java`
  - Add corsConfigurationSource() bean
  - Allow origins: localhost:3000, localhost:3001, localhost:8080
  - Test: Manual curl test with Origin header
  - Test: Create CorsConfigurationTest.java integration test
  - **Tests Required:** 3 tests (one per allowed origin)
  - ⏱️ Estimate: 30 minutes

- [ ] **Task 1.2:** Rebuild and deploy backend with CORS enabled
  - Command: `mvn clean package -DskipTests`
  - Command: `docker-compose build backend && docker-compose up -d backend`
  - Verify: `docker logs chain-backend | grep "CORS"`
  - Verify: Health check returns 200 OK
  - **Tests Required:** Manual health check
  - ⏱️ Estimate: 10 minutes

- [ ] **Task 1.3:** Test Flutter Public App connectivity
  - Command: `cd frontend/public-app && flutter run -d chrome --web-port 3000`
  - Verify: Chain stats load without CORS errors in console
  - Verify: Home page displays data from backend
  - Test: Network tab shows 200 responses from API
  - **Tests Required:** Manual E2E test
  - ⏱️ Estimate: 10 minutes

- [ ] **Task 1.4:** Test Flutter Private App authentication flow
  - Command: `cd frontend/private-app && flutter run -d chrome --web-port 3001`
  - Credentials: alpaslan@alpaslan.com / alpaslan
  - Verify: Login succeeds and JWT stored
  - Verify: Dashboard loads after authentication
  - Test: Create AuthFlowTest.dart for login/logout cycle
  - **Tests Required:** 5 tests (login success, login failure, logout, token refresh, protected route)
  - ⏱️ Estimate: 20 minutes

- [ ] **Task 1.5:** Document CORS configuration
  - File: `docs/DEPLOYMENT_STATUS.md`
  - Add CORS section with dev vs prod origins
  - Include security implications and troubleshooting
  - **Tests Required:** Peer review for clarity
  - ⏱️ Estimate: 10 minutes

### Acceptance Criteria
- [x] Backend builds successfully with CORS configuration
- [ ] Flutter public app loads and displays chain statistics (no CORS errors)
- [ ] Flutter private app allows login with seed user
- [ ] Browser console shows 0 CORS errors
- [ ] 8+ tests passing (3 backend CORS + 5 frontend auth flow)
- [ ] Documentation updated with CORS configuration

### Progress Tracking
**Completed:** 0/5 tasks (0%)
**Tests Written:** 0/8 required tests
**Blockers:** None

---

## 📋 PRIORITY 2: Core Notification System 📧 HIGH
**Status:** 🔴 NOT STARTED
**Business Value:** 🔥🔥🔥🔥⚪ (4/5) - Critical for engagement
**Technical Complexity:** ⭐⭐⭐ (3/5) - Medium complexity
**Estimated Effort:** 8 hours
**Dependencies:** Priority 1 (for frontend display)
**Assigned Agents:** backend-architect, api-integration-specialist, test-engineer

### Tasks
- [ ] **Task 2.1:** Create EmailService with SMTP configuration
  - File: `backend/src/main/java/com/thechain/service/EmailService.java`
  - Add spring-boot-starter-mail dependency to pom.xml
  - Implement 5 email methods (ticket expiring, expired, tip change, badge, invitee joined)
  - Configure Gmail SMTP with environment variables
  - Use GreenMail for integration tests
  - **Tests Required:** 8 tests (5 happy paths + 3 error cases)
  - ⏱️ Estimate: 2 hours

- [ ] **Task 2.2:** Create NotificationService orchestration layer
  - File: `backend/src/main/java/com/thechain/service/NotificationService.java`
  - Implement 6 notification methods
  - Save notifications to database for in-app display
  - Track delivery failures
  - Mock EmailService in tests
  - **Tests Required:** 10 tests (6 happy paths + 4 error/edge cases)
  - ⏱️ Estimate: 2 hours

- [ ] **Task 2.3:** Integrate notifications into existing schedulers
  - File: `backend/src/main/java/com/thechain/scheduler/TicketExpirationScheduler.java`
  - Add notification calls to checkExpiringTickets() job
  - Add notification calls to handleExpiredTickets() job
  - Ensure idempotency (no duplicate notifications)
  - **Tests Required:** Update 3 existing integration tests
  - ⏱️ Estimate: 1 hour

- [ ] **Task 2.4:** Integrate notifications into AuthService registration
  - File: `backend/src/main/java/com/thechain/service/AuthService.java`
  - Call notificationService after successful registration
  - Notify inviter that their ticket was used
  - Test notification NOT sent on failure
  - **Tests Required:** Add 2 tests to existing suite (19 → 21)
  - ⏱️ Estimate: 30 minutes

- [ ] **Task 2.5:** Create Notification API endpoints
  - File: `backend/src/main/java/com/thechain/controller/NotificationController.java`
  - GET /api/v1/notifications (paginated in-app notifications)
  - PATCH /api/v1/notifications/{id}/read (mark as read)
  - GET /api/v1/notifications/preferences (get user preferences)
  - PUT /api/v1/notifications/preferences (update preferences)
  - Create notification_preferences table or JSONB column
  - **Tests Required:** 10 tests (8 controller + 2 integration)
  - ⏱️ Estimate: 2 hours

- [ ] **Task 2.6:** Configure SMTP environment in Docker
  - File: `docker-compose.yml`
  - Add SMTP environment variables to backend service
  - Create `.env` file with SMTP credentials (not committed)
  - Test email delivery to personal inbox
  - **Tests Required:** Manual email delivery test
  - ⏱️ Estimate: 30 minutes

### Acceptance Criteria
- [ ] 12-hour and 1-hour ticket expiration warnings sent via email
- [ ] Chain tip users receive "you're now the tip" notification
- [ ] Badge awards trigger celebration emails
- [ ] Inviters notified when their ticket is used
- [ ] 36+ new tests passing (breakdown: 8 + 10 + 3 + 2 + 10 + 3)
- [ ] Email delivery rate >95% (tracked in logs)
- [ ] Notification preferences API functional

### Progress Tracking
**Completed:** 0/6 tasks (0%)
**Tests Written:** 0/36 required tests
**Blockers:** Waiting for Priority 1 completion

---

## 📋 PRIORITY 3: Badge Awarding System 🏆 MEDIUM-HIGH
**Status:** 🔴 NOT STARTED
**Business Value:** 🔥🔥🔥⚪⚪ (3/5) - Gamification for retention
**Technical Complexity:** ⭐⭐ (2/5) - Low-medium complexity
**Estimated Effort:** 6 hours
**Dependencies:** Priority 2 (for badge award notifications)
**Assigned Agents:** backend-architect, ticket-system-specialist, test-engineer

### Tasks
- [ ] **Task 3.1:** Implement chain save event tracking
  - File: `backend/src/main/java/com/thechain/service/ChainService.java`
  - Add recordChainSave() method
  - Increment chain_saves_count on user
  - Integrate with existing chain reversion logic
  - **Tests Required:** 4 tests (increment, integration, edge cases)
  - ⏱️ Estimate: 1 hour

- [ ] **Task 3.2:** Create BadgeService for award logic
  - File: `backend/src/main/java/com/thechain/service/BadgeService.java`
  - Implement checkAndAwardBadges() method
  - Award Chain Savior (1st save), Guardian (5th), Legend (10th)
  - Store context data in JSONB column
  - Prevent duplicate badge awards
  - **Tests Required:** 6 tests (3 badge levels + duplicate check + context + error)
  - ⏱️ Estimate: 2 hours

- [ ] **Task 3.3:** Create database migration for save counter
  - File: `backend/src/main/resources/db/migration/V4__add_chain_saves_tracking.sql`
  - Add chain_saves_count column to users table
  - Create index for leaderboard queries
  - Backfill existing users' save counts (if applicable)
  - **Tests Required:** 2 tests (migration success + rollback)
  - ⏱️ Estimate: 30 minutes

- [ ] **Task 3.4:** Update User entity and repository
  - File: `backend/src/main/java/com/thechain/entity/User.java`
  - Add chainSavesCount field
  - File: `backend/src/main/java/com/thechain/repository/UserBadgeRepository.java`
  - Add existsByUserIdAndBadgeCode() query
  - Add findByUserIdOrderByCreatedAtDesc() query
  - **Tests Required:** 3 tests (entity validation + 2 repository queries)
  - ⏱️ Estimate: 30 minutes

- [ ] **Task 3.5:** Create User Profile API endpoints
  - File: `backend/src/main/java/com/thechain/controller/UserController.java`
  - GET /api/v1/users/me (profile with badges)
  - GET /api/v1/users/me/badges (badges list)
  - GET /api/v1/users/leaderboard (top chain savers)
  - Create DTOs: UserProfileResponse, BadgeResponse, LeaderboardEntry
  - **Tests Required:** 8 tests (3 controller + 1 integration + 1 security + 3 DTO)
  - ⏱️ Estimate: 2 hours

- [ ] **Task 3.6:** Integrate badge checking into chain reversion
  - File: `backend/src/main/java/com/thechain/service/ChainService.java`
  - Call badge service in revertChain() method
  - Update ChainReversionIntegrationTest
  - Verify save count increments and badges awarded
  - **Tests Required:** Add 3 assertions to existing 7 tests
  - ⏱️ Estimate: 30 minutes

### Acceptance Criteria
- [ ] Users earn Chain Savior badge on first successful chain save
- [ ] Users earn Chain Guardian badge at 5 saves
- [ ] Users earn Chain Legend badge at 10 saves
- [ ] GET /api/v1/users/me returns user profile with badges list
- [ ] GET /api/v1/users/leaderboard shows top chain savers
- [ ] 26+ new tests passing (4 + 6 + 2 + 3 + 8 + 3)
- [ ] Badge award triggers email notification (via Priority 2)

### Progress Tracking
**Completed:** 0/6 tasks (0%)
**Tests Written:** 0/26 required tests
**Blockers:** Can proceed without Priority 2, but degraded UX (no notifications)

---

## 📊 Sprint Burndown Chart

```
Total Tasks: 17 (5 + 6 + 6)
Total Tests Required: 70 (8 + 36 + 26)

Day 1  [█████░░░░░░░░░░░░] Priority 1 Complete (5 tasks, 8 tests)
Day 2  [██████████░░░░░░░] Priority 2 Tasks 1-3 (3 tasks, 18 tests)
Day 3  [█████████████░░░░] Priority 2 Tasks 4-6 (3 tasks, 18 tests)
Day 4  [████████████████░] Priority 3 Tasks 1-3 (3 tasks, 12 tests)
Day 5  [█████████████████] Priority 3 Tasks 4-6 Complete (3 tasks, 14 tests)
```

**Estimated Completion:** Day 5 (October 13, 2025)

---

## 🚀 Backlog: Phase 4 Features

### High Priority (Next Sprint)
1. **±1 Visibility Enforcement** - Prevent data leakage beyond immediate neighbors
   - Effort: 4 hours
   - Business Value: High (security)
   - Tests Required: 15+ tests

2. **WebSocket Real-time Updates** - Live chain growth notifications
   - Effort: 12 hours
   - Business Value: High (engagement)
   - Tests Required: 20+ tests

3. **API Rate Limiting (Comprehensive)** - Multi-layer protection
   - Effort: 6 hours
   - Business Value: High (security)
   - Tests Required: 18+ tests

### Medium Priority
4. **Display Name Change API** - Allow name updates with cooldown
   - Effort: 3 hours
   - Business Value: Medium (user experience)
   - Tests Required: 8+ tests

5. **Geographic Distribution Map** - Visualize chain spread
   - Effort: 8 hours
   - Business Value: Medium (engagement)
   - Tests Required: 10+ tests

6. **Push Notifications (FCM/APNs)** - Mobile native notifications
   - Effort: 12 hours
   - Business Value: Medium (engagement)
   - Tests Required: 15+ tests

### Low Priority
7. **Email Verification Flow** - Verify user emails
   - Effort: 6 hours
   - Business Value: Low (optional)
   - Tests Required: 12+ tests

8. **Password Reset Functionality** - Self-service password recovery
   - Effort: 4 hours
   - Business Value: Low (convenience)
   - Tests Required: 10+ tests

9. **Social Authentication** - Apple, Google sign-in
   - Effort: 16 hours
   - Business Value: Low (nice-to-have)
   - Tests Required: 20+ tests

10. **Chain Visualization Tree** - Interactive hierarchy view
    - Effort: 20 hours
    - Business Value: Low (exploratory)
    - Tests Required: 12+ tests

---

## 📈 Metrics Dashboard

### Current Sprint Metrics
| Metric | Current | Target | Status |
|--------|---------|--------|--------|
| Test Coverage | 66% | 80% | 🟡 Improving |
| Integration Tests Passing | 26/26 | 26/26 | ✅ 100% |
| Backend Tests Passing | 33/33 auth | All | 🟡 Partial |
| Flutter Tests Passing | 11/11 | 11/11 | ✅ 100% |
| API Response Time (p95) | ~500ms | <200ms | 🔴 Needs work |
| CORS Enabled | ❌ | ✅ | 🔴 Blocked |
| Notification System | 0% | 100% | 🔴 Not started |
| Badge System | 0% | 100% | 🔴 Not started |

### Cumulative Progress
| Phase | Status | Tests Passing | Completion |
|-------|--------|---------------|------------|
| Week 1: Database Schema | ✅ Complete | 17/17 migrations | 100% |
| Week 2: Authentication | ✅ Complete | 33/33 tests | 100% |
| Week 3: Ticket System | ✅ Complete | 26/26 integration | 100% |
| **Week 4: Frontend Integration** | 🟡 **In Progress** | **0/70 tests** | **0%** |

---

## 🎯 Definition of Done

A feature is considered DONE when:
- [ ] All implementation tasks completed
- [ ] **All required tests written and passing** (non-negotiable)
- [ ] Code reviewed by code-reviewer agent
- [ ] Security audited by security-guy agent (if applicable)
- [ ] Documentation updated (API spec, implementation status, testing guide)
- [ ] Deployed to staging environment
- [ ] Manual testing completed (if applicable)
- [ ] Performance validated (if applicable)

---

## 🚨 Risk Register

| Risk | Impact | Probability | Mitigation | Owner |
|------|--------|-------------|------------|-------|
| CORS misconfiguration breaks existing endpoints | High | Low | Test all endpoints after change | backend-architect |
| SMTP credentials invalid/expired | Medium | Medium | Test email delivery first, have backup service | deployment-engineer |
| Email spam filtering blocks notifications | Medium | High | Use reputable SMTP service, implement SPF/DKIM | deployment-engineer |
| Badge duplicate awards due to race condition | Low | Low | Comprehensive unit tests, idempotency checks | ticket-system-specialist |
| Frontend tests flaky in CI/CD | Medium | Medium | Mock API responses, use deterministic test data | test-engineer |

---

## 📝 Notes & Decisions

### Decision Log
1. **2025-10-09:** Prioritized CORS fix as #1 priority to unblock all frontend work
2. **2025-10-09:** Email notifications before push notifications (simpler MVP)
3. **2025-10-09:** Badge system MVP with 3 badge levels (Savior, Guardian, Legend)
4. **2025-10-09:** Using Gmail SMTP for MVP, will migrate to SendGrid/SES later

### Blockers
- **Priority 1:** CORS configuration must complete before Flutter apps functional
- **Priority 2:** Requires SMTP credentials configuration
- **Priority 3:** Best with notifications (Priority 2), but can proceed independently

### Dependencies Map
```
Priority 1 (CORS)
    ↓ (unblocks)
Frontend Testing & UX Validation
    ↓ (enables)
Priority 2 (Notifications) → Priority 3 (Badges)
                                      ↓ (enhances)
                              User Engagement Loop
```

---

## 🏅 Success Criteria for Week 4

**Sprint will be successful if:**
1. ✅ Flutter public app displays real chain data (Priority 1)
2. ✅ Users receive email notifications for ticket expiration (Priority 2)
3. ✅ Users earn and view badges in their profile (Priority 3)
4. ✅ 70+ new tests passing (8 + 36 + 26)
5. ✅ Test coverage improves from 66% → 75%+
6. ✅ Zero new security vulnerabilities introduced
7. ✅ All existing functionality remains working (regression testing)

---

## 📞 Agent Assignments

| Priority | Lead Agent | Supporting Agents |
|----------|------------|-------------------|
| **Priority 1** | backend-architect | test-engineer, deployment-engineer |
| **Priority 2** | backend-architect | api-integration-specialist, test-engineer, deployment-engineer |
| **Priority 3** | backend-architect | ticket-system-specialist, test-engineer, api-integration-specialist |

---

**Last Updated:** October 9, 2025 by technical-project-manager
**Next Review:** October 13, 2025 (End of Week 4, Day 5)
**Escalation Contact:** technical-project-manager agent for re-prioritization requests
