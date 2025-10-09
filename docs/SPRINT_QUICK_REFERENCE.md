# Week 4 Sprint - Quick Reference Card

**Sprint Duration:** Oct 9-18, 2025 | **Total Effort:** 18 hours | **Tasks:** 17 | **Tests:** 70+

---

## 🎯 The 3 Priorities (In Order)

### 1️⃣ CORS Fix ⚡ CRITICAL (1 hour)
**Why:** Unblocks all Flutter frontend work
**What:** Add CORS configuration to SecurityConfig
**Tests:** 8 required (3 backend + 5 frontend)

**Quick Start:**
```bash
# 1. Edit SecurityConfig.java - add corsConfigurationSource() bean
# 2. mvn clean package && docker-compose up -d backend
# 3. cd frontend/public-app && flutter run -d chrome
# 4. Verify: No CORS errors in browser console
```

---

### 2️⃣ Notifications 📧 HIGH (8 hours)
**Why:** Critical for user engagement, prevent ticket expirations
**What:** Email notifications for ticket warnings, badge awards, chain events
**Tests:** 36 required (distributed across 6 tasks)

**Quick Start:**
```bash
# 1. Add spring-boot-starter-mail to pom.xml
# 2. Create EmailService.java with 5 notification methods
# 3. Create NotificationService.java orchestration layer
# 4. Integrate into existing schedulers
# 5. Add API endpoints for in-app notifications
# 6. Configure SMTP in docker-compose.yml + .env
```

---

### 3️⃣ Badges 🏆 MEDIUM (6 hours)
**Why:** Gamification increases retention, rewards chain-savers
**What:** Award badges for chain saves, user profile API
**Tests:** 26 required (distributed across 6 tasks)

**Quick Start:**
```bash
# 1. Add chain_saves_count column (V4 migration)
# 2. Create BadgeService.java with award logic
# 3. Update ChainService to track saves
# 4. Create UserController with profile endpoints
# 5. Integrate badge checking into chain reversion
```

---

## ✅ Daily Checklist

### Day 1 (2 hours) - CORS & Flutter Integration
- [ ] Update SecurityConfig with CORS bean
- [ ] Write CorsConfigurationTest (3 tests)
- [ ] Rebuild backend and redeploy
- [ ] Test Flutter public app (chain stats load)
- [ ] Test Flutter private app (login flow)
- [ ] Write AuthFlowTest.dart (5 tests)
- [ ] Update DEPLOYMENT_STATUS.md
- **🎯 Goal:** Flutter apps working end-to-end

### Day 2 (4 hours) - Notification System Part 1
- [ ] Add spring-boot-starter-mail dependency
- [ ] Create EmailService.java
- [ ] Write 8 EmailService tests
- [ ] Create NotificationService.java
- [ ] Write 10 NotificationService tests
- [ ] Integrate into TicketExpirationScheduler
- **🎯 Goal:** Email infrastructure complete, 18 tests passing

### Day 3 (4 hours) - Notification System Part 2
- [ ] Integrate notifications into AuthService
- [ ] Write 2 AuthService notification tests
- [ ] Create NotificationController.java (4 endpoints)
- [ ] Write 10 NotificationController tests
- [ ] Add SMTP config to docker-compose.yml
- [ ] Test email delivery to personal inbox
- **🎯 Goal:** Notification system complete, 36 tests passing total

### Day 4 (4 hours) - Badge System Part 1
- [ ] Create V4 migration (chain_saves_count column)
- [ ] Write 2 migration tests
- [ ] Update User entity and repositories
- [ ] Write 3 repository tests
- [ ] Create BadgeService.java with award logic
- [ ] Write 6 BadgeService tests
- **🎯 Goal:** Badge core logic complete, 11 tests passing

### Day 5 (4 hours) - Badge System Part 2
- [ ] Create UserController.java with 3 endpoints
- [ ] Write 8 UserController tests
- [ ] Update ChainService to track saves
- [ ] Write 4 chain save tracking tests
- [ ] Integrate badge checking into reversion
- [ ] Update ChainReversionIntegrationTest (3 assertions)
- [ ] Manual E2E test: Trigger chain save → badge awarded
- **🎯 Goal:** Badge system complete, 26 tests passing total

---

## 📊 Progress Tracker

| Day | Priority | Tasks | Tests | Status |
|-----|----------|-------|-------|--------|
| 1 | P1 CORS | 5/5 | 8/8 | ⬜ Not Started |
| 2 | P2 Notif (1/2) | 3/6 | 18/36 | ⬜ Not Started |
| 3 | P2 Notif (2/2) | 6/6 | 36/36 | ⬜ Not Started |
| 4 | P3 Badge (1/2) | 3/6 | 11/26 | ⬜ Not Started |
| 5 | P3 Badge (2/2) | 6/6 | 26/26 | ⬜ Not Started |

**Total:** 17 tasks, 70+ tests

---

## 🧪 Test Requirements Summary

### Priority 1: CORS (8 tests)
- 3 backend integration tests (CorsConfigurationTest)
- 5 frontend auth flow tests (AuthFlowTest.dart)

### Priority 2: Notifications (36 tests)
- 8 EmailService tests (unit)
- 10 NotificationService tests (unit)
- 3 Scheduler integration tests (updated)
- 2 AuthService tests (updated)
- 10 NotificationController tests (unit + integration)
- 3 Integration tests (E2E notification flow)

### Priority 3: Badges (26 tests)
- 4 Chain save tracking tests
- 6 BadgeService tests (unit)
- 2 Migration tests
- 3 Repository tests
- 8 UserController tests (unit + integration)
- 3 ChainReversion tests (updated)

---

## 🚨 Critical Reminders

### Before You Code:
1. ✅ Read the full task description in PROJECT_BOARD.md
2. ✅ Understand what tests are required
3. ✅ Set up test file BEFORE writing implementation
4. ✅ Write failing test first (TDD approach)

### During Implementation:
1. ⚠️ **Write tests as you go** - Don't leave for end
2. ⚠️ Run tests frequently - Catch bugs early
3. ⚠️ Follow existing code patterns
4. ⚠️ Use agents for guidance (backend-architect, test-engineer)

### After Implementation:
1. ✅ All tests passing (green)
2. ✅ Code reviewed (use code-reviewer agent)
3. ✅ Security checked (if applicable)
4. ✅ Documentation updated
5. ✅ Update PROJECT_BOARD.md progress

---

## 🤖 Agent Quick Reference

**When to invoke which agent:**

| Task | Invoke Agent | Purpose |
|------|--------------|---------|
| "How do I implement X?" | **backend-architect** | Design & implementation guidance |
| "What tests do I need?" | **test-engineer** | Test strategy & test writing |
| "Is this code good?" | **code-reviewer** | Code quality review |
| "How do I connect frontend?" | **api-integration-specialist** | API contracts & Flutter client |
| "This query is slow" | **database-optimizer** | Query optimization |
| "How do I deploy this?" | **deployment-engineer** | Docker, CI/CD, production |
| "Is this secure?" | **security-guy** | Security audit |
| "What should I work on?" | **technical-project-manager** | Prioritization & roadmap |

---

## 📁 Key Files Reference

### Priority 1 (CORS)
- `backend/src/main/java/com/thechain/config/SecurityConfig.java`
- `backend/src/test/java/com/thechain/config/CorsConfigurationTest.java`
- `frontend/public-app/test/auth_flow_test.dart`

### Priority 2 (Notifications)
- `backend/src/main/java/com/thechain/service/EmailService.java`
- `backend/src/main/java/com/thechain/service/NotificationService.java`
- `backend/src/main/java/com/thechain/controller/NotificationController.java`
- `backend/src/main/java/com/thechain/scheduler/TicketExpirationScheduler.java`
- `docker-compose.yml` (SMTP config)
- `.env` (SMTP credentials)

### Priority 3 (Badges)
- `backend/src/main/resources/db/migration/V4__add_chain_saves_tracking.sql`
- `backend/src/main/java/com/thechain/service/BadgeService.java`
- `backend/src/main/java/com/thechain/controller/UserController.java`
- `backend/src/main/java/com/thechain/service/ChainService.java`

---

## 💡 Success Tips

### Time Management
- **Don't rush tests** - They save time later by catching bugs
- **Use agents** - Don't waste time researching, ask for help
- **Take breaks** - Better code quality when not fatigued
- **Review daily progress** - Update PROJECT_BOARD.md each day

### Code Quality
- **Follow existing patterns** - Consistency matters
- **Small commits** - Easier to review and rollback
- **Meaningful commit messages** - Help future you
- **Test edge cases** - Not just happy path

### Communication
- **Ask TPM for priorities** - Don't assume, verify
- **Use code-reviewer** - Catch issues before merge
- **Document decisions** - Add notes to PROJECT_BOARD.md
- **Update status** - Keep board current

---

## 🎯 Sprint Success = All 3 Checkboxes ✅

- [ ] **Flutter apps working** (Priority 1 complete)
- [ ] **Users receiving emails** (Priority 2 complete)
- [ ] **Badges being awarded** (Priority 3 complete)

**Bonus achievements:**
- [ ] 70+ tests passing
- [ ] Test coverage 66% → 75%+
- [ ] Zero new security issues
- [ ] All existing tests still passing

---

**Print this page and keep it next to your keyboard! 🖨️**

Last updated: October 9, 2025
