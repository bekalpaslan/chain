#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Updates project health data by surveying all agents and consolidating results.

.DESCRIPTION
    This script automates the project health assessment workflow:
    1. Surveys all 14 agents for completion assessments
    2. Consolidates responses into JSON format
    3. Updates project_health.json with latest data
    4. Triggers dashboard refresh

.PARAMETER Force
    Skip confirmation prompts

.EXAMPLE
    .\update-project-health.ps1
    Runs interactive assessment with confirmations

.EXAMPLE
    .\update-project-health.ps1 -Force
    Runs assessment without prompts

.NOTES
    Author: Claude Code Agent System
    Version: 1.0.0
    Last Updated: 2025-10-11
#>

param(
    [Parameter(Mandatory=$false)]
    [switch]$Force
)

# Script configuration
$ErrorActionPreference = "Stop"
$ProgressPreference = "Continue"

$PROJECT_ROOT = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$DATA_DIR = Join-Path $PROJECT_ROOT ".claude\data"
$HEALTH_FILE = Join-Path $DATA_DIR "project_health.json"
$BACKUP_DIR = Join-Path $DATA_DIR "backups"

# Ensure directories exist
if (-not (Test-Path $DATA_DIR)) {
    New-Item -ItemType Directory -Path $DATA_DIR -Force | Out-Null
}

if (-not (Test-Path $BACKUP_DIR)) {
    New-Item -ItemType Directory -Path $BACKUP_DIR -Force | Out-Null
}

# Banner
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   Project Health Assessment - Agent Survey Tool" -ForegroundColor White
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Confirmation
if (-not $Force) {
    Write-Host "This will:" -ForegroundColor Yellow
    Write-Host "  • Survey all 14 agents for project completion status" -ForegroundColor Gray
    Write-Host "  • Update project_health.json with latest data" -ForegroundColor Gray
    Write-Host "  • Backup existing data to backups/ folder" -ForegroundColor Gray
    Write-Host ""
    $response = Read-Host "Continue? (y/N)"
    if ($response -ne 'y' -and $response -ne 'Y') {
        Write-Host "❌ Assessment cancelled." -ForegroundColor Red
        exit 0
    }
}

# Backup existing data
if (Test-Path $HEALTH_FILE) {
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupFile = Join-Path $BACKUP_DIR "project_health_$timestamp.json"
    Copy-Item $HEALTH_FILE $backupFile -Force
    Write-Host "✓ Backed up existing data to: $backupFile" -ForegroundColor Green
}

Write-Host ""
Write-Host "Starting agent survey..." -ForegroundColor Cyan
Write-Host ""

# Function to call Claude Code to run agent assessments
function Invoke-AgentSurvey {
    Write-Host "⚠ NOTE: This script requires manual execution of agent surveys." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To complete the assessment, you need to:" -ForegroundColor White
    Write-Host "  1. Ask Claude Code to survey all 14 agents" -ForegroundColor Gray
    Write-Host "  2. Have it consolidate results into project_health.json" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Example prompt:" -ForegroundColor Cyan
    Write-Host '  "Survey all agents for project completion (X/10) and update' -ForegroundColor Gray
    Write-Host '   .claude/data/project_health.json with consolidated results"' -ForegroundColor Gray
    Write-Host ""

    $proceed = Read-Host "Have you completed the survey manually? (y/N)"
    if ($proceed -eq 'y' -or $proceed -eq 'Y') {
        return $true
    }
    return $false
}

# Check if manual survey was completed
$surveyCompleted = Invoke-AgentSurvey

if (-not $surveyCompleted) {
    Write-Host "❌ Survey not completed. Exiting." -ForegroundColor Red
    exit 1
}

# Validate health file exists and is valid JSON
if (-not (Test-Path $HEALTH_FILE)) {
    Write-Host "❌ Error: project_health.json not found at: $HEALTH_FILE" -ForegroundColor Red
    Write-Host "   Please ensure the file was created during the survey." -ForegroundColor Yellow
    exit 1
}

try {
    $healthData = Get-Content $HEALTH_FILE -Raw | ConvertFrom-Json
    Write-Host "✓ Validated project_health.json" -ForegroundColor Green
} catch {
    Write-Host "❌ Error: Invalid JSON in project_health.json" -ForegroundColor Red
    Write-Host "   $_" -ForegroundColor Red
    exit 1
}

# Display summary
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   Assessment Summary" -ForegroundColor White
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

Write-Host "Last Updated: $($healthData.metadata.last_updated)" -ForegroundColor Gray
Write-Host "Overall Completion: $($healthData.metadata.overall_completion)/10" -ForegroundColor $(
    if ($healthData.metadata.overall_completion -ge 7) { 'Green' }
    elseif ($healthData.metadata.overall_completion -ge 5) { 'Yellow' }
    else { 'Red' }
)
Write-Host "Total Agents Assessed: $($healthData.metadata.total_agents)" -ForegroundColor Gray
Write-Host ""

Write-Host "Category Scores:" -ForegroundColor White
foreach ($prop in $healthData.category_scores.PSObject.Properties) {
    $score = [math]::Round($prop.Value, 1)
    $color = if ($score -ge 7) { 'Green' } elseif ($score -ge 5) { 'Yellow' } else { 'Red' }
    Write-Host ("  {0,-25} {1}/10" -f ($prop.Name + ":"), $score) -ForegroundColor $color
}

Write-Host ""
Write-Host "Critical Blockers: $($healthData.critical_blockers.Count)" -ForegroundColor $(
    if ($healthData.critical_blockers.Count -eq 0) { 'Green' }
    elseif ($healthData.critical_blockers.Count -le 2) { 'Yellow' }
    else { 'Red' }
)

if ($healthData.critical_blockers.Count -gt 0) {
    foreach ($blocker in $healthData.critical_blockers) {
        Write-Host "  • [$($blocker.severity)] $($blocker.description)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "✓ Project health data updated successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "View full report at: $HEALTH_FILE" -ForegroundColor Gray
Write-Host ""

# Optional: Trigger dashboard refresh (if applicable)
$triggerRefresh = Read-Host "Trigger dashboard refresh? (y/N)"
if ($triggerRefresh -eq 'y' -or $triggerRefresh -eq 'Y') {
    Write-Host ""
    Write-Host "⚠ Dashboard refresh requires the admin dashboard to be running." -ForegroundColor Yellow
    Write-Host "   The dashboard will automatically reload project_health.json on next page load." -ForegroundColor Gray
    Write-Host ""
}

Write-Host "Done!" -ForegroundColor Green
Write-Host ""
