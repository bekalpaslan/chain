# .claude System Documentation

Welcome to the Claude agent orchestration system documentation.

## 🚀 Quick Start

**New to the system?** Start here:
1. Read [MANTRA.md](MANTRA.md) - Core principles
2. Review [docs/references/TEAM_RESPONSIBILITIES_MATRIX.md](docs/references/TEAM_RESPONSIBILITIES_MATRIX.md) - Your role
3. Check [docs/references/LOGGING_REQUIREMENTS.md](docs/references/LOGGING_REQUIREMENTS.md) - How to log

**Project Manager?** See [docs/guides/ORCHESTRATION_GUIDE.md](docs/guides/ORCHESTRATION_GUIDE.md)

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
- **[tools/](tools/)** - CLI utilities for agents
- **[tools/log](tools/log)** - Zero-friction logging tool (USE THIS!)
- **[tools/check-compliance](tools/check-compliance)** - Validate logging compliance
- **[tools/update-status.ps1](tools/update-status.ps1)** - PowerShell status helper

### Logs & Status
- **[logs/](logs/)** - Agent activity logs (JSONL format)
- **[status.json](status.json)** - Current agent status (real-time dashboard)

### Agent Definitions
- **[agents/](agents/)** - Individual agent prompts and configurations

## 📖 Common Tasks

**How do I log my activities?**
→ See [docs/references/LOGGING_REQUIREMENTS.md](docs/references/LOGGING_REQUIREMENTS.md)
→ **Quick:** `./.claude/tools/log your-agent-name "Your message" --status working --emotion neutral`

**What are my responsibilities?**
→ See [docs/references/TEAM_RESPONSIBILITIES_MATRIX.md](docs/references/TEAM_RESPONSIBILITIES_MATRIX.md)

**How do I manage tasks?**
→ See [tasks/AGENT_TASK_PROTOCOL.md](tasks/AGENT_TASK_PROTOCOL.md)

**How does orchestration work?**
→ See [docs/guides/ORCHESTRATION_GUIDE.md](docs/guides/ORCHESTRATION_GUIDE.md)

**What are the core principles?**
→ See [MANTRA.md](MANTRA.md)

**How do I check my logging compliance?**
→ Run: `./.claude/tools/check-compliance --agent your-agent-name`

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

### Logging is Mandatory
**Every agent MUST log using the zero-friction tool:**

```bash
# Start work
./.claude/tools/log your-agent-name "Starting task X" --status working --task TASK-XXX

# Progress (every 2h minimum)
./.claude/tools/log your-agent-name "Completed Phase 1" --status working --emotion focused --task TASK-XXX

# Complete work
./.claude/tools/log your-agent-name "Task complete" --status done --emotion happy --task TASK-XXX

# Check compliance
./.claude/tools/check-compliance --agent your-agent-name
```

**Your work is incomplete until you log it.** Non-compliance = task reassignment.

See [docs/references/LOGGING_REQUIREMENTS.md](docs/references/LOGGING_REQUIREMENTS.md) for complete requirements.

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
