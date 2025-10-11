#!/usr/bin/env python3
"""
Add AGENT_CAPABILITIES reference to all agent prompts.
Inserts at the top of system prompt section.
"""

import os
import re
from pathlib import Path

# The reference text to add
CAPABILITIES_REFERENCE = """
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

**How to Work with Orchestrator:**
- Provide COMPLETE file contents in your response
- Use structured JSON or clear markdown sections
- Mark which operations can run in parallel
- Include verification steps

**📖 Full Guide:** `docs/references/AGENT_CAPABILITIES.md`

**Example Output:**
```json
{
  "files_to_create": [
    {"path": "file.md", "content": "Full content here...", "parallel_safe": true}
  ],
  "commands_to_run": [
    {"command": "git add .", "parallel_safe": false, "depends_on": []}
  ]
}
```

---

"""

def update_agent_prompt(file_path):
    """Add capabilities reference to agent prompt."""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Check if already added
    if 'AGENT_CAPABILITIES.md' in content:
        return False, "Already has reference"

    # Find "System Prompt:" section
    match = re.search(r'^System Prompt:\s*$', content, re.MULTILINE)
    if not match:
        return False, "No 'System Prompt:' section found"

    # Insert after "System Prompt:"
    insert_pos = match.end()

    new_content = (
        content[:insert_pos] +
        '\n\n' +
        CAPABILITIES_REFERENCE +
        content[insert_pos:]
    )

    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(new_content)

    return True, "Added capabilities reference"

def main():
    """Update all agent prompts."""
    script_dir = Path(__file__).parent
    agents_dir = script_dir.parent / 'agents'

    if not agents_dir.exists():
        print(f"ERROR: Agents directory not found: {agents_dir}")
        return

    print(">> Adding AGENT_CAPABILITIES reference to all agent prompts...")
    print()

    updated = 0
    skipped = 0
    errors = 0

    for agent_file in sorted(agents_dir.glob('*.md')):
        try:
            agent_name = agent_file.stem
            was_updated, reason = update_agent_prompt(agent_file)

            if was_updated:
                print(f"[OK] {agent_name}: {reason}")
                updated += 1
            else:
                print(f"[SKIP] {agent_name}: {reason}")
                skipped += 1
        except Exception as e:
            print(f"[ERROR] {agent_file.name}: {e}")
            errors += 1

    print()
    print("Summary:")
    print(f"  Updated: {updated}")
    print(f"  Skipped: {skipped}")
    print(f"  Errors:  {errors}")
    print()

    if updated > 0:
        print("[SUCCESS] Agent prompts updated with capabilities reference!")
        print()
        print("Next steps:")
        print("1. Review changes: git diff .claude/agents/")
        print("2. Test an agent to verify they follow the pattern")
        print("3. Commit: git add .claude/ && git commit -m 'docs: add capabilities reference to all agents'")
    else:
        print("[INFO] No updates needed")

if __name__ == '__main__':
    main()
