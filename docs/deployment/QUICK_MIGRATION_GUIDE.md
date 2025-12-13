# Quick Migration Guide - The Chain Database

## TL;DR

Choose your path:

### Path A: Fresh Development Environment
```bash
# 1. Backup old migrations
mkdir -p backend/src/main/resources/db/migration/archive
mv backend/src/main/resources/db/migration/V1__initial_schema.sql backend/src/main/resources/db/migration/archive/
mv backend/src/main/resources/db/migration/V2__add_chain_mechanics.sql backend/src/main/resources/db/migration/archive/
mv backend/src/main/resources/db/migration/V3__switch_to_username_auth.sql backend/src/main/resources/db/migration/archive/

# 2. Rename consolidated schema
mv backend/src/main/resources/db/migration/V1__initial_schema_consolidated.sql backend/src/main/resources/db/migration/V1__initial_schema.sql

# 3. Reset database
./mvnw flyway:clean  # WARNING: Deletes all data!
./mvnw flyway:migrate

# 4. Verify
./mvnw test
```

### Path B: Existing Production Database
```bash
# 1. Keep V4__schema_optimization.sql in migrations folder
# (Already present at: backend/src/main/resources/db/migration/V4__schema_optimization.sql)

# 2. Backup database
pg_dump -h localhost -U postgres -d thechain > backup_$(date +%Y%m%d_%H%M%S).sql

# 3. Run migration
./mvnw flyway:migrate

# 4. Verify
./mvnw test
```

## What Changed?

### Fixed Issues
1. ✅ **Invitations table:** Changed from position-based (inviter_position, invitee_position) to UUID-based (parent_id, child_id)
2. ✅ **Missing columns:** Added duration_hours, qr_code_url, used_at to tickets table
3. ✅ **Missing index:** Added idx_tickets_attempt_number
4. ✅ **Documentation:** Added comments to all 17 tables

### What Stays the Same
- ✅ All existing data preserved (Path B)
- ✅ All 17 tables same structure
- ✅ All JPA entities compatible
- ✅ All authentication flows work
- ✅ No breaking changes

## Verification (30 seconds)

```sql
-- Connect to database
psql -h localhost -U postgres -d thechain

-- Quick checks
SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';
-- Expected: 17

SELECT username, position FROM users WHERE position = 1;
-- Expected: alpaslan, 1

SELECT COUNT(*) FROM badges;
-- Expected: 3

SELECT version FROM chain_rules WHERE version = 1;
-- Expected: 1
```

## Rollback (if needed)

### Path A Rollback
```bash
# Restore old migrations
cp backend/src/main/resources/db/migration/archive/* backend/src/main/resources/db/migration/
rm backend/src/main/resources/db/migration/V1__initial_schema_consolidated.sql
./mvnw flyway:clean
./mvnw flyway:migrate
```

### Path B Rollback
```bash
# Delete V4 from history
psql -h localhost -U postgres -d thechain -c "DELETE FROM flyway_schema_history WHERE version = '4';"

# Restore database from backup
psql -h localhost -U postgres -d thechain < backup_YYYYMMDD_HHMMSS.sql
```

## Files Reference

| File | Size | Purpose |
|------|------|---------|
| V1__initial_schema_consolidated.sql | 40 KB | Fresh installations (Path A) |
| V4__schema_optimization.sql | 8 KB | Existing databases (Path B) |
| MIGRATION_STRATEGY.md | 12 KB | Detailed migration guide |
| SCHEMA_VERIFICATION_CHECKLIST.md | 15 KB | Complete verification steps |
| SCHEMA_CONSOLIDATION_ANALYSIS.md | 18 KB | Full analysis and findings |
| QUICK_MIGRATION_GUIDE.md | This file | Quick reference |

## Need Help?

1. **Schema questions:** See SCHEMA_CONSOLIDATION_ANALYSIS.md
2. **Migration steps:** See MIGRATION_STRATEGY.md
3. **Verification:** See SCHEMA_VERIFICATION_CHECKLIST.md
4. **Quick start:** This file

## Status Dashboard

After migration, check application health:

```bash
# Start application
./mvnw spring-boot:run

# Check logs for errors
tail -f logs/spring.log

# Test endpoints
curl http://localhost:8080/api/auth/login -X POST \
  -H "Content-Type: application/json" \
  -d '{"username":"alpaslan","password":"alpaslan"}'

# Expected: JWT token returned
```

## Common Issues

### Issue: "Table 'invitations' has wrong columns"
**Solution:** You're on V2 schema. Run Path B (V4 migration).

### Issue: "Flyway validation failed"
**Solution:** Checksums changed. Either:
- Use `flyway:repair` (risky)
- Start fresh with Path A

### Issue: "Tests failing after migration"
**Solution:**
1. Check application.yml database connection
2. Verify all 17 tables exist
3. Check seed data loaded
4. Run `./mvnw clean test`

### Issue: "Missing columns in tickets"
**Solution:** Run V4 migration (Path B) or use consolidated V1 (Path A)

## Success Criteria

✅ All tests pass
✅ Application starts without errors
✅ Login works (username: alpaslan, password: alpaslan)
✅ 17 tables in database
✅ Seed user exists (position 1)
✅ 3 badges exist
✅ Default chain rule exists

---

**Choose your path above and execute. Total time: 2-5 minutes.**
