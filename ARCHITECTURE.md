# Architecture

**Locked decision (2026-07-10, EJ):** Foreman Company Builder is harness-agnostic.

## What this repo is

Foreman Company Builder packages **company operating systems** as markdown and JSON: departments, roles, checklists, templates, and pipeline definitions. Any capable agent harness can load and execute those packages. The repo does not assume a single runtime.

The **foreman CLI** (`foreman init`, `foreman blast`, `foreman run`, …) remains the primary product surface. Users interact with company packages through Foreman commands and local workspace artifacts. Harnesses are optional engines behind that surface.

## Harness targets

| Harness | Role |
|---------|------|
| **Hermes** | Reference harness — agents, tools, skills, cron, and follow-up in one runtime |
| **OpenClaw** | Second target — same company packages, different dispatch path |
| **Standalone CLI** | Primary path — Cursor, Claude, Codex, Ollama, or any discovered provider |

Hermes and OpenClaw are integration targets, not architectural owners. Company semantics live in the packages; harnesses provide dispatch, tooling, and scheduling.

## Package layers

```text
Company template (modules/<domain>/)
  = selected departments + capabilities + merged manifests

Department primitive (modules/departments/<slug>/)
  = reusable business function (workflows, roles, inspectors, gates)

Catalog (modules/departments/catalog.json)
  = source of truth for department synthesis
```

Department manifests are generated from the catalog (`scripts/sync-department-modules.py`). Do not hand-edit generated `module.json` files when the catalog or sync script should own the field.

See [docs/department-module-schema.md](docs/department-module-schema.md) for manifest fields, capability composition, and validation rules.

## Operating discipline

Regardless of harness, Foreman enforces:

- Builder → inspector → arbitration → fix loop
- Human approval gates as first-class pause events
- Evidence capture before closeout
- Durable company state (runs, decisions, artifacts)

The Foreman skill documents dispatch, provider discovery, and loop modes: [skills/foreman/SKILL.md](skills/foreman/SKILL.md).

## What is out of scope here

- Harness-specific plugin code (lives in Hermes/OpenClaw integrations)
- Paperclip board UI (optional visibility layer; see README)
- Runtime secrets, credentials, or per-user workspace state

This repo ships **packages and discipline**, not a locked-in agent platform.
