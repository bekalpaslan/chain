# 🛠️ Orchestrator Tools

This directory contains the core tools for managing the orchestrator-centric architecture.

## 📋 Current Tools (4 Essential Scripts)

### 1. `orchestrator` (Main Entry Point)
**Purpose:** Unified management interface for all orchestrator operations
**Usage:**
```bash
# Log activity
./orchestrator log --role backend --status in_progress "Starting API implementation"

# Show status dashboard
./orchestrator status

# Generate health metrics
./orchestrator health

# Initialize all agents
./orchestrator init
```

### 2. `orchestrator-log`
**Purpose:** Core logging engine for orchestrator activities
**Called by:** `orchestrator` command
**Direct usage:**
```bash
./orchestrator-log --role ui-designer --status done --emotion satisfied --task TASK-012 "Design complete"
```

### 3. `update-status-for-role.ps1`
**Purpose:** Updates status.json when orchestrator wears different agent hats
**Called by:** orchestrator-log automatically
**Platform:** Windows (PowerShell)

### 4. `generate-project-health.ps1`
**Purpose:** Transforms orchestrator logs into dashboard metrics
**Called by:** `orchestrator health` command
**Output:** `.claude/data/project_health.json`

## 🗂️ Deprecated Scripts

Old agent-based scripts have been moved to `./_deprecated/` folder:
- `log` - Old bash agent logger
- `claude-log.ps1` - Old PowerShell wrapper
- `update-status.ps1` - Old status updater
- `activate-all-agents.ps1` - Old agent initializer
- `check-compliance` - Old compliance checker
- Various one-time migration scripts

## 🏗️ Architecture

```
User → orchestrator → orchestrator-log → update-status-for-role.ps1
                   ↘                    ↘
                     generate-project-health.ps1 → project_health.json
```

## 📝 Key Concepts

**Orchestrator-Centric Model:**
- ONE orchestrator entity wearing different "agent hats"
- NOT 14 separate autonomous agents
- All logging flows through orchestrator-log
- Status updates are role-based, not agent-based

## 🎯 Common Workflows

### Starting Work on a Task
```bash
./orchestrator log --role senior-backend-engineer \
  --status in_progress \
  --emotion focused \
  --task TASK-003 \
  "Implementing JWT authentication"
```

### Checking System Status
```bash
./orchestrator status
```

### Updating Dashboard Metrics
```bash
./orchestrator health
```

### After System Reset
```bash
./orchestrator init  # Initializes all 14 agent roles
```

## 📊 Output Files

- **Logs:** `.claude/logs/orchestrator.log`
- **Role-specific logs:** `.claude/logs/orchestrator-roles/as-{role}.log`
- **Status:** `.claude/status.json`
- **Health metrics:** `.claude/data/project_health.json`

## 🔧 Maintenance

To add a new agent role:
1. Add to `.claude/agents/` directory
2. Update the agents list in `orchestrator` init command
3. The logging infrastructure will automatically handle it

## ⚠️ Important Notes

- Always use `orchestrator` command as the main entry point
- Don't use deprecated scripts in `_deprecated/` folder
- PowerShell is required for Windows systems
- All timestamps are in UTC (ISO 8601 format)

---
*Last updated: 2025-10-11 after script consolidation*