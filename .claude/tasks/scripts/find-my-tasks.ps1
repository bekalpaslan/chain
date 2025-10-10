# Find My Tasks Script
# Usage: .\find-my-tasks.ps1 -Agent "backend-engineer"

param(
    [Parameter(Mandatory=$true)]
    [string]$Agent,

    [Parameter(Mandatory=$false)]
    [ValidateSet("all","pending","in_progress","review","blocked")]
    [string]$Status = "all"
)

$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$TasksDir = Join-Path $ProjectRoot ".claude\tasks"

Write-Host "`n=== Tasks for $Agent ===" -ForegroundColor Cyan
Write-Host ""

$FoundTasks = @()

# Search in _active
$ActiveDir = Join-Path $TasksDir "_active"
if (Test-Path $ActiveDir) {
    $ActiveTasks = Get-ChildItem -Path $ActiveDir -Directory | ForEach-Object {
        $TaskJsonPath = Join-Path $_.FullName "task.json"
        if (Test-Path $TaskJsonPath) {
            $TaskJson = Get-Content $TaskJsonPath -Raw | ConvertFrom-Json
            if ($TaskJson.assigned_to -eq $Agent) {
                if ($Status -eq "all" -or $TaskJson.status -eq $Status) {
                    [PSCustomObject]@{
                        Location = "_active"
                        FolderName = $_.Name
                        Id = $TaskJson.id
                        Title = $TaskJson.title
                        Status = $TaskJson.status
                        Priority = $TaskJson.priority
                        Type = $TaskJson.type
                        StoryPoints = $TaskJson.story_points
                        UpdatedAt = $TaskJson.updated_at
                        Path = $_.FullName
                    }
                }
            }
        }
    }
    $FoundTasks += $ActiveTasks
}

# Search in _blocked
$BlockedDir = Join-Path $TasksDir "_blocked"
if (Test-Path $BlockedDir) {
    $BlockedTasks = Get-ChildItem -Path $BlockedDir -Directory | ForEach-Object {
        $TaskJsonPath = Join-Path $_.FullName "task.json"
        if (Test-Path $TaskJsonPath) {
            $TaskJson = Get-Content $TaskJsonPath -Raw | ConvertFrom-Json
            if ($TaskJson.assigned_to -eq $Agent) {
                if ($Status -eq "all" -or $Status -eq "blocked") {
                    [PSCustomObject]@{
                        Location = "_blocked"
                        FolderName = $_.Name
                        Id = $TaskJson.id
                        Title = $TaskJson.title
                        Status = $TaskJson.status
                        Priority = $TaskJson.priority
                        Type = $TaskJson.type
                        StoryPoints = $TaskJson.story_points
                        UpdatedAt = $TaskJson.updated_at
                        Path = $_.FullName
                    }
                }
            }
        }
    }
    $FoundTasks += $BlockedTasks
}

if ($FoundTasks.Count -eq 0) {
    Write-Host "No tasks found for $Agent" -ForegroundColor Yellow
    if ($Status -ne "all") {
        Write-Host "(Filtered by status: $Status)" -ForegroundColor Gray
    }
    exit 0
}

# Display results
$FoundTasks | Sort-Object Priority,UpdatedAt | ForEach-Object {
    $PriorityColor = switch ($_.Priority) {
        "CRITICAL" { "Red" }
        "HIGH" { "Yellow" }
        "MEDIUM" { "Cyan" }
        "LOW" { "Gray" }
    }

    $StatusColor = switch ($_.Status) {
        "in_progress" { "Green" }
        "blocked" { "Red" }
        "review" { "Yellow" }
        "pending" { "White" }
    }

    Write-Host "[$($_.Id)]" -ForegroundColor Magenta -NoNewline
    Write-Host " $($_.Title)" -ForegroundColor White
    Write-Host "  Status: " -NoNewline
    Write-Host $_.Status -ForegroundColor $StatusColor -NoNewline
    Write-Host " | Priority: " -NoNewline
    Write-Host $_.Priority -ForegroundColor $PriorityColor -NoNewline
    Write-Host " | Type: $($_.Type) | Points: $($_.StoryPoints)"
    Write-Host "  Path: $($_.Path)" -ForegroundColor Gray
    Write-Host ""
}

Write-Host "Total: $($FoundTasks.Count) task(s)" -ForegroundColor Cyan
Write-Host ""

# Summary by status
$StatusSummary = $FoundTasks | Group-Object Status | ForEach-Object {
    [PSCustomObject]@{
        Status = $_.Name
        Count = $_.Count
    }
}

Write-Host "Summary by Status:" -ForegroundColor Yellow
$StatusSummary | ForEach-Object {
    Write-Host "  $($_.Status): $($_.Count)"
}
