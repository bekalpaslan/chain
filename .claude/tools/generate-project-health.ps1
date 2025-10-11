#
# generate-project-health.ps1
#
# Transforms orchestrator logs and status.json into project_health.json
# for admin dashboard consumption
#
# Usage:
#   .\generate-project-health.ps1
#
# Outputs:
#   .claude/data/project_health.json - Dashboard-ready health metrics
#

param(
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"

# Navigate to project root
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent (Split-Path -Parent $scriptDir)
Set-Location $projectRoot

# Ensure output directory exists
New-Item -ItemType Directory -Path ".claude/data" -Force | Out-Null

# Read current status.json
$statusPath = ".claude/status.json"
if (-not (Test-Path $statusPath)) {
    Write-Error "❌ status.json not found"
    exit 1
}

$status = Get-Content $statusPath -Raw | ConvertFrom-Json

# Read orchestrator logs for metrics
$orchestratorLog = ".claude/logs/orchestrator.log"
$logs = @()
if (Test-Path $orchestratorLog) {
    $logs = Get-Content $orchestratorLog | ForEach-Object {
        try { $_ | ConvertFrom-Json } catch { $null }
    } | Where-Object { $_ -ne $null }
}

# Calculate metrics
$timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")

# Count tasks by status from logs
$taskStatuses = @{}
$recentLogs = $logs | Where-Object { $_.task } | Select-Object -Last 100
foreach ($log in $recentLogs) {
    if ($log.task -and $log.status -eq 'done') {
        $taskStatuses[$log.task] = 'completed'
    } elseif ($log.task -and $log.status -eq 'blocked') {
        $taskStatuses[$log.task] = 'blocked'
    } elseif ($log.task -and $log.status -in @('in_progress', 'working')) {
        if (-not $taskStatuses.ContainsKey($log.task)) {
            $taskStatuses[$log.task] = 'in_progress'
        }
    }
}

$completedTasks = ($taskStatuses.Values | Where-Object { $_ -eq 'completed' }).Count
$inProgressTasks = ($taskStatuses.Values | Where-Object { $_ -eq 'in_progress' }).Count
$blockedTasks = ($taskStatuses.Values | Where-Object { $_ -eq 'blocked' }).Count
$totalTasks = $taskStatuses.Count

# Calculate agent activity metrics
$activeAgents = 0
$blockedAgents = 0
$idleAgents = 0

foreach ($agent in $status.agents.PSObject.Properties) {
    switch ($agent.Value.status) {
        'in_progress' { $activeAgents++ }
        'working' { $activeAgents++ }
        'blocked' { $blockedAgents++ }
        'idle' { $idleAgents++ }
        'done' { $idleAgents++ }
    }
}

# Calculate health score (0-10)
$healthScore = 10.0
if ($blockedAgents -gt 0) { $healthScore -= ($blockedAgents * 0.5) }
if ($blockedTasks -gt 0) { $healthScore -= ($blockedTasks * 0.3) }
if ($activeAgents -eq 0) { $healthScore -= 2.0 }
if ($totalTasks -gt 0) {
    $completionRate = $completedTasks / $totalTasks
    $healthScore = [Math]::Max($healthScore, $completionRate * 10)
}
$healthScore = [Math]::Max(0, [Math]::Min(10, $healthScore))

# Determine health status
$healthStatus = if ($healthScore -ge 7) { "healthy" }
                elseif ($healthScore -ge 5) { "warning" }
                else { "critical" }

# Extract recent activity messages
$recentActivity = $logs | Select-Object -Last 5 | ForEach-Object {
    @{
        timestamp = $_.timestamp
        agent = $_.role
        message = $_.message
        status = $_.status
    }
}

# Build project health JSON
$projectHealth = @{
    timestamp = $timestamp
    health = @{
        score = [Math]::Round($healthScore, 1)
        status = $healthStatus
        lastCheck = $timestamp
    }
    agents = @{
        total = 14  # Fixed: 14 agents total
        active = $activeAgents
        blocked = $blockedAgents
        idle = $idleAgents
    }
    tasks = @{
        total = $totalTasks
        completed = $completedTasks
        inProgress = $inProgressTasks
        blocked = $blockedTasks
    }
    sprint = @{
        current = "Sprint 2025-10"
        progress = if ($totalTasks -gt 0) { [Math]::Round(($completedTasks / $totalTasks) * 100) } else { 0 }
        daysRemaining = (New-TimeSpan -Start (Get-Date) -End (Get-Date "2025-10-31")).Days
    }
    recentActivity = $recentActivity
    metrics = @{
        codeVelocity = @{
            value = $logs.Count
            unit = "logs/day"
            trend = "stable"
        }
        testCoverage = @{
            value = 0
            unit = "%"
            trend = "unknown"
        }
        deploymentFrequency = @{
            value = 0
            unit = "deploys/week"
            trend = "unknown"
        }
    }
}

# Save to file
$outputPath = ".claude/data/project_health.json"
$projectHealth | ConvertTo-Json -Depth 10 | Set-Content $outputPath -Encoding UTF8

if ($Verbose) {
    Write-Host "✅ Generated project_health.json" -ForegroundColor Green
    Write-Host "   Health Score: $healthScore/10 ($healthStatus)" -ForegroundColor Cyan
    Write-Host "   Active Agents: $activeAgents/$($status.agents.PSObject.Properties.Count)" -ForegroundColor Gray
    Write-Host "   Tasks: $completedTasks completed, $inProgressTasks in progress" -ForegroundColor Gray
    Write-Host "   Output: $outputPath" -ForegroundColor Gray
}

exit 0