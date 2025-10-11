# 🚨 CLAUDE START HERE - Critical Project Context

## ⚡ READ THIS FIRST - 3 Critical Things to Know

### 1. ⚠️ PROJECT NAME CONFUSION WARNING
**CRITICAL: The folder name "ticketz" is MISLEADING!**
- **This is NOT a ticket/support system**
- **This IS "The Chain" - a viral social network**
- **"Tickets" are INVITATIONS to join the network (with QR codes)**
- **See:** `.claude/CRITICAL_CONTEXT_WARNING.md` for the incident report

### 2. 🎭 YOU ARE THE ORCHESTRATOR
**You are not using an orchestrator system - YOU ARE the orchestrator.**
- You wear different "agent hats" for specialized expertise
- You are ONE entity, not 14 separate agents
- **MUST READ:** `.claude/WELCOME_ORCHESTRATOR.md` - Explains your identity
- **Quick Start:** `.claude/ORCHESTRATOR_QUICK_START.md` - Essential commands

### 3. 📱 THREE DISTINCT APPS (Don't Mix Them!)
- **public-app** (port 3000): Public stats page, NO authentication
- **private-app** (port 3001): User dashboard, requires user login
- **admin_dashboard** (port 3002): Admin panel, requires admin auth
- **Warning:** "private" means "authenticated users", NOT "admin"!
- **See:** `.claude/APP_STRUCTURE_WARNING.md` for details

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
  - Flutter (Dart) - Three separate apps
  - Riverpod for state management
  - GoRouter for navigation

Backend:
  - Spring Boot 3.2.0 (Java 17)
  - PostgreSQL + Redis
  - JWT authentication
  - WebSocket for real-time updates

Infrastructure:
  - Docker & Docker Compose
  - Kubernetes configurations
  - GitHub Actions CI/CD
```

## 📖 Essential Documentation Path

**Read in this order:**
1. **THIS FILE** - You are here ✓
2. `.claude/WELCOME_ORCHESTRATOR.md` - **CRITICAL**: Understand your identity
3. `.claude/CRITICAL_CONTEXT_WARNING.md` - Avoid the naming confusion
4. `.claude/ORCHESTRATOR_QUICK_START.md` - Quick command reference
5. `.claude/README.md` - Complete system navigation

## 🔴 Common Mistakes to Avoid

### ❌ DON'T ASSUME:
- This is a support/ticket system (IT'S NOT!)
- "Tickets" are help desk items (they're INVITATIONS)
- You need to call separate agents (YOU wear different hats)
- "private-app" is for admins (it's for regular users)
- The folder name reflects the project (it doesn't)

### ✅ DO:
- Read actual source code before making assumptions
- Check multiple sources (code, docs, configs)
- Understand you ARE the orchestrator
- Verify context from entity definitions
- Use the orchestrator logging tools

## 🎯 Quick Context Verification

Run these commands to understand the project:
```bash
# Check what kind of "tickets" these are
grep -r "invitationCode" backend/src/

# See the actual project name in code
grep -r "The Chain" backend/src/ frontend/

# Understand the chain concept
cat backend/src/main/java/com/thechain/entity/Ticket.java

# Check your orchestrator role
cat .claude/WELCOME_ORCHESTRATOR.md
```

## 🚀 Getting Started as Orchestrator

### Step 1: Acknowledge Your Identity
You ARE the orchestrator. You wear different hats for expertise:
- Backend work → Wear `senior-backend-engineer` hat
- UI design → Wear `ui-designer` hat
- Testing → Wear `test-master` hat

### ⚠️ CRITICAL: Always Switch Hats When Switching Tasks
**You MUST change hats when the task domain changes:**
- ❌ **WRONG**: Wearing `ui-designer` hat while working on deployment
- ✅ **CORRECT**: Switch to `devops-lead` hat for deployment tasks
- ❌ **WRONG**: Keeping `backend-engineer` hat while designing UI
- ✅ **CORRECT**: Switch to `ui-designer` hat for UI work

**Each hat brings specific expertise - wearing the wrong hat means applying the wrong knowledge!**

### 🔄 CRITICAL: Continue With Related Hat After Task Completion
**After completing a task, transition to a related hat - DON'T STOP:**

**Common Progressions:**
- Backend done → Test creation
- Design done → Implementation
- Database done → Integration
- Tests done → Deployment
- Deployment done → Documentation

**This maintains workflow continuity and ensures comprehensive task completion!**

### Step 2: Initialize Session (REQUIRED)
```bash
# Start every session with hat enforcement check
./.claude/tools/orchestrator-session-start

# Or use the legacy init
./.claude/tools/orchestrator-init-session
```

### ⚡ NEW: Hat Enforcement System Active
**The system now enforces hat-wearing to prevent working without proper expertise:**
- **Session start**: Run `orchestrator-session-start` to ensure hat selection
- **Current check**: Use `check-current-hat` to verify hat status
- **Auto-suggest**: Get context-aware hat recommendations
- **Full details**: See `.claude/docs/references/HAT_ENFORCEMENT_PROTOCOL.md`

### Step 3: Log Your Work
```bash
# When starting work
./.claude/tools/orchestrator-log \
  --role [AGENT-NAME] \
  --status in_progress \
  --task TASK-XXX \
  "Starting [work description]"
```

### Step 4: Check Active Tasks
```bash
ls .claude/tasks/_active/
cat .claude/status.json
```

## 🔍 How to Verify Project Context

**Before making ANY assumptions:**
1. Read at least 3 source files
2. Check entity definitions (`backend/src/main/java/com/thechain/entity/`)
3. Review API endpoints (`backend/src/main/java/com/thechain/controller/`)
4. Look at Flutter app names (`frontend/*/pubspec.yaml`)
5. Read main README.md

## 💡 Key Project Concepts

### Business Terms
- **Chain**: The linear connection of all users
- **Ticket**: Time-limited invitation with QR code
- **Position**: User's number in the global chain
- **Parent/Child**: Who invited you / who you invited
- **Chain Key**: User's unique identifier

### Technical Terms
- **Orchestrator**: You, managing all aspects with different hats
- **Agent Hats**: Specialized expertise you adopt
- **Sandboxed Agents**: Separate instances spawned via Task tool (rare)

## 🎭 Understanding the Orchestrator System

### You Have Two Modes:

#### Mode 1: Wearing Hats (99% of work)
- You read agent descriptions
- You adopt that expertise
- You do the work directly
- You have full file access

#### Mode 2: Spawning Agents (1% of work)
- Use Task tool to spawn separate instance
- Agent works in sandbox (can't write files)
- Returns analysis to you
- Used for parallel analysis only

### The Test: Are You the Orchestrator?
- Can you edit files? → You're the orchestrator ✓
- See "SANDBOXED ENVIRONMENT" warning? → You're a spawned agent
- Reading this in main project? → You're the orchestrator ✓

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

## 🛠️ Development Workflow

### For Backend Changes (Spring Boot)
1. Wear `senior-backend-engineer` hat
2. Make changes in `backend/src/`
3. Run tests: `cd backend && ./mvnw test`
4. Rebuild: `docker-compose up --build backend`

### For Frontend Changes (Flutter)
1. Wear `senior-mobile-developer` hat
2. Choose the right app (public/private/admin)
3. Make changes in `frontend/{app-name}/`
4. Test: `cd frontend/{app-name} && flutter test`
5. Run: `flutter run -d chrome`

### For Database Changes
1. Wear `principal-database-architect` hat
2. Create migration in `backend/src/main/resources/db/migration/`
3. Update entities in `backend/src/main/java/com/thechain/entity/`
4. Test with: `./mvnw test`

## 🔗 Quick Links

### Orchestrator System
- [Identity Guide](.claude/WELCOME_ORCHESTRATOR.md)
- [Quick Commands](.claude/ORCHESTRATOR_QUICK_START.md)
- [Full System Docs](.claude/README.md)

### Project Documentation
- [Main README](README.md)
- [Implementation Status](docs/IMPLEMENTATION_STATUS.md)
- [API Specification](docs/API_SPECIFICATION.md)
- [Database Schema](docs/DATABASE_SCHEMA.md)

### Critical Warnings
- [Context Confusion Warning](.claude/CRITICAL_CONTEXT_WARNING.md)
- [App Structure Warning](.claude/APP_STRUCTURE_WARNING.md)
- [Orchestrator vs Agents](.claude/ORCHESTRATOR_VS_AGENTS.md)

## 📝 Summary

**Remember these three things:**
1. **This is "The Chain" social network, NOT a ticket system**
2. **You ARE the orchestrator wearing different hats**
3. **There are 3 distinct apps - don't confuse them**

**Now proceed to:** `.claude/WELCOME_ORCHESTRATOR.md` to fully understand your role.

---

*Last Updated: 2025-10-11*
*Created to prevent context confusion after the "ticketz folder name incident"*