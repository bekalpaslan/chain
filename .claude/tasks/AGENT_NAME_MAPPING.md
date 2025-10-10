# Agent Name Mapping Reference

## Purpose
This document establishes the canonical agent names to be used throughout the system for consistency between task assignments, status tracking, and agent instruction manuals.

## Critical Issue Discovered (2025-01-10)
During a status tracking audit, we discovered that task assignments used **different agent names** than the official agent roster in `.claude/status.json`, causing coordination failures where agents couldn't find their assigned tasks.

## Canonical Agent Names (Official Roster)

These are the **ONLY** valid agent names. All task assignments MUST use these exact names:

| Agent Name | Role | Status Tracked | Instruction Manual |
|------------|------|----------------|-------------------|
| `project-manager` | Project coordination, task assignment, sprint planning | ✅ Yes | `.claude/agents/project-manager.md` |
| `solution-architect` | System design, architecture decisions | ✅ Yes | `.claude/agents/solution-architect.md` |
| `senior-backend-engineer` | Backend development (Java/Spring Boot) | ✅ Yes | `.claude/agents/senior-backend-engineer.md` |
| `principal-database-architect` | Database design, optimization | ✅ Yes | `.claude/agents/principal-database-architect.md` |
| `test-master` | Testing strategy, QA, test coverage | ✅ Yes | `.claude/agents/test-master.md` |
| `devops-lead` | CI/CD, infrastructure, deployment | ✅ Yes | `.claude/agents/devops-lead.md` |
| `ui-designer` | UI/UX design, Figma prototypes | ✅ Yes | `.claude/agents/ui-designer.md` |
| `web-dev-master` | Frontend web development (React/Vue) | ✅ Yes | `.claude/agents/web-dev-master.md` |
| `senior-mobile-developer` | Mobile development (Flutter) | ✅ Yes | `.claude/agents/senior-mobile-developer.md` |
| `scrum-master` | Agile facilitation, process guardian | ✅ Yes | `.claude/agents/scrum-master.md` |
| `opportunist-strategist` | Market analysis, strategic opportunities | ✅ Yes | `.claude/agents/opportunist-strategist.md` |
| `psychologist-game-dynamics` | Gamification, user motivation | ✅ Yes | `.claude/agents/psychologist-game-dynamics.md` |
| `game-theory-master` | Strategic modeling, incentive design | ✅ Yes | `.claude/agents/game-theory-master.md` |
| `legal-software-advisor` | Legal compliance, licensing | ✅ Yes | `.claude/agents/legal-software-advisor.md` |

**Total Agents**: 14

## Invalid Names Found in Tasks (DO NOT USE)

During the audit, these **incorrect** agent names were found in task assignments:

| ❌ Invalid Name | ✅ Correct Name | Found In |
|----------------|----------------|----------|
| `frontend-engineer` | `web-dev-master` | TASK-002, TASK-006, TASK-008 |
| `backend-engineer` | `senior-backend-engineer` | TASK-005, TASK-007 |
| `devops-engineer` | `devops-lead` | TASK-003 |
| `qa-engineer` | `test-master` | TASK-004 |

## Task Assignment Rules

### When Creating New Tasks

1. **ALWAYS** use agent names from the "Canonical Agent Names" table above
2. **NEVER** invent new agent names or use abbreviations
3. **VERIFY** the agent name exists in `.claude/status.json` before assigning
4. If unsure which agent to assign, consult `project-manager`

### Task Assignment Template

```json
{
  "id": "TASK-XXX",
  "assigned_to": "senior-backend-engineer",  // ✅ Use exact canonical name
  ...
}
```

**Invalid Examples**:
```json
"assigned_to": "backend-engineer"     // ❌ Wrong - doesn't exist
"assigned_to": "Backend Engineer"     // ❌ Wrong - incorrect casing
"assigned_to": "senior-backend"       // ❌ Wrong - incomplete name
```

## Migration Plan for Existing Tasks

All tasks with invalid agent names should be updated:

### TASK-002, TASK-006, TASK-008
- **Current**: `"assigned_to": "frontend-engineer"`
- **Fix**: `"assigned_to": "web-dev-master"`
- **Reason**: Web development is handled by web-dev-master

### TASK-005, TASK-007
- **Current**: `"assigned_to": "backend-engineer"`
- **Fix**: `"assigned_to": "senior-backend-engineer"`
- **Reason**: Backend development is handled by senior-backend-engineer

### TASK-003
- **Current**: `"assigned_to": "devops-engineer"`
- **Fix**: `"assigned_to": "devops-lead"`
- **Reason**: DevOps work is handled by devops-lead

### TASK-004
- **Current**: `"assigned_to": "qa-engineer"`
- **Fix**: `"assigned_to": "test-master"`
- **Reason**: Testing is handled by test-master

## Validation Script

To validate agent names in task files:

```powershell
# Check all task.json files for invalid agent names
Get-ChildItem .claude/tasks/_active/*/task.json | ForEach-Object {
    $task = Get-Content $_ | ConvertFrom-Json
    $agent = $task.assigned_to

    $validAgents = @(
        "project-manager", "solution-architect", "senior-backend-engineer",
        "principal-database-architect", "test-master", "devops-lead",
        "ui-designer", "web-dev-master", "senior-mobile-developer",
        "scrum-master", "opportunist-strategist", "psychologist-game-dynamics",
        "game-theory-master", "legal-software-advisor"
    )

    if ($agent -notin $validAgents) {
        Write-Host "❌ INVALID: $($_.Directory.Name) assigned to '$agent'"
    } else {
        Write-Host "✅ VALID: $($_.Directory.Name) assigned to '$agent'"
    }
}
```

## Status Tracking Integration

The `.claude/status.json` file tracks agent activity. Each agent entry structure:

```json
{
  "agents": {
    "agent-name": {
      "status": "in_progress|idle|blocked",
      "emotion": "happy|focused|frustrated|satisfied|neutral",
      "current_task": {
        "id": "TASK-XXX",
        "title": "Task Title"
      },
      "last_activity": "2025-01-10T15:30:00Z"
    }
  }
}
```

**Important**: The `agent-name` key in status.json MUST match the `assigned_to` field in task.json files.

## Automated Enforcement

To prevent future mismatches, implement these safeguards:

1. **Task Creation Validation**: Reject tasks with invalid agent names
2. **Status Sync**: Automatically update status.json when task status changes
3. **Agent Discovery**: Agents query tasks by their canonical name
4. **CI/CD Check**: Validate agent names in all task files before commit

## Reference Files

- Agent roster: `.claude/status.json` (agents section)
- Agent manuals: `.claude/agents/*.md`
- Task specifications: `.claude/tasks/_active/*/task.json`
- Protocol: `.claude/tasks/AGENT_TASK_PROTOCOL.md`

## Change Log

- **2025-01-10**: Initial mapping document created after discovering 4 invalid agent names in 8 tasks
- **2025-01-10**: Corrected status.json to reflect 3 agents with in_progress tasks

---

**Last Updated**: 2025-01-10T15:30:00Z
**Maintained By**: project-manager
**Status**: Active
