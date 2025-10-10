# Multi-Agent Task Assignment Update Script
# Updates task.json files with correct agent assignments and current dates

$tasks = @{
    "TASK-004" = @{
        lead = "test-master"
        support = @("senior-backend-engineer", "senior-mobile-developer")
        due_days = 7
    }
    "TASK-005" = @{
        lead = "senior-backend-engineer"
        support = @("web-dev-master")
        due_days = 10
    }
    "TASK-006" = @{
        lead = "web-dev-master"
        support = @("ui-designer", "senior-backend-engineer")
        due_days = 8
    }
    "TASK-007" = @{
        lead = "principal-database-architect"
        support = @("senior-backend-engineer", "devops-lead")
        due_days = 12
    }
    "TASK-008" = @{
        lead = "web-dev-master"
        support = @("ui-designer", "senior-backend-engineer")
        due_days = 9
    }
}

$currentDate = (Get-Date).ToUniversalTime()
$timestamp = $currentDate.ToString("yyyy-MM-ddTHH:mm:ssZ")

foreach ($taskId in $tasks.Keys) {
    $taskInfo = $tasks[$taskId]
    $taskDir = Get-ChildItem ".claude/tasks/_active" | Where-Object { $_.Name -like "$taskId-*" } | Select-Object -First 1

    if ($taskDir) {
        $taskFile = Join-Path $taskDir.FullName "task.json"

        if (Test-Path $taskFile) {
            Write-Host "Updating $taskId..." -ForegroundColor Cyan

            $task = Get-Content $taskFile -Raw | ConvertFrom-Json

            # Update agent assignments
            $task.assigned_to = $taskInfo.lead
            $task | Add-Member -MemberType NoteProperty -Name "support_agents" -Value $taskInfo.support -Force

            # Update timestamps
            $task.updated_at = $timestamp
            $task.created_at = $currentDate.ToString("yyyy-MM-ddT10:00:00Z")
            $task.due_date = $currentDate.AddDays($taskInfo.due_days).ToString("yyyy-MM-ddT18:00:00Z")

            # Update sprint
            $task.sprint = "SPRINT-2025-10"

            # Save updated task
            $task | ConvertTo-Json -Depth 10 | Set-Content $taskFile

            Write-Host "  ✓ Lead: $($taskInfo.lead)" -ForegroundColor Green
            Write-Host "  ✓ Support: $($taskInfo.support -join ', ')" -ForegroundColor Green
        }
    }
}

Write-Host "`nTask assignments updated successfully!" -ForegroundColor Green
