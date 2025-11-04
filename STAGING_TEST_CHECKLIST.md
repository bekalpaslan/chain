# 📋 Staging Environment Test Checklist

## 🎯 Candidate/Permanent System Testing

### Prerequisites
- [ ] PR merged to main branch
- [ ] Staging deployment completed successfully
- [ ] Database migration V007 applied
- [ ] Backend service healthy

---

## 1️⃣ Grandfathering Tests

### Test 1.1: Existing Users Are Permanent
```sql
-- Run in staging database
SELECT username, membership_tier, promoted_to_permanent_at
FROM users
WHERE created_at < '2024-11-05'
LIMIT 10;
```
**Expected**: All should have `membership_tier = 'permanent'`

### Test 1.2: Seed User Is Permanent
```sql
SELECT username, membership_tier, status
FROM users
WHERE chain_key = 'SEED00000001';
```
**Expected**: `membership_tier = 'permanent'`, `status = 'seed'`

---

## 2️⃣ New User Registration Tests

### Test 2.1: New Users Start as Candidates
1. Register a new user via API:
```bash
curl -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testcandidate1",
    "email": "candidate1@test.com",
    "password": "Test123!",
    "displayName": "Test Candidate 1"
  }'
```
2. Check user status:
```sql
SELECT username, membership_tier, invitee_depth
FROM users
WHERE username = 'testcandidate1';
```
**Expected**: `membership_tier = 'candidate'`, `invitee_depth = 0`

---

## 3️⃣ Ticket Duration Halving Tests

### Test 3.1: First Ticket - 24 Hours
1. Get user's active ticket:
```bash
curl http://localhost:8080/api/v1/tickets/me/active \
  -H "Authorization: Bearer {token}"
```
**Expected**: `durationHours: 24`, `attemptNumber: 1`

### Test 3.2: Second Ticket - 12 Hours
1. Wait for ticket to expire (or manually expire it)
2. Check new ticket duration
**Expected**: `durationHours: 12`, `attemptNumber: 2`

### Test 3.3: Third Ticket - 6 Hours
1. Let second ticket expire
2. Check third ticket
**Expected**: `durationHours: 6`, `attemptNumber: 3`

---

## 4️⃣ Depth-2 Promotion Tests

### Test 4.1: User Invites Someone - Still Candidate
1. User A invites User B
2. Check User A status:
```sql
SELECT username, membership_tier, invitee_depth
FROM users
WHERE username = 'userA';
```
**Expected**: Still `candidate`, `invitee_depth = 1`

### Test 4.2: Invitee Invites Someone - Original Promoted
1. User B invites User C
2. Check User A status after depth-2:
```sql
SELECT username, membership_tier, promoted_to_permanent_at, invitee_depth
FROM users
WHERE username = 'userA';
```
**Expected**: `membership_tier = 'permanent'`, `promoted_to_permanent_at` NOT NULL, `invitee_depth = 2`

---

## 5️⃣ Chain Reversion Tests

### Test 5.1: Candidate Fails - Reverts to Last Permanent
Setup:
- Permanent A → Candidate B → Candidate C → Candidate D

1. Let D's third ticket expire
2. Check who gets the new ticket:
```sql
SELECT t.*, u.username, u.membership_tier
FROM tickets t
JOIN users u ON t.owner_id = u.id
WHERE t.status = 'ACTIVE'
ORDER BY t.created_at DESC
LIMIT 1;
```
**Expected**: Ticket should belong to User A (last permanent)

---

## 6️⃣ API Response Tests

### Test 6.1: UserProfileResponse Includes Tier
```bash
curl http://localhost:8080/api/v1/users/profile \
  -H "Authorization: Bearer {token}"
```
**Expected Response Should Include**:
```json
{
  "membershipTier": "candidate",
  "promotedToPermanentAt": null,
  "inviteeDepth": 0,
  "isPermanent": false,
  "nextTicketDurationHours": 12
}
```

### Test 6.2: TicketResponse Includes Attempts
```bash
curl http://localhost:8080/api/v1/tickets/me/active \
  -H "Authorization: Bearer {token}"
```
**Expected Response Should Include**:
```json
{
  "attemptNumber": 2,
  "durationHours": 12,
  "strikeCount": 1,
  "nextAttemptDurationHours": 6
}
```

---

## 7️⃣ Edge Cases

### Test 7.1: Permanent Member Gets Ticket Back
1. Create chain: Permanent A → Candidate B
2. B fails 3 times
3. Verify A gets ticket and can reinvite

### Test 7.2: All Candidates in Chain Fail
1. Create: Permanent A → Candidate B → Candidate C → Candidate D
2. D fails 3 times
3. Verify ticket goes to A (not B or C)

---

## 8️⃣ Performance Tests

### Test 8.1: Chain Walking Performance
```sql
-- Check findLastPermanentMember performance
EXPLAIN ANALYZE
SELECT * FROM users
WHERE membership_tier = 'permanent'
ORDER BY position DESC
LIMIT 1;
```
**Expected**: Query should complete in < 100ms

### Test 8.2: Migration Rollback Test
```sql
-- Save current state
CREATE TABLE users_backup AS SELECT * FROM users;

-- Test rollback (DO NOT RUN IN PRODUCTION)
ALTER TABLE users DROP COLUMN membership_tier;
ALTER TABLE users DROP COLUMN promoted_to_permanent_at;
ALTER TABLE users DROP COLUMN invitee_depth;

-- Restore
-- Would need to re-run migration V007
```

---

## ✅ Sign-off Checklist

- [ ] All grandfathering tests pass
- [ ] New users correctly start as candidates
- [ ] Ticket duration halving works (24→12→6)
- [ ] Depth-2 promotion works correctly
- [ ] Chain reversion finds last permanent
- [ ] API responses include new fields
- [ ] No performance degradation
- [ ] Error handling works correctly
- [ ] Logs show expected behavior

**Tester**: ________________
**Date**: ________________
**Status**: [ ] PASS [ ] FAIL

## 🐛 Issues Found

| Issue # | Description | Severity | Status |
|---------|-------------|----------|--------|
| | | | |

---

**Notes**:
- Run tests in order as some depend on previous test data
- Monitor logs during testing: `docker-compose logs -f backend`
- Check metrics: `curl http://localhost:8080/api/v1/actuator/metrics`