#
# update-status-for-role.ps1
#
# Updates .claude/status.json with the current status of a specific agent role
# when the orchestrator is wearing that role's hat.
#
# Usage:
#   .\update-status-for-role.ps1 -Role "senior-backend-engineer" -Status "in_progress" -Emotion "focused" [-Task "TASK-003"]
#
# Parameters:
#   -Role      (Required) Agent role name (must match agent file name)
#   -Status    (Required) One of: idle, in_progress, working, blocked, done
#   -Emotion   (Required) One of: happy, sad, frustrated, satisfied, neutral, focused
#   -Task      (Optional) Task ID (e.g., TASK-003)
#   -Title     (Optional) Task title (fetched from task.json if not provided)
#

param(
    [Parameter(Mandatory=$true)]
    [string]$Role,

    [Parameter(Mandatory=$true)]
    [ValidateSet('idle','in_progress','working','blocked','done')]
    [string]$Status,

    [Parameter(Mandatory=$true)]
    [ValidateSet('happy','sad','frustrated','satisfied','neutral','focused')]
    [string]$Emotion,

    [Parameter(Mandatory=$false)]
    [string]$Task,

    [Parameter(Mandatory=$false)]
    [string]$Title
)

# Get script directory and navigate to project root
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent (Split-Path -Parent $scriptDir)
Set-Location $projectRoot

$statusFile = ".claude/status.json"

# Check if status.json exists
if (-not (Test-Path $statusFile)) {
    Write-Error "❌ Error: $statusFile not found"
    exit 1
}

try {
    # Read current status
    $statusData = Get-Content $statusFile -Raw | ConvertFrom-Json

    # Check if agents object exists
    if (-not $statusData.agents) {
        Write-Error "❌ Error: 'agents' object not found in $statusFile"
        exit 1
    }

    # Check if this agent role exists in status.json
    if (-not $statusData.agents.$Role) {
        Write-Warning "⚠️  Agent role '$Role' not found in status.json, creating entry..."
        $statusData.agents | Add-Member -NotePropertyName $Role -NotePropertyValue @{} -Force
    }

    # Get current UTC timestamp (ISO 8601, seconds only)
    $timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

    # Update agent status
    $statusData.agents.$Role.status = $Status
    $statusData.agents.$Role.emotion = $Emotion
    $statusData.agents.$Role.last_activity = $timestamp

    # Handle task information
    if ($Task) {
        # If title not provided, try to fetch from task.json
        if (-not $Title) {
            $taskFolders = @(
                (Get-ChildItem -Path ".claude/tasks/_active" -Directory -Filter "$Task*" -ErrorAction SilentlyContinue),
                (Get-ChildItem -Path ".claude/tasks/_blocked" -Directory -Filter "$Task*" -ErrorAction SilentlyContinue)
            ) | Where-Object { $_ -ne $null }

            if ($taskFolders.Count -gt 0) {
                $taskJsonPath = Join-Path $taskFolders[0].FullName "task.json"
                if (Test-Path $taskJsonPath) {
                    try {
                        $taskData = Get-Content $taskJsonPath -Raw | ConvertFrom-Json
                        $Title = $taskData.title
                    } catch {
                        $Title = "Unknown Task"
                    }
                } else {
                    $Title = "Unknown Task"
                }
            } else {
                $Title = "Unknown Task"
            }
        }

        $statusData.agents.$Role.current_task = @{
            id = $Task
            title = $Title
        }
    } else {
        # No task - clear current_task
        $statusData.agents.$Role.current_task = $null
    }

    # Save updated status
    $statusData | ConvertTo-Json -Depth 10 | Set-Content $statusFile -Encoding UTF8

    # Success output
    Write-Host "✅ Updated status.json for role: " -NoNewline -ForegroundColor Green
    Write-Host $Role -ForegroundColor Cyan
    Write-Host "   Status: " -NoNewline -ForegroundColor Gray

    # Color-code status
    $statusColor = switch ($Status) {
        "in_progress" { "Green" }
        "working"     { "Green" }
        "blocked"     { "Red" }
        "done"        { "Blue" }
        "idle"        { "Gray" }
        default       { "White" }
    }
    Write-Host $Status -ForegroundColor $statusColor

    Write-Host "   Emotion: " -NoNewline -ForegroundColor Gray

    # Color-code emotion
    $emotionColor = switch ($Emotion) {
        "happy"       { "Green" }
        "satisfied"   { "Cyan" }
        "focused"     { "Yellow" }
        "frustrated"  { "Red" }
        "sad"         { "Magenta" }
        "neutral"     { "Gray" }
        default       { "White" }
    }
    Write-Host $Emotion -ForegroundColor $emotionColor

    if ($Task) {
        Write-Host "   Task: " -NoNewline -ForegroundColor Gray
        Write-Host "$Task - $Title" -ForegroundColor Cyan
    }

} catch {
    Write-Error "❌ Failed to update status.json: $_"
    exit 1
}

exit 0
