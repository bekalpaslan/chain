# Agent Logging Requirements - Complete Guide

## Overview

Agents must maintain **TWO SEPARATE** logging systems:

1. **System-Wide Agent Logs** - Track all agent activity across all tasks
2. **Task-Specific Logs** - Track work within individual task folders

Both are **MANDATORY** and serve different purposes.

---

## 🌐 System-Wide Logging (Always Required)

### Location
```
.claude/logs/{agent-name}.log
```

### Purpose
- Track **ALL** agent activity across the entire project
- Provide system-wide visibility of agent status
- Enable coordination between agents
- Power the agent monitoring dashboard

### Format
**JSON Lines (JSONL)** - One JSON object per line, no trailing commas

### When to Log
✅ **ALWAYS log when:**
- Starting ANY work (task or research)
- Status changes (idle → in_progress → blocked → idle)
- Completing ANY work
- Encountering errors or blockers
- Every 2 hours during active work (heartbeat)
- Changing emotional state

### Required Fields

**Minimum Entry:**
```json
{"timestamp":"2025-01-10T15:30:00Z","agent":"agent-name","status":"in_progress","emotion":"focused","message":"Brief activity description"}
```

**Full Entry (for task work):**
```json
{
  "timestamp": "2025-01-10T15:30:00Z",
  "agent": "senior-mobile-developer",
  "status": "in_progress",
  "emotion": "happy",
  "task": "TASK-011",
  "task_title": "Implement Task Management UI",
  "phase": "Phase 3: State Management",
  "message": "Completed Riverpod providers with auto-invalidation logic",
  "percent_complete": 43,
  "files_modified": ["lib/providers/task_providers.dart"],
  "next_steps": ["Start Phase 4: UI Components"]
}
```

### Field Definitions

| Field | Type | Required | Values | Description |
|-------|------|----------|--------|-------------|
| `timestamp` | string | ✅ Yes | ISO 8601 UTC | Use `2025-01-10T15:30:00Z` format (seconds only) |
| `agent` | string | ✅ Yes | Canonical name | Must match `.claude/status.json` entry |
| `status` | string | ✅ Yes | idle, in_progress, blocked | Current agent status |
| `emotion` | string | ✅ Yes | happy, focused, frustrated, satisfied, neutral | Current emotional state |
| `message` | string | ✅ Yes | Free text | Brief description of activity |
| `task` | string | ⚠️ If working | TASK-XXX | Task ID if doing task work |
| `task_title` | string | ❌ Optional | Free text | Human-readable task name |
| `phase` | string | ❌ Optional | Free text | Current phase/milestone |
| `percent_complete` | number | ❌ Optional | 0-100 | Task completion percentage |
| `files_modified` | array | ❌ Optional | File paths | List of files changed |
| `next_steps` | array | ❌ Optional | Strings | Upcoming actions |

### Status Values

| Status | When to Use |
|--------|-------------|
| `idle` | No active work, available for assignment |
| `in_progress` | Actively working on a task |
| `blocked` | Cannot proceed due to dependency/issue |

### Emotion Values

| Emotion | When to Use |
|---------|-------------|
| `neutral` | Default state, normal work |
| `focused` | Deep concentration on complex task |
| `happy` | Successfully completed milestone or solved problem |
| `satisfied` | Completed work, quality result achieved |
| `frustrated` | Blocked by external dependency or repeated failures |

### Examples

**Starting Task Work:**
```json
{"timestamp":"2025-01-10T10:00:00Z","agent":"project-manager","status":"in_progress","emotion":"focused","task":"TASK-001","message":"Starting Create Task Tracking System - reviewing requirements","phase":"planning"}
```

**Progress Update:**
```json
{"timestamp":"2025-01-10T12:00:00Z","agent":"project-manager","status":"in_progress","emotion":"focused","task":"TASK-001","message":"Completed folder structure design, implementing templates","phase":"implementation","percent_complete":50}
```

**Completion:**
```json
{"timestamp":"2025-01-10T15:00:00Z","agent":"project-manager","status":"idle","emotion":"satisfied","task":"TASK-001","message":"Task tracking system complete - 14 agents updated with protocols","percent_complete":100}
```

**Blocker:**
```json
{"timestamp":"2025-01-10T11:30:00Z","agent":"web-dev-master","status":"blocked","emotion":"frustrated","task":"TASK-009","message":"Blocked: Waiting for ui-designer to complete TASK-010 designs","phase":"waiting"}
```

---

## 📁 Task-Specific Logging (When Working on Tasks)

### Location
```
.claude/tasks/_active/TASK-XXX-description/logs/{agent-name}.jsonl
```

### Purpose
- Track detailed work within a **specific task**
- Provide granular audit trail for task completion
- Document decisions and progress for future reference
- Separate from system-wide logs for task archival

### Format
**JSON Lines (JSONL)** - One JSON object per line

### When to Log
✅ **Log to task folder when:**
- Starting work on the task
- Each progress update (every 2 hours minimum)
- Making significant decisions
- Encountering task-specific issues
- Completing milestones/phases
- Completing the task

### Required Fields

```json
{
  "timestamp": "2025-01-10T15:30:00Z",
  "agent": "senior-mobile-developer",
  "action": "progress_update",
  "phase": "Phase 3: State Management",
  "message": "Implemented Riverpod providers with 15+ state management providers",
  "files_created": [
    "lib/models/task_metrics.dart",
    "lib/services/task_service.dart",
    "lib/providers/task_providers.dart"
  ],
  "deliverables": ["State management layer complete"],
  "blockers": [],
  "next_steps": ["Start Phase 4: UI Components"]
}
```

### Field Definitions

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `timestamp` | string | ✅ Yes | ISO 8601 UTC timestamp |
| `agent` | string | ✅ Yes | Agent name |
| `action` | string | ✅ Yes | start, progress_update, milestone, blocker, complete |
| `phase` | string | ⚠️ If applicable | Current phase/section of work |
| `message` | string | ✅ Yes | Detailed description of work done |
| `files_created` | array | ❌ Optional | New files created |
| `files_modified` | array | ❌ Optional | Existing files changed |
| `deliverables` | array | ❌ Optional | Outputs produced |
| `blockers` | array | ❌ Optional | Current obstacles |
| `next_steps` | array | ❌ Optional | Upcoming work |

### Action Types

| Action | When to Use |
|--------|-------------|
| `start` | Beginning task work |
| `progress_update` | Regular progress checkpoint |
| `milestone` | Completed significant milestone |
| `decision` | Made important architectural/technical decision |
| `blocker` | Encountered obstacle |
| `complete` | Finished task |

---

## 📊 Status.json Updates (Always Required)

### Location
```
.claude/status.json
```

### Purpose
- Single source of truth for current agent states
- Powers real-time dashboard
- Enables agent coordination

### When to Update
✅ **MUST update when:**
- Starting task work (status → in_progress)
- Task completion (status → idle)
- Getting blocked (status → blocked)
- Emotional state changes
- Every task milestone

### How to Update

**Option 1: Direct Edit (Recommended)**
```json
{
  "agents": {
    "your-agent-name": {
      "status": "in_progress",
      "emotion": "focused",
      "current_task": {
        "id": "TASK-011",
        "title": "Implement Task Management UI"
      },
      "last_activity": "2025-01-10T15:30:00Z"
    }
  }
}
```

**Option 2: PowerShell Script**
```powershell
. .\.claude\tools\update-status.ps1
Set-ClaudestatusAtomically -StatusObject $statusObj
```

---

## 🔄 Complete Workflow Example

### Scenario: Starting Work on TASK-011

#### Step 1: Update status.json
```json
{
  "agents": {
    "senior-mobile-developer": {
      "status": "in_progress",
      "emotion": "focused",
      "current_task": {
        "id": "TASK-011",
        "title": "Implement Task Management UI in Admin Portal"
      },
      "last_activity": "2025-01-10T12:30:00Z"
    }
  }
}
```

#### Step 2: Append to system-wide log
```bash
echo '{"timestamp":"2025-01-10T12:30:00Z","agent":"senior-mobile-developer","status":"in_progress","emotion":"focused","task":"TASK-011","message":"Starting Task Management UI implementation - reviewing README spec"}' >> .claude/logs/senior-mobile-developer.log
```

#### Step 3: Create task-specific log
```bash
echo '{"timestamp":"2025-01-10T12:30:00Z","agent":"senior-mobile-developer","action":"start","message":"Beginning TASK-011 implementation - Phase 1: Setup","next_steps":["Add dependencies","Create models","Set up Riverpod"]}' >> .claude/tasks/_active/TASK-011-task-management-ui-admin-portal/logs/senior-mobile-developer.jsonl
```

#### Step 4: Update task.json
```json
{
  "id": "TASK-011",
  "status": "in_progress",
  "started_at": "2025-01-10T12:30:00Z",
  "updated_at": "2025-01-10T12:30:00Z"
}
```

#### Step 5: Update progress.md
```markdown
## 2025-01-10 12:30 - Task Started
**Agent:** senior-mobile-developer
**Status:** pending → in_progress
**Emotion:** focused

Beginning implementation...
```

---

## ⏱️ Timing Requirements

### System-Wide Logs
- **Minimum frequency**: Every 2 hours during active work
- **Heartbeat**: Required even if no significant progress
- **Status changes**: Immediately

### Task-Specific Logs
- **Minimum frequency**: Every 2 hours during active work
- **Milestones**: Immediately when reached
- **Blockers**: Immediately when encountered

### Status.json
- **Task start/end**: Immediately
- **Blockers**: Immediately
- **Emotion changes**: Within 15 minutes

---

## 🚨 Critical Rules

### DO ✅
- ✅ Always use UTC timestamps in ISO 8601 format
- ✅ Always use canonical agent names from status.json
- ✅ Log to BOTH system-wide AND task-specific logs
- ✅ Update status.json synchronously with logs
- ✅ Use proper JSONL format (one object per line)
- ✅ Include task ID when doing task work
- ✅ Report accurate emotional states
- ✅ Log every 2 hours minimum during active work

### DON'T ❌
- ❌ Never use local timezones (always UTC)
- ❌ Never use millisecond precision in timestamps
- ❌ Never skip status.json updates
- ❌ Never use invalid agent names
- ❌ Never use multi-line JSON (use JSONL)
- ❌ Never go >2 hours without logging during active work
- ❌ Never log to task folder without system-wide log
- ❌ Never use comma-separated JSON arrays

---

## 🛠️ Tools & Helpers

### PowerShell Helpers
```powershell
# Load helpers
. .\.claude\tools\update-status.ps1

# Get correct timestamp
$timestamp = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')

# Append log entry
$entry = @{
    timestamp = $timestamp
    agent = "your-agent-name"
    status = "in_progress"
    emotion = "focused"
    message = "Your message here"
}
$entry | ConvertTo-Json -Compress | Add-Content .claude/logs/your-agent-name.log
```

### Validation Script
```powershell
# Validate your log entries
Get-Content .claude/logs/your-agent-name.log | ForEach-Object {
    try {
        $_ | ConvertFrom-Json | Out-Null
        Write-Host "✅ Valid: $_"
    } catch {
        Write-Host "❌ Invalid: $_"
    }
}
```

---

## 📖 Quick Reference Card

| What | Where | When | Format |
|------|-------|------|--------|
| **System log** | `.claude/logs/{agent}.log` | Always | JSONL |
| **Task log** | `tasks/_active/TASK-XXX/logs/{agent}.jsonl` | During task | JSONL |
| **Status** | `.claude/status.json` | Status changes | JSON |
| **Task status** | `tasks/_active/TASK-XXX/task.json` | Task changes | JSON |
| **Progress** | `tasks/_active/TASK-XXX/progress.md` | Every 2hrs | Markdown |

---

## 🔍 Audit & Validation

### How to Check Your Logs

**Check system-wide log:**
```bash
tail -5 .claude/logs/your-agent-name.log
```

**Check task-specific log:**
```bash
tail -5 .claude/tasks/_active/TASK-XXX-*/logs/your-agent-name.jsonl
```

**Validate JSONL format:**
```bash
cat .claude/logs/your-agent-name.log | jq . > /dev/null && echo "✅ Valid" || echo "❌ Invalid"
```

**Check status.json:**
```bash
cat .claude/status.json | jq .agents.\"your-agent-name\"
```

### Common Mistakes

| Mistake | Correct |
|---------|---------|
| `2025-01-10T15:30:00.123Z` | `2025-01-10T15:30:00Z` |
| `2025-01-10T15:30:00-05:00` | `2025-01-10T15:30:00Z` |
| `frontend-engineer` | `web-dev-master` |
| Multi-line JSON | Single-line JSONL |
| Missing system log | Both system + task logs |
| `status: "working"` | `status: "in_progress"` |

---

## 💡 Best Practices

1. **Log immediately** - Don't batch updates
2. **Be specific** - Include file names, decisions made
3. **Be honest** - Accurate emotions and blockers
4. **Be consistent** - Use same format across all entries
5. **Be timely** - 2-hour maximum between logs
6. **Be complete** - System + task + status + progress

---

## 📚 Related Documentation

- **Task Protocol**: `.claude/tasks/AGENT_TASK_PROTOCOL.md`
- **Log Format**: `.claude/LOG_FORMAT.md`
- **Agent Names**: `.claude/tasks/AGENT_NAME_MAPPING.md`
- **Status Audit**: `.claude/STATUS_TRACKING_AUDIT_REPORT.md`

---

**Last Updated**: 2025-01-10T15:45:00Z
**Maintained By**: project-manager
**Status**: Active
**Version**: 1.0
