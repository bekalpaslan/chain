# ⚠️ CRITICAL CONTEXT WARNING - READ BEFORE MAKING ASSUMPTIONS

## The Mistake That Led to This Document

On 2025-10-11, the orchestrator made a critical context error that revealed a dangerous pattern of assumptions. This document exists to prevent you from making the same mistake.

### What Happened

1. **Saw folder name:** `ticketz`
2. **Made assumption:** "This must be a ticket management/support system"
3. **Started designing:** Ticket dashboards, support queues, issue tracking
4. **Reality:** The project is "The Chain" - a social network where "tickets" are **invitations** to join

### Why This Happened (Root Causes)

1. **Name-based assumptions:** Jumped to conclusions based on folder name
2. **Ignored actual code:** Didn't read existing files that clearly show "The Chain"
3. **Ignored documentation:** Legal docs all reference "The Chain" social network
4. **Pattern matching failure:** Applied common interpretation ("ticket" = support) without verification
5. **Context blindness:** Focused on one piece of evidence (folder name) while ignoring overwhelming counter-evidence

## 🚨 CRITICAL RULES TO PREVENT THIS

### Rule 1: Evidence Over Assumptions
**ALWAYS examine actual code and documentation before making ANY assumptions about project purpose.**

❌ **WRONG:**
- See "ticketz" → Assume ticket management system
- See "chain" → Assume blockchain
- See "admin" → Assume admin panel for employees

✅ **CORRECT:**
- Read actual source code first
- Check existing documentation
- Look at database schemas
- Examine API endpoints
- Read legal documents for context

### Rule 2: Multiple Sources of Truth
**Never rely on a single indicator (like a folder name) to understand project context.**

Check at least 3 sources:
1. Source code (actual implementation)
2. Documentation (.md files)
3. Configuration files
4. Database schemas
5. API definitions
6. Legal documents
7. Test files

### Rule 3: Ask When Uncertain
**If context is unclear, explicitly state your uncertainty and ask for clarification.**

Example:
"I see the folder is named 'ticketz' but the code references 'The Chain' social network. Can you confirm this is about invitation tickets, not support tickets?"

## 📋 Project-Specific Context

### THIS PROJECT IS:
- **Name in code:** "The Chain"
- **Working folder name:** ticketz (confusing but true)
- **Type:** Invite-only social network
- **"Tickets" are:** Time-limited invitations to join the network
- **NOT:** A support/issue ticket management system

### Key Concepts:
1. **Chain:** The connected network of users (who invited whom)
2. **Tickets:** Invitations with unique codes and QR codes that expire
3. **Position:** User's numerical position in the global invitation chain
4. **Parent/Child:** Invitation relationships (who invited you / who you invited)

## 🔍 Verification Checklist

Before making ANY assumption about project purpose:

- [ ] Read at least 3 source files
- [ ] Check main.dart or main.java for project name
- [ ] Read README.md files
- [ ] Check database schema/entities
- [ ] Look at legal documents (privacy policy, terms)
- [ ] Examine API endpoints
- [ ] Read test files for business logic

## 🎓 Lessons for All Agents

### For Backend Engineers:
- Don't assume "ticket" means support ticket - check the Ticket entity definition
- The Chain has invitation logic, not issue tracking

### For UI Designers:
- Don't design ticket queues - design invitation flows and chain visualization
- Focus on social network patterns, not support desk patterns

### For Database Architects:
- Tickets have expiration and invitation codes, not priority and status
- Chain relationships are parent-child (tree), not assignment-based

### For Test Masters:
- Test invitation expiration, not ticket escalation
- Test chain integrity, not support SLAs

### For Legal Advisors:
- This is a social network with invite mechanics
- Privacy concerns are about social data, not support interactions

## 💡 The Meta-Lesson

**Names can be misleading. Architecture names, folder names, and project names might not reflect actual functionality.**

Common misleading patterns:
- Legacy names that no longer match current purpose
- Working names vs. production names
- Internal codenames vs. public names
- Repurposed projects with old names

## 🚫 Red Flags That Should Trigger Verification

If you see these, STOP and verify context:
- Folder name doesn't match code references
- Documentation talks about different project name
- Conflicting descriptions in different files
- Your assumptions seem too obvious
- The "standard" interpretation feels too easy

## ✅ How to State Context Properly

When starting work, explicitly state your understanding:

**Good Example:**
"I understand this is The Chain social network (despite the 'ticketz' folder name), where tickets are invitations to join, not support tickets. The home screen shows the invitation chain visualization."

**Bad Example:**
"Working on the ticket management system homepage."

## 📝 Update This Document

If you discover other context confusion risks, add them here to help future sessions.

---

**Remember:** The folder says "ticketz" but this is "The Chain" social network. Tickets are invitations, not support issues.

**Always verify context before making assumptions.**