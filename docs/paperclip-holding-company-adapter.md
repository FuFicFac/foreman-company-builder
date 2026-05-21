# Paperclip Holding-Company Adapter Spec

Foreman should compose with Paperclip as an API client, not as a fragile plugin. Paperclip owns the visual company model; Foreman owns execution discipline.

## Responsibilities

### Paperclip

- company registry
- org chart / agent roster
- Kanban / issues
- routines / recurring work
- budget and approval state
- human-readable activity log
- dashboard

### Hermes

- runtime for Hank/chairman and spawned company agents
- profiles / skills / memory scopes
- cron jobs and task execution
- tool access
- delivery back to Telegram or other channels

### Foreman

- onboarding and capability selection
- tool-manifest checks
- builder dispatch
- inspector dispatch
- arbitration
- 3-strike escalation
- Paperclip status writeback
- run artifacts and verdicts

## Core Objects

### Company Context

```json
{
  "id": "company-id",
  "slug": "wam-media",
  "name": "Why AI Matters Media Co.",
  "mission": "Grow the channel and turn AI education into sustainable revenue.",
  "company_type": "youtube",
  "capabilities": ["research", "video-production", "sponsorships", "analytics"],
  "chairman": "hank",
  "ceo_agent": "wam-ceo",
  "escalation_target": "hank"
}
```

### Tool Manifest

```json
{
  "company_id": "company-id",
  "tools": {
    "research": ["wikipedia", "hackernews", "company-goat"],
    "commerce": ["stripe", "gumroad", "shopify"],
    "ops": ["linear", "github"]
  },
  "installation_source": "printing-press",
  "verified_at": "2026-05-21T13:00:00Z"
}
```

### CEO Agent

```json
{
  "id": "publishing-ceo",
  "company_id": "publishing-company",
  "role": "CEO",
  "mandate": "Manage book production, launch, direct sales, and reader growth.",
  "allowed_capabilities": ["editorial", "digital-commerce", "email-marketing", "analytics"],
  "reports_to": "hank"
}
```

### Foreman Run

```json
{
  "id": "run-id",
  "company_id": "publishing-company",
  "issue_id": "PUB-17",
  "task": "Create product page and launch email sequence for ePub release.",
  "loop_mode": "deluxe",
  "builder": "publishing-builder",
  "inspectors": ["Commerce", "Metadata", "ZIGGY"],
  "attempt": 1,
  "verdict": "needs_fixes",
  "blockers": ["No refund/support policy stated"],
  "artifacts": [],
  "escalated": false
}
```

### Audit Event

```json
{
  "company_id": "publishing-company",
  "actor": "foreman",
  "event_type": "inspection_failed",
  "summary": "Product page missing digital delivery/support language.",
  "linked_run": "run-id",
  "created_at": "2026-05-21T13:00:00Z"
}
```

## API Shape Foreman Needs

This is the minimum Paperclip-facing contract.

```text
GET    /api/companies
GET    /api/companies/:id
GET    /api/companies/:id/issues
PATCH  /api/issues/:id
POST   /api/companies/:id/activity
POST   /api/companies/:id/agents
POST   /api/companies/:id/foreman-runs
PATCH  /api/foreman-runs/:id
```

If Paperclip lacks a native `foreman-runs` object, Foreman can initially write runs as structured activity log entries plus issue comments/status fields.

## Holding-Company Flow

```text
Hank/chairman selects or creates company
        ↓
Paperclip returns company context + issue
        ↓
Foreman loads company module/capabilities
        ↓
Foreman checks tool manifest
        ↓
Hermes spawns CEO/builder/inspector agents
        ↓
Foreman arbitrates
        ↓
Paperclip receives status, artifacts, audit log
        ↓
Hank receives only final report or escalation
```

## Early Implementation Rule

Start API-light:

1. Read company and issue context from Paperclip.
2. Run Foreman locally.
3. Write result back as issue status + activity log.
4. Only later add rich Foreman run objects to Paperclip.

This keeps Foreman independent while still making Paperclip the visual command console.
