# Update Task Status Script
# Usage: .\update-task-status.ps1 -TaskId "009" -NewStatus "in_progress" -Agent "backend-engineer" -Message "Starting implementation"

param(
    [Parameter(Mandatory=$true)]
    [string]$TaskId,

    [Parameter(Mandatory=$true)]
    [ValidateSet("pending","in_progress","review","blocked","completed","cancelled")]
    [string]$NewStatus,

    [Parameter(Mandatory=$true)]
    [string]$Agent,

    [Parameter(Mandatory=$false)]
    [string]$Message = "",

    [Parameter(Mandatory=$false)]
    [ValidateSet("happy","sad","neutral","frustrated","satisfied","focused")]
    [string]$Emotion = "neutral"
)

$ErrorActionPreference = "Stop"

# Find task folder
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$TasksDir = Join-Path $ProjectRoot ".claude\tasks"
$TaskFolder = Get-ChildItem -Path (Join-Path $TasksDir "_active") -Filter "TASK-$TaskId-*" -Directory | Select-Object -First 1

if (-not $TaskFolder) {
    # Check blocked folder
    $TaskFolder = Get-ChildItem -Path (Join-Path $TasksDir "_blocked") -Filter "TASK-$TaskId-*" -Directory | Select-Object -First 1
}

if (-not $TaskFolder) {
    Write-Host "ERROR: Task TASK-$TaskId not found!" -ForegroundColor Red
    exit 1
}

$TaskPath = $TaskFolder.FullName
$TaskJsonPath = Join-Path $TaskPath "task.json"
$ProgressPath = Join-Path $TaskPath "progress.md"

Write-Host "Updating task: $($TaskFolder.Name)" -ForegroundColor Cyan

# Read current task.json
$TaskJson = Get-Content $TaskJsonPath -Raw | ConvertFrom-Json
$OldStatus = $TaskJson.status
$Timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"

Write-Host "Status change: $OldStatus → $NewStatus" -ForegroundColor Yellow

# Update task.json
$TaskJson.status = $NewStatus
$TaskJson.updated_at = $Timestamp

# Set timestamps based on status
if ($NewStatus -eq "in_progress" -and -not $TaskJson.started_at) {
    $TaskJson.started_at = $Timestamp
    Write-Host "Setting started_at timestamp" -ForegroundColor Green
}

if ($NewStatus -eq "completed") {
    $TaskJson.completed_at = $Timestamp
    Write-Host "Setting completed_at timestamp" -ForegroundColor Green
}

# Save task.json
$TaskJson | ConvertTo-Json -Depth 10 | Set-Content $TaskJsonPath -Encoding UTF8

# Update progress.md
$ProgressContent = Get-Content $ProgressPath -Raw
$StatusChangeEntry = @"


---

## $((Get-Date).ToString("yyyy-MM-dd HH:mm")) - Status Change: $NewStatus
**Agent:** $Agent
**Status:** $OldStatus → $NewStatus
**Emotion:** $Emotion

$Message

"@

$ProgressContent = $ProgressContent + $StatusChangeEntry
Set-Content -Path $ProgressPath -Value $ProgressContent -Encoding UTF8

# Create log entry
$LogsDir = Join-Path $TaskPath "logs"
if (-not (Test-Path $LogsDir)) {
    New-Item -ItemType Directory -Path $LogsDir | Out-Null
}

$LogFile = Join-Path $LogsDir "$Agent.jsonl"
$LogEntry = @{
    timestamp = $Timestamp
    agent = $Agent
    level = "info"
    emotion = $Emotion
    action = "status_change"
    message = "$OldStatus → $NewStatus. $Message"
} | ConvertTo-Json -Compress

Add-Content -Path $LogFile -Value $LogEntry -Encoding UTF8

# Handle folder moves based on status
if ($NewStatus -eq "blocked" -and $OldStatus -ne "blocked") {
    $BlockedDir = Join-Path $TasksDir "_blocked"
    $DestPath = Join-Path $BlockedDir $TaskFolder.Name
    Write-Host "Moving task to _blocked folder..." -ForegroundColor Yellow
    Move-Item -Path $TaskPath -Destination $DestPath -Force
    $TaskPath = $DestPath
}

if ($NewStatus -ne "blocked" -and $OldStatus -eq "blocked") {
    $ActiveDir = Join-Path $TasksDir "_active"
    $DestPath = Join-Path $ActiveDir $TaskFolder.Name
    Write-Host "Moving task to _active folder..." -ForegroundColor Yellow
    Move-Item -Path $TaskPath -Destination $DestPath -Force
    $TaskPath = $DestPath
}

if ($NewStatus -eq "completed") {
    $CompletedDir = Join-Path $TasksDir "_completed\$((Get-Date).ToString("yyyy-MM"))"
    if (-not (Test-Path $CompletedDir)) {
        New-Item -ItemType Directory -Path $CompletedDir -Force | Out-Null
    }
    $DestPath = Join-Path $CompletedDir $TaskFolder.Name
    Write-Host "Moving task to _completed/$((Get-Date).ToString("yyyy-MM")) folder..." -ForegroundColor Yellow
    Move-Item -Path $TaskPath -Destination $DestPath -Force
    $TaskPath = $DestPath
}

if ($NewStatus -eq "cancelled") {
    $CancelledDir = Join-Path $TasksDir "_cancelled"
    $DestPath = Join-Path $CancelledDir $TaskFolder.Name
    Write-Host "Moving task to _cancelled folder..." -ForegroundColor Yellow
    Move-Item -Path $TaskPath -Destination $DestPath -Force
    $TaskPath = $DestPath
}

Write-Host "`n✅ Task status updated successfully!" -ForegroundColor Green
Write-Host "`nNew Location: $TaskPath" -ForegroundColor Cyan

# Show reminder for specific statuses
if ($NewStatus -eq "blocked") {
    Write-Host "`n⚠️  REMINDER: Notify project-manager about the blocker!" -ForegroundColor Yellow
}

if ($NewStatus -eq "completed") {
    Write-Host "`n🎉 Task completed! Don't forget to update .claude/status.json" -ForegroundColor Green
}
