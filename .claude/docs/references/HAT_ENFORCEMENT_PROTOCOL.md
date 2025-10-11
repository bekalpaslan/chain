# Hat Enforcement Protocol - Preventing Hatless Orchestrator Work

## 🚫 The Problem We're Solving

The orchestrator system requires wearing appropriate expertise hats for all work, but it's easy to forget and work "hatless." This leads to:
- Untracked work in statistics
- Incorrect expertise application
- Violation of orchestrator principles
- Poor workflow continuity

## 🛡️ Multi-Layer Enforcement System

### Layer 1: **Session Initialization Check**
**Tool:** `orchestrator-session-start`
**When:** At the beginning of each work session
**Action:** Forces hat selection before any work begins

```bash
# Run at session start
./.claude/tools/orchestrator-session-start
```

### Layer 2: **Current Hat Verification**
**Tool:** `check-current-hat`
**When:** Before starting any new task
**Action:** Verifies a hat is worn, suggests appropriate hat if not

```bash
# Check current hat
./.claude/tools/check-current-hat

# Get suggestion based on context
./.claude/tools/check-current-hat --suggest

# Enforce (blocks if no hat)
./.claude/tools/check-current-hat --enforce
```

### Layer 3: **Pre-Commit Hook**
**Integration:** Git pre-commit hook
**When:** Before any git commit
**Action:** Prevents commits without active hat

Create `.git/hooks/pre-commit`:
```bash
#!/bin/bash
# Enforce hat-wearing before commits
./.claude/tools/check-current-hat --enforce --silent
if [ $? -ne 0 ]; then
  echo "❌ Cannot commit without wearing a hat!"
  echo "Run: ./.claude/tools/orchestrator-session-start"
  exit 1
fi
```

### Layer 4: **Tool Integration Checks**
**Where:** In orchestrator tools (Write, Edit, etc.)
**When:** Before executing any tool
**Action:** Warning or blocking based on configuration

### Layer 5: **System Reminders**
**Location:** Context reminders
**When:** Periodically during work
**Action:** Gentle reminders to check hat status

## 📋 Implementation Checklist

### For New Sessions:
- [ ] Run `orchestrator-session-start` first
- [ ] Select appropriate hat based on planned work
- [ ] Log initial hat wearing with orchestrator-log

### During Work:
- [ ] Check hat before major task switches
- [ ] Use `check-current-hat --suggest` for guidance
- [ ] Switch hats when domain changes

### For Task Completion:
- [ ] Mark current task done
- [ ] Immediately transition to related hat
- [ ] Continue workflow without stopping

## 🎯 Hat Selection Matrix

| If You're About To... | Wear This Hat |
|---------------------|---------------|
| Write Java/Spring code | `senior-backend-engineer` |
| Design database schema | `principal-database-architect` |
| Create UI mockups | `ui-designer` |
| Write Flutter code | `senior-mobile-developer` |
| Write React code | `web-dev-master` |
| Write tests | `test-master` |
| Deploy or configure | `devops-lead` |
| Plan or organize | `project-manager` |
| Design architecture | `solution-architect` |
| Review process | `scrum-master` |

## 🔄 Automatic Hat Suggestions

The `check-current-hat --suggest` tool analyzes:

1. **Git changes**: What files are modified
2. **Current directory**: Where you are in the project
3. **Active tasks**: What tasks are in progress
4. **Recent activity**: Last worn hats

And suggests the most appropriate hat based on context.

## 📊 Tracking & Metrics

All hat enforcement is tracked in:
- `.claude/data/hat_usage_statistics.json` - Usage stats
- `.claude/logs/orchestrator.log` - Activity logs
- `.claude/status.json` - Current status

### Enforcement Metrics:
- Sessions started without hat
- Hat suggestion acceptance rate
- Average time before first hat worn
- Hatless work attempts blocked

## 🚨 Emergency Override

In rare cases where you need to work without the system:

```bash
# Temporary bypass (NOT RECOMMENDED)
export ORCHESTRATOR_HAT_ENFORCE=false
```

**WARNING:** This should only be used for system recovery or critical fixes.

## 💡 Best Practices

### 1. **Start Every Session Right**
```bash
# First command of the day
./.claude/tools/orchestrator-session-start
```

### 2. **Check Before Major Work**
```bash
# Before starting new feature
./.claude/tools/check-current-hat --suggest
```

### 3. **Log Transitions Immediately**
```bash
# When switching domains
./.claude/tools/orchestrator-log --role new-hat --status in_progress
```

### 4. **Use Enforcement in CI/CD**
Add to your CI pipeline:
```yaml
- name: Verify Orchestrator Hat
  run: ./.claude/tools/check-current-hat --enforce
```

## 🎓 Training Mode

For new orchestrators learning the system:

```bash
# Enable training mode (extra reminders)
echo "training" > .claude/.enforcement_mode

# Shows:
# - More detailed suggestions
# - Explanation of why each hat is suggested
# - Transition hints after task completion
```

## 📝 Configuration

Create `.claude/enforcement.config`:
```json
{
  "enforcement_level": "strict|normal|training",
  "require_hat_for_commits": true,
  "require_hat_for_tools": true,
  "auto_suggest": true,
  "reminder_interval_minutes": 30,
  "blocked_operations_without_hat": [
    "git commit",
    "git push",
    "file write",
    "file edit"
  ]
}
```

## 🔍 Debugging Hat Issues

### No Hat Detected But You're Wearing One?
```bash
# Check status
cat .claude/status.json | jq '.agents'

# Check current role file
cat .claude/.current_role

# Force refresh
./.claude/tools/orchestrator-log --role your-hat --status in_progress "Refreshing hat status"
```

### Wrong Hat Suggested?
The suggestion system learns from patterns. Help it by:
1. Always logging accurate hat usage
2. Using consistent task naming
3. Keeping task folders organized

## 🎯 Success Metrics

The enforcement system is working when:
- ✅ 100% of sessions start with hat selection
- ✅ No commits without active hats
- ✅ Hat transitions happen immediately after task completion
- ✅ Hat usage statistics show consistent patterns
- ✅ No "orphaned" work without hat attribution

## 🚀 Quick Start Commands

```bash
# Start your day
./.claude/tools/orchestrator-session-start

# Check status anytime
./.claude/tools/check-current-hat

# Get help choosing
./.claude/tools/check-current-hat --suggest

# Switch hats
./.claude/tools/orchestrator-log --role new-hat --status in_progress "Switching to new-hat"
```

## 📚 Related Documentation

- [HAT_TRANSITION_MATRIX.md](HAT_TRANSITION_MATRIX.md)
- [ORCHESTRATOR_LOGGING_GUIDE.md](ORCHESTRATOR_LOGGING_GUIDE.md)
- [HAT_USAGE_TRACKING_GUIDE.md](HAT_USAGE_TRACKING_GUIDE.md)

---

**Remember:** The orchestrator ALWAYS wears a hat. No exceptions!

*Last Updated: 2025-10-11*
*Version: 1.0.0*