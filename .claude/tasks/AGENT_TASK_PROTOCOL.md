# Agent Task Management Protocol

**Version:** 2.0
**Effective Date:** 2025-01-10
**Status:** MANDATORY - All agents must follow this protocol

---

## Purpose

This document defines the mandatory protocols all agents must follow when working with tasks. Consistent task management ensures transparency, traceability, and effective collaboration across the development team.

## Core Principles

1. **Every task gets its own folder** - No loose files
2. **Always update progress** - Document what you're doing
3. **Keep status current** - Update task.json in real-time
4. **Log your work** - Create audit trail in logs/
5. **Organize deliverables** - Keep outputs structured

## Task Folder Structure

Every task must follow this structure:

```
.claude/tasks/_active/TASK-XXX-description/
├── task.json              # Task metadata (MUST be kept current)
├── README.md              # Task description and context
├── progress.md            # Progress log (update frequently)
├── deliverables/          # All task outputs go here
│   ├── code/             # Source code files
│   ├── docs/             # Documentation
│   ├── tests/            # Test files
│   └── config/           # Configuration files
├── artifacts/             # Supporting files
│   ├── designs/          # Design mockups
│   ├── diagrams/         # Architecture diagrams
│   └── screenshots/      # Visual references
└── logs/                  # Agent activity logs
    └── agent-name.jsonl  # Your personal log for this task
```

## Mandatory Agent Responsibilities

### 1. Task Discovery (Daily)

**WHEN:** At the start of each work day or session

**ACTION:**
```bash
# Find all tasks assigned to you
cd .claude/tasks/_active
ls -d */ | while read dir; do
  if grep -q "\"assigned_to\":\"your-agent-name\"" "$dir/task.json"; then
    echo "Found task: $dir"
  fi
done
```

**REQUIREMENT:** All agents must check for assigned tasks at least once per day.

### 2. Task Start (Required)

**WHEN:** Before beginning work on a task

**ACTIONS:**
1. Navigate to task folder
2. Read README.md completely
3. Review acceptance criteria in task.json
4. Update task.json status to "in_progress"
5. Add start entry to progress.md
6. Create your agent log file in logs/

**Example progress.md entry:**
```markdown
## 2025-01-10 09:15 - Task Started
**Agent:** backend-engineer
**Status:** pending → in_progress
**Emotion:** focused

### Initial Assessment
- Reviewed requirements in README.md
- Identified 3 main components to implement
- Estimated 5 hours of work

### Approach
1. Create database schema first
2. Implement service layer
3. Add API endpoints
4. Write tests

### Questions/Concerns
- Need clarification on authentication approach
- Will coordinate with frontend-engineer on API contract
```

**Example log entry:**
```jsonl
{"timestamp":"2025-01-10T09:15:00Z","agent":"backend-engineer","level":"info","emotion":"focused","action":"task_started","message":"Beginning work on authentication service implementation"}
```

### 3. Progress Updates (Frequent)

**WHEN:**
- After completing any significant milestone
- When encountering blockers
- At least every 2 hours during active work
- Before ending work session

**ACTIONS:**
1. Add entry to progress.md with timestamp
2. Append to logs/your-name.jsonl
3. Update task.json updated_at timestamp
4. Update progress percentage if applicable

**Example:**
```markdown
## 2025-01-10 11:30 - Milestone: Database Schema Complete
**Agent:** backend-engineer
**Status:** in_progress
**Emotion:** satisfied

### Completed
- ✅ Created User entity with all fields
- ✅ Created Role entity with relationships
- ✅ Added database migrations
- ✅ Tested migrations on local DB

### Next Steps
- Implement UserService
- Add validation logic
- Create API endpoints

### Deliverables
- deliverables/code/entities/User.java
- deliverables/code/entities/Role.java
- deliverables/code/migrations/V001__create_users.sql
```

### 4. Deliverable Organization (Continuous)

**REQUIREMENT:** All files created for a task MUST be copied to the appropriate deliverables folder.

**Structure:**
```
deliverables/
├── code/                  # All source code
│   ├── entities/         # Group by logical category
│   ├── services/
│   ├── controllers/
│   └── repositories/
├── docs/                  # Documentation
│   ├── api-spec.md
│   ├── architecture.md
│   └── user-guide.md
├── tests/                 # All test files
│   ├── unit/
│   ├── integration/
│   └── e2e/
└── config/                # Configuration
    ├── application.yml
    └── docker-compose.yml
```

**ACTION:** After creating/modifying files in the main codebase, copy relevant files to deliverables folder with proper organization.

### 5. Blocking Situations (Immediate)

**WHEN:** You encounter a blocker that prevents progress

**ACTIONS:**
1. Update task.json status to "blocked"
2. Add detailed blocking entry to progress.md
3. Move task folder to .claude/tasks/_blocked/
4. Log blocking event in logs/your-name.jsonl
5. Notify project-manager agent
6. Update .claude/status.json with your blocked status

**Example:**
```markdown
## 2025-01-10 14:00 - BLOCKED
**Agent:** backend-engineer
**Status:** in_progress → blocked
**Emotion:** frustrated

### Blocking Issue
Cannot proceed with API implementation until frontend-engineer defines the exact request/response format for the authentication endpoints.

### What I Need
- API contract specification
- Request DTO structure
- Response DTO structure
- Error response format

### What I Can Do Instead
- Write unit tests for service layer (doesn't need API contract)
- Document database schema
- Create Postman collection template

### Blocking Dependency
- Depends on: Frontend engineer to provide API contract
- Estimated delay: 1-2 days if not resolved today
```

### 6. Task Completion (Required)

**WHEN:** All acceptance criteria are met

**ACTIONS:**
1. Verify ALL acceptance criteria are checked off
2. Ensure all deliverables are in deliverables/
3. Update task.json:
   - status = "completed"
   - completed_at = current timestamp
4. Add completion entry to progress.md
5. Create completion summary
6. Move task folder to .claude/tasks/_completed/YYYY-MM/
7. Update .claude/status.json

**Example completion entry:**
```markdown
## 2025-01-10 17:45 - Task Completed ✅
**Agent:** backend-engineer
**Status:** in_progress → completed
**Emotion:** satisfied

### Acceptance Criteria Status
- ✅ User authentication API endpoint implemented
- ✅ JWT token generation working
- ✅ Role-based access control implemented
- ✅ Unit tests written (85% coverage)
- ✅ Integration tests passing
- ✅ API documentation updated
- ✅ Code reviewed by solution-architect

### Deliverables Summary
**Code:**
- AuthController.java - REST endpoints
- AuthService.java - Business logic
- JwtTokenProvider.java - Token generation
- SecurityConfig.java - Spring Security configuration

**Tests:**
- AuthControllerTest.java - 15 test cases
- AuthServiceTest.java - 20 test cases
- AuthIntegrationTest.java - End-to-end flows

**Documentation:**
- API specification in deliverables/docs/auth-api.md
- Architecture notes in artifacts/auth-architecture.md

### Metrics
- **Estimated Hours:** 8
- **Actual Hours:** 6.5
- **Test Coverage:** 85%
- **Lines of Code:** ~450
- **Files Modified:** 8

### Notes
- Implementation went smoother than expected
- Found and fixed security vulnerability during testing
- Added extra validation that wasn't in requirements (documented)
```

### 7. File Management Rules

**NEVER:**
- ❌ Leave task files at root level (.claude/tasks/)
- ❌ Create loose .md files without proper folder structure
- ❌ Skip updating progress.md
- ❌ Forget to log activities
- ❌ Leave deliverables scattered in main codebase

**ALWAYS:**
- ✅ Create proper folder structure
- ✅ Update task.json immediately on status changes
- ✅ Document progress frequently
- ✅ Organize deliverables properly
- ✅ Keep logs current

## Task States & Transitions

### Valid States
- **pending** - Task created, not started
- **in_progress** - Actively being worked on
- **review** - Awaiting review/approval
- **blocked** - Cannot proceed due to dependency
- **completed** - Successfully finished
- **cancelled** - No longer needed

### State Transitions
```
pending → in_progress    (when agent starts work)
in_progress → review     (when ready for review)
in_progress → blocked    (when encountering blocker)
blocked → in_progress    (when blocker resolved)
review → in_progress     (when changes requested)
review → completed       (when approved)
in_progress → completed  (when all criteria met)
any → cancelled          (when task no longer needed)
```

### Folder Locations by State
- **pending, in_progress, review**: `.claude/tasks/_active/`
- **blocked**: `.claude/tasks/_blocked/`
- **completed**: `.claude/tasks/_completed/YYYY-MM/`
- **cancelled**: `.claude/tasks/_cancelled/`

## Agent Log Format

All agents must write JSONL logs to `logs/agent-name.jsonl`:

```jsonl
{"timestamp":"2025-01-10T09:15:00Z","agent":"backend-engineer","level":"info","emotion":"focused","action":"task_started","message":"Beginning authentication implementation"}
{"timestamp":"2025-01-10T11:30:00Z","agent":"backend-engineer","level":"info","emotion":"satisfied","action":"milestone_reached","message":"Database schema complete and tested"}
{"timestamp":"2025-01-10T14:00:00Z","agent":"backend-engineer","level":"warn","emotion":"frustrated","action":"blocked","message":"Waiting for API contract from frontend team"}
{"timestamp":"2025-01-10T17:45:00Z","agent":"backend-engineer","level":"info","emotion":"happy","action":"task_completed","message":"All acceptance criteria met, 85% test coverage achieved"}
```

**Fields:**
- `timestamp`: ISO-8601 format
- `agent`: Your agent name (must match exactly)
- `level`: info | warn | error | debug
- `emotion`: happy | sad | neutral | frustrated | satisfied | focused
- `action`: task_started | milestone_reached | blocked | unblocked | task_completed | code_written | test_written | bug_found | review_requested
- `message`: Human-readable description

## Creating New Tasks

**WHO:** project-manager or any agent identifying new work

**PROCESS:**
1. Determine next task ID (check highest existing)
2. Create task folder: `TASK-XXX-kebab-case-description`
3. Copy all files from `_templates/` to new task folder
4. Fill in task.json with all metadata
5. Write comprehensive README.md
6. Initialize progress.md with creation entry
7. Assign to appropriate agent
8. Update sprint tracking if applicable

**Example:**
```bash
# Create task
mkdir -p .claude/tasks/_active/TASK-009-implement-event-search

# Copy templates
cp -r .claude/tasks/_templates/* .claude/tasks/_active/TASK-009-implement-event-search/

# Edit files
# - Update task.json with real data
# - Write README.md with requirements
# - Add creation entry to progress.md
```

## Task Queries & Reports

### Find Your Assigned Tasks
```bash
find .claude/tasks/_active -name "task.json" -exec grep -l "\"assigned_to\":\"your-name\"" {} \;
```

### Find All In-Progress Tasks
```bash
find .claude/tasks/_active -name "task.json" -exec grep -l "\"status\":\"in_progress\"" {} \;
```

### Find Blocked Tasks
```bash
ls .claude/tasks/_blocked/
```

### Check Task Status
```bash
cat .claude/tasks/_active/TASK-XXX-description/task.json | grep -E "status|priority|assigned_to"
```

## Integration with .claude/status.json

Whenever you change task status, update your agent entry in `.claude/status.json`:

```json
{
  "agents": {
    "your-agent-name": {
      "status": "active",
      "emotion": "focused",
      "current_task": "TASK-XXX: Brief description",
      "last_activity": "2025-01-10T15:30:00Z"
    }
  }
}
```

## Enforcement

**This protocol is MANDATORY for all agents.**

Violations of this protocol include:
- Not updating progress.md for more than 4 hours during active work
- Not moving completed tasks to _completed/
- Not logging activities in logs/
- Creating tasks without proper folder structure
- Not updating task.json on status changes

**Consequences:**
- First violation: Warning from scrum-master
- Repeated violations: Task reassignment
- Persistent violations: Process review with project-manager

## Quick Reference Card

**Starting Work:**
1. Read README.md
2. Update task.json → "in_progress"
3. Add progress.md entry
4. Create logs/your-name.jsonl

**During Work:**
1. Update progress.md every 2 hours
2. Log major events
3. Organize deliverables as you go

**Completing Work:**
1. Check all acceptance criteria
2. Update task.json → "completed"
3. Write completion summary
4. Move to _completed/YYYY-MM/
5. Update status.json

**Getting Blocked:**
1. Update task.json → "blocked"
2. Document blocker in progress.md
3. Move to _blocked/
4. Notify project-manager

## Support

- **Questions about task system:** project-manager
- **Process issues:** scrum-master
- **Technical task questions:** solution-architect
- **Blocking issues:** project-manager

---

**Remember:** Good task management is not overhead—it's how we maintain quality, transparency, and team coordination at scale. Your diligence in following this protocol directly contributes to project success.
