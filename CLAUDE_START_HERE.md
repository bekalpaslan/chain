# 🚨 CLAUDE START HERE - Critical Project Context

## ⚡ READ THIS FIRST - 2 Critical Things to Know

### 1. ⚠️ PROJECT NAME CONFUSION WARNING
**CRITICAL: The folder name "ticketz" is MISLEADING!**
- **This is NOT a ticket/support system**
- **This IS "The Chain" - a viral social network**
- **"Tickets" are INVITATIONS to join the network (with QR codes)**

### 2. 📱 TWO DISTINCT APPS (Don't Mix Them!)
- **public-app** (port 3000): Public stats page, NO authentication
- **private-app** (port 3001): User dashboard, requires user login
- **Warning:** "private" means "authenticated users" only!

## 🏗️ Project Architecture Overview

### What This Project Actually Is
**"The Chain"** - A viral social experiment where users form a single linear chain through time-limited invitations:
- Each user gets ONE ticket (invitation) to give
- Tickets expire in 24 hours if unused
- Creates a single, unbroken chain of connections
- Real-time visualization of global growth

### Technology Stack
```yaml
Frontend:
  - Flutter (Dart) - Two separate apps
  - Riverpod for state management
  - GoRouter for navigation

Backend:
  - Spring Boot 3.2.0 (Java 17)
  - PostgreSQL + Redis
  - JWT authentication
  - WebSocket for real-time updates

Infrastructure:
  - Docker & Docker Compose
  - GitHub Actions CI/CD (planned)
```

## 🔴 Common Mistakes to Avoid

### ❌ DON'T ASSUME:
- This is a support/ticket system (IT'S NOT!)
- "Tickets" are help desk items (they're INVITATIONS)
- "private-app" is restricted access (it's for regular users)
- The folder name reflects the project (it doesn't)

### ✅ DO:
- Read actual source code before making assumptions
- Check multiple sources (code, docs, configs)
- Verify context from entity definitions

## 🎯 Quick Context Verification

Run these commands to understand the project:
```bash
# Check what kind of "tickets" these are
grep -r "invitationCode" backend/src/

# See the actual project name in code
grep -r "The Chain" backend/src/ frontend/

# Understand the chain concept
cat backend/src/main/java/com/thechain/entity/Ticket.java
```

## 🚀 Getting Started

### Quick Start with Docker
```bash
# Clone the repository
git clone https://github.com/your-username/ticketz.git
cd ticketz

# Copy environment configuration
cp .env.example .env
# Edit .env with secure passwords

# Start all services
docker-compose up -d

# Access the applications
# - Backend API: http://localhost:8080
# - Public App: http://localhost:3000
# - Private App: http://localhost:3001
```

## 🛠️ Development Workflow

### For Backend Changes (Spring Boot)
1. Make changes in `backend/src/`
2. Run tests: `cd backend && mvn test`
3. Rebuild: `docker-compose up --build backend`

### For Frontend Changes (Flutter)
1. Choose the right app (public/private)
2. Make changes in `frontend/{app-name}/`
3. Test: `cd frontend/{app-name} && flutter test`
4. Run: `flutter run -d chrome`

### For Database Changes
1. Create migration in `backend/src/main/resources/db/migration/`
2. Update entities in `backend/src/main/java/com/thechain/entity/`
3. Test with: `mvn test`

## 📊 Current Project Status

Check these for current state:
```bash
# Backend status
curl http://localhost:8080/api/v1/actuator/health

# View chain statistics
curl http://localhost:8080/api/v1/chain/stats

# Docker services
docker-compose ps

# Git status
git status
git log --oneline -10
```

## 💡 Key Project Concepts

### Business Terms
- **Chain**: The linear connection of all users
- **Ticket**: Time-limited invitation with QR code
- **Position**: User's number in the global chain
- **Parent/Child**: Who invited you / who you invited
- **Chain Key**: User's unique identifier

### Technical Architecture
- **Backend**: Spring Boot microservice with PostgreSQL
- **Frontend**: Two Flutter web applications
- **Authentication**: JWT tokens with refresh mechanism
- **Real-time**: WebSocket connections for live updates

## 🔍 How to Verify Project Context

**Before making ANY assumptions:**
1. Read at least 3 source files
2. Check entity definitions (`backend/src/main/java/com/thechain/entity/`)
3. Review API endpoints (`backend/src/main/java/com/thechain/controller/`)
4. Look at Flutter app names (`frontend/*/pubspec.yaml`)
5. Read main README.md

## 🎨 Available Agent Definitions

The `.claude/agents/` directory contains specialized agent definitions for different domains:
- `senior-backend-engineer.md` - Java/Spring Boot expertise
- `senior-mobile-developer.md` - Flutter/Dart expertise
- `devops-lead.md` - Infrastructure and deployment
- `ui-designer.md` - User interface design
- `test-master.md` - Testing strategies
- And more...

These can be used to get specialized expertise for specific tasks.

## 🔗 Quick Links

### Critical Documentation
- [Main README](README.md)
- [App Structure Warning](.claude/APP_STRUCTURE_WARNING.md)
- [Context Confusion Warning](.claude/CRITICAL_CONTEXT_WARNING.md)

### Project Documentation
- [Implementation Status](docs/IMPLEMENTATION_STATUS.md)
- [API Specification](docs/API_SPECIFICATION.md)
- [Database Schema](docs/DATABASE_SCHEMA.md)

## 📝 Summary

**Remember these key things:**
1. **This is "The Chain" social network, NOT a ticket system**
2. **There are 2 distinct apps - don't confuse them**
3. **The seed user (position 1) has admin privileges in private-app**
4. **Docker Compose is now configured for local development**

---

*Last Updated: 2025-10-21*
*Simplified to focus on essential project context*