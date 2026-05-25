# Foreman — Paperclip Compatibility Adapter

This adapter lets Foreman read issues from and write status to a Paperclip company through the Paperclip API.

The long-term product goal is broader than a thin adapter: Foreman should be able to import an existing Paperclip company, preserve what the user already built, classify stale/zombie/live work, and add closeout discipline without forcing a rebuild.

Default strategy: keep Foreman native and Paperclip-compatible rather than maintaining a hard fork. A hard fork should be a last resort, not the plan. Foreman should selectively reuse the good ideas and import shapes without inheriting Paperclip's whole lifecycle mess or upstream merge treadmill.

Foreman may run as a separate process, a Paperclip-compatible importer, or a native app that understands Paperclip company packages. The user-facing promise stays the same: bring your Paperclip company; Foreman upgrades how it runs.

## Configuration

```bash
# Paperclip server URL
export PAPERCLIP_API_BASE="http://127.0.0.1:3100"

# Paperclip company ID
export PAPERCLIP_COMPANY_ID="your-company-id"

# Agent API key (generate in Paperclip dashboard)
export PAPERCLIP_AGENT_KEY="your-agent-key"
```

## How It Works

1. Foreman reads open issues from Paperclip
2. Foreman dispatches builders and inspectors using the Foreman skill
3. Foreman updates issue status in Paperclip as work progresses
4. Foreman logs run results back to Paperclip

## Import / Upgrade Flow

A future `foreman import paperclip` flow should:

1. read company metadata, org charts, agents, goals, issues, comments/evidence, budgets, routines, skills, and workspace references;
2. scrub or re-request secrets instead of copying sensitive values blindly;
3. classify active work as live, in review, blocked, stale, zombie, invalid run state, or needs human;
4. produce a migration report before resuming execution;
5. offer `foreman closeout --company <company-id>` as the first safe action.

Foreman must not blindly resume imported active runs. Completed or cancelled work should stay completed unless the human explicitly reopens it. Newly discovered defects should become follow-up issues.

## API Endpoints Used

- `GET /api/companies/:id/issues` — list open issues
- `GET /api/companies/:id/issues/:issueId` — read issue details
- `PATCH /api/companies/:id/issues/:issueId` — update status
- `POST /api/companies/:id/runs` — log run results

## Independence

If Paperclip is unavailable, Foreman falls back to standalone mode:
- Tasks can be specified via CLI flags or local files
- Status tracking happens in local markdown or git
- No Paperclip dependency for core Foreman functionality