# Hat Transition Matrix - Orchestrator Workflow Guide

## 🔄 Overview

This matrix defines the natural transitions between orchestrator hats after task completion. Following these patterns ensures continuous workflow, maintains context, and delivers comprehensive solutions.

## 🎯 Core Principle

**NEVER STOP after completing a task - always transition to a related hat to continue the workflow.**

## 📊 Transition Matrix

### From Each Hat → To Next Hat(s)

| Current Hat | Task Completed | → Transition To | Reason |
|------------|---------------|-----------------|---------|
| **project-manager** | Planning done | → solution-architect | Design the architecture |
| | Requirements gathered | → ui-designer | Create mockups |
| | Sprint planned | → Any implementation hat | Start development |
| | Status updated | → scrum-master | Facilitate process |
| **solution-architect** | Architecture designed | → principal-database-architect | Design data layer |
| | System design complete | → senior-backend-engineer | Implement core |
| | Integration planned | → devops-lead | Setup infrastructure |
| | Security designed | → legal-software-advisor | Compliance check |
| **senior-backend-engineer** | API implemented | → test-master | Write API tests |
| | Service created | → principal-database-architect | Optimize queries |
| | Integration done | → devops-lead | Deploy service |
| | Feature complete | → senior-mobile-developer | Mobile integration |
| **principal-database-architect** | Schema designed | → senior-backend-engineer | Create entities |
| | Migrations created | → test-master | Test data layer |
| | Queries optimized | → devops-lead | Production tuning |
| | Indexes added | → senior-backend-engineer | Update repositories |
| **test-master** | Tests written | → devops-lead | CI/CD setup |
| | Tests passing | → senior-backend-engineer | Refactor code |
| | Coverage complete | → project-manager | Update status |
| | Bugs found | → senior-backend-engineer | Fix issues |
| **devops-lead** | Pipeline created | → test-master | Validate deployment |
| | Deployment ready | → project-manager | Report completion |
| | Infrastructure set | → senior-backend-engineer | Configure services |
| | Monitoring added | → solution-architect | Review architecture |
| **ui-designer** | Mockups complete | → web-dev-master | Implement UI |
| | Design system done | → senior-mobile-developer | Mobile UI |
| | UX flow designed | → psychologist-game-dynamics | Engagement check |
| | Accessibility done | → test-master | A11y testing |
| **web-dev-master** | React UI built | → test-master | Frontend tests |
| | Components done | → senior-backend-engineer | API integration |
| | PWA complete | → devops-lead | Deploy frontend |
| | State managed | → ui-designer | UX refinement |
| **senior-mobile-developer** | Flutter app built | → test-master | Mobile testing |
| | Native features | → senior-backend-engineer | Backend sync |
| | App optimized | → devops-lead | App store deploy |
| | UI implemented | → ui-designer | Design review |
| **scrum-master** | Sprint complete | → project-manager | Planning next |
| | Blockers removed | → Any blocked hat | Resume work |
| | Retrospective done | → solution-architect | Process improvement |
| | Team aligned | → test-master | Quality check |
| **opportunist-strategist** | Market analyzed | → project-manager | Prioritize features |
| | Opportunity found | → psychologist-game-dynamics | User psychology |
| | Competition studied | → ui-designer | Differentiation |
| | Trends identified | → solution-architect | Tech adoption |
| **psychologist-game-dynamics** | Engagement designed | → ui-designer | Visual hooks |
| | Retention planned | → senior-backend-engineer | Gamification |
| | Behavior analyzed | → game-theory-master | Strategic modeling |
| | Flow optimized | → web-dev-master | Implement flow |
| **game-theory-master** | Model created | → senior-backend-engineer | Algorithm implementation |
| | Strategy defined | → opportunist-strategist | Market positioning |
| | Incentives designed | → psychologist-game-dynamics | User motivation |
| | Nash equilibrium | → project-manager | Strategic decision |
| **legal-software-advisor** | Compliance verified | → project-manager | Risk report |
| | Privacy assessed | → senior-backend-engineer | Implement GDPR |
| | License chosen | → devops-lead | Update dependencies |
| | Terms drafted | → solution-architect | Architecture review |

## 🌟 Common Workflow Patterns

### 1. **Feature Development Flow**
```
project-manager (plan)
→ ui-designer (design)
→ web-dev-master (implement)
→ test-master (test)
→ devops-lead (deploy)
```

### 2. **Backend Service Flow**
```
solution-architect (design)
→ principal-database-architect (schema)
→ senior-backend-engineer (implement)
→ test-master (test)
→ devops-lead (deploy)
```

### 3. **Mobile App Flow**
```
ui-designer (mockups)
→ senior-mobile-developer (build)
→ senior-backend-engineer (API)
→ test-master (test)
→ devops-lead (publish)
```

### 4. **Database Optimization Flow**
```
principal-database-architect (analyze)
→ senior-backend-engineer (refactor)
→ test-master (benchmark)
→ devops-lead (deploy)
```

### 5. **Bug Fix Flow**
```
test-master (identify)
→ senior-backend-engineer (fix)
→ test-master (verify)
→ devops-lead (hotfix)
```

### 6. **Strategic Planning Flow**
```
opportunist-strategist (analyze)
→ game-theory-master (model)
→ psychologist-game-dynamics (engage)
→ project-manager (execute)
```

## 🎭 Multi-Hat Collaboration Patterns

Some tasks require rapid switching between multiple hats:

### **Full Stack Feature**
```
Cycle between:
- senior-backend-engineer ↔ web-dev-master
- Both → test-master (periodically)
```

### **Architecture Review**
```
Rotate through:
- solution-architect → principal-database-architect → devops-lead → solution-architect
```

### **User Experience Optimization**
```
Iterate between:
- ui-designer ↔ psychologist-game-dynamics ↔ web-dev-master
```

## 📋 Transition Triggers

### **Immediate Transitions** (Switch right away)
- ✅ Task marked `done`
- ✅ Deliverable complete
- ✅ Blocker resolved
- ✅ Milestone reached

### **Context Preserving Transitions** (Keep momentum)
- 🔄 Related domain expertise needed
- 🔄 Next logical step in workflow
- 🔄 Testing what was just built
- 🔄 Documenting what was implemented

### **Strategic Transitions** (Plan ahead)
- 📅 Sprint boundary
- 📅 Phase completion
- 📅 Major integration point
- 📅 Release preparation

## 🚫 Anti-Patterns to Avoid

### ❌ **Stopping After Completion**
```
WRONG: senior-backend-engineer (done) → [STOP]
RIGHT: senior-backend-engineer (done) → test-master
```

### ❌ **Skipping Related Work**
```
WRONG: ui-designer → devops-lead (skipping implementation)
RIGHT: ui-designer → web-dev-master → devops-lead
```

### ❌ **Circular Without Progress**
```
WRONG: test-master → senior-backend-engineer → test-master (endless loop)
RIGHT: test-master → senior-backend-engineer → test-master → devops-lead
```

## 💡 Best Practices

### 1. **Complete the Cycle**
Always follow through to deployment or documentation:
- Implementation → Testing → Deployment
- Design → Build → Verify → Ship

### 2. **Test Early and Often**
Frequently transition to `test-master`:
- After implementing features
- Before major integrations
- Following bug fixes

### 3. **Update Stakeholders**
Periodically wear `project-manager` hat:
- After major milestones
- When blockers arise
- At phase boundaries

### 4. **Consider User Impact**
Include user-focused hats in your flow:
- `ui-designer` for experience
- `psychologist-game-dynamics` for engagement
- `legal-software-advisor` for privacy

### 5. **Document Decisions**
Don't forget documentation transitions:
- Technical decisions → solution-architect
- API changes → senior-backend-engineer
- Database changes → principal-database-architect

## 📝 Logging Transitions

### Proper Transition Logging:
```bash
# Complete current hat's work
./.claude/tools/orchestrator-log \
  --role senior-backend-engineer \
  --status done \
  --task TASK-003 \
  "API implementation complete, all endpoints working"

# Immediately transition to next hat
./.claude/tools/orchestrator-log \
  --role test-master \
  --status in_progress \
  --task TASK-003 \
  "Starting API test suite creation"
```

## 🎯 Quick Reference Card

### After You Complete...
- **Backend code** → Write tests
- **Frontend code** → Test UI
- **Database work** → Integrate with backend
- **Tests** → Deploy or fix
- **Deployment** → Monitor and document
- **Documentation** → Update project status
- **Bug fix** → Test the fix
- **Design** → Implement it
- **Planning** → Start building
- **Review** → Address feedback

## 📊 Success Metrics

Your transitions are effective when:
- ✅ No "orphaned" completed tasks (always followed by related work)
- ✅ Natural workflow progression visible in logs
- ✅ Related work completed in clusters
- ✅ Minimal context switching between unrelated domains
- ✅ Comprehensive feature delivery (design → test → deploy)

## 🔄 Continuous Improvement

Review your transition patterns regularly:
1. Check hat usage statistics for patterns
2. Identify common transition sequences
3. Optimize for your project's needs
4. Document project-specific transitions

---

**Remember:** The orchestrator never stops working - they transition between expertise hats to deliver complete, tested, and deployed solutions.

*Last Updated: 2025-10-11*
*Version: 1.0.0*