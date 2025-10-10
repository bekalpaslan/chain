# Task Management Scripts

Helper scripts for managing tasks in the folder-based task system.

## Available Scripts

### 1. create-task.ps1
Creates a new task with proper folder structure and metadata.

**Usage:**
```powershell
.\create-task.ps1 `
    -TaskId "011" `
    -Slug "implement-payment-gateway" `
    -Title "Implement Payment Gateway Integration" `
    -AssignedTo "senior-backend-engineer" `
    -Type "feature" `
    -Priority "HIGH" `
    -StoryPoints 8 `
    -Description "Integrate Stripe payment processing"
```

**Parameters:**
- `TaskId` (required): 3-digit task number (e.g., "011")
- `Slug` (required): kebab-case short description
- `Title` (required): Full task title
- `AssignedTo` (required): Agent name (validates against known agents)
- `Type` (optional): feature|bug|infrastructure|testing|documentation|devops|refactor|research (default: feature)
- `Priority` (optional): CRITICAL|HIGH|MEDIUM|LOW (default: MEDIUM)
- `Description` (optional): Detailed description
- `StoryPoints` (optional): Complexity estimate (default: 0)

**Output:**
- Creates task folder in `.claude/tasks/_active/`
- Generates task.json with all metadata
- Creates README.md from template
- Initializes progress.md with creation entry
- Creates all subdirectories (deliverables/, artifacts/, logs/)

---

### 2. update-task-status.ps1
Updates task status and handles folder moves.

**Usage:**
```powershell
.\update-task-status.ps1 `
    -TaskId "009" `
    -NewStatus "in_progress" `
    -Agent "backend-engineer" `
    -Message "Starting database schema implementation" `
    -Emotion "focused"
```

**Parameters:**
- `TaskId` (required): Task number
- `NewStatus` (required): pending|in_progress|review|blocked|completed|cancelled
- `Agent` (required): Your agent name
- `Message` (optional): Status change description
- `Emotion` (optional): happy|sad|neutral|frustrated|satisfied|focused (default: neutral)

**Behavior:**
- Updates task.json status and timestamps
- Adds entry to progress.md
- Creates log entry in logs/agent-name.jsonl
- **Moves folders automatically:**
  - `blocked` → moves to `_blocked/`
  - `completed` → moves to `_completed/YYYY-MM/`
  - `cancelled` → moves to `_cancelled/`
  - `unblocked` → moves back to `_active/`

---

### 3. find-my-tasks.ps1
Find all tasks assigned to you.

**Usage:**
```powershell
# Find all your tasks
.\find-my-tasks.ps1 -Agent "backend-engineer"

# Find only in-progress tasks
.\find-my-tasks.ps1 -Agent "backend-engineer" -Status "in_progress"

# Find blocked tasks
.\find-my-tasks.ps1 -Agent "backend-engineer" -Status "blocked"
```

**Parameters:**
- `Agent` (required): Your agent name
- `Status` (optional): all|pending|in_progress|review|blocked (default: all)

**Output:**
- Lists all matching tasks with details
- Shows priority (color-coded)
- Shows status (color-coded)
- Displays file paths
- Summary statistics by status

---

### 4. add-progress.ps1
Add progress entry to task without changing status.

**Usage:**
```powershell
.\add-progress.ps1 `
    -TaskId "009" `
    -Agent "backend-engineer" `
    -Message "Completed database schema design" `
    -Emotion "satisfied" `
    -Completed @("User entity created", "Role entity created", "Migrations written") `
    -NextSteps @("Implement UserService", "Write unit tests") `
    -Blocker "Waiting for API contract from frontend"
```

**Parameters:**
- `TaskId` (required): Task number
- `Agent` (required): Your agent name
- `Message` (required): Progress description
- `Emotion` (optional): happy|sad|neutral|frustrated|satisfied|focused (default: neutral)
- `Completed` (optional): Array of completed items
- `NextSteps` (optional): Array of next steps
- `Blocker` (optional): Blocker description (if any)

**Behavior:**
- Adds structured progress entry to progress.md
- Updates task.json timestamp
- Creates log entry
- Warns if blocker is present

---

## Common Workflows

### Starting Work on a Task

```powershell
# 1. Find your tasks
.\find-my-tasks.ps1 -Agent "your-name" -Status "pending"

# 2. Start the task
.\update-task-status.ps1 -TaskId "009" -NewStatus "in_progress" -Agent "your-name" -Message "Beginning implementation"

# 3. Read the task details
cd ..\_active\TASK-009-*
cat README.md
cat task.json
```

### Regular Progress Updates

```powershell
# Add progress every 2 hours or after milestones
.\add-progress.ps1 `
    -TaskId "009" `
    -Agent "your-name" `
    -Message "Implemented user authentication service" `
    -Emotion "satisfied" `
    -Completed @("AuthService class", "JWT token generation", "Unit tests") `
    -NextSteps @("Add API endpoints", "Integration tests")
```

### Handling Blockers

```powershell
# 1. Document the blocker
.\add-progress.ps1 `
    -TaskId "009" `
    -Agent "your-name" `
    -Message "Cannot proceed without API specification" `
    -Emotion "frustrated" `
    -Blocker "Waiting for frontend team to provide API contract"

# 2. Change status to blocked
.\update-task-status.ps1 `
    -TaskId "009" `
    -NewStatus "blocked" `
    -Agent "your-name" `
    -Message "Blocked waiting for API specification from frontend team"

# Task will automatically move to _blocked/ folder
```

### Completing a Task

```powershell
# 1. Add final progress update
.\add-progress.ps1 `
    -TaskId "009" `
    -Agent "your-name" `
    -Message "All acceptance criteria met, tests passing" `
    -Emotion "happy" `
    -Completed @("All features implemented", "Tests at 85% coverage", "Documentation complete", "Code reviewed")

# 2. Mark as completed
.\update-task-status.ps1 `
    -TaskId "009" `
    -NewStatus "completed" `
    -Agent "your-name" `
    -Message "Task completed successfully. All acceptance criteria verified."

# Task will automatically move to _completed/YYYY-MM/ folder
```

### Creating a New Task

```powershell
# Project manager creates new task
.\create-task.ps1 `
    -TaskId "012" `
    -Slug "add-email-notifications" `
    -Title "Add Email Notification System" `
    -AssignedTo "senior-backend-engineer" `
    -Type "feature" `
    -Priority "HIGH" `
    -StoryPoints 5 `
    -Description "Implement email notifications for important events using SendGrid"

# Then manually edit:
# - README.md for detailed requirements
# - task.json for acceptance criteria and dependencies
```

---

## Tips & Best Practices

### For All Agents

1. **Check tasks daily**
   ```powershell
   .\find-my-tasks.ps1 -Agent "your-name"
   ```

2. **Update progress frequently** (every 2 hours minimum)
   ```powershell
   .\add-progress.ps1 -TaskId "XXX" -Agent "your-name" -Message "..."
   ```

3. **Always log your emotion** - it helps track team morale and identify stress points

4. **Document blockers immediately** - don't wait until standup

5. **Use meaningful messages** - future you will thank you

### For Project Managers

1. **Keep task IDs sequential** - use `ls _active` to find the highest number

2. **Validate assignments** - ensure the agent has capacity

3. **Set realistic story points** - use Fibonacci: 1, 2, 3, 5, 8, 13

4. **Define clear acceptance criteria** - edit task.json after creation

5. **Monitor blocked tasks** - check `_blocked/` folder daily

### For All Technical Agents

1. **Copy deliverables as you go** - don't wait until the end
   ```powershell
   cp backend/src/main/java/com/myapp/Service.java .claude/tasks/_active/TASK-009-*/deliverables/code/
   ```

2. **Run scripts from scripts folder**
   ```powershell
   cd .claude/tasks/scripts
   .\find-my-tasks.ps1 -Agent "your-name"
   ```

3. **Keep logs up to date** - the JSONL logs are for automation and metrics

---

## Troubleshooting

### Script Won't Run

**Error:** "Running scripts is disabled on this system"

**Solution:**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Task Not Found

**Error:** "Task TASK-XXX not found"

**Check:**
1. Is the task in `_blocked/` folder?
2. Was it already completed? (check `_completed/YYYY-MM/`)
3. Was it cancelled? (check `_cancelled/`)

**Fix:** Manually locate the task folder
```powershell
Get-ChildItem -Path ..\ -Recurse -Filter "TASK-XXX-*" -Directory
```

### Invalid Agent Name

**Error:** Validation failed on AssignedTo parameter

**Valid agent names:**
- project-manager
- solution-architect
- senior-backend-engineer
- principal-database-architect
- test-master
- devops-lead
- ui-designer
- web-dev-master
- senior-mobile-developer
- scrum-master
- opportunist-strategist
- psychologist-game-dynamics
- game-theory-master
- legal-software-advisor

---

## Integration with Other Systems

### Update .claude/status.json

After changing task status, remember to update the global status:

```powershell
# Read current status
$Status = Get-Content ..\..\status.json | ConvertFrom-Json

# Update your agent
$Status.agents.'your-agent-name'.status = "active"
$Status.agents.'your-agent-name'.emotion = "focused"
$Status.agents.'your-agent-name'.current_task = "TASK-009: Brief description"
$Status.agents.'your-agent-name'.last_activity = (Get-Date -Format "o")

# Save
$Status | ConvertTo-Json -Depth 10 | Set-Content ..\..\status.json
```

### Query Task Metrics

```powershell
# Count tasks by status
Get-ChildItem -Path ..\_active -Directory | ForEach-Object {
    $Task = Get-Content "$($_.FullName)\task.json" | ConvertFrom-Json
    $Task.status
} | Group-Object | Sort-Object Count -Descending

# Calculate total story points
$TotalPoints = Get-ChildItem -Path ..\_active -Directory | ForEach-Object {
    $Task = Get-Content "$($_.FullName)\task.json" | ConvertFrom-Json
    $Task.story_points
} | Measure-Object -Sum
Write-Host "Total story points in active sprint: $($TotalPoints.Sum)"
```

---

## Support

- **Script Issues:** devops-lead
- **Process Questions:** scrum-master
- **Task System Design:** project-manager

---

**Remember:** These scripts are helpers, but the real work is in the tasks themselves. Keep your focus on delivering value!
