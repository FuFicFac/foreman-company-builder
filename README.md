# Foreman Company Builder

> **Foreman** is the dispatch, verification, and operating-discipline layer for AI agent companies.

**Foreman keeps agent companies honest. Paperclip shows the work. Hermes runs the crew.**

Foreman began as a standalone feedback loop that dispatches builders, inspects their work, and only accepts what passes verification. It runs on any machine with any CLI setup — Cursor, Claude, Codex, Ollama, Hermes, or just one of those.

Foreman's architecture is aligned with [12-Factor Agents](docs/foreman-12-factor-agents.md): natural language is translated into structured company actions; prompts, context, control flow, and state are owned by Foreman; role agents are small and focused; every run can pause/resume; human decisions are first-class events; and each agent call behaves like a stateless reducer over durable company state.

The current product direction is broader: Foreman is the shared discipline layer for specialized agent companies and Paperclip holding companies. Paperclip tracks companies, Hermes runs agents and scheduled work, each company gets a spawnable CEO/worker/inspector roster, and Foreman enforces builder → inspector → arbitration → escalation loops.

The first front-facing company suite is **Little Publishing House**, a Foreman Company for writers and small publishers:

> **Start where you are. Build the publishing company around the book you already have.**

Little Publishing House absorbs the publishing-specific parts of Foreman: manuscript intake, editorial coordination, proofing, metadata, product pages, direct sales, email/audience operations, launch planning, customer support, reader follow-up, relaunch work, blockers, approvals, and daily status. It is the branded company package that helps a writer build this specific kind of agent company without forcing them to understand Foreman internals first.

The generic pattern is still a **Personal Publishing House**. The product/package name is **Little Publishing House**.

Core Foreman Company rule:

> **Discover current state → infer stage → confirm with human → start from there → preserve prior work.**

For this direction:

- **Paperclip** is the optional external company board: a strong README, visible Kanban/issues, org chart, routines, evidence trail, and manual override surface. Use it when the user wants to *see* the company and manage work outside the chat.
- **Hermes** is the recommended all-in-one runtime path: agents, tools, skills, cron, messaging, memory, and follow-up can all live inside Hermes for users who do not want a separate Paperclip board.
- **Foreman** is the discipline layer in either path: it enforces builder → inspector → arbitration → closeout, drains review queues, verifies evidence, and stops zombie work.
- **Little Publishing House** is the publishing company package: it bundles the roles, workflows, workspace template, approval gates, and reporting style for writers/publishers.
- **Printing Press** gives the company agent-native external tools when a workflow needs them.
- Each book gets a simple local workspace and living wiki. A full Second Brain is optional, not required.

Foreman offers two clear operating modes:

```text
Hermes-only mode:     README/workspace + Hermes skills/cron/tools + Foreman closeout
Paperclip-board mode: Strong README + Paperclip Kanban/org chart + Hermes runtime + Foreman closeout
```

People who already built Paperclip companies should be able to import them, preserve the useful company structure, and let Foreman upgrade the operating discipline instead of starting over. People who do not want Paperclip should still be able to run the whole Foreman loop inside Hermes from a strong README and local workspace.

## Quick Start

```bash
# 1. Clone
git clone https://github.com/FuFicFac/foreman-company-builder.git
cd foreman-company-builder

# 2. Install (adds foreman to your PATH)
./scripts/install.sh
source ~/.zshrc   # or ~/.bashrc — or just restart your terminal

# 3. Initialize — discover your CLIs and API keys, assign roles
foreman init

# 4. Blast a task — Foreman auto-detects the template and fires the pipeline
foreman blast "Fix the dropdown z-index using createPortal"
```

That's it. `foreman blast` is the main entry point. You give it a prompt, it auto-detects the right capability template (software, creative-writing, publishing, marketing, youtube), loads roles from your fleet, and fires the builder → inspector → arbitration loop.

### One-line install (coming soon)

```bash
curl -fsSL https://raw.githubusercontent.com/FuFicFac/foreman-company-builder/main/scripts/install.sh | zsh
```

A vanity URL (`get.foreman.dev`) is planned but not yet wired. Use the raw GitHub URL above for now.

## CLI Commands

The `foreman` wrapper (`scripts/foreman`) routes these subcommands:

| Command | What it does |
|---------|-------------|
| `foreman blast "<prompt>"` | **Main entry point.** Auto-detect template, load roles, fire the builder → inspector → arbitration pipeline. |
| `foreman init` | First-run setup: discover CLIs, scan API keys, assign roles, save profile to `~/.foreman/`. |
| `foreman press propose\|validate\|register\|list\|inspect` | Printing Press: draft and register safe JSON CLI tool manifests. |
| `foreman tools doctor\|list\|search\|install\|manifest` | Tool supply: check, find, install, and manifest agent-native CLIs. |
| `foreman module [args]` | Manage capability module templates. |
| `foreman issues` | Work with the Foreman issues queue. |
| `foreman chat` | Talk to the Foreman brain (orchestration LLM). |
| `foreman run <command> [args]` | Run lifecycle: start, status, advance runs. |
| `foreman update` | Update Foreman and check external dependencies. |
| `foreman fleet` | Re-scan your CLI fleet. |
| `foreman lph <command> [args]` | Little Publishing House company package. |

### Blast Options

```
  --template <name>    Force a specific template (creative-writing, software, marketing, youtube, publishing)
  --provider <name>    Force a specific provider
  --dir <path>         Output directory (default: temp dir)
  --deluxe             Run Deluxe loop instead of Lean
  --skip-launch        Stop after QA; do not generate launch assets
  --dry-run            Show what would fire without executing
```

Keyword matching is automatic when no `--template` is given:

```
write/story/book/chapter/novel → creative-writing
code/build/fix/app/deploy      → software
market/ad/copy/campaign/email  → marketing
video/youtube/script/thumbnail → youtube
publish/launch/metadata/store  → publishing
Default: software
```

## How Foreman Works (Headless / Standalone)

This is the default mode. No dashboard. No org chart. Just the feedback loop.

```bash
# Tell Foreman what to do
foreman blast "Fix the dropdown z-index issue"

# Foreman does this:
# 1. Builder (Composer 2.5) implements the fix
# 2. Inspector (Claude Opus) reviews the work — does NOT fix, just reports
# 3. Foreman arbitrates: accept, reject, or send back for fixes
# 4. If fixes needed: Fix-Planner writes the plan, Builder applies it
# 5. Final Inspector verifies: pass or fail with blockers
```

That's it. The builder can't grade its own homework. The inspector doesn't silently fix things. The foreman decides. If a builder fails the same problem 3 times, it stops and escalates. No infinite retry spirals.

## The Feedback Loop

### Lean Loop (default — routine work)

```
Builder implements → Inspector reports → Foreman arbitrates → Fix if needed → Final verify
```

### Deluxe Loop (high-stakes — security, production, money)

```
Builder implements
       ↓
  ┌────┴────┐
  │         │  (parallel — independent, no shared context)
Inspector A  Inspector B
  │         │
  └────┬────┘
       ↓
  Foreman adjudicates → one verdict
```

## Works With What You Have

Foreman auto-discovers your CLIs and adapts. You don't need a full fleet.

| Your Setup | Inspector | Builder | Cheap |
|-----------|-----------|---------|-------|
| Full fleet | Claude Opus | Cursor Composer | Ollama |
| Claude Code only | `claude -p --model opus` | `claude -p --model sonnet` | `claude -p --model haiku` |
| Cursor Agent only | `composer-2.5` | `composer-2.5-fast` | `composer-2.5-fast` (shorter prompts) |
| Ollama only | strongest model | mid model | cheapest model |
| Codex only | top model | default model | cheap model |

One provider is enough. The feedback loop uses different model tiers for different roles — Opus inspects, Sonnet builds, Haiku plans fixes. Same loop, whatever you've got.

## Company Packages

### Little Publishing House

Little Publishing House is the first physical Foreman Company package.

```bash
foreman lph new /tmp/my-book \
  --title "My Book" \
  --stage "partial draft" \
  --mode hermes \
  --goal "book project map"

foreman lph doctor /tmp/my-book
foreman lph heartbeat /tmp/my-book
```

Use `--mode hermes` when the README/workspace is enough and Hermes will run the work. Use `--mode paperclip` when Paperclip should act as the visible external Kanban/company board.

## Capability Templates + Tool Supply

Foreman templates are capability bundles, not stereotypes. A publishing company is not only a writing room — if it sells ePubs directly, it may need Shopify, Stripe, Gumroad, email marketing, launch operations, support, and analytics.

Built-in templates:

- `software`
- `creative-writing`
- `publishing`
- `youtube`
- `marketing`

Printing Press can supply agent-native CLIs for those capabilities:

```bash
foreman tools doctor
foreman tools search wikipedia
foreman tools install wikipedia
foreman tools manifest publishing
```

### Foreman Press V0 demo

Foreman Press V0 can draft and locally register safe JSON CLI manifests:

```bash
foreman press propose \
  --id com.printingpress.demo-json-tool \
  --name "Demo JSON Tool" \
  --description "Safe read-only demo CLI that emits JSON." \
  --binary "$PWD/examples/press/demo-json-tool" \
  --command-name lookup \
  --smoke-args "lookup --city Austin" \
  --expected-output-path '$.city' \
  --tag demo \
  --tag read-only \
  > /tmp/demo.manifest.json

foreman press validate /tmp/demo.manifest.json
foreman press register /tmp/demo.manifest.json
foreman press list
foreman press inspect com.printingpress.demo-json-tool
```

See [`docs/foreman-press-demo.md`](docs/foreman-press-demo.md) for copy/paste-safe demo commands using a temporary `FOREMAN_CONFIG_DIR`.

## Resolution Heartbeat

Foreman should not just show that work is stuck. Foreman should drain the review queue.

Paperclip is optional visibility: the cockpit, dashboard, and manual override surface. Foreman is the accountability layer that keeps checking review, approval, blocked, failed, stale, and waiting-on-human queues until each item is resolved, retried, escalated, or deliberately deferred.

```text
Paperclip shows the queue.
Foreman drains the queue.
Office hours protect the person.
```

With Hermes cron, Foreman can run a resolution heartbeat without requiring Paperclip at all:

- during office hours, inspect queues frequently and resolve safe blockers;
- after hours, suppress noncritical interruptions and batch reports;
- wake the human only for critical events such as paid customer access failures, public launch breakage, data exposure, runaway spend, or security incidents;
- support optional escalation channels such as Telegram, SMS, webhooks, or smart-home signals.

See [`docs/resolution-heartbeat-office-hours.md`](docs/resolution-heartbeat-office-hours.md) for the full policy model.

## Paperclip Import and Upgrade

Paperclip proved the agent-company model: org charts, agents, goals, tasks, routines, and a dashboard people can understand. Foreman should not strand that work.

Existing Paperclip users should be able to import a company into Foreman, preserve agents, roles, goals, issues, comments, evidence, budgets, routines, skills, and workspace references, then let Foreman classify the current state before it resumes anything.

The migration rule is:

```text
Import first.
Classify before executing.
Close out before declaring quiet.
```

Foreman should map imported work into stricter lifecycle states: ready, active, in review, done, blocked, stale, zombie, invalid run state, or needs human. A done or cancelled issue should not be resurrected by an old heartbeat. Newly discovered defects should become follow-up issues instead of muddying completed work.

See [`docs/paperclip-import-and-upgrade.md`](docs/paperclip-import-and-upgrade.md) for the import model.

## Paperclip Supercharger / Compatibility Layer (Optional)

Running headless is fine. But if you want the full visual stack — Kanban boards, org charts, agent management, worktree coordination — plug Foreman into Paperclip.

**Without Paperclip:** Foreman is headless. You give it tasks, it gets them done, verified.

**With Paperclip:** Same Foreman, plus the visual dashboard and company model. Foreman reads issues from Paperclip, dispatches and verifies the work, then writes status back. Through the API. Not a plugin. Paperclip updates won't break Foreman — if the API changes, you update one adapter.

**With an existing Paperclip company:** Foreman imports it, classifies stale/zombie/live work, produces a migration report, and offers a closeout pass before resuming operations.

Paperclip should never be mandatory just to keep work moving. If a user wants to watch execution, they open Paperclip. If they do not, Foreman still runs the company discipline loop and delivers only the decisions or emergencies that matter.

## One Responsible Operator

The customer should not feel like they are managing a swarm. Foreman companies should present one responsible operator — a CEO, managing editor, producer, or foreman — who reports to the human, asks for decisions, and shields them from process noise while many agents work behind the curtain.

For Little Publishing House, that means: drop in whatever exists — idea, notes, partial draft, finished manuscript, already-edited book, or launch mess — choose how far you want the company to take it, and let one accountable publishing operator report back while the system handles editorial review, proofing, metadata, product pages, direct-sales setup, launch planning, reader follow-up, and relaunch work.

## Why Foreman Exists

AI agent companies assign tasks and mark them done. But nothing checks if the work is actually good. Nothing catches regressions. Nothing stops an agent from retrying the same failing deploy 8 times in a row.

Foreman is the missing quality layer. It doesn't trust builders to grade their own work. It doesn't let agents spiral. It inspects, escalates, and only accepts verified results.

## The Model Currency Rule

Foreman never hardcodes model names. They go stale in months. Before dispatching, it checks what's latest:

- Cursor: `agent models` → pick latest Composer
- Claude: use tier names (`opus`, `sonnet`, `haiku`) that auto-resolve
- Ollama: `ollama list` → pick by capability
- Codex: `codex --help` → current flags

Self-correcting by design.

## Troubleshooting

See [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md) for common issues: PATH not sourced, no CLIs found, API key/auth problems.

## Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md).

## Changelog

See [`CHANGELOG.md`](CHANGELOG.md).

## License

MIT — FF Factory Media LLC

---

*Foreman gets shit done. Paperclip makes it pretty.*
