# Orchestrator Logging Guide

**Version:** 2.0 (Orchestrator-Centric Model)
**Last Updated:** 2025-10-11
**Status:** ACTIVE

---

## 🎯 Philosophy: Single Entity, Multiple Hats

**Core Concept:** The orchestrator is the single entity performing all work. When working on different types of tasks, the orchestrator "wears different hats" (adopts different agent roles/expertise).

**You are always the orchestrator. The "role" is just which domain expertise you're applying.**

### Old Model ❌
```
Agent prompts: "You must log your activities"
                ↓
Agents forget to log
                ↓
Compliance checking
                ↓
Task reassignment
```

### New Model ✅
```
Orchestrator receives task
                ↓
Orchestrator: "I'm working as [agent-role]"
                ↓
Orchestrator logs with role context
                ↓
Work performed with agent's expertise
                ↓
Orchestrator logs completion
```

---

## 🛠️ The Tool: `orchestrator-log`

### Basic Syntax

```bash
./.claude/tools/orchestrator-log [OPTIONS] "message"
```

### Options

| Option | Type | Description | Example |
|--------|------|-------------|---------|
| `--role` | String | Agent role being adopted | `senior-backend-engineer` |
| `--delegation` | Flag | This is a delegation to external agent | - |
| `--delegated-to` | String | Agent name when delegating | `test-master` |
| `--status` | Enum | Current status | `in_progress` |
| `--emotion` | Enum | Current emotion | `focused` |
| `--task` | String | Task ID | `TASK-003` |
| `--phase` | String | Current phase/milestone | `implementation` |
| `--risk` | Enum | Risk level | `high` |
| `--affected` | CSV | Affected agents (comma-separated) | `web-dev,ui-designer` |

### Valid Values

**Status:**
- `idle` - No active work
- `in_progress` / `working` - Actively working
- `blocked` - Cannot proceed
- `done` - Work completed

**Emotion:**
- `happy` - Success, milestone achieved
- `satisfied` - Problem solved, unblocked
- `focused` - Deep concentration
- `neutral` - Normal state
- `frustrated` - Encountering problems
- `sad` - Prolonged issues

**Risk Levels:**
- `low` - Minimal impact
- `medium` - Some coordination needed
- `high` - Requires notification
- `critical` - Immediate escalation

---

## 📝 Usage Examples

### 1. Starting Work (Wearing a Role)

```bash
./.claude/tools/orchestrator-log \
  --role senior-backend-engineer \
  --status in_progress \
  --emotion focused \
  --task TASK-003 \
  "Starting JWT authentication service implementation"
```

**Creates entries in:**
- `.claude/logs/orchestrator.log`
- `.claude/logs/orchestrator-roles/as-senior-backend-engineer.log`
- `.claude/tasks/_active/TASK-003-*/logs/orchestrator.jsonl` (if task exists)

---

### 2. Progress Update

```bash
./.claude/tools/orchestrator-log \
  --role senior-backend-engineer \
  --status in_progress \
  --emotion focused \
  --task TASK-003 \
  --phase implementation \
  "AuthService complete, moving to SecurityConfig"
```

**Frequency:** Update every **2 hours minimum** during active work, or after completing milestones.

---

### 3. Getting Blocked

```bash
./.claude/tools/orchestrator-log \
  --role senior-backend-engineer \
  --status blocked \
  --emotion frustrated \
  --task TASK-003 \
  "Blocked: Need database schema definition from principal-database-architect"
```

**Important:** Document **why** you're blocked and **what you need** to unblock.

---

### 4. Completing Work

```bash
./.claude/tools/orchestrator-log \
  --role senior-backend-engineer \
  --status done \
  --emotion satisfied \
  --task TASK-003 \
  "JWT authentication complete: AuthService, SecurityConfig, 15 tests, API docs"
```

---

### 5. Delegating to External Agent

When you need to use the **Task tool** to delegate complex work:

```bash
# Step 1: Log the delegation
./.claude/tools/orchestrator-log \
  --delegation \
  --delegated-to test-master \
  --task TASK-004 \
  "Delegating comprehensive test suite creation to test-master agent"

# Step 2: Then use Task tool to actually delegate
```

**Creates entry in:**
- `.claude/logs/orchestrator.log`
- `.claude/logs/delegations.log`

---

### 6. Switching Roles Mid-Task

Sometimes you need to wear multiple hats for the same task:

```bash
# Finish backend work
./.claude/tools/orchestrator-log \
  --role senior-backend-engineer \
  --status done \
  --task TASK-003 \
  "Backend implementation complete"

# Switch to testing
./.claude/tools/orchestrator-log \
  --role test-master \
  --status in_progress \
  --task TASK-003 \
  "Now writing integration tests for JWT auth"
```

---

### 7. High-Risk Operations

When doing work that affects other agents:

```bash
./.claude/tools/orchestrator-log \
  --role principal-database-architect \
  --status in_progress \
  --emotion focused \
  --task TASK-007 \
  --risk high \
  --affected "senior-backend-engineer,web-dev-master" \
  "Modifying core database schema - impacts all API services"
```

---

## 🗂️ Role Selection Guide

| Task Type | Recommended Role |
|-----------|------------------|
| Implement API endpoint | `senior-backend-engineer` |
| Design database schema | `principal-database-architect` |
| Create UI mockups | `ui-designer` |
| Implement React component | `web-dev-master` |
| Implement Flutter widget | `senior-mobile-developer` |
| Write test suite | `test-master` |
| Setup CI/CD pipeline | `devops-lead` |
| Design system architecture | `solution-architect` |
| Manage project roadmap | `project-manager` |
| Analyze user motivation | `psychologist-game-dynamics` |
| Model pricing strategy | `game-theory-master` |
| Review licenses | `legal-software-advisor` |
| Find market opportunities | `opportunist-strategist` |
| Facilitate conflict | `scrum-master` |

**Tip:** Check `.claude/agents/[role].md` for detailed expertise of each role.

---

## 📊 What Gets Logged Where

### `.claude/logs/orchestrator.log`
- **All** orchestrator activity
- All role adoptions
- All delegations
- Complete audit trail

**Example entry:**
```json
{"timestamp":"2025-10-11T02:40:55Z","logger":"orchestrator","role":"senior-backend-engineer","delegation":false,"status":"in_progress","emotion":"focused","task":"TASK-003","message":"Starting JWT authentication implementation"}
```

### `.claude/logs/orchestrator-roles/as-{role}.log`
- Filtered view: **only** entries for that specific role
- Useful for role-specific analysis
- Auto-generated from main log

**Example:**
- `as-senior-backend-engineer.log` - All backend work
- `as-ui-designer.log` - All UI design work

### `.claude/logs/delegations.log`
- All Task tool invocations
- Delegation start and completion
- Results from delegated agents

**Example entry:**
```json
{"timestamp":"2025-10-11T02:40:59Z","logger":"orchestrator","role":null,"delegation":true,"delegated_to":"test-master","status":"in_progress","emotion":"neutral","task":"TASK-004","message":"Delegating comprehensive test suite creation"}
```

### `.claude/tasks/_active/TASK-XXX/logs/orchestrator.jsonl`
- Task-specific orchestrator log
- All roles active on that task
- Complete task work history

---

## ⏱️ Frequency Requirements

**Minimum logging frequency:**

| Event | When to Log |
|-------|-------------|
| **Starting work** | Always log when adopting a role |
| **During work** | Every 2 hours minimum |
| **Status changes** | Immediately (blocked → in_progress, etc.) |
| **Completing work** | Always log completion |
| **Delegation** | Log before using Task tool |
| **Role switching** | Log completion of previous role, start of new role |

---

## 🔄 Status.json Integration

Every orchestrator log with `--role` automatically updates `.claude/status.json`:

```json
{
  "agents": {
    "senior-backend-engineer": {
      "status": "in_progress",
      "emotion": "focused",
      "current_task": {"id": "TASK-003", "title": "JWT Authentication"},
      "last_activity": "2025-10-11T02:40:55Z"
    }
  }
}
```

**Note:** status.json shows "as if" that agent is working, but it's always the orchestrator wearing that role's hat.

---

## ✅ Compliance Checking

Before completing any task, verify logging compliance:

```bash
# Check orchestrator logging compliance (all roles)
./.claude/tools/check-orchestrator-compliance

# Check specific role compliance
./.claude/tools/check-orchestrator-compliance --role senior-backend-engineer

# Check task-specific compliance
./.claude/tools/check-orchestrator-compliance --task TASK-003
```

**Requirements:**
- ✅ Logged task start
- ✅ Progress updates every 2 hours
- ✅ Logged task completion
- ✅ All status changes logged
- ✅ Delegations logged before Task tool use

---

## 🎯 Best Practices

### DO ✅

1. **Log immediately when changing roles**
   ```bash
   ./.claude/tools/orchestrator-log --role ui-designer --status in_progress ...
   ```

2. **Include descriptive messages**
   ```bash
   # Good: "AuthService complete with BCrypt hashing, validation, and error handling"
   # Bad: "done"
   ```

3. **Use appropriate emotions**
   - `focused` when doing deep work
   - `satisfied` when unblocking or solving problems
   - `frustrated` when encountering blockers
   - `happy` when completing milestones

4. **Update status accurately**
   - `in_progress` while actively working
   - `blocked` only when truly cannot proceed
   - `done` only when complete

5. **Document blockers clearly**
   ```bash
   ./.claude/tools/orchestrator-log \
     --status blocked \
     --emotion frustrated \
     "Blocked: Waiting for API spec from frontend team. Need request/response DTOs."
   ```

### DON'T ❌

1. **Don't forget to log status changes**
   - Every transition must be logged

2. **Don't use vague messages**
   - Be specific about what you did/need

3. **Don't skip progress updates**
   - Log every 2 hours minimum

4. **Don't use wrong emotions**
   - `happy` only for real achievements
   - `frustrated` only when actually blocked

5. **Don't delegate without logging**
   - Always log before using Task tool

---

## 🚀 Quick Reference Card

### Starting work as a role
```bash
./.claude/tools/orchestrator-log \
  --role [ROLE] \
  --status in_progress \
  --emotion focused \
  --task [TASK-ID] \
  "[What you're starting]"
```

### Progress update
```bash
./.claude/tools/orchestrator-log \
  --role [ROLE] \
  --status in_progress \
  --emotion [EMOTION] \
  --task [TASK-ID] \
  "[What you completed / current milestone]"
```

### Getting blocked
```bash
./.claude/tools/orchestrator-log \
  --role [ROLE] \
  --status blocked \
  --emotion frustrated \
  --task [TASK-ID] \
  "Blocked: [Why] Need: [What]"
```

### Completing work
```bash
./.claude/tools/orchestrator-log \
  --role [ROLE] \
  --status done \
  --emotion satisfied \
  --task [TASK-ID] \
  "[Deliverables summary]"
```

### Delegating
```bash
./.claude/tools/orchestrator-log \
  --delegation \
  --delegated-to [AGENT] \
  --task [TASK-ID] \
  "[What you're delegating and why]"
```

---

## 📖 Benefits of Orchestrator-Centric Logging

✅ **Single source of truth**: All logs from orchestrator
✅ **No agent compliance issues**: No forgetting to log
✅ **Cleaner agent prompts**: No logging overhead
✅ **Better traceability**: Know exactly what orchestrator did
✅ **Flexible role switching**: Easy to see role transitions
✅ **Accurate status tracking**: status.json reflects actual work
✅ **Centralized audit trail**: One place for all activity
✅ **Simpler mental model**: You wear hats, you log. Simple.

---

## 🆘 Troubleshooting

### "Unknown Task" in status.json

**Problem:** status.json shows task ID but no title

**Solution:** The task title is fetched from `task.json`. Ensure:
1. Task folder exists in `.claude/tasks/_active/`
2. Task folder name starts with the task ID
3. `task.json` file exists and has valid JSON

### Logs not appearing in task folder

**Problem:** orchestrator.jsonl not created in task logs/

**Solution:** Ensure:
1. Task folder exists (not in _completed or _cancelled)
2. You're using exact task ID format (TASK-XXX)
3. Task folder has `/logs/` directory

### PowerShell script not running

**Problem:** update-status-for-role.ps1 not executing

**Solution:**
```bash
# On Windows, ensure execution policy allows:
powershell -ExecutionPolicy Bypass -File .claude/tools/update-status-for-role.ps1 ...
```

---

**For more information:**
- Agent prompts: `.claude/agents/[role].md`
- Task protocol: `.claude/tasks/ORCHESTRATOR_TASK_PROTOCOL.md`
- System overview: `.claude/README.md`
