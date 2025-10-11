# Hat Usage Tracking Guide

## 📊 Overview

The Hat Usage Tracking System monitors and records which orchestrator "hats" (expertise roles) are worn during development work. This provides insights into work patterns, expertise utilization, and helps identify bottlenecks or skill gaps.

## 🎭 Key Distinction: Orchestrator vs Spawned Agents

The system tracks **two distinct execution modes**:

### 1. **Orchestrator Wearing Hat** (🎭)
- **99% of all work**
- You (the main Claude session) wearing different expertise hats
- Full file system access (can read/write/edit)
- Direct implementation of features
- Logs show: `execution_mode: "orchestrator"`

### 2. **Spawned Agent** (🤖)
- **1% of work**
- Separate Claude instances created via Task tool
- Sandboxed environment (read-only)
- Used for parallel analysis or specialized research
- Logs show: `execution_mode: "spawned_agent"`

## 📁 Data Storage

### Primary Statistics File
**Location:** `.claude/data/hat_usage_statistics.json`

### Structure:
```json
{
  "metadata": {
    "version": "1.0.0",
    "last_updated": "timestamp"
  },
  "hat_statistics": {
    "[role-name]": {
      "display_name": "Human Readable Name",
      "total_sessions": 0,
      "total_duration_minutes": 0,
      "tasks_completed": 0,
      "average_session_minutes": 0,
      "last_worn": "timestamp",
      "color": "#hex"
    }
  },
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
  "session_history": [
    {
      "role": "role-name",
      "started_at": "timestamp",
      "ended_at": "timestamp",
      "duration_minutes": 0,
      "task": "TASK-XXX",
      "execution_mode": "orchestrator|spawned_agent",
      "is_orchestrator": true|false
    }
  ],
  "task_associations": {
    "TASK-XXX": {
      "primary_role": "role-name",
      "roles_involved": ["role1", "role2"],
      "completed": true|false,
      "execution_mode": "orchestrator|spawned_agent",
      "completed_by_orchestrator": true|false
    }
  },
  "daily_breakdown": {
    "YYYY-MM-DD": {
      "[role-name]": {
        "sessions": 0,
        "minutes": 0,
        "tasks_completed": 0
      }
    }
  }
}
```

## 🛠️ Tracking Implementation

### Update Script
**Location:** `.claude/tools/update-hat-usage.ps1`

### Usage:
```powershell
# Starting a session (orchestrator wearing hat)
./.claude/tools/update-hat-usage.ps1 `
  -Role "senior-backend-engineer" `
  -StartSession `
  -Task "TASK-003" `
  -ExecutionMode "orchestrator"

# Completing a task (spawned agent)
./.claude/tools/update-hat-usage.ps1 `
  -Role "test-master" `
  -Status "done" `
  -Task "TASK-003" `
  -ExecutionMode "spawned_agent"

# Ending a session
./.claude/tools/update-hat-usage.ps1 `
  -Role "senior-backend-engineer" `
  -EndSession
```

### Parameters:
- `-Role`: The hat/role being used (required)
- `-Status`: Task status (in_progress|blocked|done)
- `-Task`: Task ID being worked on
- `-StartSession`: Flag to start a new session
- `-EndSession`: Flag to end current session
- `-ExecutionMode`: "orchestrator" (default) or "spawned_agent"

## 📈 Integration with Orchestrator Logging

The hat usage tracking should be automatically triggered when using the orchestrator-log tool:

```bash
# When orchestrator logs work (automatically tracks as orchestrator mode)
./.claude/tools/orchestrator-log \
  --role senior-backend-engineer \
  --status in_progress \
  --task TASK-003 \
  "Implementing JWT authentication"

# When delegating to spawned agent (tracks as spawned_agent mode)
./.claude/tools/orchestrator-log \
  --delegation \
  --delegated-to test-master \
  --task TASK-003 \
  "Delegating test plan creation"
```

## 📊 Metrics Tracked

### Per Hat Metrics:
- **Total Sessions**: Number of times hat was worn
- **Total Duration**: Cumulative time in minutes
- **Average Session**: Mean session length
- **Tasks Completed**: Number of tasks marked done
- **Last Worn**: Most recent usage timestamp

### Execution Mode Metrics:
- **Orchestrator Sessions**: Work done by orchestrator wearing hats
- **Spawned Agent Sessions**: Work delegated to sandboxed agents
- **Task Distribution**: Which tasks used which mode
- **Mode Percentage**: Ratio of orchestrator vs agent work

### Time-based Metrics:
- **Daily Breakdown**: Usage per day per hat
- **Session History**: Complete timeline of all sessions
- **Task Associations**: Which hats worked on which tasks

## 🎨 Visualization in Admin Dashboard

The admin dashboard (Task: TASK-HAT-USAGE-DASHBOARD) will display:

### Key Visualizations:
1. **Execution Mode Split**
   - Pie chart showing orchestrator vs spawned agent work
   - Clear 🎭 vs 🤖 iconography

2. **Hat Usage Distribution**
   - Time spent in each hat
   - Color-coded by hat colors

3. **Timeline View**
   - Sessions over time
   - Execution mode indicated by icons

4. **Ranking Table**
   - Hats ranked by usage
   - Shows tasks split (orchestrator/agent)
   - Mode percentage per hat

## 🔄 Workflow Integration

### Automatic Tracking Points:

1. **Session Start**
   - Triggered when orchestrator-log first uses a role
   - Records timestamp and execution mode

2. **Task Updates**
   - Triggered on status changes
   - Tracks which mode completed the task

3. **Session End**
   - Triggered when role switches or completes
   - Calculates duration and updates averages

4. **Delegation Events**
   - Special tracking for spawned agents
   - Records both orchestrator delegation and agent completion

## 📝 Best Practices

### For Accurate Tracking:

1. **Always specify execution mode** when using Task tool:
   ```python
   # This creates a spawned agent
   Task(
       subagent_type="test-master",
       prompt="Create test plan"
   )
   # Should trigger spawned_agent tracking
   ```

2. **Log role switches** immediately:
   ```bash
   # Ending one hat
   orchestrator-log --role backend --status done

   # Starting another hat
   orchestrator-log --role ui-designer --status in_progress
   ```

3. **Include task IDs** for association tracking:
   ```bash
   orchestrator-log --role backend --task TASK-003
   ```

## 🚨 Important Notes

### Execution Mode Indicators:
- **🎭** = Orchestrator (you) wearing a hat
- **🤖** = Spawned agent via Task tool
- Most work (99%) should be 🎭
- Only specialized analysis should be 🤖

### Data Integrity:
- Statistics file is updated atomically
- Session history is append-only
- Daily breakdowns are calculated on write
- Averages update automatically

### Performance Considerations:
- Statistics file should stay under 1MB
- Old session history can be archived monthly
- Dashboard should cache data for 5 minutes

## 🔍 Debugging

### Check Current Statistics:
```powershell
# View current stats
cat .claude/data/hat_usage_statistics.json | jq '.'

# Check specific hat
cat .claude/data/hat_usage_statistics.json | jq '.hat_statistics."senior-backend-engineer"'

# View execution mode split
cat .claude/data/hat_usage_statistics.json | jq '.execution_mode_stats'
```

### Common Issues:

1. **Session not ending**: Check for active sessions in session_history
2. **Wrong execution mode**: Verify ExecutionMode parameter is set
3. **Missing task associations**: Ensure Task parameter is provided
4. **Duration calculation errors**: Check timestamp formats

## 📚 Related Documentation

- [Orchestrator Logging Guide](ORCHESTRATOR_LOGGING_GUIDE.md)
- [Orchestrator vs Agents](../../ORCHESTRATOR_VS_AGENTS.md)
- [Task: Hat Usage Dashboard](../../tasks/TASK-HAT-USAGE-DASHBOARD.md)
- [Team Responsibilities Matrix](TEAM_RESPONSIBILITIES_MATRIX.md)

---

*Last Updated: 2025-10-11*
*System Version: 1.0.0*