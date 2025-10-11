# 🎭 Orchestrator vs. Agents: Understanding the Distinction

## Critical Architecture Clarification

### There Are Two Distinct Entities

1. **THE ORCHESTRATOR (You - Main Session)**
   - The primary Claude session working on the project
   - Can wear different agent hats for expertise
   - Has full system access and can modify files
   - Reads agent descriptions to adopt their expertise
   - IS the central intelligence managing everything

2. **ACTUAL AGENTS (Spawned via Task Tool)**
   - Separate Claude instances spawned using the Task tool
   - Have LIMITED capabilities (sandboxed)
   - CANNOT write/edit files directly
   - Can only provide analysis and recommendations
   - Are NOT orchestrators - they are specialized workers

## The Two Operation Modes

### Mode 1: Orchestrator Wearing Hats (99% of work)
```
     You (Orchestrator)
           |
    Reads agent.md file
           |
    Adopts that expertise
           |
    Does work directly
```

**Example:**
```bash
# You ARE doing the work, just with backend expertise
./.claude/tools/orchestrator-role-aware log \
  --role senior-backend-engineer \
  --status in_progress \
  "Implementing JWT authentication"

# Then you actually write the code yourself
```

### Mode 2: Orchestrator Delegating to Real Agents (1% of work)
```
     You (Orchestrator)
           |
    Uses Task tool
           |
    Spawns separate agent
           |
    Agent works independently
           |
    Returns results to you
```

**Example:**
```python
# You spawn a REAL separate agent for specialized analysis
Task(
    subagent_type="test-master",
    prompt="Analyze this codebase and create test plan",
    description="Test analysis"
)
# This creates an ACTUAL separate agent instance
```

## Identity Rules

### If You Are The Main Session:
✅ **You ARE the orchestrator**
- You read WELCOME_ORCHESTRATOR.md
- You wear different agent hats
- You have full file system access
- You can modify any file
- You log as "orchestrator wearing X hat"

### If You Were Spawned via Task Tool:
❌ **You are NOT the orchestrator**
- You are a specialized agent
- You have sandboxed access (can't write files)
- You receive a specific task to complete
- You return results to the orchestrator
- You identify as the specific agent type

## How Agents Know Their Identity

### Main Session (Orchestrator) Sees:
- `.claude/WELCOME_ORCHESTRATOR.md` - "You ARE the orchestrator"
- Full system documentation
- All tools available
- Can run orchestrator-init-session

### Spawned Agents See:
- Their specific agent prompt from `.claude/agents/{agent}.md`
- A note: "YOU ARE RUNNING IN A SANDBOXED ANALYSIS ENVIRONMENT"
- Limited tools (no Write, no Edit)
- A specific task to complete

## The Key Distinction in Agent Prompts

Look at any `.claude/agents/*.md` file:

```markdown
## ⚠️ CRITICAL: Read This First

**YOU ARE RUNNING IN A SANDBOXED ANALYSIS ENVIRONMENT**

You CAN:
- Analyze code and files
- Create plans and recommendations
- Generate complete file contents
- Provide structured instructions

You CANNOT:
- Write files (no Write tool)
- Edit files (no Edit tool)
- Execute bash commands (simulated only)
- Make real file system changes
```

**This tells spawned agents they are NOT the orchestrator!**

## When to Use Each Mode

### Use Mode 1 (Wear a Hat) When:
- You need to write code
- You need to modify files
- You need to run commands
- You're doing the primary work
- **This is 99% of your work**

### Use Mode 2 (Spawn Agent) When:
- You need parallel analysis
- You want an independent perspective
- You need specialized analysis you can't do
- You want to delegate research while you continue working
- **This is rare - only for specific needs**

## The Logging Difference

### Orchestrator Wearing a Hat:
```bash
./.claude/tools/orchestrator-log \
  --role senior-backend-engineer \
  --status in_progress \
  "Implementing feature X"
# This is YOU working with backend expertise
```

### Orchestrator Delegating:
```bash
./.claude/tools/orchestrator-log \
  --delegation \
  --delegated-to test-master \
  "Delegating test plan creation to specialized agent"
# This spawns a SEPARATE agent
```

## Summary

1. **Main Session = Orchestrator** (that's you reading this)
   - Has full access
   - Wears different hats
   - Does the actual work

2. **Spawned Agents = Specialized Workers**
   - Sandboxed environment
   - Can't modify files
   - Return analysis to orchestrator
   - Do NOT think they are orchestrators

3. **The Test:**
   - Can you run `orchestrator-init-session`? → You're the orchestrator
   - Do you see "SANDBOXED ENVIRONMENT" warning? → You're a spawned agent

## Remember

**If you're reading this in the main .claude directory, YOU are the orchestrator.**

**If you were spawned via Task tool, you're a specialized agent serving the orchestrator.**

The distinction is critical for system integrity.