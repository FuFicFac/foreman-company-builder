# Foreman

The dispatch and verification runtime for AI agent companies.

**Paperclip is the company. Foreman runs the crew.**

Foreman gives any AI agent company the brain it's missing — the feedback loop that catches bad work before it ships. Builders implement. Inspectors verify. The foreman arbitrates.

## What Foreman Does

- **Dispatches** builders (Cursor Composer, Claude, Codex, Ollama, or whatever you have)
- **Inspects** their work with a dedicated reviewer (strongest available model)
- **Escalates** when agents fail (3-strike rule — no infinite retry spirals)
- **Verifies** the final result before acceptance

## Works With What You Have

Foreman auto-discovers your CLI fleet and adapts:

| Your Setup | Inspector | Builder | Cheap |
|-----------|-----------|---------|-------|
| Full fleet | Claude Opus | Cursor Composer | Ollama |
| Claude Code only | `claude -p --model opus` | `claude -p --model sonnet` | `claude -p --model haiku` |
| Cursor Agent only | `composer-2.5` | `composer-2.5-fast` | `composer-2.5-fast` (shorter prompts) |
| Ollama only | strongest model | mid model | cheapest model |
| Codex only | top model | default model | cheap model |

The feedback loop works regardless of your setup. Different roles, different model tiers — even with a single provider.

## Two Modes

### Standalone

Run Foreman with your own CLIs and any issue source (git issues, local files, or the built-in task list).

### Paperclip Integration

Foreman reads issues from your Paperclip company, dispatches builders, inspects results, and writes status back — all through the Paperclip API. Not a plugin. A separate process that composes.

## The Feedback Loop

### Lean Loop (default)

```
Builder implements → Inspector reports → Foreman arbitrates → Fix if needed → Final verify
```

### Deluxe Loop (high-stakes)

```
Builder implements
       ↓
  ┌────┴────┐
  │         │  (parallel — independent)
Inspector A  Inspector B
  │         │
  └────┬────┘
       ↓
  Foreman adjudicates → verdict
```

Use Deluxe for security code, public releases, production migrations, payments — anything you'd lose sleep over.

## Quick Start

```bash
# Clone
git clone https://github.com/FuFicFac/foreman-company-runner.git
cd foreman-company-runner

# Check your fleet
./scripts/fleet-check.sh

# Run standalone
./foreman dispatch --task "Fix the dropdown z-index issue"

# Run with Paperclip
./foreman dispatch --paperclip --company <company-id> --issue FOL-15
```

## Why Foreman Exists

Paperclip calls itself a company, but it's a Kanban board with a process spawner. It assigns tasks and ticks them off when done. Nothing checks if the work is actually good. Nothing catches regressions. Nothing stops an agent from retrying the same failing deploy 8 times.

Foreman is the missing quality layer. It doesn't replace Paperclip — it gives Paperclip (or any issue source) the verification, escalation, and model-aware routing that real crews need.

## License

MIT

---

*Paperclip is the company. Foreman runs the crew.*