# Foreman

The dispatch and verification runtime for AI agent companies.

**Foreman gets shit done. Paperclip makes it pretty.**

Foreman is a standalone feedback loop that dispatches builders, inspects their work, and only accepts what passes verification. It runs on any machine with any CLI setup — Cursor, Claude, Codex, Ollama, or just one of those.

If you want the visual Kanban board, org charts, and company model, you can plug Foreman into Paperclip. That's a supercharger, not a requirement.

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