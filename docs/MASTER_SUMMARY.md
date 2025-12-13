# The Chain - Master Project Summary

**Last Updated:** December 13, 2025
**Project Status:** Candidate/Permanent Member System - COMPLETE
**Version:** 3.0

---

## Executive Summary

**The Chain** is a viral invitation-based social application that implements a sophisticated two-tier membership system. Users must prove themselves through successful invitations to maintain their position in the chain, creating a self-regulating community of engaged participants.

### Key Milestone: Candidate/Permanent System COMPLETE

The project has successfully transitioned from the original "hot potato" 3-strike system to an advanced **candidate/permanent member system**. This two-tier approach adds depth and strategy to the invitation mechanic, rewarding users who successfully build their network while maintaining accountability.

---

## What is The Chain?

The Chain is an invitation-only platform where each user receives a ticket to invite one person. Success requires not just inviting someone, but ensuring they also succeed - creating a self-sustaining chain of engaged users.

### Core Mechanics

1. **Invitation Tickets**
   - Each user receives a unique QR code ticket
   - Tickets have time-limited validity (24h, 12h, or 6h depending on attempt)
   - Tickets can only be used once

2. **Two-Tier Membership** (NEW - IMPLEMENTED)
   - **Candidate:** New users start here with 3 attempts to succeed
   - **Permanent:** Achieved when your invitee successfully invites someone (depth-2)

3. **Halving Time Window** (NEW - IMPLEMENTED)
   - First attempt: 24 hours
   - Second attempt: 12 hours
   - Final attempt: 6 hours

4. **Smart Chain Reversion** (NEW - IMPLEMENTED)
   - When candidates fail, tickets return to the last permanent member
   - Not just the immediate parent - walks up the chain to find stability

5. **Selective Ticketing** (NEW - IMPLEMENTED)
   - Only candidates and reactivated permanents receive tickets
   - Permanent members with active children are "settled"

---

## System Architecture

### Backend Stack
- **Framework:** Spring Boot 3.2.0 (Java 17)
- **Database:** PostgreSQL 15.14
- **Cache:** Redis 7 (Alpine)
- **Security:** Spring Security + JWT
- **Build:** Maven 3.9
- **Features:**
  - RESTful API with versioning
  - WebSocket for real-time updates
  - QR code generation (ZXing)
  - Database migrations (Flyway)
  - Comprehensive caching layer

### Frontend Stack
- **Framework:** Flutter 3.x
- **Platforms:** Web, iOS, Android (planned)
- **Apps:**
  - **Public App** (Port 3000): Marketing, stats, onboarding
  - **Private App** (Port 3001): User dashboard, tickets, chain management
- **State Management:** Provider/Riverpod
- **Design System:** Dark Mystique (custom dark theme)

### Infrastructure
- **Containerization:** Docker & Docker Compose
- **Reverse Proxy:** Nginx
- **Deployment:** Multi-stage Docker builds
- **Database Backups:** Automated procedures
- **Monitoring:** Spring Boot Actuator

---

## Candidate/Permanent Member System

### Overview

The candidate/permanent system replaces the simpler 3-strike model with a more nuanced approach that rewards depth-2 network building.

### How It Works

#### Candidate Phase
1. **New User Registration**
   - User starts as "candidate"
   - Receives first ticket (24-hour validity)
   - Must successfully invite someone

2. **First Invitation**
   - If invitee succeeds: Still candidate, but closer to permanent
   - If invitee fails: Strike 1, new ticket (12-hour validity)

3. **Path to Permanent**
   - Your invitee must successfully invite someone
   - This "depth-2" achievement promotes you to permanent
   - Permanent status is recorded with timestamp

#### Permanent Status
- **Benefits:**
  - Secure position in the chain
  - No more tickets needed (unless chain reverts)
  - Eligible for "Chain Builder" badge

- **Responsibilities:**
  - Can still receive tickets if descendants fail
  - Can earn "Chain Savior" badge for recovery

### Strike System with Halving

```
Attempt 1: 24 hours → Fail → Strike 1
Attempt 2: 12 hours → Fail → Strike 2
Attempt 3: 6 hours  → Fail → Strike 3 → REMOVED
```

### Reversion Logic

**Old System (Simple):**
```
User A → User B → User C
C fails → B gets ticket
```

**New System (Smart):**
```
Seed (P) → Alice (P) → Bob (C) → Charlie (C) → Diana (C)
Diana fails → Finds last permanent → Alice gets ticket
```

The system walks up the chain until it finds a permanent member, providing stability and rewarding successful users.

---

## Database Schema

### Core Tables

| Table | Rows | Purpose |
|-------|------|---------|
| `users` | Growing | User profiles, chain relationships, membership tier |
| `tickets` | Active + Historical | Invitation tickets with expiration |
| `invitations` | All attempts | Complete invitation history |
| `badges` | 10+ types | Achievement system |
| `user_badges` | User achievements | Badge awards with context |

### Key New Columns (V9 Migration)

```sql
users.membership_tier          -- 'candidate' or 'permanent'
users.promoted_to_permanent_at -- Timestamp of promotion
users.invitee_depth            -- 0, 1, or 2 (optimization)
```

### Indexes for Performance

```sql
idx_users_membership_tier
idx_users_invitee_depth
idx_users_active_child_id
idx_tickets_owner_status
```

---

## API Endpoints

### Authentication
- `POST /api/v1/auth/register` - Register new user
- `POST /api/v1/auth/login` - Login (email/password + device fingerprint)
- `POST /api/v1/auth/refresh` - Refresh JWT token
- `GET /api/v1/auth/me` - Get current user info (includes membership tier)

### Tickets
- `GET /api/v1/tickets/me/active` - Get active ticket (with tier info)
- `POST /api/v1/tickets/use` - Use a ticket to invite someone
- `GET /api/v1/tickets/history` - Ticket history

### Chain
- `GET /api/v1/chain/stats` - Global chain statistics
- `GET /api/v1/chain/my-lineage` - User's position in chain
- `GET /api/v1/chain/depth` - Check depth-2 status

### User
- `GET /api/v1/users/me` - User profile
- `PATCH /api/v1/users/me` - Update profile
- `GET /api/v1/users/me/badges` - User's badges

---

## Feature Implementation Status

### ✅ Completed Features

#### Core System
- [x] User registration and authentication
- [x] Hybrid auth (email/password + device fingerprint)
- [x] JWT-based session management
- [x] QR code ticket generation
- [x] Ticket expiration with scheduler
- [x] Chain relationship tracking
- [x] Real-time notifications (WebSocket)

#### Candidate/Permanent System (v1.0)
- [x] Database schema with membership_tier
- [x] Depth-2 detection algorithm
- [x] Halving time window logic (24h → 12h → 6h)
- [x] Find last permanent member algorithm
- [x] Smart ticket reversion
- [x] Selective ticket creation
- [x] Chain Builder badge
- [x] Chain Savior badge
- [x] Grandfathering existing users
- [x] Migration V9 deployed

#### Frontend
- [x] Flutter dual app architecture
- [x] Public app (marketing/stats)
- [x] Private app (user dashboard)
- [x] Dark Mystique design system
- [x] Responsive layouts
- [x] QR code scanning
- [x] Real-time ticket countdown
- [x] Membership tier badges (NEW)
- [x] Variable time display (NEW)

#### Infrastructure
- [x] Docker containerization
- [x] Docker Compose orchestration
- [x] PostgreSQL with Flyway migrations
- [x] Redis caching
- [x] Nginx reverse proxy configuration
- [x] CORS configuration
- [x] Environment-based configuration

### 🔄 In Progress

- [ ] Mobile app deployment (iOS/Android)
- [ ] Enhanced analytics dashboard
- [ ] Performance optimization
- [ ] Load testing

### 📋 Planned

- [ ] Advanced gamification
- [ ] Multi-language support
- [ ] Push notifications (mobile)
- [ ] Social sharing features
- [ ] Admin dashboard
- [ ] User reporting system

---

## Key Technical Decisions

### Why Two-Tier Membership?

**Problem:** Simple 3-strike system doesn't reward successful network building
**Solution:** Permanent status for users who prove they can build depth-2 networks
**Benefit:** Stabilizes the chain, rewards engagement, creates aspirational goal

### Why Halving Time Windows?

**Problem:** Equal 24-hour windows don't create urgency
**Solution:** Progressive pressure (24h → 12h → 6h)
**Benefit:** Increases engagement, reduces dead time, maintains fairness

### Why Smart Reversion?

**Problem:** Returning tickets to immediate parents can create cascading failures
**Solution:** Walk up chain to find last permanent member
**Benefit:** Rewards successful users, provides stability, prevents chain collapse

### Why Depth-2 Promotion?

**Problem:** Depth-1 is too easy, doesn't prove network-building ability
**Solution:** Require grandchild to achieve permanent status
**Benefit:** Ensures users build sustainable networks, not just one-off invites

---

## Performance Characteristics

### Response Times (Local Testing)
- Auth endpoints: < 100ms
- Ticket generation: < 200ms (including QR code)
- Chain stats: < 50ms (cached)
- User profile: < 75ms
- Depth-2 check: < 150ms (with indexes)

### Caching Strategy
- Redis for session tokens
- API response caching
- QR code caching
- Statistics caching (5-minute TTL)

### Database Optimization
- Indexed foreign keys
- Composite indexes for common queries
- Connection pooling (HikariCP)
- Query optimization for chain traversal

---

## Security Model

### Authentication
- **Password:** BCrypt with cost factor 10
- **Sessions:** JWT tokens (15-minute access, 7-day refresh)
- **Device Fingerprinting:** Browser/device identification
- **CSRF Protection:** Token-based

### Authorization
- Role-based access control (USER, ADMIN)
- Ticket ownership verification
- Chain relationship validation

### Data Protection
- HTTPS only in production
- Secure cookie settings
- Input validation and sanitization
- SQL injection prevention (JPA/Hibernate)
- XSS protection

---

## Testing Strategy

### Backend Tests
- Unit tests for business logic
- Integration tests for API endpoints
- Database migration tests
- Candidate/permanent system tests

### Frontend Tests
- Widget tests
- Integration tests
- Shared package tests (9/9 passing)

### Test Coverage
- Backend: ~70%
- Frontend: ~60%
- Shared: 100%

---

## Deployment

### Current Environment
- **Backend:** Docker container on port 8080
- **PostgreSQL:** Docker container on port 5432
- **Redis:** Docker container on port 6379
- **Public App:** Port 3000 (ready to deploy)
- **Private App:** Port 3001 (ready to deploy)

### Quick Start
```bash
# Start all backend services
docker-compose up -d

# Run frontend (development)
cd frontend/public-app
flutter run -d chrome --web-port=3000

cd frontend/private-app
flutter run -d chrome --web-port=3001
```

### Production Deployment
1. Build Docker images
2. Run migrations
3. Start containers with docker-compose
4. Configure Nginx reverse proxy
5. Set up SSL certificates
6. Configure monitoring

---

## Documentation Structure

All documentation has been reorganized into logical categories:

```
docs/
├── architecture/      - Technical architecture, API, database
├── features/         - Candidate/permanent system, auth, design
├── deployment/       - Docker, nginx, migration guides
├── testing/          - Test guides and known issues
├── planning/         - Roadmaps, sprints, project plans
├── guides/           - Installation and user guides
├── status/           - Implementation and deployment status
├── database/         - Database docs, backups, migrations
└── archive/          - Historical documentation
```

### Essential Documents
1. **[DOCS_INDEX.md](DOCS_INDEX.md)** - Complete documentation index
2. **[features/CANDIDATE_PERMANENT_IMPLEMENTATION_PLAN.md](features/CANDIDATE_PERMANENT_IMPLEMENTATION_PLAN.md)** - Main feature docs
3. **[status/IMPLEMENTATION_STATUS.md](status/IMPLEMENTATION_STATUS.md)** - Current technical state
4. **[architecture/API_SPECIFICATION.md](architecture/API_SPECIFICATION.md)** - API reference
5. **[architecture/DATABASE_SCHEMA.md](architecture/DATABASE_SCHEMA.md)** - Database structure

---

## Project Timeline

### Phase 1: Foundation (Completed)
- ✅ Project setup
- ✅ Database schema
- ✅ Basic authentication
- ✅ Ticket system
- ✅ Chain mechanics

### Phase 2: Enhancement (Completed)
- ✅ Hybrid authentication
- ✅ Dark Mystique design system
- ✅ Flutter apps
- ✅ Caching layer
- ✅ Real-time features

### Phase 3: Candidate/Permanent System (COMPLETED)
- ✅ Database migration V9
- ✅ Two-tier membership
- ✅ Depth-2 promotion
- ✅ Halving time windows
- ✅ Smart reversion logic
- ✅ Updated frontend with tier badges

### Phase 4: Optimization (In Progress)
- 🔄 Performance tuning
- 🔄 Load testing
- 🔄 Mobile deployment
- 📋 Advanced analytics

### Phase 5: Scale (Planned)
- 📋 Multi-region deployment
- 📋 Advanced gamification
- 📋 Social features
- 📋 Admin tools

---

## Team & Contributors

**Project Lead:** Alpaslan Bek
**Development:** Claude Code (AI Assistant)
**Architecture:** Collaborative design
**Testing:** Automated + Manual

---

## Links & Resources

### Repository
- **GitHub:** (Add repository URL)
- **Issues:** (Add issues URL)
- **Wiki:** (Add wiki URL)

### Documentation
- **API Docs:** [architecture/API_SPECIFICATION.md](architecture/API_SPECIFICATION.md)
- **Database Schema:** [architecture/DATABASE_SCHEMA.md](architecture/DATABASE_SCHEMA.md)
- **Deployment Guide:** [deployment/DOCKER_README.md](deployment/DOCKER_README.md)
- **User Flows:** [features/USER_FLOWS.md](features/USER_FLOWS.md)

### External Resources
- Spring Boot Documentation
- Flutter Documentation
- PostgreSQL Documentation
- Redis Documentation

---

## Contact & Support

For questions, issues, or contributions:
- Review documentation in `docs/` folder
- Check existing issues
- Follow contribution guidelines
- Reach out to project maintainers

---

## License

(Add license information)

---

## Acknowledgments

This project implements advanced chain invitation mechanics with a unique two-tier membership system. The candidate/permanent model creates a self-regulating community that rewards engagement and network-building ability.

Special thanks to all contributors and the open-source community for the tools and libraries that made this project possible.

---

**Last Updated:** December 13, 2025
**Document Version:** 3.0
**Project Status:** Candidate/Permanent System COMPLETE
**Next Milestone:** Mobile App Deployment
