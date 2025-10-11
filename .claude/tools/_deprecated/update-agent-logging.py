#!/usr/bin/env python3
"""
Update all agent prompts with standardized logging enforcement section.
This replaces old logging instructions with the new zero-friction approach.
"""

import os
import re
from pathlib import Path

# The standardized logging enforcement section
LOGGING_SECTION = """### 🚨 MANDATORY LOGGING REQUIREMENTS

**⚠️ CRITICAL: This is not optional. Your work WILL BE REJECTED if you don't log properly.**

**READ FIRST:** `.claude/LOGGING_ENFORCEMENT.md` - Complete enforcement rules and consequences

#### The Easy Way (Use This)

Use the zero-friction bash wrapper for ALL logging:

```bash
# Start work
./.claude/tools/log {agent_name} "Starting [task description]" --status working --task TASK-XXX

# Progress update (every 2 hours minimum)
./.claude/tools/log {agent_name} "Completed [milestone]" --status working --emotion focused --task TASK-XXX

# Complete work
./.claude/tools/log {agent_name} "All [deliverables] complete" --status done --emotion happy --task TASK-XXX

# Get blocked
./.claude/tools/log {agent_name} "Blocked by [reason]" --status blocked --emotion frustrated --task TASK-XXX
```

**This automatically:**
- ✅ Appends to `.claude/logs/{agent_name}.log`
- ✅ Updates `.claude/status.json`
- ✅ Uses correct timestamp format
- ✅ Validates JSON

#### Three Non-Negotiable Rules

1. **Log BEFORE every status change** (idle → working, working → blocked, etc.)
2. **Log every 2 hours minimum** during active work
3. **Log BEFORE marking task complete**

**If you skip logging, your task will be reassigned.**

#### Required Fields (Automatically Handled by Tool)

- `timestamp` - UTC, seconds only: `2025-01-10T15:30:00Z`
- `agent` - Your name: `{agent_name}`
- `status` - One of: `idle`, `working`, `in_progress`, `blocked`, `done`
- `emotion` - One of: `happy`, `sad`, `frustrated`, `satisfied`, `neutral`, `focused`
- `message` - What you're doing/completed
- `task` - Task ID (e.g., `TASK-012`) when working on tasks

#### Compliance Check

Before completing ANY task:

```bash
./.claude/tools/check-compliance --agent {agent_name}
```

**This must pass or your work is incomplete.**

**📖 Full Enforcement Rules:** `.claude/LOGGING_ENFORCEMENT.md`
**🛠️ Logging Tool:** `.claude/tools/log`
**✅ Compliance Checker:** `.claude/tools/check-compliance`
"""

# Patterns to identify existing logging sections (case insensitive)
LOGGING_PATTERNS = [
    r'### Logging:.*?(?=###|\Z)',
    r'### MANDATORY: Task Management Protocol.*?(?=### Example|\Z)',
    r'#### 1\. System-Wide Agent Log.*?(?=###|\Z)',
    r'\*\*YOU MUST maintain TWO separate logging systems:\*\*.*?(?=###|\Z)',
]

def extract_agent_name(file_path):
    """Extract agent name from frontmatter."""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Look for name: field in frontmatter
    match = re.search(r'^name:\s*(.+)$', content, re.MULTILINE)
    if match:
        return match.group(1).strip()

    # Fallback to filename
    return Path(file_path).stem

def update_agent_prompt(file_path):
    """Update a single agent prompt file with logging enforcement."""
    agent_name = extract_agent_name(file_path)

    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Create the logging section with agent-specific name
    agent_logging_section = LOGGING_SECTION.format(agent_name=agent_name)

    # Try to find and replace existing logging section
    original_content = content
    replaced = False

    for pattern in LOGGING_PATTERNS:
        if re.search(pattern, content, re.DOTALL | re.IGNORECASE):
            content = re.sub(pattern, agent_logging_section, content, flags=re.DOTALL | re.IGNORECASE)
            replaced = True
            break

    # If no existing section found, insert before "Example" section or at end
    if not replaced:
        if '### Example' in content:
            content = content.replace('### Example', f'{agent_logging_section}\n\n### Example')
            replaced = True
        elif '---\n\n' in content:  # After frontmatter
            parts = content.split('---\n\n', 1)
            if len(parts) == 2:
                content = f"{parts[0]}---\n\n{parts[1]}\n\n{agent_logging_section}"
                replaced = True

    # Only write if content changed
    if content != original_content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        return True, agent_name

    return False, agent_name

def main():
    """Update all agent prompts in .claude/agents/"""
    script_dir = Path(__file__).parent
    agents_dir = script_dir.parent / 'agents'

    if not agents_dir.exists():
        print(f"ERROR: Agents directory not found: {agents_dir}")
        return

    print(">> Updating agent prompts with logging enforcement...")
    print()

    updated_count = 0
    skipped_count = 0

    for agent_file in sorted(agents_dir.glob('*.md')):
        try:
            was_updated, agent_name = update_agent_prompt(agent_file)
            if was_updated:
                print(f"[OK] Updated: {agent_name} ({agent_file.name})")
                updated_count += 1
            else:
                print(f"[SKIP] Skipped: {agent_name} ({agent_file.name}) - no changes needed")
                skipped_count += 1
        except Exception as e:
            print(f"[ERROR] Error updating {agent_file.name}: {e}")

    print()
    print(f"Summary:")
    print(f"   Updated: {updated_count}")
    print(f"   Skipped: {skipped_count}")
    print(f"   Total:   {updated_count + skipped_count}")
    print()

    if updated_count > 0:
        print("[SUCCESS] All agent prompts updated successfully!")
        print()
        print("Next steps:")
        print("1. Review changes: git diff .claude/agents/")
        print("2. Test compliance: ./.claude/tools/check-compliance")
        print("3. Commit changes: git add .claude/agents/ && git commit -m 'feat: enforce logging compliance'")
    else:
        print("[INFO] No updates needed - all agents already have enforcement language")

if __name__ == '__main__':
    main()
