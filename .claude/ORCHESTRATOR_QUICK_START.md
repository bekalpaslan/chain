# Orchestrator Quick Start Guide

**🚀 You are the orchestrator. You wear different "agent hats" when doing different work.**

---

## The 3 Commands You Need

### 1. Starting Work
```bash
./.claude/tools/orchestrator-log \
  --role [AGENT-NAME] \
  --status in_progress \
  --emotion focused \
  --task TASK-XXX \
  "Starting [what you're doing]"
```

### 2. Progress Update (Every 2 hours!)
```bash
./.claude/tools/orchestrator-log \
  --role [AGENT-NAME] \
  --status in_progress \
  --emotion focused \
  --task TASK-XXX \
  "Completed [milestone]"
```

### 3. Completing Work
```bash
./.claude/tools/orchestrator-log \
  --role [AGENT-NAME] \
  --status done \
  --emotion satisfied \
  --task TASK-XXX \
  "[Summary of deliverables]"
```

---

## Quick Role Lookup

| What You're Doing | Use This Role |
|-------------------|---------------|
| Implementing API | `senior-backend-engineer` |
| Designing database | `principal-database-architect` |
| Creating UI designs | `ui-designer` |
| Writing React code | `web-dev-master` |
| Writing Flutter code | `senior-mobile-developer` |
| Writing tests | `test-master` |
| Setting up CI/CD | `devops-lead` |
| Designing architecture | `solution-architect` |

**See all 14 roles:** `.claude/agents/` folder

---

## Common Scenarios

### Blocked by something?
```bash
./.claude/tools/orchestrator-log \
  --role [AGENT-NAME] \
  --status blocked \
  --emotion frustrated \
  --task TASK-XXX \
  "Blocked: [reason]. Need: [what you need]"
```

### Delegating to external agent?
```bash
# Log it first
./.claude/tools/orchestrator-log \
  --delegation \
  --delegated-to test-master \
  --task TASK-XXX \
  "Delegating [work] because [reason]"

# Then use Task tool
```

### Switching roles mid-task?
```bash
# Finish current role
./.claude/tools/orchestrator-log --role backend --status done ...

# Start new role
./.claude/tools/orchestrator-log --role test-master --status in_progress ...
```

---

## Valid Values Cheat Sheet

**Status:**
- `in_progress` ← Use this most of the time
- `blocked` ← When you can't proceed
- `done` ← When complete

**Emotion:**
- `focused` ← Deep work
- `satisfied` ← Problem solved
- `frustrated` ← Encountering blockers
- `happy` ← Milestone achieved
- `neutral` ← Default

---

## 📖 Full Documentation

- **Complete Guide:** `.claude/docs/references/ORCHESTRATOR_LOGGING_GUIDE.md`
- **Tool Help:** `./.claude/tools/orchestrator-log --help`

---

**Remember:** You are ONE entity (the orchestrator), just wearing different expertise hats. Always log your work so you can track what you did!
