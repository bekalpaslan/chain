# .claude — logging and status conventions

# .claude — logging and status conventions

This document shows safe, repeatable patterns for:

- Appending newline-delimited JSON (JSONL) entries to per-agent logs in `.claude/logs/<agent>.log`.
- Atomically updating the last-state file `.claude/status.json` so the dashboard and other readers always see a consistent snapshot.

These examples target PowerShell (pwsh) since your default shell is `pwsh.exe`. There are short notes for portability and concurrency considerations.

## Recommended flow for an agent when reporting progress

1. Create a JSON object representing the log entry (one object per line).
2. Append that JSON object as a single newline-terminated line to the agent's log file (`.claude/logs/<agent>.log`).
3. Prepare an updated `status.json` object reflecting the agent's latest state, write it to a temp file, then atomically replace `.claude/status.json` with the temp file.

Append-only logs preserve history. `status.json` stores the single source-of-truth latest snapshot and must be replaced atomically.

## PowerShell example — append one JSON line to an agent log

The snippet below builds a small hashtable, converts it to a compact JSON string, and appends it to the agent log file as one line.

```powershell
# Build a log entry as a PowerShell hashtable
$entry = @{ 
    timestamp = (Get-Date).ToUniversalTime().ToString('o')
    agent = 'java-backend-master'
    task_id = 'TASK-0001'
    phase = 'analysis'
    status = 'working'
    percent_complete = 5
    importance = 'medium'
    emotion = 'neutral'
    blocked = $false
    blocked_by = $null
    interactions = @()
    disagree = $false
    disagree_reason = $null
    findings = 'Started task'
    artifacts = @()
    next_steps = @('implement endpoint')
    confidence = 0.5
    meta = @{ duration_seconds = 0 }
}

# Convert to compact JSON (PowerShell 7+ supports -Compress)
$line = $entry | ConvertTo-Json -Compress -Depth 10

# Append the single-line JSON to the agent log (creates file if missing)
Add-Content -Path '.\.claude\logs\java-backend-master.log' -Value $line

# Optionally append a newline (Add-Content will place the value as a separate line already).
```

Notes:
- Use `ConvertTo-Json -Compress` so the entry is a single-line JSON object. That keeps logs strictly newline-delimited JSON (JSONL).
- `Add-Content` is append-only and works well for preserving history. If multiple processes append concurrently, the file system will generally serialize small append calls, but race conditions are possible on highly concurrent workloads — consider a dedicated logging service for heavy concurrency.

## PowerShell example — atomically update `.claude/status.json`

To ensure readers never see a partial write of `status.json`, write the full JSON to a temporary file and then replace the original with `Move-Item -Force`. The move/rename is atomic on the same filesystem.

```powershell
function Update-StatusAtomically {
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$StatusObject,
        [string]$StatusPath = '.\.claude\status.json'
    )

    # Build temp path in same folder
    $dir = Split-Path -Parent $StatusPath
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }

    $tmp = Join-Path $dir ([System.IO.Path]::GetRandomFileName() + '.tmp')

    # Convert to compact JSON and write to temp file
    $StatusObject | ConvertTo-Json -Compress -Depth 10 | Set-Content -Path $tmp -Encoding UTF8

    # Atomically replace target file. Move-Item is atomic on the same volume.
    Move-Item -Path $tmp -Destination $StatusPath -Force
}

# Example usage:
$status = @{
    last_update = (Get-Date).ToUniversalTime().ToString('o')
    agents = @{
        'java-backend-master' = @{
            status = 'working'
            task_id = 'TASK-0001'
            percent_complete = 5
            importance = 'medium'
            emotion = 'neutral'
            updated = (Get-Date).ToUniversalTime().ToString('o')
            display_name = 'Java Backend Master'
            findings = 'Started implementation'
        }
    }
}

Update-StatusAtomically -StatusObject $status -StatusPath '.\.claude\status.json'
```

Notes and caveats:
- Ensure the temp file is written to the same filesystem/volume as the final file — Move/rename semantics are atomic only within the same filesystem.
- Use `-Compress` to avoid pretty-printed multi-line JSON (so the file is compact). If you prefer pretty JSON for human readability, omit `-Compress` but be aware consumers must handle multi-line JSON parsing.
- `Set-Content` in PowerShell Core (pwsh) writes UTF-8 without BOM by default which is safe for most readers; include `-Encoding UTF8` to be explicit.

## Combined pattern (append log, then update status)

Agents should typically append to their log first (history) and then update `status.json` (latest snapshot). That ensures the snapshot references the latest chronological history.

```powershell
# Append history
Add-Content -Path '.\.claude\logs\java-backend-master.log' -Value $line

# Atomically update snapshot
Update-StatusAtomically -StatusObject $status -StatusPath '.\.claude\status.json'
```

If you must perform the two operations together in a transactional manner, consider using an external coordination service (e.g., a small HTTP API that performs both writes under a lock), or implement a retry/backoff approach in readers.

## Concurrency guidance

- Append-only logs are resilient for audit history. Frequent concurrent writes are usually OK for light-to-moderate throughput.
- `status.json` should be small; each agent should write the full snapshot object and rely on atomic replace. If multiple agents update the snapshot concurrently, last-writer-wins; include timestamps (`last_update`) so the dashboard can choose the latest.
- For heavy concurrency or strict consistency, use a central datastore (Redis, Postgres) or a local daemon that serializes agent updates and writes the files.

## Optional: small Node.js and Bash examples

- If you want Node or Bash examples as well, tell me and I will add them.

---

If you'd like, I can also:
- Initialize `.claude/status.json` with all agents present and set to `idle` so the dashboard shows placeholders immediately.
- Add a small PowerShell helper script `tools/update-status.ps1` that agents can call.
