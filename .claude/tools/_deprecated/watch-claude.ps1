<#
watch-claude.ps1

Watches .claude/logs for new high/critical risk entries and appends an alert line to affected agents' logs.
Intended to run as a long-lived process or scheduled task.
#>

param(
    [string] $ClaudeRoot = (Join-Path $PSScriptRoot "..")
)

# Resolve .claude path
$claudePath = $null
$candidates = @(Join-Path $ClaudeRoot ".claude", Join-Path $PSScriptRoot "..\.claude", Join-Path (Get-Location) ".claude")
foreach($c in $candidates){ if (Test-Path $c){ $claudePath = $c; break } }
if (-not $claudePath) { Write-Error ".claude folder not found"; exit 2 }

$logsDir = Join-Path $claudePath "logs"
if (-not (Test-Path $logsDir)) { New-Item -ItemType Directory -Path $logsDir | Out-Null }

Write-Output "Watching logs in $logsDir for high/critical events..."

# Keep track of offsets per file
$offsets = @{}

while ($true) {
    Get-ChildItem -Path $logsDir -Filter *.log -File | ForEach-Object {
        $file = $_.FullName
        $last = 0
        if ($offsets.ContainsKey($file)) { $last = $offsets[$file] }
        $lines = Get-Content -LiteralPath $file -Encoding UTF8
        for ($i = $last; $i -lt $lines.Length; $i++) {
            $line = $lines[$i]
            if ([string]::IsNullOrWhiteSpace($line)) { continue }
            try {
                $obj = $line | ConvertFrom-Json -ErrorAction Stop
            } catch { continue }
            $shouldAlert = $false
            if ($null -ne $obj.risk_level) {
                if ($obj.risk_level -in @('high','critical')) { $shouldAlert = $true }
            }
            if ($null -ne $obj.potential_consequences) {
                foreach ($pc in $obj.potential_consequences) { if ($pc.severity -in @('high','critical')) { $shouldAlert = $true } }
            }
            if ($shouldAlert -and $obj.affected_agents) {
                foreach ($affected in $obj.affected_agents) {
                    $alert = @{
                        timestamp = (Get-Date).ToUniversalTime().ToString('o')
                        agent = $affected
                        status = 'alert'
                        findings = "ALERT: Agent '$($obj.agent)' reported high-risk task '$($obj.task_id)' affecting you: $($obj.potential_consequences | ConvertTo-Json -Compress)"
                        meta = @{ source = $obj.agent; related_task = $obj.task_id }
                    }
                    # Append alert to affected agent's log
                    $logFile = Join-Path $logsDir ("$affected.log")
                    $jsonLine = ($alert | ConvertTo-Json -Compress) + "`n"
                    Add-Content -LiteralPath $logFile -Value $jsonLine -Encoding UTF8
                    Write-Output "Appended alert to $logFile"
                }
            }
        }
        $offsets[$file] = $lines.Length
    }
    Start-Sleep -Seconds 2
}
