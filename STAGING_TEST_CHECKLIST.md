# Staging Test Checklist - Candidate/Permanent System

## Deployment Information
- **Deploy Date**: November 5, 2025
- **Version**: V9 - Membership Tier System
- **Environment**: Docker Compose (Staging)

## 1. Health Checks ✅
- [x] Backend API: http://localhost:8080/api/v1/actuator/health
- [x] Public App: http://localhost:3000
- [x] Private App: http://localhost:3001
- [x] Database Migration: V9 applied successfully
- [x] Redis Cache: Connected
- [x] All containers running

## 2. Database Schema Validation
- [ ] Verify `membership_tier` column exists in users table
- [ ] Verify `promoted_to_permanent_at` column exists
- [ ] Verify `invitee_depth` column exists
- [ ] Check existing users are marked as "permanent"
- [ ] Check seed user is "permanent"

## 3. API Endpoint Testing

### User Registration
- [ ] New users start as "candidate"
- [ ] `membershipTier` field appears in profile response
- [ ] `inviteeDepth` starts at 0

### Ticket System
- [ ] First ticket: 24 hours (strike 0)
- [ ] Second ticket: 12 hours (strike 1)
- [ ] Third ticket: 6 hours (strike 2)
- [ ] Ticket response includes:
  - `attemptNumber`
  - `durationHours`
  - `strikeCount`
  - `nextAttemptDurationHours`

### Promotion Logic
- [ ] Candidate remains candidate with depth-1 (child only)
- [ ] Candidate promotes to permanent at depth-2 (grandchild)
- [ ] `promotedToPermanentAt` timestamp is set on promotion
- [ ] `inviteeDepth` updates correctly

### Chain Reversion
- [ ] Failed candidate (3 strikes) is removed
- [ ] Ticket reverts to last permanent member
- [ ] Chain correctly walks up to find permanent
- [ ] Permanent member receives new ticket

## 4. Frontend UI Validation

### Public App (Landing Page)
- [ ] Membership badges display correctly
- [ ] Statistics show membership tier breakdown

### Private App (Dashboard)
- [ ] User profile shows membership badge:
  - 🎯 for candidates
  - 👑 for permanent members
- [ ] Ticket page shows attempt information
- [ ] Progression indicator for candidates
- [ ] Celebration animation on promotion

## 5. Edge Cases

### Grandfathering
- [ ] Existing active users marked as permanent
- [ ] Users with children have inviteeDepth=2

### Multiple Candidates
- [ ] Chain walks past multiple candidates to find permanent
- [ ] Correct permanent member receives ticket

### Permanent Members
- [ ] Don't get auto-tickets after strikes
- [ ] Can manually request new tickets
- [ ] Don't lose permanent status on failures

## 6. Performance Tests
- [ ] API response times < 200ms
- [ ] Database queries optimized (check logs)
- [ ] No memory leaks in long-running tests
- [ ] Cache hit rates acceptable

## 7. Security Validation
- [ ] JWT tokens include membership tier
- [ ] No unauthorized access to tier data
- [ ] Migration doesn't expose sensitive data

## 8. Monitoring Setup
- [ ] Error logs clean
- [ ] No migration warnings
- [ ] Resource usage stable
- [ ] Database connections healthy

## 9. 24-Hour Stability Test
Start Time: _______________
End Time: _______________

### Hour 1-6
- [ ] No crashes or restarts
- [ ] Memory usage stable
- [ ] No error spikes

### Hour 6-12
- [ ] Ticket expirations handled correctly
- [ ] Promotions working
- [ ] Chain reversions successful

### Hour 12-18
- [ ] Database performance consistent
- [ ] Cache functioning properly
- [ ] No degradation in response times

### Hour 18-24
- [ ] System remains stable
- [ ] All features still working
- [ ] Ready for production

## 10. Rollback Plan
If issues are found:
1. Document the issue in detail
2. Capture logs and stack traces
3. Rollback procedure:
   ```bash
   git checkout main
   git revert HEAD
   docker-compose down
   docker-compose build --no-cache
   docker-compose up -d
   ```
4. Verify rollback successful
5. Fix issues in feature branch
6. Re-deploy to staging

## Sign-off
- [ ] All tests passed
- [ ] 24-hour stability confirmed
- [ ] Ready for production deployment
- [ ] Stakeholder approval received

---

## Notes
_Add any observations or issues discovered during testing_

---

## Production Deployment Approval
- Developer: _________________ Date: _________
- QA Lead: ___________________ Date: _________
- Product Owner: _____________ Date: _________