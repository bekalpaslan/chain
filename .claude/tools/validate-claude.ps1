<#
validate-claude.ps1

Validates .claude/status.json is valid JSON and that each line in .claude/logs/*.log is valid JSON (JSONL).
Exits with non-zero on validation failure.
#>

param(
    [string] $ClaudeDir = $null
)

# Try multiple ways to find the .claude directory: explicit param, PSScriptRoot relatives, or current working directory
$candidates = @()
if ($ClaudeDir) { $candidates += (Join-Path $ClaudeDir ".claude") }
$candidates += (Join-Path $PSScriptRoot "..\.claude")
$candidates += (Join-Path $PSScriptRoot "..\..\.claude")
$candidates += (Join-Path (Get-Location) ".claude")

$claudeRoot = $null
foreach ($cand in $candidates) {
    if (Test-Path $cand) { $claudeRoot = $cand; break }
}
if (-not $claudeRoot) {
    # Fallback to literal .claude in repo root
    $claudeRoot = Join-Path (Get-Location) ".claude"
}

$statusFile = Join-Path $claudeRoot "status.json"
if (-not (Test-Path $statusFile)) {
    Write-Error ".claude/status.json not found"
    exit 2
}

# Validate status.json
try {
    Get-Content -Raw -LiteralPath $statusFile | ConvertFrom-Json -ErrorAction Stop | Out-Null
    Write-Output "status.json: OK"
}
catch {
    Write-Error "status.json is not valid JSON: $_"
    exit 3
}

# Validate logs
$logsDir = Join-Path $claudeRoot "logs"
if (-not (Test-Path $logsDir)) {
    Write-Output "No logs directory found; skipping logs validation."
    exit 0
}

$failed = $false
Get-ChildItem -Path $logsDir -Filter *.log -File -ErrorAction SilentlyContinue | ForEach-Object {
    $file = $_.FullName
    $lineNum = 0
    Get-Content -LiteralPath $file | ForEach-Object {
        $line = $_
        $lineNum++
        if ([string]::IsNullOrWhiteSpace($line)) { return }
        try {
            $line | ConvertFrom-Json -ErrorAction Stop | Out-Null
        }
        catch {
            Write-Error "Invalid JSON in ${file} at line ${lineNum}: ${line}"
            $failed = $true
        }
        # Additional semantic checks on work-item fields
        try {
            $obj = $line | ConvertFrom-Json -ErrorAction Stop
            if ($null -ne $obj.affected_agents -or ($null -ne $obj.risk_level -and $obj.risk_level -ne 'low')) {
                # Enforce potential_consequences (array) and mitigation (string)
                if (-not $obj.potential_consequences) {
                    Write-Error "Missing 'potential_consequences' for high-impact entry in ${file} at line ${lineNum}"
                    $failed = $true
                }
                if (-not $obj.mitigation) {
                    Write-Error "Missing 'mitigation' for high-impact entry in ${file} at line ${lineNum}"
                    $failed = $true
                }
                # Validate severity values inside potential_consequences
                if ($obj.potential_consequences) {
                    foreach ($pc in $obj.potential_consequences) {
                        if ((($pc.severity) -ne 'low') -and (($pc.severity) -ne 'medium') -and (($pc.severity) -ne 'high') -and (($pc.severity) -ne 'critical')) {
                            Write-Error "Invalid severity '$($pc.severity)' in potential_consequences in ${file} at line ${lineNum}"
                            $failed = $true
                        }
                    }
                }
            }
        } catch {
            # ignore convert errors already reported
        }
    }
}

if ($failed) { exit 4 } else { Write-Output "All logs: OK"; exit 0 }
