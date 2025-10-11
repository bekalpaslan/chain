#!/bin/bash
# Orchestrator Framework Initialization Script (Bash)
# This script sets up the complete orchestrator system from scratch
# Version: 1.0.0
# Platform: Unix/Linux/macOS

# Default values
PROJECT_PATH=$(pwd)
FORCE=false
SKIP_GIT_CONFIG=false

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --project-path) PROJECT_PATH="$2"; shift ;;
        --force) FORCE=true ;;
        --skip-git-config) SKIP_GIT_CONFIG=true ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  --project-path PATH    Set project path (default: current directory)"
            echo "  --force               Overwrite existing files"
            echo "  --skip-git-config     Skip git hooks configuration"
            echo "  --help                Show this help message"
            exit 0
            ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

echo -e "${CYAN}================================================${NC}"
echo -e "${CYAN} ORCHESTRATOR FRAMEWORK INITIALIZATION${NC}"
echo -e "${CYAN}================================================${NC}"
echo ""

# Function to create directory if it doesn't exist
ensure_directory() {
    local path="$1"
    if [ ! -d "$path" ]; then
        mkdir -p "$path"
        echo -e "${GREEN}✓ Created: $path${NC}"
    else
        echo -e "${YELLOW}→ Exists: $path${NC}"
    fi
}

# Function to create file with content
create_file() {
    local path="$1"
    local content="$2"
    local executable="${3:-false}"

    if [ -f "$path" ] && [ "$FORCE" != "true" ]; then
        echo -e "${YELLOW}→ Exists: $path (use --force to overwrite)${NC}"
    else
        echo "$content" > "$path"
        if [ "$executable" = "true" ]; then
            chmod +x "$path"
        fi
        echo -e "${GREEN}✓ Created: $path${NC}"
    fi
}

echo -e "Setting up in: ${BLUE}$PROJECT_PATH${NC}"
echo ""

# 1. Create directory structure
echo -e "${YELLOW}Step 1: Creating directory structure...${NC}"
ensure_directory "$PROJECT_PATH/.claude"
ensure_directory "$PROJECT_PATH/.claude/agents"
ensure_directory "$PROJECT_PATH/.claude/tools"
ensure_directory "$PROJECT_PATH/.claude/data"
ensure_directory "$PROJECT_PATH/.claude/docs"
ensure_directory "$PROJECT_PATH/.claude/docs/references"
ensure_directory "$PROJECT_PATH/.claude/docs/tasks"
ensure_directory "$PROJECT_PATH/.claude/hooks"
ensure_directory "$PROJECT_PATH/.claude/logs"
echo ""

# 2. Create main documentation files
echo -e "${YELLOW}Step 2: Creating core documentation...${NC}"

# Create .claude/README.md
create_file "$PROJECT_PATH/.claude/README.md" '# 🎭 The Orchestrator System

## YOU ARE THE ORCHESTRATOR
You don'"'"'t "use" an orchestrator - YOU ARE the orchestrator. You wear different "agent hats" to access specialized expertise.

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
- `orchestrator-session-start` - Initialize a work session'

# Create WELCOME_ORCHESTRATOR.md
create_file "$PROJECT_PATH/.claude/WELCOME_ORCHESTRATOR.md" '# Welcome, Orchestrator! 🎭

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
./.claude/tools/orchestrator-log --role [hat-name] --status in_progress "What you'"'"'re doing"
```

## Remember
You'"'"'re not managing other agents - you ARE all the agents. Each hat is just a different aspect of your capabilities.'

# 3. Create agent role definitions
echo -e "${YELLOW}Step 3: Creating agent role definitions...${NC}"

# Project Manager
create_file "$PROJECT_PATH/.claude/agents/project-manager.md" '# Project Manager Agent 📊

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
- Communicating with stakeholders'

# Solution Architect
create_file "$PROJECT_PATH/.claude/agents/solution-architect.md" '# Solution Architect Agent 🏗️

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
- Solving scalability challenges'

# Senior Backend Engineer
create_file "$PROJECT_PATH/.claude/agents/senior-backend-engineer.md" '# Senior Backend Engineer Agent ⚙️

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
- Optimizing backend performance'

# Principal Database Architect
create_file "$PROJECT_PATH/.claude/agents/principal-database-architect.md" '# Principal Database Architect Agent 🗄️

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
- Implementing data backups'

# Test Master
create_file "$PROJECT_PATH/.claude/agents/test-master.md" '# Test Master Agent 🧪

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
- Setting up test environments'

# DevOps Lead
create_file "$PROJECT_PATH/.claude/agents/devops-lead.md" '# DevOps Lead Agent 🚀

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
- Troubleshooting deployments'

# UI Designer
create_file "$PROJECT_PATH/.claude/agents/ui-designer.md" '# UI Designer Agent 🎨

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
- Improving UX'

# Web Development Master
create_file "$PROJECT_PATH/.claude/agents/web-dev-master.md" '# Web Development Master Agent 🌐

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
- Debugging browser issues'

# Senior Mobile Developer
create_file "$PROJECT_PATH/.claude/agents/senior-mobile-developer.md" '# Senior Mobile Developer Agent 📱

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
- Preparing app store releases'

# Scrum Master
create_file "$PROJECT_PATH/.claude/agents/scrum-master.md" '# Scrum Master Agent 🏃

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
- Coaching on agile'

# Create specialized agents
create_file "$PROJECT_PATH/.claude/agents/opportunist-strategist.md" '# Opportunist Strategist Agent 🎯

Market intelligence and strategic opportunity identification.'

create_file "$PROJECT_PATH/.claude/agents/psychologist-game-dynamics.md" '# Psychologist Game Dynamics Agent 🧠

User psychology and gamification strategies.'

create_file "$PROJECT_PATH/.claude/agents/game-theory-master.md" '# Game Theory Master Agent ♟️

Strategic decision-making and competitive analysis.'

create_file "$PROJECT_PATH/.claude/agents/legal-software-advisor.md" '# Legal Software Advisor Agent ⚖️

Software licensing and compliance guidance.'

echo ""

# 4. Create tools
echo -e "${YELLOW}Step 4: Creating orchestrator tools...${NC}"

# Create orchestrator-log tool
create_file "$PROJECT_PATH/.claude/tools/orchestrator-log" '#!/bin/bash
# Orchestrator Logging Tool
# Logs work progress and updates system status

# Color codes
GREEN='\''\033[0;32m'\''
YELLOW='\''\033[1;33m'\''
RED='\''\033[0;31m'\''
BLUE='\''\033[0;34m'\''
NC='\''\033[0m'\''

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
    echo "→ Updated status.json for role: $ROLE"
    # In production, use jq or python to update JSON
fi

# Update hat usage statistics
if [ -f ".claude/tools/update-hat-usage.sh" ]; then
    EXECUTION_MODE="orchestrator"
    if [ "$DELEGATION" = true ]; then
        EXECUTION_MODE="spawned_agent"
    fi
    ./.claude/tools/update-hat-usage.sh "$ROLE" "$STATUS" "$TASK" "$EXECUTION_MODE" 2>/dev/null
fi' true

# Create check-current-hat tool
create_file "$PROJECT_PATH/.claude/tools/check-current-hat" '#!/bin/bash
# Check Current Hat Tool
# Verifies which hat is currently being worn

GREEN='\''\033[0;32m'\''
YELLOW='\''\033[1;33m'\''
RED='\''\033[0;31m'\''
BLUE='\''\033[0;34m'\''
NC='\''\033[0m'\''

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
fi' true

# Create orchestrator-session-start tool
create_file "$PROJECT_PATH/.claude/tools/orchestrator-session-start" '#!/bin/bash
# Orchestrator Session Start
# Enforces hat selection at session start

GREEN='\''\033[0;32m'\''
YELLOW='\''\033[1;33m'\''
BLUE='\''\033[0;34m'\''
NC='\''\033[0m'\''

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
fi' true

# Create usage tracking script for Unix/Linux
create_file "$PROJECT_PATH/.claude/tools/update-hat-usage.sh" '#!/bin/bash
# Update Hat Usage Statistics (Bash version)

ROLE="$1"
STATUS="$2"
TASK="$3"
EXECUTION_MODE="${4:-orchestrator}"

STATS_FILE=".claude/data/hat_usage_statistics.json"

if [ -f "$STATS_FILE" ]; then
    # Use python for JSON manipulation (more portable than jq)
    python3 -c "
import json
from datetime import datetime

with open('"'"'$STATS_FILE'"'"', '"'"'r'"'"') as f:
    stats = json.load(f)

# Initialize role if not exists
if '"'"'$ROLE'"'"' not in stats['"'"'hat_usage'"'"']:
    stats['"'"'hat_usage'"'"']['"'"'$ROLE'"'"'] = {
        '"'"'total_uses'"'"': 0,
        '"'"'tasks'"'"': {},
        '"'"'last_used'"'"': '"'"''"'"'
    }

# Update usage
stats['"'"'hat_usage'"'"']['"'"'$ROLE'"'"']['"'"'total_uses'"'"'] += 1
stats['"'"'hat_usage'"'"']['"'"'$ROLE'"'"']['"'"'last_used'"'"'] = datetime.utcnow().strftime('"'"'%Y-%m-%dT%H:%M:%SZ'"'"')

# Update execution mode stats
if '"'"'$EXECUTION_MODE'"'"' == '"'"'orchestrator'"'"':
    stats['"'"'execution_mode_stats'"'"']['"'"'orchestrator_wearing_hat'"'"']['"'"'total_tasks'"'"'] += 1
else:
    stats['"'"'execution_mode_stats'"'"']['"'"'spawned_agent'"'"']['"'"'total_tasks'"'"'] += 1

stats['"'"'last_updated'"'"'] = datetime.utcnow().strftime('"'"'%Y-%m-%dT%H:%M:%SZ'"'"')

with open('"'"'$STATS_FILE'"'"', '"'"'w'"'"') as f:
    json.dump(stats, f, indent=2)
" 2>/dev/null || true
fi' true

echo ""

# 5. Create data files
echo -e "${YELLOW}Step 5: Initializing data files...${NC}"

# Create status.json
create_file "$PROJECT_PATH/.claude/status.json" '{
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
}'

# Create hat usage statistics
create_file "$PROJECT_PATH/.claude/data/hat_usage_statistics.json" '{
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
}'

echo ""

# 6. Create quick start guide
echo -e "${YELLOW}Step 6: Creating quick start guide...${NC}"

create_file "$PROJECT_PATH/.claude/ORCHESTRATOR_QUICK_START.md" '# Orchestrator Quick Start Guide

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
YOU are the orchestrator wearing different hats, not someone using separate agents!'

echo ""

# 7. Create main entry point
echo -e "${YELLOW}Step 7: Creating main entry point documentation...${NC}"

create_file "$PROJECT_PATH/ORCHESTRATOR_START_HERE.md" '# 🚀 START HERE - Orchestrator System

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
Never work without wearing an appropriate hat!'

echo ""

# 8. Setup git hooks (optional)
if [ "$SKIP_GIT_CONFIG" != "true" ]; then
    echo -e "${YELLOW}Step 8: Setting up git hooks...${NC}"

    if [ -d "$PROJECT_PATH/.git" ]; then
        ensure_directory "$PROJECT_PATH/.git/hooks"

        create_file "$PROJECT_PATH/.git/hooks/pre-commit" '#!/bin/bash
# Pre-commit hook to check hat status

if [ -f ".claude/.current_role" ]; then
    CURRENT_HAT=$(cat .claude/.current_role)
    echo "✓ Committing with hat: $CURRENT_HAT"
else
    echo "⚠️  Warning: No hat currently worn!"
    echo "Run: ./.claude/tools/orchestrator-session-start"
fi' true
    else
        echo -e "${YELLOW}→ Skipped: Not a git repository${NC}"
    fi
else
    echo -e "${YELLOW}Step 8: Skipping git configuration (--skip-git-config specified)${NC}"
fi

echo ""

# 9. Final summary
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN} ✅ ORCHESTRATOR FRAMEWORK INITIALIZED!${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""
echo -e "${CYAN}Next Steps:${NC}"
echo -e "${WHITE}1. Start a session: ./.claude/tools/orchestrator-session-start${NC}"
echo -e "${WHITE}2. Read the guide: ORCHESTRATOR_START_HERE.md${NC}"
echo -e "${WHITE}3. Begin work with appropriate hat${NC}"
echo ""
echo -e "${GRAY}Framework Location: $PROJECT_PATH/.claude${NC}"
echo -e "${GRAY}Documentation: $PROJECT_PATH/ORCHESTRATOR_START_HERE.md${NC}"
echo ""