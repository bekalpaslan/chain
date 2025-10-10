# Task Summary Report Script
# Usage: .\task-summary.ps1 [-Sprint "SPRINT-2025-01"]

param(
    [Parameter(Mandatory=$false)]
    [string]$Sprint = ""
)

$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$TasksDir = Join-Path $ProjectRoot ".claude\tasks"

Write-Host "`n╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║              TASK MANAGEMENT SYSTEM SUMMARY                    ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

$AllTasks = @()

# Collect all tasks from all folders
foreach ($FolderName in @("_active", "_blocked", "_completed\*", "_cancelled")) {
    $SearchPath = Join-Path $TasksDir $FolderName
    if (Test-Path $SearchPath) {
        Get-ChildItem -Path $SearchPath -Recurse -Filter "task.json" | ForEach-Object {
            $TaskJson = Get-Content $_.FullName -Raw | ConvertFrom-Json

            # Filter by sprint if specified
            if (-not $Sprint -or $TaskJson.sprint -eq $Sprint) {
                $Location = if ($_.DirectoryName -like "*_active*") { "active" }
                           elseif ($_.DirectoryName -like "*_blocked*") { "blocked" }
                           elseif ($_.DirectoryName -like "*_completed*") { "completed" }
                           elseif ($_.DirectoryName -like "*_cancelled*") { "cancelled" }
                           else { "unknown" }

                $AllTasks += [PSCustomObject]@{
                    Id = $TaskJson.id
                    Title = $TaskJson.title
                    Status = $TaskJson.status
                    Priority = $TaskJson.priority
                    Type = $TaskJson.type
                    AssignedTo = $TaskJson.assigned_to
                    StoryPoints = $TaskJson.story_points
                    Location = $Location
                    Sprint = $TaskJson.sprint
                    CreatedAt = $TaskJson.created_at
                    UpdatedAt = $TaskJson.updated_at
                    CompletedAt = $TaskJson.completed_at
                }
            }
        }
    }
}

if ($AllTasks.Count -eq 0) {
    Write-Host "No tasks found" -ForegroundColor Yellow
    if ($Sprint) {
        Write-Host "(Filtered by sprint: $Sprint)" -ForegroundColor Gray
    }
    exit 0
}

# Overall Statistics
Write-Host "📊 Overall Statistics" -ForegroundColor Yellow
Write-Host "══════════════════════════════════════════════════════════════" -ForegroundColor Gray
Write-Host "Total Tasks:        $($AllTasks.Count)"
Write-Host "Active Tasks:       $(($AllTasks | Where-Object {$_.Location -eq 'active'}).Count)"
Write-Host "Blocked Tasks:      $(($AllTasks | Where-Object {$_.Location -eq 'blocked'}).Count)" -ForegroundColor Red
Write-Host "Completed Tasks:    $(($AllTasks | Where-Object {$_.Location -eq 'completed'}).Count)" -ForegroundColor Green
Write-Host "Cancelled Tasks:    $(($AllTasks | Where-Object {$_.Location -eq 'cancelled'}).Count)" -ForegroundColor Gray
Write-Host ""

# Story Points
$TotalPoints = ($AllTasks | Measure-Object -Property StoryPoints -Sum).Sum
$CompletedPoints = ($AllTasks | Where-Object {$_.Status -eq 'completed'} | Measure-Object -Property StoryPoints -Sum).Sum
$InProgressPoints = ($AllTasks | Where-Object {$_.Status -eq 'in_progress'} | Measure-Object -Property StoryPoints -Sum).Sum
$PendingPoints = ($AllTasks | Where-Object {$_.Status -eq 'pending'} | Measure-Object -Property StoryPoints -Sum).Sum

Write-Host "📈 Story Points" -ForegroundColor Yellow
Write-Host "══════════════════════════════════════════════════════════════" -ForegroundColor Gray
Write-Host "Total Points:       $TotalPoints"
Write-Host "Completed:          $CompletedPoints" -ForegroundColor Green
Write-Host "In Progress:        $InProgressPoints" -ForegroundColor Cyan
Write-Host "Pending:            $PendingPoints" -ForegroundColor White
if ($TotalPoints -gt 0) {
    $CompletionPercent = [math]::Round(($CompletedPoints / $TotalPoints) * 100, 1)
    Write-Host "Completion:         $CompletionPercent%" -ForegroundColor $(if($CompletionPercent -gt 75){"Green"}elseif($CompletionPercent -gt 50){"Yellow"}else{"Red"})
}
Write-Host ""

# By Priority
Write-Host "🔥 By Priority" -ForegroundColor Yellow
Write-Host "══════════════════════════════════════════════════════════════" -ForegroundColor Gray
$AllTasks | Group-Object Priority | Sort-Object {
    switch ($_.Name) {
        "CRITICAL" { 1 }
        "HIGH" { 2 }
        "MEDIUM" { 3 }
        "LOW" { 4 }
        default { 5 }
    }
} | ForEach-Object {
    $Color = switch ($_.Name) {
        "CRITICAL" { "Red" }
        "HIGH" { "Yellow" }
        "MEDIUM" { "Cyan" }
        "LOW" { "Gray" }
    }
    Write-Host "  $($_.Name):" -NoNewline -ForegroundColor $Color
    Write-Host " $($_.Count) tasks"
}
Write-Host ""

# By Type
Write-Host "📦 By Type" -ForegroundColor Yellow
Write-Host "══════════════════════════════════════════════════════════════" -ForegroundColor Gray
$AllTasks | Group-Object Type | Sort-Object Count -Descending | ForEach-Object {
    Write-Host "  $($_.Name): $($_.Count) tasks"
}
Write-Host ""

# By Agent
Write-Host "👤 By Agent" -ForegroundColor Yellow
Write-Host "══════════════════════════════════════════════════════════════" -ForegroundColor Gray
$AllTasks | Group-Object AssignedTo | Sort-Object Count -Descending | ForEach-Object {
    $AgentTasks = $_.Group
    $AgentCompleted = ($AgentTasks | Where-Object {$_.Status -eq 'completed'}).Count
    $AgentInProgress = ($AgentTasks | Where-Object {$_.Status -eq 'in_progress'}).Count
    $AgentPending = ($AgentTasks | Where-Object {$_.Status -eq 'pending'}).Count
    $AgentBlocked = ($AgentTasks | Where-Object {$_.Status -eq 'blocked'}).Count

    Write-Host "  $($_.Name):" -ForegroundColor Cyan
    Write-Host "    Total: $($_.Count) | Completed: $AgentCompleted | In Progress: $AgentInProgress | Pending: $AgentPending | Blocked: $AgentBlocked"
}
Write-Host ""

# Critical & Blocked Tasks (Alerts)
$CriticalTasks = $AllTasks | Where-Object {$_.Priority -eq 'CRITICAL' -and $_.Status -ne 'completed'}
$BlockedTasks = $AllTasks | Where-Object {$_.Location -eq 'blocked'}

if ($CriticalTasks.Count -gt 0 -or $BlockedTasks.Count -gt 0) {
    Write-Host "⚠️  ALERTS" -ForegroundColor Red
    Write-Host "══════════════════════════════════════════════════════════════" -ForegroundColor Gray

    if ($CriticalTasks.Count -gt 0) {
        Write-Host "🔴 Critical Tasks Not Completed: $($CriticalTasks.Count)" -ForegroundColor Red
        $CriticalTasks | ForEach-Object {
            Write-Host "  [$($_.Id)] $($_.Title) - $($_.Status) - $($_.AssignedTo)" -ForegroundColor Red
        }
        Write-Host ""
    }

    if ($BlockedTasks.Count -gt 0) {
        Write-Host "🚫 Blocked Tasks: $($BlockedTasks.Count)" -ForegroundColor Red
        $BlockedTasks | ForEach-Object {
            Write-Host "  [$($_.Id)] $($_.Title) - $($_.AssignedTo)" -ForegroundColor Red
        }
        Write-Host ""
    }
}

# Recent Activity (Last 7 days)
$RecentCutoff = (Get-Date).AddDays(-7)
$RecentTasks = $AllTasks | Where-Object {
    try {
        $UpdatedDate = [DateTime]::Parse($_.UpdatedAt)
        $UpdatedDate -gt $RecentCutoff
    } catch {
        $false
    }
} | Sort-Object UpdatedAt -Descending

if ($RecentTasks.Count -gt 0) {
    Write-Host "📅 Recent Activity (Last 7 days)" -ForegroundColor Yellow
    Write-Host "══════════════════════════════════════════════════════════════" -ForegroundColor Gray
    $RecentTasks | Select-Object -First 10 | ForEach-Object {
        $UpdatedDate = [DateTime]::Parse($_.UpdatedAt)
        $DaysAgo = [math]::Round(((Get-Date) - $UpdatedDate).TotalDays, 1)
        Write-Host "  [$($_.Id)] $($_.Title)" -ForegroundColor Cyan
        Write-Host "    Status: $($_.Status) | Updated: $DaysAgo days ago | Agent: $($_.AssignedTo)" -ForegroundColor Gray
    }
    Write-Host ""
}

# Sprint Info
if ($Sprint) {
    Write-Host "🏃 Sprint: $Sprint" -ForegroundColor Yellow
    Write-Host "══════════════════════════════════════════════════════════════" -ForegroundColor Gray
    Write-Host "This report is filtered by sprint: $Sprint" -ForegroundColor Gray
    Write-Host ""
}

Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                      END OF REPORT                             ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# Export option
Write-Host "💾 Export Options:" -ForegroundColor Yellow
Write-Host "  To export to CSV: `$AllTasks | Export-Csv -Path 'task-report.csv' -NoTypeInformation" -ForegroundColor Gray
Write-Host "  To export to JSON: `$AllTasks | ConvertTo-Json | Out-File 'task-report.json'" -ForegroundColor Gray
Write-Host ""
