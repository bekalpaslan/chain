<#
Update-StatusAtomically.ps1

Provides two helpers for consistent logging and atomic status updates:
- Add-ClaudelogEntry: appends a single JSON line to an agent's JSONL log in .claude/logs.
- Set-ClaudestatusAtomically: atomically replaces .claude/status.json with a new JSON object.

Usage examples:
# Append a log entry (object) for agent 'web-dev-master':
# $entry = @{ timestamp = (Get-Date).ToUniversalTime().ToString('o'); agent='web-dev-master'; status='working'; emotion='neutral' }
# Add-ClaudelogEntry -Agent 'web-dev-master' -Entry $entry

# Atomically update status.json:
# $status = @{ last_updated = (Get-Date).ToUniversalTime().ToString('o'); agents = @{ 'web-dev-master' = @{ status='working'; last_activity=(Get-Date).ToUniversalTime().ToString('o') } } }
# Set-ClaudestatusAtomically -StatusObject $status
#>

param()

function Add-ClaudelogEntry {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)] [string] $Agent,
        [Parameter(Mandatory=$true)] [object] $Entry,
        [string] $ClaudeDir = $null
    )

    # Find .claude directory using multiple fallback strategies
    if ($ClaudeDir) {
        $claudeRoot = Join-Path $ClaudeDir ".claude"
    } elseif ($PSScriptRoot) {
        # Try relative to script location first
        $claudeRoot = Resolve-Path -Path (Join-Path $PSScriptRoot "..") -ErrorAction SilentlyContinue
        if (-not (Test-Path (Join-Path $claudeRoot "status.json"))) {
            $claudeRoot = Resolve-Path -Path (Join-Path $PSScriptRoot "..\..\.claude") -ErrorAction SilentlyContinue
        }
    }

    # Fallback to current directory
    if (-not $claudeRoot -or -not (Test-Path $claudeRoot)) {
        $claudeRoot = Join-Path (Get-Location) ".claude"
    }

    $logsDir = Join-Path $claudeRoot "logs"
    if (-not (Test-Path $logsDir)) { New-Item -ItemType Directory -Path $logsDir -Force | Out-Null }

    $logFile = Join-Path $logsDir "$Agent.log"

    # Serialize to compact JSON and append as one line
    $json = if ($Entry -is [string]) { $Entry } else { $Entry | ConvertTo-Json -Compress -Depth 10 }
    $jsonLine = $json.Trim() + "`n"
    Add-Content -LiteralPath $logFile -Value $jsonLine -Encoding UTF8 -NoNewline

    Write-Output $logFile
}

function Set-ClaudestatusAtomically {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)] [object] $StatusObject,
        [string] $ClaudeDir = $null
    )

    # Find .claude directory using multiple fallback strategies
    if ($ClaudeDir) {
        $claudeRoot = Join-Path $ClaudeDir ".claude"
    } elseif ($PSScriptRoot) {
        # Try relative to script location first
        $claudeRoot = Resolve-Path -Path (Join-Path $PSScriptRoot "..") -ErrorAction SilentlyContinue
        if (-not (Test-Path (Join-Path $claudeRoot "status.json"))) {
            $claudeRoot = Resolve-Path -Path (Join-Path $PSScriptRoot "..\..\.claude") -ErrorAction SilentlyContinue
        }
    }

    # Fallback to current directory
    if (-not $claudeRoot -or -not (Test-Path $claudeRoot)) {
        $claudeRoot = Join-Path (Get-Location) ".claude"
    }

    if (-not (Test-Path $claudeRoot)) { New-Item -ItemType Directory -Path $claudeRoot -Force | Out-Null }

    $statusFile = Join-Path $claudeRoot "status.json"
    $tmpFile = [System.IO.Path]::GetTempFileName()

    try {
        $StatusObject | ConvertTo-Json -Depth 10 -Compress | Set-Content -LiteralPath $tmpFile -Encoding UTF8 -NoNewline
        # Replace atomically by moving on same volume
        Move-Item -Path $tmpFile -Destination $statusFile -Force
    }
    catch {
        Write-Error "Failed to write status atomically: $_"
        if (Test-Path $tmpFile) { Remove-Item $tmpFile -Force }
        throw
    }

    Write-Output $statusFile
}

# Note: Not using Export-ModuleMember as this is a .ps1 script, not a .psm1 module
# Functions are available when dot-sourced: . .\update-status.ps1
