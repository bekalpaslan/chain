# Multi-Agent Task Assignment Strategy

**Version**: 1.0.0
**Date**: 2025-10-10
**Status**: Active

---

## Overview

This document defines the strategy for assigning multiple agents to tasks, enabling collaborative work and better skill coverage across the development team.

### Key Principles

1. **Lead + Support Model**: Every task has one lead agent (primary responsible party) and optional support agents (contributors)
2. **Skill-Based Assignment**: Agents are assigned based on expertise match with task requirements
3. **Workload Balance**: Distribute tasks to avoid overloading individual agents
4. **Cross-Functional Teams**: Encourage collaboration between different specialties

---

## Task Assignment Structure

### JSON Schema

```json
{
  "assigned_to": "lead-agent-name",
  "support_agents": ["agent-1", "agent-2", "agent-3"]
}
```

### Field Definitions

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `assigned_to` | string | ✅ Yes | Lead agent - primary responsible party, appears in status.json |
| `support_agents` | array | ❌ No | Contributing agents - provide expertise and collaboration |

---

## Agent Role Matrix

### Role-Based Assignment Guidelines

| Task Type | Recommended Lead | Typical Support Agents |
|-----------|-----------------|----------------------|
| **Frontend UI** | `web-dev-master` | `ui-designer`, `senior-backend-engineer` |
| **Backend API** | `senior-backend-engineer` | `principal-database-architect`, `test-master` |
| **Database** | `principal-database-architect` | `senior-backend-engineer`, `devops-lead` |
| **Mobile App** | `senior-mobile-developer` | `ui-designer`, `senior-backend-engineer` |
| **DevOps/CI/CD** | `devops-lead` | `senior-backend-engineer`, `test-master` |
| **Testing/QA** | `test-master` | `senior-backend-engineer`, `senior-mobile-developer` |
| **UI/UX Design** | `ui-designer` | `web-dev-master`, `psychologist-game-dynamics` |
| **Documentation** | `senior-backend-engineer` | `web-dev-master`, `solution-architect` |

---

## Assignment Examples

### Example 1: Frontend Development Task

```json
{
  "id": "TASK-002",
  "title": "Frontend Development Kickoff",
  "type": "frontend",
  "assigned_to": "web-dev-master",
  "support_agents": ["ui-designer", "senior-backend-engineer"]
}
```

**Rationale:**
- **Lead (web-dev-master)**: Primary implementer, owns code delivery
- **Support (ui-designer)**: Provides design specs and UX guidance
- **Support (senior-backend-engineer)**: Ensures API integration compatibility

### Example 2: CI/CD Pipeline Task

```json
{
  "id": "TASK-003",
  "title": "Initialize CI/CD Pipeline",
  "type": "devops",
  "assigned_to": "devops-lead",
  "support_agents": ["senior-backend-engineer", "test-master"]
}
```

**Rationale:**
- **Lead (devops-lead)**: Infrastructure expert, owns pipeline design
- **Support (senior-backend-engineer)**: Provides build requirements
- **Support (test-master)**: Defines test automation integration

### Example 3: Database Migration Task

```json
{
  "id": "TASK-007",
  "title": "Database Migration Strategy",
  "type": "database",
  "assigned_to": "principal-database-architect",
  "support_agents": ["senior-backend-engineer", "devops-lead"]
}
```

**Rationale:**
- **Lead (principal-database-architect)**: Schema design authority
- **Support (senior-backend-engineer)**: Application layer impact assessment
- **Support (devops-lead)**: Migration deployment and rollback planning

---

## Workload Distribution Strategy

### Maximum Concurrent Tasks Per Agent

| Agent Role | Max Lead Tasks | Max Support Tasks | Total Cap |
|------------|---------------|-------------------|-----------|
| Senior/Lead Roles | 2 | 4 | 6 |
| Specialist Roles | 1 | 3 | 4 |
| Strategic Roles | 1 | 2 | 3 |

### Priority Rules

1. **Critical tasks** take precedence over high/medium priority
2. **Blocked agents** should be reassigned to unblock others
3. **Support roles** don't count toward agent "active" status in status.json
4. Only **lead agents** appear as "in_progress" in status.json

---

## Collaboration Workflow

### Lead Agent Responsibilities

- ✅ Update task status (pending → in_progress → completed)
- ✅ Maintain task progress.md with regular updates
- ✅ Coordinate with support agents
- ✅ Update status.json when starting/completing
- ✅ Write to task-specific log (logs/lead-agent.jsonl)
- ✅ Ensure acceptance criteria are met
- ✅ Deliver final artifacts

### Support Agent Responsibilities

- ✅ Provide specialized expertise when requested
- ✅ Review deliverables from their domain perspective
- ✅ Contribute to task logs (logs/support-agent.jsonl)
- ✅ Flag blockers or concerns to lead agent
- ❌ Do NOT update task status (lead agent's responsibility)
- ❌ Do NOT appear in status.json for this task

### Communication Protocol

1. **Lead agent** creates initial task entry in progress.md
2. **Support agents** add entries when contributing
3. **All agents** log their activities to task-specific logs
4. **Lead agent** consolidates and reports completion

---

## Task Discovery for Agents

### For Lead Agents

```bash
# Find tasks where you are the lead
grep -r '"assigned_to".*:"your-agent-name"' .claude/tasks/_active/*/task.json
```

### For Support Agents

```bash
# Find tasks where you are a support agent
grep -r '"support_agents".*"your-agent-name"' .claude/tasks/_active/*/task.json
```

### PowerShell Helper

```powershell
# Find all your assignments (lead + support)
. .\.claude\tools\find-my-tasks.ps1 -AgentName "your-agent-name"
```

---

## Benefits of Multi-Agent Assignment

### 1. Better Skill Coverage
- Tasks leverage multiple areas of expertise
- Reduces single points of failure
- Improves solution quality

### 2. Knowledge Sharing
- Junior agents learn from seniors
- Cross-functional understanding increases
- Documentation improves through collaboration

### 3. Faster Completion
- Parallel work on different aspects
- Faster reviews and feedback loops
- Reduced context switching for specialists

### 4. Risk Mitigation
- Multiple perspectives catch more issues
- Support agents can take over if lead is blocked
- Better estimation accuracy with team input

---

## Assignment Decision Tree

```
Task Received
    │
    ├─→ Is task single-domain? (e.g., pure backend)
    │       ├─→ YES: Assign specialist as lead, add test-master as support
    │       └─→ NO: Continue ↓
    │
    ├─→ Is task cross-functional? (e.g., full-stack feature)
    │       ├─→ YES: Assign primary domain lead + 2-3 cross-domain support
    │       └─→ NO: Continue ↓
    │
    ├─→ Is task infrastructure/tooling?
    │       ├─→ YES: Assign devops-lead, add relevant domain experts
    │       └─→ NO: Continue ↓
    │
    └─→ Is task design/UX?
            ├─→ YES: Assign ui-designer, add implementers as support
            └─→ NO: Escalate to project-manager for clarification
```

---

## Metrics & Success Criteria

### Track These Metrics

- **Task completion velocity** (with multi-agent vs single-agent)
- **Quality metrics** (bugs found, rework required)
- **Agent utilization** (balanced workload distribution)
- **Collaboration frequency** (log entries per support agent)

### Success Indicators

- ✅ Tasks complete 20-30% faster with multi-agent teams
- ✅ Defect rate reduced by 40% due to peer review
- ✅ No agent exceeds workload cap
- ✅ All agents contribute to at least 1 support role per sprint

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-10-10 | Initial strategy documentation |

---

**Maintained by**: project-manager
**Review Frequency**: Monthly
**Next Review**: 2025-11-10
