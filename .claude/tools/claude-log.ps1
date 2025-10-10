<#
claude-log.ps1

Tiny wrapper CLI for PowerShell-based agents.
Reads a JSON object from stdin and either appends it as a log line (requires -Agent) or writes a snapshot when -Snapshot switch is used.

Examples:
  Get-Content entry.json | . .\.claude\tools\claude-log.ps1 -Agent web-dev-master
  Get-Content snapshot.json | . .\.claude\tools\claude-log.ps1 -Snapshot
#>

param(
    [string] $Agent,
    [switch] $Snapshot
)

# Dot-source the helper (assumes relative layout)
. "$PSScriptRoot\update-status.ps1"

$stdin = [Console]::In.ReadToEnd().Trim()
if ([string]::IsNullOrWhiteSpace($stdin)) {
    Write-Error "No JSON provided on stdin."
    exit 2
}

try {
    $obj = $stdin | ConvertFrom-Json -ErrorAction Stop
}
catch {
    Write-Error "Failed to parse JSON from stdin: $_"
    exit 3
}

if ($Snapshot) {
    # Write snapshot atomically
    Set-ClaudestatusAtomically -StatusObject $obj
    Write-Output "Wrote snapshot to .claude/status.json"
    exit 0
}

if (-not $Agent) {
    Write-Error "When not using -Snapshot, you must specify -Agent <name> to append a log entry."
    exit 4
}

Add-ClaudelogEntry -Agent $Agent -Entry $obj | Write-Output
