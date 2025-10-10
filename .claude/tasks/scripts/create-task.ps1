# Create New Task Script
# Usage: .\create-task.ps1 -TaskId "009" -Slug "implement-feature" -Title "Implement Feature" -AssignedTo "backend-engineer"

param(
    [Parameter(Mandatory=$true)]
    [string]$TaskId,

    [Parameter(Mandatory=$true)]
    [string]$Slug,

    [Parameter(Mandatory=$true)]
    [string]$Title,

    [Parameter(Mandatory=$true)]
    [ValidateSet("project-manager","solution-architect","senior-backend-engineer","principal-database-architect","test-master","devops-lead","ui-designer","web-dev-master","senior-mobile-developer","scrum-master","opportunist-strategist","psychologist-game-dynamics","game-theory-master","legal-software-advisor")]
    [string]$AssignedTo,

    [Parameter(Mandatory=$false)]
    [ValidateSet("feature","bug","infrastructure","testing","documentation","devops","refactor","research")]
    [string]$Type = "feature",

    [Parameter(Mandatory=$false)]
    [ValidateSet("CRITICAL","HIGH","MEDIUM","LOW")]
    [string]$Priority = "MEDIUM",

    [Parameter(Mandatory=$false)]
    [string]$Description = "",

    [Parameter(Mandatory=$false)]
    [int]$StoryPoints = 0
)

$ErrorActionPreference = "Stop"

# Paths
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$TasksDir = Join-Path $ProjectRoot ".claude\tasks"
$TemplatesDir = Join-Path $TasksDir "_templates"
$ActiveDir = Join-Path $TasksDir "_active"
$TaskFolder = "TASK-$TaskId-$Slug"
$TaskPath = Join-Path $ActiveDir $TaskFolder

Write-Host "Creating new task: $TaskFolder" -ForegroundColor Cyan

# Check if task already exists
if (Test-Path $TaskPath) {
    Write-Host "ERROR: Task $TaskFolder already exists!" -ForegroundColor Red
    exit 1
}

# Copy template structure
Write-Host "Copying template structure..." -ForegroundColor Yellow
Copy-Item -Path $TemplatesDir -Destination $TaskPath -Recurse

# Get current timestamp
$Timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"

# Update task.json
Write-Host "Creating task.json..." -ForegroundColor Yellow
$TaskJsonPath = Join-Path $TaskPath "task.json"
$TaskJson = Get-Content $TaskJsonPath -Raw | ConvertFrom-Json

$TaskJson.id = "TASK-$TaskId"
$TaskJson.title = $Title
$TaskJson.description = if ($Description) { $Description } else { $Title }
$TaskJson.type = $Type
$TaskJson.priority = $Priority
$TaskJson.assigned_to = $AssignedTo
$TaskJson.created_at = $Timestamp
$TaskJson.updated_at = $Timestamp
$TaskJson.story_points = $StoryPoints
$TaskJson.sprint = "SPRINT-2025-01"

$TaskJson | ConvertTo-Json -Depth 10 | Set-Content $TaskJsonPath -Encoding UTF8

# Update README.md
Write-Host "Creating README.md..." -ForegroundColor Yellow
$ReadmePath = Join-Path $TaskPath "README.md"
$ReadmeContent = Get-Content $ReadmePath -Raw
$ReadmeContent = $ReadmeContent -replace "TASK-XXX", "TASK-$TaskId"
$ReadmeContent = $ReadmeContent -replace "\[Task Title\]", $Title
Set-Content -Path $ReadmePath -Value $ReadmeContent -Encoding UTF8

# Update progress.md
Write-Host "Creating progress.md..." -ForegroundColor Yellow
$ProgressPath = Join-Path $TaskPath "progress.md"
$ProgressContent = Get-Content $ProgressPath -Raw

# Add creation entry
$CreationEntry = @"

---

## $((Get-Date).ToString("yyyy-MM-dd HH:mm")) - Task Created
**Agent:** $AssignedTo
**Status:** none → pending

Task created and assigned to $AssignedTo.

**Task Details:**
- ID: TASK-$TaskId
- Type: $Type
- Priority: $Priority
- Story Points: $StoryPoints

Task is ready to begin work.

"@

$ProgressContent = $ProgressContent + $CreationEntry
Set-Content -Path $ProgressPath -Value $ProgressContent -Encoding UTF8

Write-Host "`n✅ Task created successfully!" -ForegroundColor Green
Write-Host "`nTask Location: $TaskPath" -ForegroundColor Cyan
Write-Host "`nNext Steps:" -ForegroundColor Yellow
Write-Host "1. Edit README.md to add detailed requirements"
Write-Host "2. Update acceptance criteria in task.json"
Write-Host "3. Add any dependencies if needed"
Write-Host "4. Notify $AssignedTo about the new task"

# Display task info
Write-Host "`n--- Task Information ---" -ForegroundColor Magenta
Write-Host "ID:          TASK-$TaskId"
Write-Host "Title:       $Title"
Write-Host "Type:        $Type"
Write-Host "Priority:    $Priority"
Write-Host "Assigned To: $AssignedTo"
Write-Host "Status:      pending"
Write-Host "Created:     $Timestamp"
Write-Host "------------------------" -ForegroundColor Magenta
