# Add Progress Entry Script
# Usage: .\add-progress.ps1 -TaskId "009" -Agent "backend-engineer" -Message "Completed database schema" -Emotion "satisfied"

param(
    [Parameter(Mandatory=$true)]
    [string]$TaskId,

    [Parameter(Mandatory=$true)]
    [string]$Agent,

    [Parameter(Mandatory=$true)]
    [string]$Message,

    [Parameter(Mandatory=$false)]
    [ValidateSet("happy","sad","neutral","frustrated","satisfied","focused")]
    [string]$Emotion = "neutral",

    [Parameter(Mandatory=$false)]
    [string[]]$Completed = @(),

    [Parameter(Mandatory=$false)]
    [string[]]$NextSteps = @(),

    [Parameter(Mandatory=$false)]
    [string]$Blocker = ""
)

$ErrorActionPreference = "Stop"

# Find task folder
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$TasksDir = Join-Path $ProjectRoot ".claude\tasks"

$TaskFolder = $null
foreach ($Dir in @("_active", "_blocked")) {
    $SearchPath = Join-Path $TasksDir $Dir
    if (Test-Path $SearchPath) {
        $Found = Get-ChildItem -Path $SearchPath -Filter "TASK-$TaskId-*" -Directory | Select-Object -First 1
        if ($Found) {
            $TaskFolder = $Found
            break
        }
    }
}

if (-not $TaskFolder) {
    Write-Host "ERROR: Task TASK-$TaskId not found!" -ForegroundColor Red
    exit 1
}

$TaskPath = $TaskFolder.FullName
$ProgressPath = Join-Path $TaskPath "progress.md"
$TaskJsonPath = Join-Path $TaskPath "task.json"

Write-Host "Adding progress entry to: $($TaskFolder.Name)" -ForegroundColor Cyan

# Get current status
$TaskJson = Get-Content $TaskJsonPath -Raw | ConvertFrom-Json
$CurrentStatus = $TaskJson.status

# Build progress entry
$Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
$ProgressEntry = @"


---

## $Timestamp - Progress Update
**Agent:** $Agent
**Status:** $CurrentStatus
**Emotion:** $Emotion

### Update
$Message

"@

if ($Completed.Count -gt 0) {
    $ProgressEntry += @"

### Completed
"@
    foreach ($Item in $Completed) {
        $ProgressEntry += "`n- ✅ $Item"
    }
    $ProgressEntry += "`n"
}

if ($NextSteps.Count -gt 0) {
    $ProgressEntry += @"

### Next Steps
"@
    foreach ($Step in $NextSteps) {
        $ProgressEntry += "`n- $Step"
    }
    $ProgressEntry += "`n"
}

if ($Blocker) {
    $ProgressEntry += @"

### ⚠️ Blocker
$Blocker

"@
}

# Append to progress.md
$ProgressContent = Get-Content $ProgressPath -Raw
$ProgressContent = $ProgressContent + $ProgressEntry
Set-Content -Path $ProgressPath -Value $ProgressContent -Encoding UTF8

# Update task.json timestamp
$TaskJson.updated_at = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
$TaskJson | ConvertTo-Json -Depth 10 | Set-Content $TaskJsonPath -Encoding UTF8

# Add log entry
$LogsDir = Join-Path $TaskPath "logs"
if (-not (Test-Path $LogsDir)) {
    New-Item -ItemType Directory -Path $LogsDir | Out-Null
}

$LogFile = Join-Path $LogsDir "$Agent.jsonl"
$LogEntry = @{
    timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
    agent = $Agent
    level = "info"
    emotion = $Emotion
    action = "progress_update"
    message = $Message
} | ConvertTo-Json -Compress

Add-Content -Path $LogFile -Value $LogEntry -Encoding UTF8

Write-Host "✅ Progress entry added successfully!" -ForegroundColor Green

if ($Blocker) {
    Write-Host "`n⚠️  BLOCKER NOTED: Consider updating task status to 'blocked'" -ForegroundColor Yellow
    Write-Host "Run: .\update-task-status.ps1 -TaskId $TaskId -NewStatus blocked -Agent $Agent" -ForegroundColor Gray
}
