# Documentation Index

**Last Updated:** December 13, 2025
**Project:** The Chain (ticketz)
**Status:** Candidate/Permanent Member System - COMPLETE

---

## Executive Summary

The Chain is a viral invitation-based application with a sophisticated two-tier membership system. This documentation has been reorganized to reflect the current state of the project with the **candidate/permanent member system fully implemented**.

**Key Achievement:** The candidate/permanent member system has been successfully deployed, replacing the original "hot potato" 3-strike system with a more sophisticated probation period model.

### Recent Changes (December 2025)
- ✅ **public-app removed** - Consolidated into private-app (now on port 3000)
- ✅ Private-app now serves as unified landing page + authenticated dashboard
- ✅ Public stats visible without login, full features require authentication
- ✅ **Public landing page** - `/` shows live chain statistics with Dark Mystique theme
- ✅ **Public stats page** - `/stats` shows detailed chain metrics
- ✅ **Top-right login button** - Sign In button in landing page header

---

## Quick Start

### Essential Reading (Start Here)
1. **[Master Summary](MASTER_SUMMARY.md)** - Complete project overview with candidate/permanent system
2. **[Status: Implementation Status](status/IMPLEMENTATION_STATUS.md)** - Current technical state
3. **[Status: Deployment Status](status/DEPLOYMENT_STATUS.md)** - Deployment state and access
4. **[Features: Candidate/Permanent System](features/CANDIDATE_PERMANENT_IMPLEMENTATION_PLAN.md)** - Complete feature documentation

### For Developers
- **[Architecture: API Specification](architecture/API_SPECIFICATION.md)** - REST API contracts
- **[Architecture: Database Schema](architecture/DATABASE_SCHEMA.md)** - Database structure
- **[Guides: Flutter Installation](guides/FLUTTER_INSTALLATION.md)** - Frontend setup
- **[Testing: Testing Guide](testing/TESTING_GUIDE.md)** - How to run tests

### For Deployment
- **[Deployment: Docker README](deployment/DOCKER_README.md)** - Docker deployment guide
- **[Deployment: Migration Strategy](deployment/MIGRATION_STRATEGY.md)** - Deployment best practices

---

## Documentation Structure

All documentation is organized into logical folders:

```
docs/
├── architecture/      - Technical architecture, database, API specs
├── features/         - Feature documentation (candidate/permanent, auth, design)
├── deployment/       - Docker, nginx, deployment guides
├── testing/          - Testing guides and issue tracking
├── planning/         - Project plans, roadmaps, sprints
├── guides/           - User guides, installation instructions
├── status/           - Implementation status, progress reports
├── database/         - Database-specific documentation
└── archive/          - Historical documentation (reference only)
```

---

## 1. Architecture Documentation

**Location:** `docs/architecture/`

Technical architecture, database design, API specifications, and system design.

| Document | Purpose | Status |
|----------|---------|--------|
| [TECHICAL_DOCS.md](architecture/TECHICAL_DOCS.md) | Core technical architecture | ✅ Current |
| [API_SPECIFICATION.md](architecture/API_SPECIFICATION.md) | REST API endpoints and contracts | ✅ Current |
| [API_VERSIONING_STRATEGY.md](architecture/API_VERSIONING_STRATEGY.md) | API version management | ✅ Current |
| [API_CLIENT_GENERATION.md](architecture/API_CLIENT_GENERATION.md) | Client SDK generation | ✅ Current |
| [DATABASE_SCHEMA.md](architecture/DATABASE_SCHEMA.md) | Complete database structure | ✅ Current |
| [DATABASE_SCHEMA_DIAGRAM.md](architecture/DATABASE_SCHEMA_DIAGRAM.md) | Visual database diagrams | ✅ Current |
| [SECURITY_MODEL.md](architecture/SECURITY_MODEL.md) | Security architecture and practices | ✅ Current |
| [NETWORK_ARCHITECTURE_ANALYSIS.md](architecture/NETWORK_ARCHITECTURE_ANALYSIS.md) | Network topology and routing | 📚 Reference |
| [SCHEMA_CONSOLIDATION_ANALYSIS.md](architecture/SCHEMA_CONSOLIDATION_ANALYSIS.md) | Schema migration analysis | 📚 Reference |
| [SCHEMA_VERIFICATION_CHECKLIST.md](architecture/SCHEMA_VERIFICATION_CHECKLIST.md) | Schema validation checklist | 📚 Reference |
| [OFFLINE_FIRST_ARCHITECTURE.md](architecture/OFFLINE_FIRST_ARCHITECTURE.md) | Offline-first design patterns | 📚 Reference |
| [PLATFORM_SPECIFIC_CONSIDERATIONS.md](architecture/PLATFORM_SPECIFIC_CONSIDERATIONS.md) | Cross-platform considerations | 📚 Reference |
| [CROSS_PLATFORM_STRATEGY.md](architecture/CROSS_PLATFORM_STRATEGY.md) | Multi-platform strategy | 📚 Reference |

---

## 2. Feature Documentation

**Location:** `docs/features/`

Detailed documentation for implemented features including the candidate/permanent system.

| Document | Purpose | Status |
|----------|---------|--------|
| [CANDIDATE_PERMANENT_IMPLEMENTATION_PLAN.md](features/CANDIDATE_PERMANENT_IMPLEMENTATION_PLAN.md) | **Complete implementation plan** | ✅ COMPLETE |
| [HYBRID_AUTHENTICATION_IMPLEMENTATION.md](features/HYBRID_AUTHENTICATION_IMPLEMENTATION.md) | Email/password + device fingerprint auth | ✅ Complete |
| [MVP_REQUIREMENTS.md](features/MVP_REQUIREMENTS.md) | MVP feature requirements | ✅ Current |
| [USER_FLOWS.md](features/USER_FLOWS.md) | User interaction flows | ✅ Current |
| [DARK_MYSTIQUE_DESIGN_SYSTEM.md](features/DARK_MYSTIQUE_DESIGN_SYSTEM.md) | Complete design system | ✅ Current |
| [DARK_MYSTIQUE_INDEX.md](features/DARK_MYSTIQUE_INDEX.md) | Design system index | ✅ Current |
| [DARK_MYSTIQUE_COMPLETE_SUMMARY.md](features/DARK_MYSTIQUE_COMPLETE_SUMMARY.md) | Design system summary | ✅ Current |
| [DARK_MYSTIQUE_ACCESSIBILITY_REPORT.md](features/DARK_MYSTIQUE_ACCESSIBILITY_REPORT.md) | Accessibility compliance | ✅ Current |
| [DARK_MYSTIQUE_VISUAL_REFERENCE.md](features/DARK_MYSTIQUE_VISUAL_REFERENCE.md) | Visual component reference | ✅ Current |
| [DARK_MYSTIQUE_WEB_STYLES.css](features/DARK_MYSTIQUE_WEB_STYLES.css) | CSS implementation | ✅ Current |

### Candidate/Permanent Member System

The two-tier membership system is now fully implemented with:
- **Candidate Status:** New users start as candidates with 3 attempts
- **Halving Time Window:** 24h → 12h → 6h for each failed attempt
- **Depth-2 Promotion:** Candidates become permanent when their invitee successfully invites someone
- **Smart Reversion:** Tickets revert to last permanent member, not just parent
- **Selective Ticketing:** Only candidates and reactivated permanents receive tickets

See [CANDIDATE_PERMANENT_IMPLEMENTATION_PLAN.md](features/CANDIDATE_PERMANENT_IMPLEMENTATION_PLAN.md) for complete details.

---

## 3. Deployment Documentation

**Location:** `docs/deployment/`

Docker configuration, nginx setup, deployment strategies, and migration guides.

| Document | Purpose | Status |
|----------|---------|--------|
| [DOCKER_README.md](deployment/DOCKER_README.md) | Docker setup and usage | ✅ Current |
| [DOCKER_NGINX_DEPLOYMENT.md](deployment/DOCKER_NGINX_DEPLOYMENT.md) | Nginx + Docker deployment | ✅ Current |
| [NGINX_DEPLOYMENT.md](deployment/NGINX_DEPLOYMENT.md) | Nginx configuration | ✅ Current |
| [DEPLOYMENT_ROADMAP.md](deployment/DEPLOYMENT_ROADMAP.md) | Deployment phases roadmap | ✅ Current |
| [MIGRATION_STRATEGY.md](deployment/MIGRATION_STRATEGY.md) | Database migration strategy | ✅ Current |
| [QUICK_MIGRATION_GUIDE.md](deployment/QUICK_MIGRATION_GUIDE.md) | Quick migration reference | ✅ Current |

---

## 4. Testing Documentation

**Location:** `docs/testing/`

Testing guides, test results, and known issues.

| Document | Purpose | Status |
|----------|---------|--------|
| [TESTING_GUIDE.md](testing/TESTING_GUIDE.md) | How to run tests | ✅ Current |
| [TESTING_SUMMARY.md](testing/TESTING_SUMMARY.md) | Test coverage and results | ✅ Current |
| [BACKEND_TEST_ISSUES.md](testing/BACKEND_TEST_ISSUES.md) | Known backend test issues | ✅ Current |

---

## 5. Planning Documentation

**Location:** `docs/planning/`

Project plans, roadmaps, sprint documentation, and quick references.

| Document | Purpose | Status |
|----------|---------|--------|
| [PROJECT_PLAN.md](planning/PROJECT_PLAN.md) | 6-month project roadmap | ⚠️ Needs update |
| [PROJECT_BOARD.md](planning/PROJECT_BOARD.md) | Kanban-style project board | ✅ Current |
| [ROADMAP_VISUAL.md](planning/ROADMAP_VISUAL.md) | Visual project roadmap | ✅ Current |
| [SPRINT_QUICK_REFERENCE.md](planning/SPRINT_QUICK_REFERENCE.md) | Sprint planning reference | ✅ Current |
| [CORS_QUICK_REFERENCE.md](planning/CORS_QUICK_REFERENCE.md) | CORS configuration reference | ✅ Current |

---

## 6. Guides Documentation

**Location:** `docs/guides/`

User guides, installation instructions, and implementation guides.

| Document | Purpose | Status |
|----------|---------|--------|
| [FLUTTER_INSTALLATION.md](guides/FLUTTER_INSTALLATION.md) | Flutter setup guide | ✅ Current |
| [FLUTTER_IMPLEMENTATION_COMPLETE.md](guides/FLUTTER_IMPLEMENTATION_COMPLETE.md) | Flutter implementation overview | ✅ Current |
| [FLUTTER_PROJECT_STRUCTURE.md](guides/FLUTTER_PROJECT_STRUCTURE.md) | Flutter project organization | ✅ Current |

---

## 7. Status Documentation

**Location:** `docs/status/`

Current implementation status, deployment status, and progress reports.

| Document | Purpose | Status |
|----------|---------|--------|
| [IMPLEMENTATION_STATUS.md](status/IMPLEMENTATION_STATUS.md) | **Master technical status** | ✅ Current (v2.4) |
| [IMPLEMENTATION_PROGRESS.md](status/IMPLEMENTATION_PROGRESS.md) | Feature progress tracking | ✅ Current |
| [DEPLOYMENT_STATUS.md](status/DEPLOYMENT_STATUS.md) | Current deployment state | ✅ Current |
| [DOCUMENTATION_CLEANUP_SUMMARY.md](status/DOCUMENTATION_CLEANUP_SUMMARY.md) | Documentation organization | ✅ Current |
| [SESSION_SUMMARY_2025-10-30.md](status/SESSION_SUMMARY_2025-10-30.md) | Development session summary | 📚 Reference |

---

## 8. Database Documentation

**Location:** `docs/database/`

Detailed database documentation, migration guides, and backup procedures.

| Document | Purpose | Status |
|----------|---------|--------|
| [BACKUP_PROCEDURES.md](database/BACKUP_PROCEDURES.md) | Database backup procedures | ✅ Current |
| [DATA_DICTIONARY.md](database/DATA_DICTIONARY.md) | Complete data dictionary | ✅ Current |
| [DATABASE_CONSOLIDATION_PLAN.md](database/DATABASE_CONSOLIDATION_PLAN.md) | Schema consolidation plan | 📚 Reference |
| [MIGRATION_GUIDE.md](database/MIGRATION_GUIDE.md) | Database migration guide | ✅ Current |

---

## 9. Archive Documentation

**Location:** `docs/archive/`

Historical documentation for completed features, migrations, and superseded plans. These documents are preserved for reference but are no longer actively maintained.

See [archive/README.md](archive/README.md) for a complete list of archived documents.

---

## Technology Stack

### Backend
- **Framework:** Spring Boot 3.2.0
- **Language:** Java 17
- **Database:** PostgreSQL 15.14
- **Cache:** Redis 7
- **Build:** Maven 3.9

### Frontend
- **Framework:** Flutter 3.x
- **Platforms:** Web, iOS, Android
- **State Management:** Provider/Riverpod

### Infrastructure
- **Containerization:** Docker & Docker Compose
- **Reverse Proxy:** Nginx
- **CI/CD:** Docker multi-stage builds

---

## Current Project Status

### Completed Features ✅
- ✅ **Candidate/Permanent Member System** - Fully implemented and deployed
- ✅ **Public Landing Page** - Live chain statistics at `/` with Dark Mystique theme
- ✅ **Public Stats Page** - Detailed chain metrics at `/stats`
- ✅ Hybrid Authentication (Email/Password + Device Fingerprint)
- ✅ Dark Mystique Design System (consistent across all pages)
- ✅ Complete REST API with versioning
- ✅ Docker containerization
- ✅ Flutter unified app architecture (formerly dual Public + Private, now consolidated)
- ✅ Database schema with migrations
- ✅ Redis caching layer
- ✅ QR code ticket generation
- ✅ Real-time notifications (WebSocket)

### In Progress 🔄
- 🔄 Mobile app deployment (iOS/Android)
- 🔄 Enhanced monitoring and analytics
- 🔄 Performance optimization

### Planned 📋
- 📋 Advanced analytics dashboard
- 📋 Multi-language support
- 📋 Enhanced gamification features

---

## Quick Reference

### For New Developers
1. Read [MASTER_SUMMARY.md](MASTER_SUMMARY.md)
2. Review [status/IMPLEMENTATION_STATUS.md](status/IMPLEMENTATION_STATUS.md)
3. Set up environment with [guides/FLUTTER_INSTALLATION.md](guides/FLUTTER_INSTALLATION.md)
4. Review [architecture/API_SPECIFICATION.md](architecture/API_SPECIFICATION.md)

### For Understanding the Core System
1. [features/CANDIDATE_PERMANENT_IMPLEMENTATION_PLAN.md](features/CANDIDATE_PERMANENT_IMPLEMENTATION_PLAN.md) - The main feature
2. [features/USER_FLOWS.md](features/USER_FLOWS.md) - How users interact
3. [architecture/DATABASE_SCHEMA.md](architecture/DATABASE_SCHEMA.md) - Data structure
4. [features/MVP_REQUIREMENTS.md](features/MVP_REQUIREMENTS.md) - What we built

### For Deployment
1. [deployment/DOCKER_README.md](deployment/DOCKER_README.md)
2. [status/DEPLOYMENT_STATUS.md](status/DEPLOYMENT_STATUS.md)
3. [deployment/MIGRATION_STRATEGY.md](deployment/MIGRATION_STRATEGY.md)

---

## Documentation Maintenance

### Update Frequency
- **status/** - Update after each development session
- **features/** - Update when features are completed or modified
- **architecture/** - Update when system design changes
- **MASTER_SUMMARY.md** - Update monthly or after major milestones

### Status Legend
| Symbol | Meaning |
|--------|---------|
| ✅ | Current and accurate |
| ⚠️ | Needs review or update |
| 📚 | Reference only (historical) |
| 🔄 | In progress |
| 📋 | Planned |

---

## Need Help?

- **Quick Overview:** [MASTER_SUMMARY.md](MASTER_SUMMARY.md)
- **Technical Status:** [status/IMPLEMENTATION_STATUS.md](status/IMPLEMENTATION_STATUS.md)
- **API Reference:** [architecture/API_SPECIFICATION.md](architecture/API_SPECIFICATION.md)
- **Deployment:** [status/DEPLOYMENT_STATUS.md](status/DEPLOYMENT_STATUS.md)
- **Main Feature:** [features/CANDIDATE_PERMANENT_IMPLEMENTATION_PLAN.md](features/CANDIDATE_PERMANENT_IMPLEMENTATION_PLAN.md)

---

**Maintained by:** Claude Code
**Project:** The Chain
**Repository:** ticketz
**Documentation Version:** 3.0 (Reorganized December 2025)
