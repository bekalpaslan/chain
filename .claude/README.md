# .claude System Documentation

## 🚨 STOP - READ THIS FIRST

### ⚡ **[CLAUDE_START_HERE.md](../CLAUDE_START_HERE.md)** ← **ABSOLUTE FIRST READ!**
**Critical project context and confusion prevention. Start here to avoid major mistakes.**

### ➤ **[WELCOME_ORCHESTRATOR.md](WELCOME_ORCHESTRATOR.md)** ← **THEN READ THIS**
**This file establishes your identity. You MUST read it to understand that you ARE the orchestrator, not a user of the system.**

---

## ⚡ After Reading WELCOME_ORCHESTRATOR.md

### 🎭 Quick Reminder: You Are The Orchestrator

**You are THE ORCHESTRATOR wearing different "agent hats" - not 14 separate agents.**

When working, you adopt expertise by wearing different hats:
- Backend work → Wear `senior-backend-engineer` hat
- UI design → Wear `ui-designer` hat
- Testing → Wear `test-master` hat

### 🚀 Initialize Your Session

**For new sessions, ALWAYS start with enforcement check:**
```bash
# REQUIRED: Start with hat enforcement
./.claude/tools/orchestrator-session-start
```
This ensures you select a hat before any work begins.

### 🛡️ Hat Enforcement System
**NEW: Automatic prevention of hatless work:**
- **Check current hat:** `./.claude/tools/check-current-hat`
- **Get suggestions:** `./.claude/tools/check-current-hat --suggest`
- **Enforce in scripts:** `./.claude/tools/check-current-hat --enforce`
- **Full protocol:** [HAT_ENFORCEMENT_PROTOCOL.md](docs/references/HAT_ENFORCEMENT_PROTOCOL.md)

### 📖 Essential Documents (In Order)

1. ✅ **[WELCOME_ORCHESTRATOR.md](WELCOME_ORCHESTRATOR.md)** - Your identity (READ FIRST!)
2. **[ORCHESTRATOR_QUICK_START.md](ORCHESTRATOR_QUICK_START.md)** - Quick command reference
3. **[MANTRA.md](MANTRA.md)** - Core principles
4. **[docs/references/ORCHESTRATOR_LOGGING_GUIDE.md](docs/references/ORCHESTRATOR_LOGGING_GUIDE.md)** - Complete logging guide

**Your Three Main Commands:**
```bash
# Starting work
./.claude/tools/orchestrator-log --role [AGENT-NAME] --status in_progress --emotion focused --task TASK-XXX "Starting [work]"

# Progress (every 2h!)
./.claude/tools/orchestrator-log --role [AGENT-NAME] --status in_progress --task TASK-XXX "Completed [milestone]"

# Completing
./.claude/tools/orchestrator-log --role [AGENT-NAME] --status done --emotion satisfied --task TASK-XXX "[Deliverables]"
```

**Available Roles:**
See `.claude/agents/` for all 14 agent roles and their expertise areas.

## 📚 Documentation Structure

### Core Documents (Root)
- **[MANTRA.md](MANTRA.md)** - Core operating principles and philosophy
- **[NEXT_ACTIONS_STRATEGIC_PLAN.md](NEXT_ACTIONS_STRATEGIC_PLAN.md)** - Current strategic roadmap
- **[DOCUMENTATION_REORGANIZATION_PLAN.md](DOCUMENTATION_REORGANIZATION_PLAN.md)** - Documentation structure plan

### Guides (`docs/guides/`)
Step-by-step workflows and how-to documents:
- **[ORCHESTRATION_GUIDE.md](docs/guides/ORCHESTRATION_GUIDE.md)** - Project Manager workflow and agent delegation

### References (`docs/references/`)
Authoritative specifications and quick references:
- **[LOGGING_REQUIREMENTS.md](docs/references/LOGGING_REQUIREMENTS.md)** - Complete logging specification
- **[TEAM_RESPONSIBILITIES_MATRIX.md](docs/references/TEAM_RESPONSIBILITIES_MATRIX.md)** - Agent roles and responsibilities

### Archives (`docs/archives/`)
Historical documents and audit reports:
- See [docs/archives/README.md](docs/archives/README.md) for index

## 🛠️ System Components

### Task Management
- **[tasks/](tasks/)** - Active and completed tasks
- **[tasks/AGENT_TASK_PROTOCOL.md](tasks/AGENT_TASK_PROTOCOL.md)** - Task management protocol

### Tools
- **[tools/](tools/)** - CLI utilities for orchestrator
- **[tools/orchestrator-log](tools/orchestrator-log)** - **PRIMARY LOGGING TOOL** (USE THIS!)
- **[tools/update-status-for-role.ps1](tools/update-status-for-role.ps1)** - Status updater (called automatically)
- **[tools/check-compliance](tools/check-compliance)** - Validate logging compliance (legacy)

**Deprecated Tools** (old agent-centric model):
- `tools/log` - Old agent logging (don't use)
- `tools/update-status.ps1` - Old status updater (don't use)

### Logs & Status
- **[logs/](logs/)** - Agent activity logs (JSONL format)
- **[status.json](status.json)** - Current agent status (real-time dashboard)

### Agent Definitions
- **[agents/](agents/)** - Individual agent prompts and configurations

## 📖 Common Tasks

**How do I log my work?**
→ See [ORCHESTRATOR_QUICK_START.md](ORCHESTRATOR_QUICK_START.md) - Quick reference
→ See [docs/references/ORCHESTRATOR_LOGGING_GUIDE.md](docs/references/ORCHESTRATOR_LOGGING_GUIDE.md) - Complete guide
→ **Quick:** `./.claude/tools/orchestrator-log --role [AGENT] --status in_progress --task TASK-XXX "message"`

**What roles can I wear?**
→ See [docs/references/TEAM_RESPONSIBILITIES_MATRIX.md](docs/references/TEAM_RESPONSIBILITIES_MATRIX.md)
→ See `.claude/agents/*.md` for individual role expertise

**How do I manage tasks?**
→ See [tasks/AGENT_TASK_PROTOCOL.md](tasks/AGENT_TASK_PROTOCOL.md) *(to be updated to ORCHESTRATOR_TASK_PROTOCOL.md)*

**What are the core principles?**
→ See [MANTRA.md](MANTRA.md) - Team philosophy
→ Remember: **You are ONE orchestrator wearing different hats**

## 🔍 Finding Information

**Use grep to search documentation:**
```bash
# Search all docs for a term
grep -r "your search term" .claude/docs/

# Search only active references
grep -r "your search term" .claude/docs/references/

# Search guides
grep -r "your search term" .claude/docs/guides/

# Find markdown files
find .claude -name "*.md" -type f
```

## 🚨 Critical Requirements

### Orchestrator Logging is Mandatory
**You MUST log all your work using the orchestrator-log tool:**

```bash
# Example: Starting backend work
./.claude/tools/orchestrator-log \
  --role senior-backend-engineer \
  --status in_progress \
  --emotion focused \
  --task TASK-003 \
  "Starting JWT authentication implementation"

# Example: Progress update
./.claude/tools/orchestrator-log \
  --role senior-backend-engineer \
  --status in_progress \
  --task TASK-003 \
  "AuthService complete, SecurityConfig in progress"

# Example: Completing work
./.claude/tools/orchestrator-log \
  --role senior-backend-engineer \
  --status done \
  --emotion satisfied \
  --task TASK-003 \
  "JWT auth complete: service, config, tests, docs"
```

**Key Points:**
- ✅ You are always the **orchestrator**
- ✅ Use `--role` to specify which expertise hat you're wearing
- ✅ Log every 2 hours minimum during active work
- ✅ Log all status changes immediately

**Full Guide:** [docs/references/ORCHESTRATOR_LOGGING_GUIDE.md](docs/references/ORCHESTRATOR_LOGGING_GUIDE.md)

## 📝 Documentation Standards

All documentation follows these standards:
- Use relative paths in cross-references (e.g., `docs/references/FILE.md`)
- Update README.md when adding new docs
- Archive superseded documents (don't delete)
- Date all audit reports and time-sensitive docs
- Use clear, descriptive filenames

## 🗂️ File Organization

**What goes where:**

| Location | Content Type | Examples |
|----------|--------------|----------|
| `.claude/` (root) | Core principles, navigation, strategic plans | README.md, MANTRA.md |
| `docs/guides/` | Step-by-step workflows | Orchestration guide |
| `docs/references/` | Authoritative specs | Logging requirements, role matrix |
| `docs/implementation/` | Technical implementation details | System design docs |
| `docs/archives/YYYY-MM/` | Historical/audit documents | Audit reports, superseded docs |

## 📊 System Health

**Check system status:**
```bash
# View current agent status
cat .claude/status.json | jq '.'

# Check logging compliance
./.claude/tools/check-compliance

# View recent logs
tail -20 .claude/logs/orchestrator.log

# Find active tasks
find .claude/tasks/_active -name "task.json"
```

## 🎯 Getting Help

**Questions about:**
- **Logging:** See [docs/references/LOGGING_REQUIREMENTS.md](docs/references/LOGGING_REQUIREMENTS.md)
- **Your Role:** See [docs/references/TEAM_RESPONSIBILITIES_MATRIX.md](docs/references/TEAM_RESPONSIBILITIES_MATRIX.md)
- **Tasks:** See [tasks/AGENT_TASK_PROTOCOL.md](tasks/AGENT_TASK_PROTOCOL.md)
- **Process:** See [docs/guides/ORCHESTRATION_GUIDE.md](docs/guides/ORCHESTRATION_GUIDE.md)
- **Philosophy:** See [MANTRA.md](MANTRA.md)

**Can't find something?** Use grep to search all documentation:
```bash
grep -r "keyword" .claude/docs/
```

---

**Last Updated:** 2025-10-10
**Documentation Structure:** v2.0 (Reorganized)
**Maintained By:** Project Manager & Scrum Master
