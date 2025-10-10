# Task Management System Specification v2.0

## Overview
Each task gets its own dedicated folder containing all related artifacts, progress logs, and deliverables. This provides complete traceability and makes collaboration between agents seamless.

## Folder Structure

```
.claude/tasks/
├── TASK_SYSTEM_SPECIFICATION.md  # This file
├── _templates/                     # Task templates
│   ├── task.json                  # Task metadata template
│   ├── progress.md                # Progress log template
│   ├── README.md                  # Task README template
│   └── deliverables/              # Deliverables folder template
├── _active/                        # Currently active tasks
│   ├── TASK-001-create-task-system/
│   │   ├── task.json              # Task metadata (status, priority, etc.)
│   │   ├── README.md              # Task description and context
│   │   ├── progress.md            # Progress log (agent updates)
│   │   ├── deliverables/          # Task outputs
│   │   │   ├── code/              # Code files
│   │   │   ├── docs/              # Documentation
│   │   │   └── tests/             # Test files
│   │   ├── artifacts/             # Design files, diagrams, etc.
│   │   └── logs/                  # Agent activity logs
│   │       └── agent-name.jsonl   # Per-agent log
│   └── TASK-002-frontend-kickoff/
│       └── ...
├── _completed/                     # Completed tasks (by month)
│   ├── 2025-01/
│   │   └── TASK-XXX-description/
│   └── 2025-02/
├── _blocked/                       # Blocked tasks
│   └── TASK-XXX-description/
└── _cancelled/                     # Cancelled tasks
    └── TASK-XXX-description/
```

## Task Folder Naming Convention

Format: `TASK-{ID}-{slug}`

- **ID**: Zero-padded 3-digit number (001, 002, etc.)
- **slug**: Kebab-case description (max 50 chars)

Examples:
- `TASK-001-create-task-system`
- `TASK-002-frontend-kickoff`
- `TASK-042-implement-jwt-refresh`

## Required Files in Each Task Folder

### 1. task.json (Metadata)
```json
{
  "id": "TASK-001",
  "title": "Create Task Tracking System",
  "description": "Establish formal task management with folder structure",
  "type": "infrastructure",
  "status": "in_progress",
  "priority": "CRITICAL",
  "assigned_to": "project-manager",
  "created_at": "2025-01-10T10:00:00Z",
  "updated_at": "2025-01-10T15:30:00Z",
  "started_at": "2025-01-10T10:30:00Z",
  "completed_at": null,
  "due_date": "2025-01-10T18:00:00Z",
  "story_points": 3,
  "tags": ["infrastructure", "project-management"],
  "dependencies": {
    "depends_on": [],
    "blocks": ["TASK-002", "TASK-003"]
  },
  "acceptance_criteria": [
    "Task folders created with standard structure",
    "Templates available for new tasks",
    "Agent guidelines updated",
    "Migration completed"
  ],
  "sprint": "SPRINT-2025-01"
}
```

### 2. README.md (Description & Context)
```markdown
# TASK-001: Create Task Tracking System

## Overview
Brief description of what this task accomplishes.

## Context
Why this task is needed, background information.

## Technical Approach
How this will be implemented.

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

## Dependencies
- Depends on: None
- Blocks: TASK-002, TASK-003

## Resources
- Related docs: [Link]
- Reference tickets: [Link]
```

### 3. progress.md (Progress Log)
```markdown
# Progress Log

## 2025-01-10 10:30 - Task Started
**Agent:** project-manager
**Status:** pending → in_progress

Starting implementation of task folder structure.

## 2025-01-10 12:00 - Milestone Reached
**Agent:** project-manager
**Status:** in_progress

- ✅ Created folder structure
- ✅ Designed templates
- 🔄 Working on agent guidelines

## 2025-01-10 15:30 - Task Completed
**Agent:** project-manager
**Status:** in_progress → completed

All acceptance criteria met. Task complete.

**Deliverables:**
- Task folder structure
- Templates in _templates/
- Updated agent guidelines
```

### 4. deliverables/ (Task Outputs)
Organized by type:
- `code/` - Source code files
- `docs/` - Documentation
- `tests/` - Test files
- `config/` - Configuration files

### 5. artifacts/ (Supporting Files)
- Design mockups
- Diagrams (Mermaid, PlantUML)
- Screenshots
- API specs

### 6. logs/ (Agent Activity Logs)
Per-agent JSONL logs:
```jsonl
{"timestamp":"2025-01-10T10:30:00Z","agent":"project-manager","level":"info","emotion":"focused","action":"task_started","message":"Beginning task implementation"}
{"timestamp":"2025-01-10T12:00:00Z","agent":"project-manager","level":"info","emotion":"satisfied","action":"milestone_reached","message":"Folder structure created"}
```

## Task Lifecycle

### 1. Task Creation
```bash
# Project manager creates new task
1. Create folder: .claude/tasks/_active/TASK-XXX-description/
2. Copy templates from _templates/
3. Fill in task.json with metadata
4. Write README.md with description
5. Initialize progress.md with creation log
```

### 2. Task Assignment
```bash
# Task assigned to agent
1. Agent receives task ID
2. Agent reads .claude/tasks/_active/TASK-XXX/README.md
3. Agent reviews acceptance criteria
4. Agent logs start in progress.md
```

### 3. Task Execution
```bash
# Agent works on task
1. Agent updates progress.md regularly
2. Agent creates deliverables in deliverables/
3. Agent logs activity in logs/agent-name.jsonl
4. Agent updates task.json status
```

### 4. Task Completion
```bash
# Agent completes task
1. Agent marks all acceptance criteria ✅
2. Agent updates progress.md with completion log
3. Agent updates task.json: status="completed", completed_at={timestamp}
4. Agent creates completion summary
5. Move folder to _completed/YYYY-MM/
```

### 5. Task Blocking
```bash
# Task becomes blocked
1. Agent updates task.json: status="blocked"
2. Agent adds blocking reason to progress.md
3. Move folder to _blocked/
4. Alert project manager
```

## Agent Responsibilities

### All Agents MUST:

1. **Check for assigned tasks daily**
   ```bash
   # Find tasks assigned to you
   find .claude/tasks/_active -name "task.json" -exec grep -l "assigned_to.*your-name" {} \;
   ```

2. **Update progress.md whenever working**
   - Minimum: Start of work session
   - After each significant milestone
   - End of work session
   - On completion or blocking

3. **Log activity in logs/agent-name.jsonl**
   ```powershell
   $entry = @{
     timestamp = (Get-Date -Format 'o')
     agent = 'agent-name'
     level = 'info'
     emotion = 'focused'
     action = 'action_type'
     message = 'What you did'
   } | ConvertTo-Json -Compress
   $entry | Out-File -Append -Encoding utf8 'logs/agent-name.jsonl'
   ```

4. **Keep task.json updated**
   - Update `updated_at` timestamp
   - Update `status` when it changes
   - Mark `completed_at` when done

5. **Organize deliverables properly**
   - Code → `deliverables/code/`
   - Docs → `deliverables/docs/`
   - Tests → `deliverables/tests/`

## Task States

- **pending**: Created but not started
- **in_progress**: Actively being worked on
- **review**: Awaiting review/approval
- **blocked**: Cannot proceed (external dependency)
- **completed**: Successfully finished
- **cancelled**: No longer needed

## Task Priorities

- **CRITICAL**: Blocks other work, must be done immediately
- **HIGH**: Should be completed this sprint
- **MEDIUM**: Important but not urgent
- **LOW**: Nice to have, can be deferred

## Task Types

- **feature**: New functionality
- **bug**: Bug fix
- **infrastructure**: System/tooling improvements
- **testing**: Test creation/improvement
- **documentation**: Documentation work
- **devops**: Deployment/CI/CD
- **refactor**: Code refactoring
- **research**: Investigation/spike

## Sprint Integration

Tasks are organized into sprints:
```json
{
  "sprint": "SPRINT-2025-01",
  "sprint_name": "Foundation & Setup",
  "sprint_start": "2025-01-10",
  "sprint_end": "2025-01-24"
}
```

## Queries & Reports

### Find all active tasks
```bash
ls .claude/tasks/_active/
```

### Find tasks by agent
```bash
find .claude/tasks/_active -name "task.json" -exec grep -l "assigned_to.*backend-engineer" {} \;
```

### Find tasks by status
```bash
find .claude/tasks/_active -name "task.json" -exec grep -l "status.*in_progress" {} \;
```

### Get task summary
```bash
cat .claude/tasks/_active/TASK-001-task-name/task.json | jq '{id, title, status, assigned_to, priority}'
```

## Migration from Old System

1. For each task in `active-tasks.jsonl`:
   - Create task folder with proper naming
   - Copy JSON to `task.json`
   - Create `README.md` from description
   - Initialize `progress.md`
   - Create empty deliverables structure

2. Existing markdown tasks (FE-001, UI-001):
   - Rename to standard format
   - Extract metadata to `task.json`
   - Move content to `README.md`
   - Create progress log

## Automation & Tooling

### Create New Task (Shell Function)
```bash
create_task() {
  ID=$1
  SLUG=$2
  cp -r .claude/tasks/_templates ".claude/tasks/_active/TASK-${ID}-${SLUG}"
  # Edit task.json with ID and slug
}
```

### Move Task (On Status Change)
```bash
move_task() {
  TASK_DIR=$1
  NEW_STATUS=$2
  case $NEW_STATUS in
    completed) mv "$TASK_DIR" ".claude/tasks/_completed/$(date +%Y-%m)/" ;;
    blocked) mv "$TASK_DIR" ".claude/tasks/_blocked/" ;;
    cancelled) mv "$TASK_DIR" ".claude/tasks/_cancelled/" ;;
  esac
}
```

## Best Practices

1. **Atomic Updates**: Update progress.md after each significant action
2. **Clear Logging**: Write descriptive progress entries
3. **Organize Deliverables**: Keep code, docs, tests separate
4. **Link Related Tasks**: Reference other tasks in README.md
5. **Regular Status Updates**: Update task.json at least daily
6. **Complete Acceptance Criteria**: Check off items as they're done
7. **Clean Artifacts**: Remove temporary/unused files before completion

## Support & Troubleshooting

- **Task System Owner**: Project Manager Agent
- **Technical Issues**: DevOps Engineer Agent
- **Process Questions**: Scrum Master Agent

---

**Version:** 2.0.0
**Last Updated:** 2025-01-10
**Status:** Active
