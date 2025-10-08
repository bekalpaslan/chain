# Requirements Specification — The Chain

This document formalizes the product requirements for The Chain. It is derived from `definition.md` and the project docs. Use this as the authoritative source for requirements, acceptance criteria, test mapping, and release priorities.

Version: 2025-10-08
Author: auto-generated from repository analysis

## Purpose
Provide a clear, testable, and traceable set of functional and non-functional requirements for design, implementation, testing, and release.

## Contract (inputs / outputs / acceptance)
- Inputs: API calls, user actions (generate ticket, claim ticket), device fingerprints, push notifications
- Outputs: tickets (signed payloads), chain state transitions, audit events (wasted, removed), notifications
- Acceptance: Each functional requirement below includes acceptance criteria that must be met for the requirement to be "Done".

---

## Requirement ID scheme
- Functional: REQ-###
- Non-functional: NFR-###
- Security / Privacy: SEC-###
- Infrastructure / Ops: OPS-###

---

## Functional Requirements (priority: Must/Should/Could)

### REQ-001 — Generate Ticket (Must)
- Description: The active tip can generate a signed ticket (QR payload) to invite the next user.
- API: POST /api/tickets/generate
- Inputs: Authorization (JWT), optional metadata (expires_in override not permitted)
- Outputs: 201 Created with JSON { ticket_id (uuid), qr_payload (base64), expires_at (ISO8601) }
- Acceptance Criteria:
  - Response contains valid UUID and iso8601 expires_at exactly 24 hours from generation.
  - Server signs the payload using server private key; signature verified by server on claim.
  - DB row created in `tickets` and audit event emitted.
- Edge cases: rate-limited per-user after X requests/min (see NFR-003)

### REQ-002 — Claim Ticket (Must)
- Description: A claimant scans QR and submits claim to join chain.
- API: POST /api/tickets/claim
- Inputs: { ticket_id, signature, claimant_device_fingerprint, optional claimant_metadata }
- Outputs: 200 OK { chain_key, user_info }
- Acceptance Criteria:
  - Ticket is validated (signature, not expired, not already claimed, owner is allowed to invite).
  - On success, new user row created, chain linkage (parent_id) stored, ticket marked consumed.
  - If ticket expired: 410 Gone with audit log; if already claimed: 409 Conflict.
  - Operation must be idempotent when same claimant retry occurs.
- Edge cases: concurrent claims must be resolved with distributed locking via Redis (see NFR-004).

### REQ-003 — Ticket Expiration & Waste (Must)
- Description: When a generated ticket expires unused, it becomes a "wasted" ticket and is publicly logged.
- Trigger: scheduled job or TTL event at expires_at
- Acceptance Criteria:
  - Expired tickets move to status `wasted` and `wasted_at` timestamp recorded.
  - Public index increments wasted counter and stores minimal record for audit (ticket_id, inviter_chain_key, timestamp).

### REQ-004 — 3-Strike Removal Rule (Must)
- Description: If an active tip generates 3 tickets that each expire (wasted) consecutively, that member is removed and chain reverts to previous tip.
- Acceptance Criteria:
  - Maintain fail_count per member while they are tip; on third consecutive wasted attempt, mark user `removed: true` with reason.
  - Chain tip becomes the previous active member; create audit event and public log entry.
  - Removed users remain visible in history as "removed" (do not re-number existing chain keys).

### REQ-005 — Reactivation Notifications (Should)
- Description: When a member becomes the active tip (first time or reactivated), notify via push + in-app badge; reminders at 12h and 1h.
- Acceptance Criteria:
  - Push notification sent within 1 minute of tip change.
  - Reminder notifications at 12h and 1h if still tip.
  - Notifications recorded in DB; retries on transient FCM failures.

### REQ-006 — Visibility Model — Two-Link Window (Must)
- Description: A user can only see their inviter and their invitee (if present); all other chain details are hidden except global stats and public removed/wasted log.
- Acceptance Criteria:
  - API returning user view: GET /api/users/{id}/view returns inviter (id, chain_key, public_name), self, invitee (if exists) and global stats.
  - Global public pages show aggregated metrics and removed/wasted lists but do not reveal private chain linkages.

### REQ-007 — Audit & Public History (Should)
- Description: Public history shows removed/wasted events with minimal identifying info; chain length and stats accessible publicly.
- Acceptance Criteria:
  - Public endpoints for stats and removed/wasted events exist and paginate.

### REQ-008 — Seed Resilience (Should)
- Description: Person #1 (seed) is immortal or managed to ensure chain continuity if chain collapses to seed.
- Acceptance Criteria:
  - Seed account is marked `managed` and not subject to removal rules.

### REQ-009 — Device-Based Authentication (Must)
- Description: Users authenticate using device fingerprint and short-lived JWTs; refresh tokens permitted if device remains unchanged.
- Acceptance Criteria:
  - JWT design documented, refresh token storage and rotation implemented, and device fingerprint mapping stored in DB/Redis.

### REQ-010 — Admin Recovery Tools (Could)
- Description: Admins can intervene to reattach or stitch chains, or mark specific removals as appeals.
- Acceptance Criteria:
  - Admin API exists but protected with RBAC; events are logged.

---

## Non-Functional Requirements (NFR)

### NFR-001 — Availability
- Target: 99.9% API availability for core endpoints (generate, claim, view) measured over 30d window.

### NFR-002 — Latency
- Target: 95th percentile API latency < 300ms for read endpoints, and <500ms for write endpoints under normal load.

### NFR-003 — Rate Limiting & Abuse Prevention
- Per-user: default 60 generate attempts per hour (configurable).
- Per-IP: default 300 requests per minute.
- Rate-limit counters stored in Redis; blocked requests return 429.

### NFR-004 — Consistency & Concurrency
- Ticket claim must be linearizable: concurrent claims are resolved via Redis-based distributed lock or atomic DB transaction.
- Idempotency keys allowed for claim endpoint.

### NFR-005 — Durability
- Postgres is the source of truth for persistent data; Redis used for cache, locks, and ephemeral state. Backups: daily RDB + AOF for Redis, daily DB backups for Postgres.

### NFR-006 — Monitoring & Alerts
- Alert: claim failure rate > 1% triggers PagerDuty.
- Metrics: ticket generation rate, waste rate, removal rate, active chain length.

---

## Security & Privacy Requirements (SEC)

### SEC-001 — Data Minimization
- Store minimal public info for removed/wasted logs; do not expose device fingerprints publicly.

### SEC-002 — Transport & At-Rest Encryption
- TLS for all external traffic; DB at rest encryption recommended.

### SEC-003 — GDPR/CCPA
- Endpoints for data export and deletion per user; removed historical log should not impede user's right to be forgotten — provide a process to pseudonymize public entries where required.

### SEC-004 — Secrets & Keys
- Private signing keys stored in KMS or environment vault; rotate keys periodically and support key versioning for signature validation.

---

## Traceability Matrix (sample)

| Req ID | Title | API Endpoint | Code area | Tests |
|--------|-------|--------------|-----------|-------|
| REQ-001 | Generate Ticket | POST /api/tickets/generate | ticket-service | unit, integration, e2e |
| REQ-002 | Claim Ticket | POST /api/tickets/claim | ticket-service, user-service | unit, integration, e2e |
| REQ-004 | 3-Strike Removal | internal job / event | ticket-service, cron | integration, e2e |

---

## Acceptance Test Skeletons
- For each REQ, create unit/integration and E2E tests. Example for REQ-002 Claim Ticket:
  - Unit: verify signature verification logic accepts valid and rejects invalid signatures.
  - Integration: seed DB, generate ticket, simulate claim from client, verify DB linkage and audit logs.
  - E2E: mobile flow: generate QR → scan → claim; assert user appears as next chain link.

---

## MoSCoW Backlog (high-level)
- Must: REQ-001, REQ-002, REQ-003, REQ-004, REQ-006, REQ-009
- Should: REQ-005, REQ-007, REQ-008
- Could: REQ-010

---

## Operational Runbook (short)
- When claim throughput spikes, check Redis latency and lock contention.
- If chain shrinkage observed, inspect audit logs to identify mass removals and possible notification failures.
- Restore process: DB backups + replay audit events to reconstruct public history.

---

## Changelog
- 2025-10-08: Initial generated spec from `definition.md` content.

---

## Next actions (I can do)
1. Convert each high-level item in `definition.md` into REQ entries (I can automate most).
2. Generate a Traceability CSV mapping to backend modules (I need package/class names to map fully).
3. Create Postman/Newman collection skeleton for API contract tests.

If you want me to proceed with (1) and update `definition.md` to embed the new REQ IDs inline, say "migrate now". If you prefer I first create unit/integration test skeletons, say which language/framework to target (Java Spring Boot JUnit + MockMvc?).

---

## Automated migration — requirements extracted from `definition.md`

The following REQ entries were created by migrating the high-level paragraphs and rules from `definition.md`. These are explicit, testable requirements with acceptance criteria and suggested tests.

### REQ-011 — Linear Chain Model & Single Active Ticket (Must)
- Description: The system enforces a single active ticket at any time — only the current tip can generate a ticket.
- Acceptance Criteria:
  - Only the user marked as `active_tip` may call `POST /api/tickets/generate`; other users receive 403 Forbidden.
  - Generating a ticket sets ticket.owner to the active tip and sets expires_at to exactly 24 hours later.
  - System metrics reflect a single active tip at a time (no parallel active tickets allowed).
- Tests: unit for permission check, integration for generate+reject attempts from non-tip users.

### REQ-012 — Ticket Return Behavior (Must)
- Description: If a generated ticket expires unused, it returns to the inviter (owner) as a wasted attempt and the owner may generate again unless removed by 3-strike rule.
- Acceptance Criteria:
  - Expired ticket moves to `wasted` status and increments inviter.fail_count.
  - Inviter can generate a new ticket after waste unless they reached removal threshold.
- Tests: simulate TTL expiry job, verify fail_count and ability to regenerate.

### REQ-013 — 3-Strike Removal & Chain Reversion (Must — implemented as REQ-004)
- Note: REQ-004 already describes the 3-strike removal rule; this migration keeps reference to that requirement and links it to events described in `definition.md`.

### REQ-014 — Tip Reactivation & Grace Periods (Must)
- Description: When a previously successful member becomes tip again (after a removal downstream), they have 24 hours to act or be removed as inactive.
- Acceptance Criteria:
  - When tip reverts to previous user, a `reactivation` event is emitted and notifications dispatched.
  - If they do not generate a ticket within 24 hours, they are removed and audit log states "removed - inactive when reactivated".
- Tests: integration test that simulates downstream removals and verifies notification + removal.

### REQ-015 — Seed Account Resilience (Should)
- Description: The seed (Person #1) is protected from automatic removal; optionally managed by operators to avoid total collapse.
- Acceptance Criteria:
  - Seed user has flag `managed_seed=true` and is exempt from automatic 3-strike/inactivity removals.
  - Admin tools can still act on seed account when necessary.
- Tests: admin integration tests and negative tests for automatic removal attempts.

### REQ-016 — Notification System & Multi-Channel Alerts (Should)
- Description: Critical chain events (tip change, reminders, final warnings, removal) are delivered via push notifications, in-app messages, and optionally email/SMS.
- Acceptance Criteria:
  - Push delivered within 1 minute of tip change; reminders at 12h and 1h before expiry.
  - Failure to deliver push is retried and recorded; escalations to email/SMS configurable per user preference.
- Tests: mock FCM/APNs, verify scheduling and retry behavior.

### REQ-017 — Visibility Model — Two-Link Window (Must — duplicate of REQ-006)
- Note: REQ-006 already captures the two-link visibility rule. This entry validates examples in `definition.md` and reinforces acceptance criteria.

### REQ-018 — Public History Format & Removed/Wasted Listings (Should)
- Description: A paginated public history lists removed and wasted members with minimal info and timestamps, plus global stats and historical max.
- Acceptance Criteria:
  - Endpoint `GET /public/history` returns paginated entries with fields: event_type (wasted/removed), position, public_label, timestamp.
  - `GET /public/stats` returns active_length, historical_max, waste_rate, success_rate.
- Tests: API contract tests and data privacy checks.

### REQ-019 — Metrics & Health Tracking (Must)
- Description: Track chain health and engagement metrics described in `definition.md` (active length, removal rate, wasted tickets, average attach time, etc.).
- Acceptance Criteria:
  - Metrics emitted to Prometheus (or metrics backend) with stable metric names and labels.
  - Alerts wired for thresholds (e.g., sudden removal spikes).
- Tests: unit metrics emission and integration with test metrics collector.

### REQ-020 — Chain Collapse Circuit Breaker (Could)
- Description: Provide an operational circuit breaker or manual intervention path to prevent catastrophic collapse (e.g., mass removals) from wiping the chain history.
- Acceptance Criteria:
  - Admin can pause automatic removals for a short window while human investigation occurs.
  - System documents and requires manual confirmation for mass removals > X% in Y hours.
- Tests: admin flow tests.

### REQ-021 — Dormant/User Reactivation Flow (Should)
- Description: When a user reappears as tip after long dormancy, system sends multi-channel reminders (push, email, SMS) before automatic removal and logs attempts.
- Acceptance Criteria:
  - Configurable retry schedule and escalation channels.
  - Logging includes delivery attempts and user response timestamps.
- Tests: simulate dormant user reactivation and verify messages & logging.

### REQ-022 — Privacy: Limited Visibility & Data Deletion (Must — aligns with SEC-001)
- Description: Public logs must not expose device fingerprints; users may request deletion/pseudonymization affecting public entries.
- Acceptance Criteria:
  - Data export and deletion endpoints available; public entries are pseudonymized upon verified deletion requests.
  - Public history retains event metadata but not personal identifiers when deletion processed.
- Tests: deletion export flows and privacy compliance tests.

### REQ-023 — UX: Two-Link Window Display & Badging (Should)
- Description: UI must show inviter, self, invitee, and a "hero" badge when a user rescues the chain after downstream removals.
- Acceptance Criteria:
  - UI endpoints deliver inviter/invitee info with minimal payload; hero badge toggles on rescue event.
  - Mobile screens use this data to render appropriate views.
- Tests: UI snapshot tests and integration tests for the badge condition.

### REQ-024 — Edge Case Handling: Concurrent Claims & Locks (Must — aligns with NFR-004)
- Description: Concurrent attempts to claim the same ticket are resolved deterministically (first valid claim wins); others see 409 Conflict.
- Acceptance Criteria:
  - Claim endpoint uses Redis lock or DB transaction to ensure single winner.
  - Idempotency keys supported to avoid duplicate processing from retries.
- Tests: concurrency integration tests.

### REQ-025 — Admin Recovery/Appeals (Could — aligns with REQ-010)
- Description: Admins can review removal events and, after verification, mark appeals that restore users or annotate public logs.
- Acceptance Criteria:
  - Admin APIs exist with RBAC; appeal actions create auditor-signed events appended to public history.
  - Appeals do not automatically re-number chain positions but may add an annotation: "appealed".
- Tests: admin API tests and audit log verification.

### REQ-026 — Onboarding Flow for Invitee (Must)
- Description: Scanning a QR should produce a fast, low-friction onboarding flow: download app (or open web), minimal profile (display name, optional coarse location), accept TOS, claim ticket.
- Acceptance Criteria:
  - Mobile deep link / web landing supports one-tap join where possible and returns to claim flow.
  - Claiming process completes within reasonable time (UX SLO: median < 60s for join flow).
  - Errors (already claimed / expired) produce clear UI states with next steps.
- Tests: E2E onboarding scenarios for mobile and web, with failure paths.

---

These entries migrate the high-level rules and product behaviors found in `definition.md` into concrete REQ entries. I can now:

- (A) Insert REQ IDs inline into `definition.md` to link narrative text to requirement IDs, or
- (B) Map each REQ to exact backend controller/service classes and add test skeletons.

Which would you like next? "embed REQs" or "map to code"?
