This file defines the canonical JSON Lines log format every subagent must append to their per-agent log file and to the global status file.

### Agent Log Specification: `.claude/logs/<agent-name>.log` (JSON Lines)

This is an append-only, newline-delimited JSON log. Each entry captures a distinct moment of state change or finding. The fields below are recommended; when an entry can affect other agents the `task_*` and `potential_consequences` blocks are required.

Example minimal entry:

```json
{
  "timestamp": "2025-10-10T01:00:00Z",
  "agent": "java-backend-master",
  "status": "working",
  "percent_complete": 10,
  "emotion": "neutral",
  "findings": "Starting migration prep"
}
```

Full entry with task and consequences (required when affected_agents or risk_level present):

```json
{
  "timestamp": "2025-10-10T12:30:00Z",
  "agent": "java-backend-master",
  "task_id": "db-migrate-2025-10-10",
  "task_title": "Apply user table schema migration",
  "task_description": "Add column X and migrate existing data offline; requires DB restart.",
  "task_phase": "working",
  "status": "running",
  "percent_complete": 10,
  "importance": "high",
  "risk_level": "high",
  "safe_to_deploy": false,
  "affected_agents": ["web-dev-master","ui-designer"],
  "potential_consequences": [
    {
      "severity": "high",
      "impact": "frontend downtime",
      "description": "API will be unavailable for ~2–5 minutes during migration",
      "estimated_duration": "2-5m"
    }
  ],
  "mitigation": "Serve maintenance page, schedule during low-traffic window, notify front-end agent and ops.",
  "rollback_plan": "Revert migration script and restore DB from pre-migration snapshot if issues.",
  "owner_contact": "java-backend-master",
  "next_steps": ["Notify web-dev agents","Take DB snapshot","Start migration"],
  "confidence": 0.6,
  "meta": {}
}
```

Field notes and constraints:

- **timestamp**: ISO 8601 UTC string with **second precision only** (format: `YYYY-MM-DDTHH:MM:SSZ`).
  - ✓ Correct: `"2025-10-10T12:30:00Z"` (second precision, UTC)
  - ✗ Incorrect: `"2025-10-10T12:30:00.123Z"` (includes milliseconds)
  - ✗ Incorrect: `"2025-10-10T12:30:00.1234567Z"` (includes microseconds)
  - ✗ Incorrect: `"2025-10-10T12:30:00-05:00"` (not UTC)
  - **Use the PowerShell utility:** `.claude/tools/Get-ClaudeTimestamp.ps1` for consistent timestamps
- agent: short agent id (must match filename in `.claude/agents`).
- task_id / task_title / task_description: identifiers and human-readable summary for the work item.
- task_phase: one of planned|working|deploy|rollback|done|cancelled.
- risk_level: low|medium|high|critical — used for gating/alerts.
- affected_agents: list of other agents likely to be impacted; when present, `potential_consequences` and `mitigation` are required.
- potential_consequences: array of objects {severity, impact, description, estimated_duration}; severity must be low|medium|high|critical.
- safe_to_deploy: boolean flag used by agents to indicate readiness for deployment; CI may require approvals before this is true for high-risk items.

### Global Status Specification: `.claude/status.json` (Last State Only)

This is a single, non-historical JSON object that contains the **last status** for every agent. Agents must perform an atomic write to this file to update their state.

Example:

```json
{
  "last_update": "2025-10-10T00:00:00Z",
  "agents": {
    "java-backend-master": {
      "display_name": "Java Backend Master",
      "status": "working",
      "task_id": "db-migrate-2025-10-10",
      "percent_complete": 10,
      "importance": "high",
      "risk_level": "high",
      "emotion": "neutral",
      "updated": "2025-10-10T12:30:00Z"
    }
  }
}
```

Recommended practice:

- Always append one compact JSON line per state change to the per-agent log.
- When a task may impact others, publish a task entry early with expected windows, affected_agents, and consequences so UIs and other agents can prepare.
- Use the atomic snapshot pattern for `.claude/status.json` so dashboards always see a consistent single-file source-of-truth.

### Timestamp Utility

**IMPORTANT:** Always use the standardized timestamp utility to ensure consistency:

```powershell
# PowerShell - Use the utility function
. .\.claude\tools\Get-ClaudeTimestamp.ps1
$timestamp = Get-ClaudeTimestamp

# Example log entry with correct timestamp
$logEntry = @{
    timestamp = Get-ClaudeTimestamp
    agent = "project-manager"
    status = "working"
    emotion = "focused"
} | ConvertTo-Json -Compress
```

**Format Requirements:**
- **Format:** `YYYY-MM-DDTHH:MM:SSZ` (ISO 8601)
- **Timezone:** Always UTC (Z suffix)
- **Precision:** Seconds only (no milliseconds or microseconds)
- **Validation:** Timestamps should be within ±30 days of current date for active logs

This ensures all timestamps across agent logs, status files, and task tracking are consistent and correctly formatted.
