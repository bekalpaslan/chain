#!/usr/bin/env pwsh
# Updates hat usage statistics when orchestrator switches or uses a hat

param(
    [Parameter(Mandatory=$true)]
    [string]$Role,

    [Parameter(Mandatory=$false)]
    [string]$Status = "in_progress",

    [Parameter(Mandatory=$false)]
    [string]$Task = "",

    [Parameter(Mandatory=$false)]
    [switch]$StartSession,

    [Parameter(Mandatory=$false)]
    [switch]$EndSession,

    [Parameter(Mandatory=$false)]
    [ValidateSet("orchestrator", "spawned_agent")]
    [string]$ExecutionMode = "orchestrator"
)

$statsFile = Join-Path $PSScriptRoot "../data/hat_usage_statistics.json"

# Ensure file exists
if (-not (Test-Path $statsFile)) {
    Write-Error "Hat usage statistics file not found at: $statsFile"
    exit 1
}

# Read current statistics
$stats = Get-Content $statsFile -Raw | ConvertFrom-Json

# Get current timestamp
$timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
$today = Get-Date -Format "yyyy-MM-dd"

# Update the specific hat statistics
if ($stats.hat_statistics.PSObject.Properties.Name -contains $Role) {
    $hatStats = $stats.hat_statistics.$Role

    if ($StartSession) {
        # Starting a new session with this hat
        $hatStats.total_sessions++
        $hatStats.last_worn = $timestamp

        # Add to session history
        $sessionEntry = @{
            role = $Role
            started_at = $timestamp
            ended_at = $null
            duration_minutes = 0
            task = $Task
            status = "active"
            execution_mode = $ExecutionMode
            is_orchestrator = ($ExecutionMode -eq "orchestrator")
        }
        $stats.session_history += $sessionEntry

        # Update execution mode statistics
        if ($ExecutionMode -eq "orchestrator") {
            $stats.execution_mode_stats.orchestrator_wearing_hat.total_sessions++
        } else {
            $stats.execution_mode_stats.spawned_agent.total_sessions++
        }

        Write-Host "🎩 Hat worn: $($hatStats.display_name)" -ForegroundColor Cyan
        Write-Host "   Total sessions: $($hatStats.total_sessions)" -ForegroundColor Gray
        Write-Host "   Last worn: $timestamp" -ForegroundColor Gray
    }
    elseif ($EndSession) {
        # Find and update the most recent active session for this role
        $activeSession = $stats.session_history |
            Where-Object { $_.role -eq $Role -and $_.status -eq "active" } |
            Select-Object -Last 1

        if ($activeSession) {
            $activeSession.ended_at = $timestamp
            $activeSession.status = "completed"

            # Calculate duration
            $startTime = [DateTime]::Parse($activeSession.started_at)
            $endTime = [DateTime]::Parse($timestamp)
            $duration = [Math]::Round(($endTime - $startTime).TotalMinutes, 2)
            $activeSession.duration_minutes = $duration

            # Update cumulative statistics
            $hatStats.total_duration_minutes += $duration
            if ($hatStats.total_sessions -gt 0) {
                $hatStats.average_session_minutes = [Math]::Round($hatStats.total_duration_minutes / $hatStats.total_sessions, 2)
            }

            Write-Host "🎩 Hat removed: $($hatStats.display_name)" -ForegroundColor Yellow
            Write-Host "   Session duration: $duration minutes" -ForegroundColor Gray
            Write-Host "   Average session: $($hatStats.average_session_minutes) minutes" -ForegroundColor Gray
        }
    }

    # Update task completion if status is "done"
    if ($Status -eq "done") {
        $hatStats.tasks_completed++

        # Update execution mode task statistics
        if ($ExecutionMode -eq "orchestrator") {
            $stats.execution_mode_stats.orchestrator_wearing_hat.total_tasks++
        } else {
            $stats.execution_mode_stats.spawned_agent.total_tasks++
        }

        # Update task associations
        if ($Task) {
            if (-not $stats.task_associations.PSObject.Properties.Name -contains $Task) {
                $stats.task_associations | Add-Member -NotePropertyName $Task -NotePropertyValue @{
                    primary_role = $Role
                    roles_involved = @($Role)
                    completed = $false
                    execution_mode = $ExecutionMode
                    completed_by_orchestrator = ($ExecutionMode -eq "orchestrator")
                }
            }
            else {
                if ($stats.task_associations.$Task.roles_involved -notcontains $Role) {
                    $stats.task_associations.$Task.roles_involved += $Role
                }
                if ($Status -eq "done") {
                    $stats.task_associations.$Task.completed = $true
                    $stats.task_associations.$Task.execution_mode = $ExecutionMode
                    $stats.task_associations.$Task.completed_by_orchestrator = ($ExecutionMode -eq "orchestrator")
                }
            }
        }

        $modeIndicator = if ($ExecutionMode -eq "orchestrator") { "🎭" } else { "🤖" }
        Write-Host "✅ Task completed by: $($hatStats.display_name) $modeIndicator" -ForegroundColor Green
        Write-Host "   Total tasks completed: $($hatStats.tasks_completed)" -ForegroundColor Gray
        Write-Host "   Execution mode: $ExecutionMode" -ForegroundColor Gray
    }

    # Update daily breakdown
    if (-not $stats.daily_breakdown.PSObject.Properties.Name -contains $today) {
        $stats.daily_breakdown | Add-Member -NotePropertyName $today -NotePropertyValue @{}
    }

    if (-not $stats.daily_breakdown.$today.PSObject.Properties.Name -contains $Role) {
        $stats.daily_breakdown.$today | Add-Member -NotePropertyName $Role -NotePropertyValue @{
            sessions = 0
            minutes = 0
            tasks_completed = 0
        }
    }

    if ($StartSession) {
        $stats.daily_breakdown.$today.$Role.sessions++
    }
    if ($EndSession -and $activeSession) {
        $stats.daily_breakdown.$today.$Role.minutes += $activeSession.duration_minutes
    }
    if ($Status -eq "done") {
        $stats.daily_breakdown.$today.$Role.tasks_completed++
    }
}
else {
    Write-Warning "Unknown role: $Role"
    exit 1
}

# Update metadata
$stats.metadata.last_updated = $timestamp

# Save updated statistics
$stats | ConvertTo-Json -Depth 10 | Set-Content $statsFile -Encoding UTF8

# Display usage summary
Write-Host "`n📊 Current Hat Usage Summary:" -ForegroundColor Magenta
$topHats = $stats.hat_statistics.PSObject.Properties |
    Where-Object { $_.Value.total_sessions -gt 0 } |
    Sort-Object { $_.Value.total_sessions } -Descending |
    Select-Object -First 5

foreach ($hat in $topHats) {
    $percentage = if ($hat.Value.total_duration_minutes -gt 0) {
        [Math]::Round(($hat.Value.total_duration_minutes / ($stats.hat_statistics.PSObject.Properties |
            Measure-Object -Property { $_.Value.total_duration_minutes } -Sum).Sum) * 100, 1)
    } else { 0 }

    Write-Host "   $($hat.Value.display_name): $($hat.Value.total_sessions) sessions, $percentage% time" -ForegroundColor Cyan
}

exit 0