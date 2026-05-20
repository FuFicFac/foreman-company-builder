# Foreman — Paperclip Adapter

This adapter lets Foreman read issues from and write status to a Paperclip company
through the Paperclip API. Foreman is NOT a Paperclip plugin — it's a separate process
that composes with Paperclip through its REST API.

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