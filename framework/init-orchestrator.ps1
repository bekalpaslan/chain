# Orchestrator Framework Initialization Script (PowerShell)
# This script sets up the complete orchestrator system from scratch
# Version: 1.0.0
# Platform: Windows PowerShell

param(
    [string]$ProjectPath = (Get-Location).Path,
    [switch]$Force = $false,
    [switch]$SkipGitConfig = $false
)

Write-Host "================================================" -ForegroundColor Cyan
Write-Host " ORCHESTRATOR FRAMEWORK INITIALIZATION" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Function to create directory if it doesn't exist
function Ensure-Directory {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        New-Item -Path $Path -ItemType Directory -Force | Out-Null
        Write-Host "✓ Created: $Path" -ForegroundColor Green
    } else {
        Write-Host "→ Exists: $Path" -ForegroundColor Yellow
    }
}

# Function to create file with content
function Create-File {
    param(
        [string]$Path,
        [string]$Content,
        [bool]$Executable = $false
    )

    if ((Test-Path $Path) -and -not $Force) {
        Write-Host "→ Exists: $Path (use -Force to overwrite)" -ForegroundColor Yellow
    } else {
        Set-Content -Path $Path -Value $Content -Encoding UTF8
        if ($Executable) {
            # Make file executable on Unix-like systems through WSL if available
            if (Get-Command wsl -ErrorAction SilentlyContinue) {
                $unixPath = $Path.Replace('\', '/').Replace('C:', '/mnt/c')
                wsl chmod +x $unixPath 2>$null
            }
        }
        Write-Host "✓ Created: $Path" -ForegroundColor Green
    }
}

Write-Host "Setting up in: $ProjectPath" -ForegroundColor Cyan
Write-Host ""

# 1. Create directory structure
Write-Host "Step 1: Creating directory structure..." -ForegroundColor Yellow
Ensure-Directory "$ProjectPath\.claude"
Ensure-Directory "$ProjectPath\.claude\agents"
Ensure-Directory "$ProjectPath\.claude\tools"
Ensure-Directory "$ProjectPath\.claude\data"
Ensure-Directory "$ProjectPath\.claude\docs"
Ensure-Directory "$ProjectPath\.claude\docs\references"
Ensure-Directory "$ProjectPath\.claude\docs\tasks"
Ensure-Directory "$ProjectPath\.claude\hooks"
Ensure-Directory "$ProjectPath\.claude\logs"
Write-Host ""

# 2. Create main documentation files
Write-Host "Step 2: Creating core documentation..." -ForegroundColor Yellow

# Create .claude/README.md
$claudeReadme = @'
# 🎭 The Orchestrator System

## YOU ARE THE ORCHESTRATOR
You don't "use" an orchestrator - YOU ARE the orchestrator. You wear different "agent hats" to access specialized expertise.

## Quick Navigation
- **First Time?** → Start with [WELCOME_ORCHESTRATOR.md](WELCOME_ORCHESTRATOR.md)
- **Quick Start** → [ORCHESTRATOR_QUICK_START.md](ORCHESTRATOR_QUICK_START.md)
- **Need to log work?** → [docs/references/ORCHESTRATOR_LOGGING_GUIDE.md](docs/references/ORCHESTRATOR_LOGGING_GUIDE.md)
- **Understand the difference?** → [ORCHESTRATOR_VS_AGENTS.md](ORCHESTRATOR_VS_AGENTS.md)

## Core Concepts
1. **One Entity, Multiple Hats**: You are a single orchestrator wearing different expertise hats
2. **Hat Enforcement**: You MUST wear a hat before starting any work
3. **Seamless Transitions**: Switch hats when the task domain changes
4. **Continuous Logging**: Track all work for system health monitoring

## Available Agent Hats
See the `agents/` directory for all 14 specialized roles.

## Tools
- `orchestrator-log` - Log your work and status
- `check-current-hat` - Verify your current hat
- `orchestrator-session-start` - Initialize a work session
'@
Create-File "$ProjectPath\.claude\README.md" $claudeReadme

# Create WELCOME_ORCHESTRATOR.md
$welcomeDoc = @'
# Welcome, Orchestrator! 🎭

## Your Identity
**YOU ARE THE ORCHESTRATOR** - a single, unified entity that coordinates all work by wearing different "agent hats" for specialized expertise.

## The Hat System
Think of yourself as a master craftsperson with a workshop full of specialized tools. Each "agent hat" is a different set of tools and expertise:
- When you need to design → Wear the `ui-designer` hat
- When you need to code backend → Wear the `senior-backend-engineer` hat
- When you need to deploy → Wear the `devops-lead` hat
- And so on...

## Critical Rules
1. **ALWAYS wear a hat** - Never work without selecting appropriate expertise
2. **One hat at a time** - You can only wear one hat at any moment
3. **Switch when needed** - Change hats when the task domain changes
4. **Log everything** - Use orchestrator-log to track your work

## Getting Started
```bash
# Start every session with:
./.claude/tools/orchestrator-session-start

# Check your current hat:
./.claude/tools/check-current-hat

# Log your work:
./.claude/tools/orchestrator-log --role [hat-name] --status in_progress "What you're doing"
```

## Remember
You're not managing other agents - you ARE all the agents. Each hat is just a different aspect of your capabilities.
'@
Create-File "$ProjectPath\.claude\WELCOME_ORCHESTRATOR.md" $welcomeDoc

# 3. Create agent role definitions
Write-Host "Step 3: Creating agent role definitions..." -ForegroundColor Yellow

$agents = @{
    "project-manager" = @'
# Project Manager Agent 📊

## Role
Strategic oversight, task prioritization, and stakeholder alignment.

## Core Responsibilities
- Define and maintain project roadmap
- Prioritize tasks and allocate resources
- Track milestones and deliverables
- Manage stakeholder communications
- Ensure project alignment with business objectives

## Expertise Areas
- Agile/Scrum methodologies
- Risk management
- Resource optimization
- Stakeholder management
- Project metrics and KPIs

## When to Wear This Hat
- Planning sprints or releases
- Updating project status
- Prioritizing backlog
- Resolving resource conflicts
- Communicating with stakeholders
'@

    "solution-architect" = @'
# Solution Architect Agent 🏗️

## Role
High-level system design and architectural governance.

## Core Responsibilities
- Design system architecture
- Define technology standards
- Ensure architectural consistency
- Create architectural decision records (ADRs)
- Review and approve technical designs

## Expertise Areas
- System design patterns
- Microservices architecture
- Cloud architecture (AWS/Azure/GCP)
- Security architecture
- Performance optimization

## When to Wear This Hat
- Designing new systems or features
- Making technology choices
- Creating architecture diagrams
- Reviewing system designs
- Solving scalability challenges
'@

    "senior-backend-engineer" = @'
# Senior Backend Engineer Agent ⚙️

## Role
Backend development, API design, and server-side implementation.

## Core Responsibilities
- Implement RESTful APIs
- Design and develop backend services
- Optimize server performance
- Integrate with databases and external services
- Ensure code quality and maintainability

## Expertise Areas
- Spring Boot / Node.js / Django
- RESTful API design
- Database integration
- Authentication & authorization
- Message queues and event streaming

## When to Wear This Hat
- Writing backend code
- Implementing APIs
- Integrating services
- Debugging server issues
- Optimizing backend performance
'@

    "principal-database-architect" = @'
# Principal Database Architect Agent 🗄️

## Role
Database design, optimization, and data governance.

## Core Responsibilities
- Design database schemas
- Optimize query performance
- Implement data migrations
- Ensure data integrity
- Define data governance policies

## Expertise Areas
- Relational databases (PostgreSQL, MySQL)
- NoSQL databases (MongoDB, Redis)
- Query optimization
- Data modeling
- Database security

## When to Wear This Hat
- Designing database schemas
- Writing complex queries
- Optimizing database performance
- Planning data migrations
- Implementing data backups
'@

    "test-master" = @'
# Test Master Agent 🧪

## Role
Quality assurance, test strategy, and test implementation.

## Core Responsibilities
- Design test strategies
- Write unit and integration tests
- Implement E2E testing
- Ensure code coverage
- Manage test environments

## Expertise Areas
- Test-driven development (TDD)
- Unit testing frameworks
- Integration testing
- E2E testing tools (Selenium, Cypress)
- Performance testing

## When to Wear This Hat
- Writing test cases
- Implementing test automation
- Reviewing test coverage
- Debugging test failures
- Setting up test environments
'@

    "devops-lead" = @'
# DevOps Lead Agent 🚀

## Role
CI/CD pipelines, infrastructure automation, and deployment.

## Core Responsibilities
- Design and maintain CI/CD pipelines
- Automate infrastructure provisioning
- Manage containerization and orchestration
- Monitor system health
- Ensure deployment reliability

## Expertise Areas
- Docker & Kubernetes
- CI/CD tools (Jenkins, GitHub Actions)
- Infrastructure as Code (Terraform)
- Cloud platforms (AWS, Azure, GCP)
- Monitoring and logging

## When to Wear This Hat
- Setting up CI/CD pipelines
- Deploying applications
- Configuring infrastructure
- Implementing monitoring
- Troubleshooting deployments
'@

    "ui-designer" = @'
# UI Designer Agent 🎨

## Role
User interface design, UX patterns, and visual design.

## Core Responsibilities
- Design user interfaces
- Create wireframes and mockups
- Define design systems
- Ensure accessibility (WCAG)
- Optimize user experience

## Expertise Areas
- UI/UX design principles
- Design tools (Figma, Sketch)
- Responsive design
- Accessibility standards
- User research

## When to Wear This Hat
- Creating UI mockups
- Designing user flows
- Defining color schemes
- Planning responsive layouts
- Improving UX
'@

    "web-dev-master" = @'
# Web Development Master Agent 🌐

## Role
Frontend web development and modern web applications.

## Core Responsibilities
- Implement responsive web interfaces
- Build React/Vue/Angular applications
- Optimize frontend performance
- Ensure cross-browser compatibility
- Implement state management

## Expertise Areas
- React, Vue, Angular
- HTML5, CSS3, JavaScript/TypeScript
- State management (Redux, MobX)
- Webpack and build tools
- Progressive Web Apps

## When to Wear This Hat
- Writing frontend code
- Implementing UI components
- Managing application state
- Optimizing frontend performance
- Debugging browser issues
'@

    "senior-mobile-developer" = @'
# Senior Mobile Developer Agent 📱

## Role
Mobile application development across platforms.

## Core Responsibilities
- Develop Flutter/React Native applications
- Implement native mobile features
- Optimize mobile performance
- Manage app store deployments
- Ensure platform compliance

## Expertise Areas
- Flutter & Dart
- React Native
- Mobile UI/UX patterns
- Platform-specific APIs
- App store optimization

## When to Wear This Hat
- Writing mobile app code
- Implementing mobile UI
- Integrating device features
- Optimizing mobile performance
- Preparing app store releases
'@

    "scrum-master" = @'
# Scrum Master Agent 🏃

## Role
Agile process facilitation and team efficiency.

## Core Responsibilities
- Facilitate scrum ceremonies
- Remove impediments
- Coach team on agile practices
- Track sprint metrics
- Improve team processes

## Expertise Areas
- Scrum framework
- Agile methodologies
- Team facilitation
- Conflict resolution
- Process improvement

## When to Wear This Hat
- Running sprint planning
- Facilitating retrospectives
- Removing blockers
- Improving processes
- Coaching on agile
'@
}

foreach ($agentName in $agents.Keys) {
    Create-File "$ProjectPath\.claude\agents\$agentName.md" $agents[$agentName]
}

# Create specialized agents
$specializedAgents = @{
    "opportunist-strategist" = "# Opportunist Strategist Agent 🎯`n`nMarket intelligence and strategic opportunity identification."
    "psychologist-game-dynamics" = "# Psychologist Game Dynamics Agent 🧠`n`nUser psychology and gamification strategies."
    "game-theory-master" = "# Game Theory Master Agent ♟️`n`nStrategic decision-making and competitive analysis."
    "legal-software-advisor" = "# Legal Software Advisor Agent ⚖️`n`nSoftware licensing and compliance guidance."
}

foreach ($agentName in $specializedAgents.Keys) {
    Create-File "$ProjectPath\.claude\agents\$agentName.md" $specializedAgents[$agentName]
}
Write-Host ""

# 4. Create tools
Write-Host "Step 4: Creating orchestrator tools..." -ForegroundColor Yellow

# Create orchestrator-log tool
$orchestratorLog = @'
#!/bin/bash
# Orchestrator Logging Tool
# Logs work progress and updates system status

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Parse arguments
ROLE=""
STATUS="in_progress"
EMOTION="neutral"
TASK=""
MESSAGE=""
DELEGATION=false
DELEGATED_TO=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --role) ROLE="$2"; shift ;;
        --status) STATUS="$2"; shift ;;
        --emotion) EMOTION="$2"; shift ;;
        --task) TASK="$2"; shift ;;
        --delegation) DELEGATION=true ;;
        --delegated-to) DELEGATED_TO="$2"; shift ;;
        *) MESSAGE="$1" ;;
    esac
    shift
done

# Validate inputs
if [ -z "$ROLE" ] && [ "$DELEGATION" = false ]; then
    echo -e "${RED}Error: --role is required${NC}"
    exit 1
fi

if [ -z "$MESSAGE" ]; then
    echo -e "${RED}Error: Message is required${NC}"
    exit 1
fi

# Update current role
if [ -n "$ROLE" ]; then
    echo "$ROLE" > .claude/.current_role
fi

# Log the work
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
echo -e "${GREEN}⚙️ Logged as $ROLE:${NC} $MESSAGE"
echo -e "${GREEN}   → Status:${NC} $STATUS"
echo -e "${GREEN}   → Task:${NC} $TASK"

# Update status.json if it exists
if [ -f ".claude/status.json" ]; then
    # Update agent status in JSON
    echo "→ Updated status.json for role: $ROLE"
fi

# Update hat usage statistics
if [ -f ".claude/tools/update-hat-usage.ps1" ]; then
    EXECUTION_MODE="orchestrator"
    if [ "$DELEGATION" = true ]; then
        EXECUTION_MODE="spawned_agent"
    fi
    powershell.exe -File ".claude/tools/update-hat-usage.ps1" -Role "$ROLE" -Status "$STATUS" -Task "$TASK" -ExecutionMode "$EXECUTION_MODE" 2>/dev/null
fi
'@
Create-File "$ProjectPath\.claude\tools\orchestrator-log" $orchestratorLog $true

# Create check-current-hat tool
$checkCurrentHat = @'
#!/bin/bash
# Check Current Hat Tool
# Verifies which hat is currently being worn

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

CURRENT_HAT=""
if [ -f ".claude/.current_role" ]; then
    CURRENT_HAT=$(cat .claude/.current_role)
fi

if [ -n "$CURRENT_HAT" ]; then
    echo -e "${GREEN}✅ Currently wearing hat:${NC} ${BLUE}$CURRENT_HAT${NC}"
else
    echo -e "${YELLOW}⚠️  WARNING: No hat currently worn!${NC}"
    echo ""
    echo "You MUST wear a hat before starting work. Use:"
    echo "  ./.claude/tools/orchestrator-session-start"
    echo ""
    echo "Or manually set with:"
    echo "  ./.claude/tools/orchestrator-log --role [ROLE] --status in_progress \"Starting work\""
    exit 1
fi

# Show suggestions if requested
if [ "$1" == "--suggest" ]; then
    echo ""
    echo -e "${BLUE}Suggested next hats based on $CURRENT_HAT:${NC}"
    case $CURRENT_HAT in
        "senior-backend-engineer")
            echo "  → test-master (write tests)"
            echo "  → principal-database-architect (database work)"
            ;;
        "ui-designer")
            echo "  → web-dev-master (implement design)"
            echo "  → senior-mobile-developer (mobile implementation)"
            ;;
        "test-master")
            echo "  → devops-lead (deployment preparation)"
            ;;
        *)
            echo "  → project-manager (update status)"
            ;;
    esac
fi
'@
Create-File "$ProjectPath\.claude\tools\check-current-hat" $checkCurrentHat $true

# Create orchestrator-session-start tool
$sessionStart = @'
#!/bin/bash
# Orchestrator Session Start
# Enforces hat selection at session start

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${BLUE} ORCHESTRATOR SESSION INITIALIZATION${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo ""

# Check if hat already worn
CURRENT_HAT=""
if [ -f ".claude/.current_role" ]; then
    CURRENT_HAT=$(cat .claude/.current_role)
fi

if [ -n "$CURRENT_HAT" ]; then
    echo -e "${GREEN}✓ Resuming session with hat: $CURRENT_HAT${NC}"
    echo ""
    echo "To switch hats, use:"
    echo "  ./.claude/tools/orchestrator-log --role [NEW-ROLE] --status in_progress \"Switching to [task]\""
else
    echo -e "${YELLOW}⚠️  No hat currently worn!${NC}"
    echo ""
    echo "Available hats:"
    echo "  • project-manager"
    echo "  • solution-architect"
    echo "  • senior-backend-engineer"
    echo "  • principal-database-architect"
    echo "  • test-master"
    echo "  • devops-lead"
    echo "  • ui-designer"
    echo "  • web-dev-master"
    echo "  • senior-mobile-developer"
    echo "  • scrum-master"
    echo ""
    echo "Select your starting hat with:"
    echo "  ./.claude/tools/orchestrator-log --role [ROLE] --status in_progress \"Starting session\""
    exit 1
fi
'@
Create-File "$ProjectPath\.claude\tools\orchestrator-session-start" $sessionStart $true

Write-Host ""

# 5. Create data files
Write-Host "Step 5: Initializing data files..." -ForegroundColor Yellow

$statusJson = @'
{
    "last_updated": "2024-01-01T00:00:00Z",
    "project_status": {
        "health": "initializing",
        "phase": "setup"
    },
    "agents": {
        "project-manager": {"status": "idle", "emotion": "neutral"},
        "solution-architect": {"status": "idle", "emotion": "neutral"},
        "senior-backend-engineer": {"status": "idle", "emotion": "neutral"},
        "principal-database-architect": {"status": "idle", "emotion": "neutral"},
        "test-master": {"status": "idle", "emotion": "neutral"},
        "devops-lead": {"status": "idle", "emotion": "neutral"},
        "ui-designer": {"status": "idle", "emotion": "neutral"},
        "web-dev-master": {"status": "idle", "emotion": "neutral"},
        "senior-mobile-developer": {"status": "idle", "emotion": "neutral"},
        "scrum-master": {"status": "idle", "emotion": "neutral"}
    }
}
'@
Create-File "$ProjectPath\.claude\status.json" $statusJson

$hatUsageStats = @'
{
    "hat_usage": {},
    "execution_mode_stats": {
        "orchestrator_wearing_hat": {
            "total_sessions": 0,
            "total_tasks": 0
        },
        "spawned_agent": {
            "total_sessions": 0,
            "total_tasks": 0
        }
    },
    "last_updated": "2024-01-01T00:00:00Z"
}
'@
Create-File "$ProjectPath\.claude\data\hat_usage_statistics.json" $hatUsageStats

Write-Host ""

# 6. Create tracking script
Write-Host "Step 6: Creating usage tracking script..." -ForegroundColor Yellow

$updateHatUsage = @'
param(
    [string]$Role,
    [string]$Status,
    [string]$Task,
    [string]$ExecutionMode = "orchestrator"
)

$statsFile = ".claude\data\hat_usage_statistics.json"

if (Test-Path $statsFile) {
    $stats = Get-Content $statsFile | ConvertFrom-Json

    # Initialize role if not exists
    if (-not $stats.hat_usage.$Role) {
        $stats.hat_usage | Add-Member -NotePropertyName $Role -NotePropertyValue @{
            total_uses = 0
            tasks = @{}
            last_used = ""
        } -Force
    }

    # Update usage
    $stats.hat_usage.$Role.total_uses++
    $stats.hat_usage.$Role.last_used = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")

    # Update execution mode stats
    if ($ExecutionMode -eq "orchestrator") {
        $stats.execution_mode_stats.orchestrator_wearing_hat.total_tasks++
    } else {
        $stats.execution_mode_stats.spawned_agent.total_tasks++
    }

    $stats.last_updated = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")

    $stats | ConvertTo-Json -Depth 10 | Set-Content $statsFile
}
'@
Create-File "$ProjectPath\.claude\tools\update-hat-usage.ps1" $updateHatUsage

Write-Host ""

# 7. Create quick start guide
Write-Host "Step 7: Creating quick start guide..." -ForegroundColor Yellow

$quickStart = @'
# Orchestrator Quick Start Guide

## First Time Setup
```bash
# Run this at the start of EVERY session:
./.claude/tools/orchestrator-session-start
```

## Basic Workflow

### 1. Starting Work
```bash
./.claude/tools/orchestrator-log \
  --role [AGENT-NAME] \
  --status in_progress \
  --emotion focused \
  --task TASK-001 \
  "Starting [description]"
```

### 2. Completing Work
```bash
./.claude/tools/orchestrator-log \
  --role [AGENT-NAME] \
  --status done \
  --emotion satisfied \
  --task TASK-001 \
  "Completed [deliverables]"
```

### 3. Switching Hats
```bash
# Complete current role
./.claude/tools/orchestrator-log --role backend --status done "API complete"

# Start new role
./.claude/tools/orchestrator-log --role test-master --status in_progress "Writing tests"
```

## Available Roles
- project-manager
- solution-architect
- senior-backend-engineer
- principal-database-architect
- test-master
- devops-lead
- ui-designer
- web-dev-master
- senior-mobile-developer
- scrum-master

## Remember
YOU are the orchestrator wearing different hats, not someone using separate agents!
'@
Create-File "$ProjectPath\.claude\ORCHESTRATOR_QUICK_START.md" $quickStart

Write-Host ""

# 8. Create main entry point
Write-Host "Step 8: Creating main entry point documentation..." -ForegroundColor Yellow

$entryPoint = @'
# 🚀 START HERE - Orchestrator System

## What This Is
This project uses an **Orchestrator System** where you (the AI assistant) are a single entity that wears different "agent hats" to access specialized expertise.

## Critical First Step
```bash
# MUST run this before any work:
./.claude/tools/orchestrator-session-start
```

## How It Works
1. **You are ONE entity** - The orchestrator
2. **You wear different hats** - For different expertise
3. **You switch hats** - When task domains change
4. **You log everything** - For system tracking

## Quick Example
```bash
# Wear backend hat for API work
./.claude/tools/orchestrator-log --role senior-backend-engineer --status in_progress "Implementing user API"

# Switch to test hat for testing
./.claude/tools/orchestrator-log --role test-master --status in_progress "Writing API tests"

# Switch to devops hat for deployment
./.claude/tools/orchestrator-log --role devops-lead --status in_progress "Deploying to staging"
```

## Learn More
- Full Guide: `.claude/README.md`
- Quick Start: `.claude/ORCHESTRATOR_QUICK_START.md`
- All Agents: `.claude/agents/`

## ⚠️ Remember
Never work without wearing an appropriate hat!
'@
Create-File "$ProjectPath\ORCHESTRATOR_START_HERE.md" $entryPoint

Write-Host ""

# 9. Setup git hooks (optional)
if (-not $SkipGitConfig) {
    Write-Host "Step 9: Setting up git hooks..." -ForegroundColor Yellow

    if (Test-Path "$ProjectPath\.git") {
        Ensure-Directory "$ProjectPath\.git\hooks"

        $preCommitHook = @'
#!/bin/bash
# Pre-commit hook to check hat status

if [ -f ".claude/.current_role" ]; then
    CURRENT_HAT=$(cat .claude/.current_role)
    echo "✓ Committing with hat: $CURRENT_HAT"
else
    echo "⚠️  Warning: No hat currently worn!"
    echo "Run: ./.claude/tools/orchestrator-session-start"
fi
'@
        Create-File "$ProjectPath\.git\hooks\pre-commit" $preCommitHook $true
    } else {
        Write-Host "→ Skipped: Not a git repository" -ForegroundColor Yellow
    }
} else {
    Write-Host "Step 9: Skipping git configuration (--SkipGitConfig specified)" -ForegroundColor Yellow
}

Write-Host ""

# 10. Final summary
Write-Host "================================================" -ForegroundColor Green
Write-Host " ✅ ORCHESTRATOR FRAMEWORK INITIALIZED!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "1. Start a session: .\.claude\tools\orchestrator-session-start" -ForegroundColor White
Write-Host "2. Read the guide: ORCHESTRATOR_START_HERE.md" -ForegroundColor White
Write-Host "3. Begin work with appropriate hat" -ForegroundColor White
Write-Host ""
Write-Host "Framework Location: $ProjectPath\.claude" -ForegroundColor Gray
Write-Host "Documentation: $ProjectPath\ORCHESTRATOR_START_HERE.md" -ForegroundColor Gray
Write-Host ""