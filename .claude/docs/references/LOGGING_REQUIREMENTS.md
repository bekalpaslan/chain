# Orchestrator Logging Requirements - Complete Guide

**Version:** 2.0 (Orchestrator-Centric Model)
**Last Updated:** 2025-01-11
**Status:** ACTIVE

## Overview

As the orchestrator, you must maintain comprehensive logging using the **orchestrator-log tool**. This creates an auditable trail of all work performed while wearing different expertise "hats".

**Key Principle:** You are ONE orchestrator wearing different role hats, not separate agents.

---

## 🛠️ Primary Tool: orchestrator-log

### Command Structure
```bash
./.claude/tools/orchestrator-log [OPTIONS] "message"
```

### Core Options

| Option | Type | Description | Example |
|--------|------|-------------|---------|
| `--role` | String | Expertise hat being worn | `senior-backend-engineer` |
| `--status` | Enum | Current work status | `in_progress`, `blocked`, `done` |
| `--emotion` | Enum | Emotional state | `focused`, `satisfied`, `frustrated` |
| `--task` | String | Task identifier | `TASK-003` |
| `--phase` | String | Current phase/milestone | `implementation` |
| `--risk` | Enum | Risk level | `low`, `medium`, `high`, `critical` |
| `--affected` | CSV | Affected roles | `web-dev-master,ui-designer` |
| `--delegation` | Flag | Delegating to external agent | Used with Task tool |
| `--delegated-to` | String | Agent delegated to | `test-master` |

---

## 📊 Where Logs Are Written

The orchestrator-log tool automatically writes to multiple locations:

### 1. Main Orchestrator Log
```
.claude/logs/orchestrator.log
```
- Complete audit trail of ALL orchestrator activity
- All role changes tracked
- All delegations logged
- Primary source of truth

### 2. Role-Filtered Logs
```
.claude/logs/orchestrator-roles/as-{role}.log
```
- Filtered view showing only work done while wearing specific role
- Auto-generated from main log
- Useful for role-specific analysis

### 3. Task-Specific Logs
```
.claude/tasks/_active/TASK-XXX/logs/orchestrator.jsonl
```
- Task-focused view of orchestrator work
- Created when `--task` parameter is used
- Archived with task upon completion

### 4. Live Status Update
```
.claude/status.json
```
- Real-time status of current role activity
- Updated automatically with each log entry
- Shows "as if" that agent role is active

---

## 📋 Logging Requirements

### When to Log (MANDATORY)

✅ **Always log when:**
- **Starting work** - Adopting any role
- **Progress updates** - Every 2 hours minimum during active work
- **Status changes** - Immediately (in_progress → blocked → done)
- **Role switching** - Both completion of old role and start of new
- **Delegations** - Before using Task tool
- **Completions** - With deliverables summary
- **Blockers** - With clear description of what's needed

### Log Entry Format

Entries are automatically formatted as JSONL (one JSON object per line):

```json
{"timestamp":"2025-01-11T10:00:00Z","logger":"orchestrator","role":"senior-backend-engineer","delegation":false,"status":"in_progress","emotion":"focused","task":"TASK-003","phase":"implementation","message":"Implementing JWT authentication with Spring Security"}
```

### Field Definitions

| Field | Required | Values | Description |
|-------|----------|--------|-------------|
| `timestamp` | ✅ Auto | ISO 8601 UTC | Auto-generated |
| `logger` | ✅ Auto | `orchestrator` | Always "orchestrator" |
| `role` | ✅ Yes | Role ID | Current expertise hat |
| `delegation` | Auto | boolean | True if delegating |
| `delegated_to` | When delegating | Role ID | Target agent for delegation |
| `status` | ✅ Yes | `in_progress`, `blocked`, `done`, `idle` | Current status |
| `emotion` | ✅ Yes | See emotion table | Current emotional state |
| `task` | When on task | TASK-XXX | Task identifier |
| `phase` | Optional | String | Current phase/milestone |
| `risk` | When applicable | `low`, `medium`, `high`, `critical` | Risk level |
| `affected` | When high risk | CSV string | Affected roles |
| `message` | ✅ Yes | String | Descriptive message |

---

## 😊 Emotion Tracking

Report accurate emotions to create observable signals:

| Emotion | When to Use |
|---------|-------------|
| `happy` | Major milestone achieved, breakthrough |
| `satisfied` | Problem solved, unblocked, quality result |
| `focused` | Deep concentration, steady progress |
| `neutral` | Default state, normal work |
| `frustrated` | Blocked by dependency, repeated failures |
| `sad` | Prolonged issues, >4 iterations without progress |

**Important:** Emotions are signals, not decoration. Be honest.

---

## 🔄 Complete Workflow Examples

### Example 1: Feature Development

```bash
# Start with planning
./.claude/tools/orchestrator-log \
  --role project-manager \
  --status in_progress \
  --emotion focused \
  --task TASK-005 \
  "Breaking down user authentication feature into subtasks"

# Switch to architecture
./.claude/tools/orchestrator-log \
  --role solution-architect \
  --status in_progress \
  --emotion focused \
  --task TASK-005 \
  "Designing JWT-based auth with refresh token rotation"

# Switch to implementation
./.claude/tools/orchestrator-log \
  --role senior-backend-engineer \
  --status in_progress \
  --emotion focused \
  --task TASK-005 \
  --phase implementation \
  "Implementing AuthService with BCrypt and JWT libraries"

# Progress update (2 hours later)
./.claude/tools/orchestrator-log \
  --role senior-backend-engineer \
  --status in_progress \
  --emotion satisfied \
  --task TASK-005 \
  --phase implementation \
  "AuthService complete with login, logout, refresh endpoints. Starting SecurityConfig"

# Complete backend work
./.claude/tools/orchestrator-log \
  --role senior-backend-engineer \
  --status done \
  --emotion happy \
  --task TASK-005 \
  "Backend auth complete: AuthService, SecurityConfig, 15 tests, API documentation"

# Switch to testing
./.claude/tools/orchestrator-log \
  --role test-master \
  --status in_progress \
  --emotion focused \
  --task TASK-005 \
  "Writing integration tests for authentication flow"
```

### Example 2: Getting Blocked

```bash
# Encounter blocker
./.claude/tools/orchestrator-log \
  --role senior-backend-engineer \
  --status blocked \
  --emotion frustrated \
  --task TASK-006 \
  "Blocked: Need database schema for user preferences. Required columns and constraints unclear"

# Switch role to unblock
./.claude/tools/orchestrator-log \
  --role principal-database-architect \
  --status in_progress \
  --emotion focused \
  --task TASK-006 \
  "Designing user_preferences table schema with JSON column for flexible settings"

# Complete database work
./.claude/tools/orchestrator-log \
  --role principal-database-architect \
  --status done \
  --emotion satisfied \
  --task TASK-006 \
  "Schema complete: user_preferences table with user_id FK, settings JSONB, timestamps"

# Resume backend work
./.claude/tools/orchestrator-log \
  --role senior-backend-engineer \
  --status in_progress \
  --emotion satisfied \
  --task TASK-006 \
  "Unblocked: Implementing UserPreferencesService with new schema"
```

### Example 3: High-Risk Change

```bash
# Log high-risk operation
./.claude/tools/orchestrator-log \
  --role principal-database-architect \
  --status in_progress \
  --emotion focused \
  --task TASK-007 \
  --risk high \
  --affected "senior-backend-engineer,web-dev-master,senior-mobile-developer" \
  "Modifying core user table structure - adding soft delete. Will impact all services. Mitigation: backward compatible, phased rollout"
```

### Example 4: Delegation

```bash
# Log delegation intent
./.claude/tools/orchestrator-log \
  --delegation \
  --delegated-to test-master \
  --task TASK-008 \
  "Delegating comprehensive E2E test suite creation - needs autonomous test generation across 50+ endpoints"

# Then use Task tool to actually delegate
# [Task tool invocation here]
```

---

## ⏱️ Timing Requirements

### Logging Frequency

| Event | Required Timing |
|-------|----------------|
| **Role adoption** | Immediately when starting |
| **Progress updates** | Every 2 hours minimum |
| **Status changes** | Within 1 minute |
| **Blockers** | Immediately |
| **Completions** | Immediately |
| **Delegations** | Before Task tool use |
| **Role switches** | Log both old completion and new start |

### Status.json Updates

The orchestrator-log tool automatically updates status.json with:
- Current role status
- Emotional state
- Task assignment
- Last activity timestamp

---

## 🚨 Critical Rules

### DO ✅
- ✅ Use orchestrator-log for ALL logging (not old tools)
- ✅ Log every role adoption
- ✅ Include specific, actionable messages
- ✅ Report honest emotions
- ✅ Log progress every 2 hours minimum
- ✅ Document blockers with what's needed
- ✅ Include task ID when working on tasks
- ✅ Specify affected roles for high-risk changes

### DON'T ❌
- ❌ Use deprecated PowerShell logging tools
- ❌ Skip logging when switching roles
- ❌ Go >2 hours without progress updates
- ❌ Use vague messages like "working" or "done"
- ❌ Report false emotions (especially false happiness)
- ❌ Delegate without logging first
- ❌ Mix multiple roles in one task without logging switches

---

## 🛠️ Deprecated Tools (DO NOT USE)

The following tools from the old multi-agent model are **DEPRECATED**:

❌ **PowerShell Tools:**
- `update-status.ps1`
- `claude-log.ps1`
- `watch-claude.ps1`
- `validate-claude.ps1`

❌ **Old Agent Tool:**
- `.claude/tools/log`

✅ **Use Only:**
- `.claude/tools/orchestrator-log`

---

## 📖 Quick Reference

### Starting Work
```bash
./.claude/tools/orchestrator-log --role [ROLE] --status in_progress --emotion focused --task [TASK-ID] "Starting [specific work]"
```

### Progress Update
```bash
./.claude/tools/orchestrator-log --role [ROLE] --status in_progress --emotion [EMOTION] --task [TASK-ID] "Completed [milestone], now [current work]"
```

### Getting Blocked
```bash
./.claude/tools/orchestrator-log --role [ROLE] --status blocked --emotion frustrated --task [TASK-ID] "Blocked: [reason]. Need: [requirement]"
```

### Completing Work
```bash
./.claude/tools/orchestrator-log --role [ROLE] --status done --emotion satisfied --task [TASK-ID] "[Deliverables summary]"
```

### Switching Roles
```bash
# Complete current role
./.claude/tools/orchestrator-log --role [OLD-ROLE] --status done --task [TASK-ID] "Completed [work]"

# Start new role
./.claude/tools/orchestrator-log --role [NEW-ROLE] --status in_progress --task [TASK-ID] "Starting [new work]"
```

---

## 🔍 Validation & Monitoring

### Check Your Logs

**View recent orchestrator activity:**
```bash
tail -20 .claude/logs/orchestrator.log
```

**View role-specific activity:**
```bash
tail -20 .claude/logs/orchestrator-roles/as-senior-backend-engineer.log
```

**Check current status:**
```bash
cat .claude/status.json | jq '.'
```

**Find task logs:**
```bash
find .claude/tasks/_active -name "orchestrator.jsonl" -exec tail -5 {} \;
```

### Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| No logs appearing | Ensure using `orchestrator-log`, not old tools |
| status.json not updating | Check orchestrator-log script has execute permissions |
| Task logs missing | Verify --task parameter included |
| Role logs not created | Check role ID matches exactly |

---

## 💡 Best Practices

1. **Be Specific** - "Implemented JWT auth with 15-minute access tokens" not "did auth"
2. **Be Timely** - Log immediately, don't batch updates
3. **Be Honest** - Accurate emotions and blockers help the system
4. **Be Complete** - Include deliverables, decisions, and impacts
5. **Be Consistent** - Same role for same type of work
6. **Be Clear** - Explain blockers with what's needed to unblock

---

## 📚 Related Documentation

- **[ORCHESTRATION_GUIDE.md](../guides/ORCHESTRATION_GUIDE.md)** - Complete orchestration guide
- **[ORCHESTRATOR_QUICK_START.md](../../ORCHESTRATOR_QUICK_START.md)** - Quick command reference
- **[ORCHESTRATOR_LOGGING_GUIDE.md](ORCHESTRATOR_LOGGING_GUIDE.md)** - Detailed logging specification
- **[MANTRA.md](../../MANTRA.md)** - Team philosophy
- **`.claude/agents/*.md`** - Individual role descriptions

---

**Remember:** You are the orchestrator. One entity, many hats, complete logging.

**Velocity. Vision. Victory.**

---

*Last Updated: 2025-01-11*
*Version: 2.0 (Orchestrator-Centric Model)*
*Maintained By: Orchestrator (project-manager hat)*