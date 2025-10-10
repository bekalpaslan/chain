# 🚨 MANDATORY LOGGING ENFORCEMENT RULES

## ⚠️ READ THIS FIRST - THIS IS NOT OPTIONAL

Every agent (including Claude Code orchestrator) **MUST** follow these logging rules. Non-compliance will result in:
- ❌ Work being rejected and discarded
- ❌ Task reassignment to compliant agents
- ❌ Blocking of future task assignments until compliance is demonstrated

---

## 🎯 The Three Non-Negotiable Requirements

### **Requirement 1: Log Every Status Change**

**BEFORE** you change your status from idle → working, working → blocked, or any other transition:

```bash
# Use the zero-friction logging tool
./.claude/tools/log your-agent-name "Starting work on X" --status working --emotion neutral --task TASK-XXX
```

**NO EXCEPTIONS.** If you don't log, the work doesn't count.

### **Requirement 2: Log Every 2 Hours During Active Work**

If you are `working` or `in_progress` for more than 2 hours, you **MUST** log progress updates:

```bash
# Every 2 hours minimum
./.claude/tools/log your-agent-name "Completed Phase 1, starting Phase 2" --status working --emotion focused --task TASK-XXX
```

**Why**: This creates an audit trail and prevents silent failures. If an agent goes silent for >2 hours, they are assumed blocked.

### **Requirement 3: Log Task Completion**

**BEFORE** you mark a task as complete, you **MUST** log the completion:

```bash
# When completing work
./.claude/tools/log your-agent-name "Completed all acceptance criteria" --status done --emotion happy --task TASK-XXX
```

Then update the task's `task.json` and move it to `_completed/`.

---

## 🛠️ How to Log (Zero Friction)

### **The Easy Way (Recommended)**

Use the bash wrapper script - it handles all complexity:

```bash
# Basic usage (defaults to status=working, emotion=neutral)
./.claude/tools/log ui-designer "Starting dashboard redesign"

# With full options
./.claude/tools/log ui-designer "Completed Phase 1" \
    --status working \
    --emotion happy \
    --task TASK-012 \
    --risk medium \
    --affected web-dev-master,senior-mobile-developer
```

**This automatically:**
- ✅ Generates UTC timestamp in correct format (seconds only)
- ✅ Appends to `.claude/logs/your-agent.log`
- ✅ Updates `.claude/status.json` atomically
- ✅ Validates JSON format
- ✅ Provides color-coded output

### **The Manual Way (Not Recommended)**

If you must use PowerShell directly:

```powershell
# Source the helper functions
. .\.claude\tools\update-status.ps1

# Get correct timestamp
. .\.claude\tools\Get-ClaudeTimestamp.ps1
$timestamp = Get-ClaudeTimestamp

# Create log entry
$entry = @{
    timestamp = $timestamp
    agent = "your-agent-name"
    status = "working"
    emotion = "neutral"
    message = "Your message here"
    task = "TASK-XXX"
}

# Append to log
Add-ClaudelogEntry -Agent "your-agent-name" -Entry $entry

# Update status.json
$status = Get-Content .claude/status.json | ConvertFrom-Json
$status.agents.'your-agent-name'.status = "working"
$status.agents.'your-agent-name'.last_activity = $timestamp
Set-ClaudestatusAtomically -StatusObject $status
```

**Why this is harder:**
- ❌ Must know PowerShell syntax
- ❌ Must manually generate timestamps
- ❌ Must handle atomic writes yourself
- ❌ More opportunity for mistakes

**Use the bash wrapper instead.**

---

## 📋 Required Fields

Every log entry **MUST** include:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `timestamp` | string | ✅ YES | UTC timestamp: `YYYY-MM-DDTHH:MM:SSZ` (seconds only) |
| `agent` | string | ✅ YES | Your canonical agent name (e.g., "ui-designer") |
| `status` | string | ✅ YES | One of: `idle`, `working`, `in_progress`, `blocked`, `done` |
| `emotion` | string | ✅ YES | One of: `happy`, `sad`, `frustrated`, `satisfied`, `neutral`, `focused` |
| `message` | string | ✅ YES | Human-readable description of what you're doing/completed |
| `task` | string | ⚠️ WHEN WORKING | Task ID (e.g., "TASK-012") - required if status is working/in_progress |
| `risk_level` | string | ⚠️ CONDITIONAL | One of: `low`, `medium`, `high`, `critical` - required if task affects others |
| `affected_agents` | array | ⚠️ CONDITIONAL | List of agent names - required if risk_level is high/critical |
| `mitigation` | string | ⚠️ CONDITIONAL | Required if risk_level is high/critical |

---

## 🎭 Emotion Guidelines

Use emotions **honestly** - they signal problems early:

| Emotion | When to Use | Example |
|---------|-------------|---------|
| `happy` | ✅ Milestone completion, breakthrough, successful deployment | "Successfully deployed feature X, all tests passing" |
| `focused` | 🔵 Deep work, making steady progress | "Implementing Phase 2, on track" |
| `neutral` | ⚪ Default state, routine work | "Starting analysis of requirements" |
| `satisfied` | ✅ Recovery from blocked/frustrated state | "Blocker resolved, resuming work" |
| `sad` | ⚠️ Task >4 iterations OR >4x estimated time | "Third attempt at fixing bug, still failing" |
| `frustrated` | 🚫 Blocked by another agent's inactivity/error | "Waiting 6 hours for backend API fix" |

**Critical Rule:** Never spam "happy" - only use it for real accomplishments. Overuse dilutes the signal.

---

## 🚦 Enforcement Mechanisms

### **1. Automated Compliance Checks**

Run this before committing:

```bash
./.claude/tools/check-compliance
```

This validates:
- ✅ All active agents have recent logs (<2h old)
- ✅ All log entries have required fields
- ✅ Timestamps use correct format
- ✅ Emotion values are from allowed list
- ✅ status.json is valid and in sync

**If this fails, you CANNOT commit.**

### **2. Watch Daemon Alerts**

The `watch-claude.ps1` daemon monitors for:
- 🚨 Agent status changes without corresponding log entries
- 🚨 High-risk tasks without affected_agents or mitigation
- 🚨 Agents silent for >2 hours while marked as "working"

**These trigger notifications in the dashboard.**

### **3. Human Review**

The project manager and scrum master will periodically review:
- 📊 Agent activity patterns
- 📊 Emotion trends (too much "happy" = suspicious, too much "sad" = need help)
- 📊 Logging gaps and inconsistencies

**Consistent non-compliance = task reassignment.**

---

## 🎯 Why This Matters

### **Without Logging:**
- ❌ No visibility into what agents are doing
- ❌ Blockers go unnoticed for hours/days
- ❌ No audit trail for decisions
- ❌ No early warning system for problems
- ❌ Dashboard shows stale/incorrect data

### **With Logging:**
- ✅ Real-time visibility into all agent activity
- ✅ Blockers trigger immediate attention
- ✅ Complete audit trail for debugging
- ✅ Emotion signals catch problems early
- ✅ Dashboard reflects actual state

**This is infrastructure, not bureaucracy.** It enables the multi-agent system to function properly.

---

## 📚 Quick Reference

### **Common Commands**

```bash
# Start work
./.claude/tools/log your-agent "Starting task X" --status working --task TASK-XXX

# Progress update
./.claude/tools/log your-agent "Completed Phase 1" --status working --emotion focused --task TASK-XXX

# Complete work
./.claude/tools/log your-agent "All acceptance criteria met" --status done --emotion happy --task TASK-XXX

# Get blocked
./.claude/tools/log your-agent "Blocked waiting for API" --status blocked --emotion frustrated --task TASK-XXX

# High-risk change
./.claude/tools/log your-agent "Schema migration starting" \
    --status working \
    --task TASK-XXX \
    --risk high \
    --affected web-dev-master,senior-mobile-developer

# Check compliance
./.claude/tools/check-compliance

# Check specific agent
./.claude/tools/check-compliance --agent ui-designer
```

### **File Locations**

- **Your log:** `.claude/logs/your-agent-name.log`
- **Global status:** `.claude/status.json`
- **Task log:** `.claude/tasks/_active/TASK-XXX/logs/your-agent-name.jsonl`
- **Tools:** `.claude/tools/`

---

## 🎓 For Claude Code Orchestrator

**You are not exempt from these rules.** When you:
- Start working on a user request
- Complete a task
- Delegate to agents
- Make high-risk changes

**You MUST log these activities:**

```bash
# Example: Claude Code starting work
./.claude/tools/log orchestrator "User requested private-app login fix" --status working --emotion focused

# Example: Claude Code completed work
./.claude/tools/log orchestrator "Fixed CSP issues, deployed container" --status done --emotion satisfied

# Example: Claude Code delegating
./.claude/tools/log orchestrator "Delegating UI work to ui-designer" --status working --emotion neutral
```

**Lead by example.** If the orchestrator doesn't log, agents won't either.

---

## ✅ Compliance Checklist

Before marking ANY task as complete, verify:

- [ ] Logged task start to `.claude/logs/your-agent.log`
- [ ] Updated `status.json` with current status
- [ ] Logged progress every 2 hours during work
- [ ] If task affects others, included `risk_level` and `affected_agents`
- [ ] Logged task completion with correct emotion
- [ ] Ran `./.claude/tools/check-compliance` successfully
- [ ] All timestamps use correct format (seconds only, UTC)
- [ ] All required fields present in log entries

**All 8 boxes checked? Good. Now you can mark the task complete.**

---

**Version:** 1.0
**Last Updated:** 2025-10-10
**Compliance Required By:** All agents, no exceptions
**Enforcement Level:** Mandatory
