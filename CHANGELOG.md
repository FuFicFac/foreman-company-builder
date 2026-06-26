# Changelog

All notable changes to Foreman Company Builder will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-06-25

### Added
- `foreman blast` — zero-friction entry point with automatic template detection via keyword matching (software, creative-writing, marketing, youtube, publishing)
- `foreman init` — first-run setup: discovers CLIs (Cursor Agent, Claude Code, Codex, Ollama, Hermes), scans API keys (OpenAI, xAI, Google, Anthropic), assigns inspector/builder/cheap roles, selects orchestration brain, saves profile to `~/.foreman/`
- `foreman press` — Printing Press V0: draft, validate, register, list, and inspect safe JSON CLI tool manifests
- `foreman tools` — tool supply: doctor, list, search, install, manifest
- `foreman run` — run lifecycle management: start, status, advance
- `foreman issues` — issues queue management
- `foreman chat` — conversational interface to the Foreman brain
- `foreman module` — capability module template management
- `foreman update` — self-update with external dependency checking
- `foreman fleet` / `foreman fleet-check` — CLI fleet discovery and reporting
- `foreman lph` — Little Publishing House company package (new, doctor, heartbeat)
- Lean and Deluxe feedback loops: builder implements → inspector reports → foreman arbitrates → fix if needed → final verify
- Capability templates: software, creative-writing, publishing, youtube, marketing
- QA swarm roles and launch phase support in module manifests
- Resolution heartbeat model with office-hours policy
- Paperclip import and upgrade path
- `scripts/install.sh` — installer that clones to `~/.foreman/` and adds to PATH
- 12-Factor Agents alignment documented in `docs/foreman-12-factor-agents.md`
- Smoke tests for wrapper dispatch, press lifecycle, issues lifecycle, run lifecycle, LPH CLI
- JSON validators for module manifests, department primitives, department catalog, run ledger, company composition