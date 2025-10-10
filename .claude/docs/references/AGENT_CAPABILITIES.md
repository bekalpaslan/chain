# Agent Capabilities & Orchestrator Collaboration Guide

**Purpose:** Define what agents CAN and CANNOT do, and how to work effectively with the orchestrator for parallel execution.

**Last Updated:** 2025-10-10
**Status:** Active Reference
**Applies To:** All agents + Orchestrator

---

## 🎯 Core Principle

**Agents analyze and plan. Orchestrator executes.**

When invoked via the Task tool, agents run in a **sandboxed analysis environment**. They provide recommendations, plans, and structured instructions that the orchestrator then executes using real file system tools.

---

## 🔧 What Agents CAN Do

### ✅ Analysis & Research
- Read files (simulated read access)
- Search through codebases
- Analyze patterns and problems
- Research best practices
- Review existing implementations

### ✅ Planning & Design
- Create implementation plans
- Design system architectures
- Propose file structures
- Draft documentation content
- Plan migration strategies

### ✅ Code Generation
- Generate code snippets
- Create complete file contents
- Write configuration files
- Design database schemas
- Draft test cases

### ✅ Structured Output
- Return JSON with file contents
- Provide step-by-step instructions
- Create actionable task lists
- Generate commands for orchestrator
- Document findings and recommendations

---

## ❌ What Agents CANNOT Do

### File System Operations
- ❌ Write files (no Write tool access)
- ❌ Edit files (no Edit tool access)
- ❌ Execute bash commands (commands are simulated)
- ❌ Create directories
- ❌ Move or delete files
- ❌ Run git commands

### External Interactions
- ❌ Make HTTP requests
- ❌ Access databases directly
- ❌ Run build processes
- ❌ Deploy applications
- ❌ Modify running services

### System Changes
- ❌ Install packages
- ❌ Modify environment variables
- ❌ Change system configuration
- ❌ Restart services

---

## 🤝 How to Work with the Orchestrator

### Pattern 1: Structured File Creation

**❌ Don't do this:**
```bash
# Agent tries to write file (won't actually execute)
cat > .claude/my-file.md << 'EOF'
Content here
EOF
```

**✅ Do this instead:**
```json
{
  "deliverables": {
    "files_to_create": [
      {
        "path": ".claude/my-file.md",
        "content": "Content here\n...",
        "reason": "Master reference for X"
      }
    ]
  }
}
```

**Result:** Orchestrator can parse and execute automatically.

---

### Pattern 2: Actionable Task Breakdown

**❌ Don't do this:**
```
I recommend reorganizing the documentation.
You should move files around and update README.
```

**✅ Do this instead:**
```markdown
## Actionable Steps for Orchestrator

**Phase 1: Preparation (Parallel Safe)**
1. Create directory structure:
   - mkdir -p .claude/docs/guides
   - mkdir -p .claude/docs/references
   - mkdir -p .claude/docs/archives/2025-01

**Phase 2: Move Files (Sequential)**
2. git mv .claude/ORCHESTRATION_GUIDE.md .claude/docs/guides/
3. git mv .claude/LOGGING_REQUIREMENTS.md .claude/docs/references/
4. git mv .claude/TEAM_RESPONSIBILITIES_MATRIX.md .claude/docs/references/

**Phase 3: Create New Files (Parallel Safe)**
5. Create .claude/docs/archives/README.md (content below)
6. Update .claude/README.md (content below)

**Files to Create:**

### File 1: .claude/docs/archives/README.md
```markdown
# Documentation Archives
...
```

### File 2: .claude/README.md
```markdown
# .claude System Documentation
...
```

**Result:** Orchestrator can execute phases in parallel where safe.

---

### Pattern 3: Parallel-Friendly Work Splitting

**❌ Don't do this:**
```
Step 1: Create file A
Step 2: Create file B
Step 3: Create file C
(Forces sequential execution)
```

**✅ Do this instead:**
```markdown
## Orchestrator: Execute in Parallel

**Independent Tasks (Run Simultaneously):**
- [ ] Create file A (content attached)
- [ ] Create file B (content attached)
- [ ] Create file C (content attached)

**Dependent Tasks (Run After Above Complete):**
- [ ] Update references in file D
- [ ] Commit all changes

**Rationale:** Files A, B, C have no dependencies and can be written in parallel.
```

**Result:** Orchestrator can use parallel tool calls for 3x speedup.

---

### Pattern 4: Return Format for File Operations

**Standard Return Structure:**

```json
{
  "analysis": {
    "summary": "Brief description of findings",
    "key_insights": ["Insight 1", "Insight 2"]
  },
  "deliverables": {
    "files_to_create": [
      {
        "path": "path/to/file.ext",
        "content": "Full file content here...",
        "reason": "Why this file is needed",
        "priority": "high|medium|low"
      }
    ],
    "files_to_edit": [
      {
        "path": "path/to/existing/file.ext",
        "changes": [
          {
            "find": "old content",
            "replace": "new content",
            "reason": "Why this change"
          }
        ]
      }
    ],
    "commands_to_run": [
      {
        "command": "bash command here",
        "description": "What this does",
        "parallel_safe": true,
        "depends_on": ["previous command ID"]
      }
    ]
  },
  "next_steps": [
    "What orchestrator should do after this",
    "How to verify success",
    "What to do if it fails"
  ]
}
```

---

## 🚀 Enabling Parallel Execution

### Key Principles

1. **Identify Independent Work**
   - Which files don't reference each other?
   - Which commands don't share state?
   - What can fail without blocking others?

2. **Mark Dependencies Explicitly**
   ```json
   {
     "command": "git commit -m 'message'",
     "depends_on": ["create_file_a", "create_file_b"],
     "parallel_safe": false
   }
   ```

3. **Use Phases**
   ```
   Phase 1 (Parallel): Create files A, B, C
   Phase 2 (Sequential): Update file D with references to A, B, C
   Phase 3 (Parallel): Run tests on A, B, C
   ```

### Example: Good Parallel Structure

```markdown
## Orchestrator Execution Plan

### Phase 1: Parallel File Creation (Estimated: 5 seconds)
The following files have no dependencies and can be created simultaneously:

**Task 1A:** Create `.claude/docs/guides/GETTING_STARTED.md`
- Content: [attached below]
- Why parallel safe: New file, no references

**Task 1B:** Create `.claude/docs/references/API_SPEC.md`
- Content: [attached below]
- Why parallel safe: New file, no references

**Task 1C:** Create `.claude/docs/implementation/ARCHITECTURE.md`
- Content: [attached below]
- Why parallel safe: New file, no references

### Phase 2: Sequential Updates (Estimated: 3 seconds)
Must run AFTER Phase 1 completes:

**Task 2A:** Update `.claude/README.md`
- Why sequential: References files created in Phase 1
- Changes: [attached below]

### Phase 3: Parallel Validation (Estimated: 2 seconds)
Can run simultaneously:

**Task 3A:** Run `grep -r "broken link" .claude/docs/`
**Task 3B:** Run `.claude/tools/check-compliance`
**Task 3C:** Run `git diff --check`

### Total Time: ~10 seconds (vs ~25 seconds sequential)
```

---

## 📝 Templates for Common Scenarios

### Template 1: Multi-File Documentation Creation

```markdown
## Agent Response: Documentation Bundle

### Analysis Summary
[Brief overview of what was analyzed and why these docs are needed]

### Files to Create (All Parallel Safe)

#### File 1: .claude/docs/guides/WORKFLOW.md
**Purpose:** Guide for daily workflow
**Content:**
```
[Full markdown content here]
```

#### File 2: .claude/docs/references/COMMANDS.md
**Purpose:** Quick reference for commands
**Content:**
```
[Full markdown content here]
```

#### File 3: .claude/docs/implementation/DESIGN.md
**Purpose:** Technical design decisions
**Content:**
```
[Full markdown content here]
```

### Orchestrator Actions

**Step 1 (Parallel):** Create all 3 files simultaneously using Write tool
**Step 2 (Sequential):** Update README.md navigation
**Step 3 (Parallel):** Validate links + check compliance

### Success Criteria
- [ ] All files created with correct content
- [ ] README navigation updated
- [ ] No broken links
- [ ] Compliance check passes
```

---

### Template 2: Code Refactoring with Tests

```markdown
## Agent Response: Refactoring Plan

### Analysis
[What needs to be refactored and why]

### Implementation Plan

**Phase 1: Create New Implementations (Parallel)**
- Create `src/utils/new-helper.ts` [content below]
- Create `src/services/new-service.ts` [content below]
- Create `tests/new-helper.test.ts` [content below]
- Create `tests/new-service.test.ts` [content below]

**Phase 2: Update Existing Code (Sequential)**
Must run AFTER Phase 1:
- Edit `src/main.ts` to import new helpers
- Edit `src/config.ts` to use new service

**Phase 3: Validation (Parallel)**
- Run `npm test`
- Run `npm run lint`
- Run `npm run type-check`

### File Contents

#### src/utils/new-helper.ts
```typescript
[Full TypeScript code here]
```

[Continue for each file...]

### Orchestrator Execution
1. Run Phase 1 in parallel (4 Write tools simultaneously)
2. Run Phase 2 sequentially (2 Edit tools in order)
3. Run Phase 3 in parallel (3 Bash commands simultaneously)
```

---

### Template 3: System Configuration

```markdown
## Agent Response: Configuration Setup

### Configuration Files (Parallel Safe)

All these files are independent and can be created simultaneously:

#### 1. .env.example
```
[Full env file content]
```

#### 2. docker-compose.yml
```yaml
[Full docker compose content]
```

#### 3. nginx.conf
```nginx
[Full nginx config]
```

#### 4. .gitignore
```
[Full gitignore content]
```

### Orchestrator Actions

**Parallel Execution (4 simultaneous Write tools):**
- Write .env.example
- Write docker-compose.yml
- Write nginx.conf
- Write .gitignore

**Sequential Validation:**
- Run `docker-compose config` to validate
- Run `nginx -t -c nginx.conf` to validate
- Run `git status` to verify gitignore

### Expected Result
4 config files created in ~2 seconds instead of ~8 seconds sequential.
```

---

## 🎓 Best Practices

### For Agents

1. **Always provide full file contents**
   - Don't say "add this to the file"
   - Provide the complete final file

2. **Mark parallel-safe operations explicitly**
   - "These files are independent and can be created in parallel"
   - "This must run after X completes"

3. **Include verification steps**
   - How to check if it worked
   - What to do if it fails

4. **Use structured output**
   - JSON for programmatic parsing
   - Markdown for human readability
   - Clear sections for each deliverable

5. **Estimate time savings**
   - "Parallel execution saves X seconds"
   - Shows value of proper structure

### For Orchestrator

1. **Look for parallel opportunities**
   - Multiple Write tools can run simultaneously
   - Independent Bash commands can run in parallel

2. **Respect dependencies**
   - Don't parallelize when agents say "sequential"
   - Check depends_on fields

3. **Extract structured data**
   - Parse JSON when provided
   - Extract file contents from markdown code blocks

4. **Provide feedback**
   - Tell agents if their structure enabled parallelism
   - Report time saved vs sequential execution

---

## 🔍 Common Anti-Patterns to Avoid

### Anti-Pattern 1: Assuming Execution

❌ **Agent writes:**
```bash
cat > file.md << 'EOF'
Content
EOF
```

✅ **Agent should write:**
```json
{"files_to_create": [{"path": "file.md", "content": "Content"}]}
```

---

### Anti-Pattern 2: Vague Instructions

❌ **Agent writes:**
```
Update the README to include the new guides.
```

✅ **Agent should write:**
```markdown
## Orchestrator: Edit README.md

Find this section:
```markdown
## Guides
- None yet
```

Replace with:
```markdown
## Guides
- [Getting Started](docs/guides/GETTING_STARTED.md)
- [Workflow](docs/guides/WORKFLOW.md)
```

**Reason:** Add new guide links for discoverability
```

---

### Anti-Pattern 3: Forcing Sequential When Parallel is Safe

❌ **Agent writes:**
```
Step 1: Create file A
Step 2: Create file B
Step 3: Create file C
```

✅ **Agent should write:**
```markdown
**Parallel Safe:** Create files A, B, C simultaneously (no dependencies)
- File A: [content]
- File B: [content]
- File C: [content]
```

---

## 📊 Success Metrics

### Agent Performance
- ✅ Provides complete file contents (not partial)
- ✅ Identifies parallel-safe operations
- ✅ Uses structured output format
- ✅ Includes verification steps
- ✅ Estimates time savings

### Orchestrator Performance
- ✅ Executes parallel operations simultaneously
- ✅ Respects dependencies
- ✅ Extracts and applies all deliverables
- ✅ Verifies success
- ✅ Reports time saved

### System Performance
- ✅ 3-5x speedup on multi-file operations
- ✅ Zero missed deliverables
- ✅ 100% of agent recommendations applied
- ✅ Clear audit trail of what was executed

---

## 🚨 Critical Rules

1. **Agents NEVER assume file operations will execute**
   - Always provide full content
   - Always mark as deliverable for orchestrator

2. **Orchestrator ALWAYS executes what agents provide**
   - Don't skip deliverables
   - Use parallel execution when safe
   - Verify success

3. **Communication is Explicit**
   - No implied actions
   - No "you know what I mean"
   - Everything documented in deliverables

4. **Parallel Opportunities are Identified**
   - Agents mark what's parallel-safe
   - Orchestrator uses parallel tool calls
   - Time savings reported

---

## 📚 Related Documentation

- **[ORCHESTRATION_GUIDE.md](../guides/ORCHESTRATION_GUIDE.md)** - How orchestrator delegates work
- **[LOGGING_REQUIREMENTS.md](LOGGING_REQUIREMENTS.md)** - How to log agent activities
- **[TEAM_RESPONSIBILITIES_MATRIX.md](TEAM_RESPONSIBILITIES_MATRIX.md)** - What each agent specializes in

---

**This guide ensures agents and orchestrator work together efficiently, with clear understanding of capabilities and responsibilities. No more assumptions, no more missed deliverables, maximum parallel execution.**

**Version:** 1.0
**Status:** Active Reference
**Enforcement:** Mandatory for all agents
