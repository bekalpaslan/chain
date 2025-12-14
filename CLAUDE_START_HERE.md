# Claude Start Here - Quick Reference

> **📍 PRIMARY SOURCE OF TRUTH:** Read the main **[docs/DOCS_INDEX.md](docs/DOCS_INDEX.md)** for complete documentation index.
> **📊 IMPLEMENTATION STATUS:** See **[docs/status/IMPLEMENTATION_STATUS.md](docs/status/IMPLEMENTATION_STATUS.md)** for current technical state.

---

## Quick Access

| What | Where |
|------|-------|
| **Web App** | http://localhost:3000 |
| **Backend API** | http://localhost:8080/api/v1 |
| **PostgreSQL** | localhost:5432 |
| **Redis** | localhost:6379 |

---

## Current Project State (December 2025)

### ✅ IMPLEMENTED - Candidate/Permanent Membership System

The two-tier membership system is **FULLY IMPLEMENTED**:
- **Candidates**: New users in probationary period (3 attempts)
- **Permanent**: Users promoted after achieving depth-2 (their invitee invites someone)
- **Halving Time**: 24h → 12h → 6h for failed attempts
- **Smart Reversion**: Failed candidates revert to last permanent member

**Implementation Files:**
- `V9__add_membership_tier.sql` - Database migration
- `User.java` - `membershipTier`, `promotedToPermanentAt`, `inviteeDepth` fields
- `ChainService.java` - `checkAndPromoteToPermament()`, `findLastPermanentMember()`
- `TicketService.java` - `calculateExpirationTime()` with halving rule

### ✅ Frontend Architecture

**Unified App on Port 3000:**
- Public routes: `/`, `/stats` (no auth required)
- Protected routes: `/dashboard`, `/home`, `/ticket` (auth required)
- Dark Mystique theme applied throughout

**Note:** The `public-app` directory was removed; everything is now in `private-app`.

---

## Critical Reminders

1. **Tickets are AUTOMATIC**: Users don't generate tickets manually. The system creates them automatically upon registration.

2. **Password Management**: NEVER update passwords directly in the database. Use the API endpoint:
   ```bash
   curl -X POST http://localhost:8080/api/v1/users/set-password \
     -H "Content-Type: application/json" \
     -d '{ "email": "user@example.com", "newPassword": "yourpassword" }'
   ```

3. **Project Name**: Repository is `ticketz`, but the project is **"The Chain"**. "Tickets" are invitations.

4. **Check Before Implementing**: Always check `/docs/status/IMPLEMENTATION_STATUS.md` and `/docs/status/FRONTEND_IMPLEMENTATION_STATUS.md` before suggesting features - they may already exist!

---

## Quick Start

```bash
# Start all services
docker-compose up -d

# Check service status
docker-compose ps

# View backend logs
docker logs chain-backend -f

# Access database
docker exec -it chain-postgres psql -U chain_user -d chaindb

# Start Flutter development server
cd frontend/private-app
flutter run -d chrome --web-port=3000
```

---

## Key Documentation

| Document | Purpose |
|----------|---------|
| [docs/DOCS_INDEX.md](docs/DOCS_INDEX.md) | Master documentation index |
| [docs/status/IMPLEMENTATION_STATUS.md](docs/status/IMPLEMENTATION_STATUS.md) | Backend technical status |
| [docs/status/FRONTEND_IMPLEMENTATION_STATUS.md](docs/status/FRONTEND_IMPLEMENTATION_STATUS.md) | Frontend implementation status |
| [docs/features/CANDIDATE_PERMANENT_IMPLEMENTATION_PLAN.md](docs/features/CANDIDATE_PERMANENT_IMPLEMENTATION_PLAN.md) | Core feature documentation |
| [docs/architecture/API_SPECIFICATION.md](docs/architecture/API_SPECIFICATION.md) | REST API contracts |
| [docs/architecture/DATABASE_SCHEMA.md](docs/architecture/DATABASE_SCHEMA.md) | Database structure |

---

## Test Credentials (Development)

**Tip of Chain (Position 50):**
- Username: `testuser_50`
- Password: `password123`
- Status: Permanent (grandfathered)

**Seed User:**
- ChainKey: `SEED00000001`
- Status: Seed (always permanent)

---

*Last Updated: December 14, 2025*
