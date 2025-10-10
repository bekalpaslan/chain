<#
.SYNOPSIS
    Generates standardized ISO 8601 timestamps for Claude agent logging system.

.DESCRIPTION
    This utility ensures all timestamps across the Claude agent system follow
    the canonical ISO 8601 UTC format with second precision (no milliseconds).

    Format: YYYY-MM-DDTHH:MM:SSZ
    Timezone: Always UTC (Z suffix)
    Precision: Seconds only (no microseconds/milliseconds)

.PARAMETER AsObject
    Returns a hashtable with both timestamp and formatted date components.

.EXAMPLE
    Get-ClaudeTimestamp
    # Output: 2025-10-10T10:52:14Z

.EXAMPLE
    $ts = Get-ClaudeTimestamp -AsObject
    # Returns: @{timestamp="2025-10-10T10:52:14Z"; date="2025-10-10"; time="10:52:14"}

.EXAMPLE
    # Using in agent logs
    $entry = @{
        timestamp = Get-ClaudeTimestamp
        agent = "project-manager"
        status = "working"
        emotion = "focused"
    }

.NOTES
    Author: Claude Code
    Version: 1.0.0
    Created: 2025-10-10

    IMPORTANT: Always use this function for timestamps to ensure consistency
    across all agent logs, status files, and task tracking systems.
#>

function Get-ClaudeTimestamp {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [switch]$AsObject
    )

    # Get current UTC time
    $utcNow = (Get-Date).ToUniversalTime()

    # Format to ISO 8601 with second precision (no milliseconds)
    # Format: yyyy-MM-ddTHH:mm:ssZ
    $timestamp = $utcNow.ToString("yyyy-MM-ddTHH:mm:ssZ")

    if ($AsObject) {
        # Return structured object with timestamp components
        return @{
            timestamp = $timestamp
            date = $utcNow.ToString("yyyy-MM-dd")
            time = $utcNow.ToString("HH:mm:ss")
            unix = [int][double]::Parse((Get-Date -Date $utcNow -UFormat %s))
        }
    }

    return $timestamp
}

# Export function if module is being loaded
if ($MyInvocation.InvocationName -ne '.') {
    Export-ModuleMember -Function Get-ClaudeTimestamp
}

# If script is executed directly, output example
if ($MyInvocation.InvocationName -eq '&') {
    Write-Host "Current Claude Timestamp: $(Get-ClaudeTimestamp)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Timestamp Object:" -ForegroundColor Cyan
    Get-ClaudeTimestamp -AsObject | Format-Table -AutoSize
}
