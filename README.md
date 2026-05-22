# Foreman

> Repository rename note: the current repo is `foreman-company-runner`, but the product direction now points toward `foreman-company-builder` as the clearer name.

The dispatch, verification, and operating-discipline layer for AI agent companies.

**Foreman keeps agent companies honest. Paperclip shows the work. Hermes runs the crew.**

Foreman began as a standalone feedback loop that dispatches builders, inspects their work, and only accepts what passes verification. It runs on any machine with any CLI setup — Cursor, Claude, Codex, Ollama, Hermes, or just one of those.

That loop still matters. But the current product direction is broader: Foreman is growing into the shared discipline layer for specialized agent companies and Paperclip holding companies. Paperclip tracks companies, Hermes runs agents and scheduled work, each company gets a spawnable CEO/worker/inspector roster, and Foreman enforces builder → inspector → arbitration → escalation loops.

The first front-facing company suite is **Personal Publishing House**, a **Foreman Company** for writers:

> **Start where you are. Get a visible publishing workflow around it.**

Personal Publishing House is for writers who want help with the publishing operation around a book — editing coordination, metadata, launch planning, reader follow-up, blockers, approvals, and daily status — without turning themselves into project managers. It should support authors who have only an idea, a partial draft, a finished manuscript, an already-edited book, or a launch already in motion.

Core Foreman Company rule:

> **Discover current state → infer stage → confirm with human → start from there → preserve prior work.**

For this direction:

- **Paperclip** is the preferred interface for seeing inside each company.
- **Hermes** is the recommended runtime that runs agents, tools, skills, scheduled checks, and follow-up.
- **Foreman** provides the publishing discipline, verification loop, and daily trust checks.
- **Printing Press** gives agents the external tools they need.
- Each book gets a simple local workspace and living wiki. A full Second Brain is optional, not required.
- **OpenClaw** can be an advanced alternate runtime path, but Hermes is the recommended default.

## How Foreman Works (Headless / Standalone)

This is the default mode. No dashboard. No org chart. Just the feedback loop.

```bash
# Tell Foreman what to do
foreman dispatch --task "Fix the dropdown z-index issue"

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

## Capability Templates + Tool Supply

Foreman templates are capability bundles, not stereotypes. A publishing company is not only a writing room — if it sells ePubs directly, it may need Shopify, Stripe, Gumroad, email marketing, launch operations, support, and analytics.

Built-in templates now include:

- `software`
- `creative-writing`
- `publishing`
- `youtube`
- `marketing`

Printing Press can supply agent-native CLIs for those capabilities:

```bash
./scripts/foreman-tools.sh doctor
./scripts/foreman-tools.sh search wikipedia
./scripts/foreman-tools.sh install wikipedia
./scripts/foreman-tools.sh manifest publishing
```

## Paperclip Supercharger (Optional)

Running headless is fine. But if you want the full visual stack — Kanban boards, org charts, agent management, worktree coordination — plug Foreman into Paperclip.

```bash
# Connect to your Paperclip company
foreman dispatch --paperclip --company <id> --issue FOL-15
```

Foreman reads issues from Paperclip, dispatches and verifies the work, then writes status back. Through the API. Not a plugin. Paperclip updates won't break Foreman — if the API changes, you update one adapter.

**Without Paperclip:** Foreman is headless. You give it tasks, it gets them done, verified.

**With Paperclip:** Same Foreman, plus the visual dashboard and company model.

## Why Foreman Exists

AI agent companies assign tasks and mark them done. But nothing checks if the work is actually good. Nothing catches regressions. Nothing stops an agent from retrying the same failing deploy 8 times in a row.

Foreman is the missing quality layer. It doesn't trust builders to grade their own work. It doesn't let agents spiral. It inspects, escalates, and only accepts verified results.

## Quick Start

```bash
# Clone
git clone https://github.com/FuFicFac/foreman-company-runner.git
cd foreman-company-runner

# Check your fleet
./scripts/fleet-check.sh

# Run headless (standalone)
foreman dispatch --task "Fix the dropdown z-index using createPortal"

# Run with Paperclip (supercharged)
foreman dispatch --paperclip --company <company-id> --issue FOL-15
```

## The Model Currency Rule

Foreman never hardcodes model names. They go stale in months. Before dispatching, it checks what's latest:

- Cursor: `agent models` → pick latest Composer
- Claude: use tier names (`opus`, `sonnet`, `haiku`) that auto-resolve
- Ollama: `ollama list` → pick by capability
- Codex: `codex --help` → current flags

Self-correcting by design.

## License

MIT — FF Factory Media LLC

---

*Foreman gets shit done. Paperclip makes it pretty.*