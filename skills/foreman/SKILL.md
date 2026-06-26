---
name: foreman
description: >
  Mixed-agent orchestration for research, implementation, verification, and review.
  The foreman (whoever runs this skill) orchestrates. Builders implement.
  Inspectors verify. Foreman arbitrates.
  Works standalone or with Paperclip via API (not plugin).
version: 3.1.0
---

# Foreman — The Dispatch and Verification Runtime

The foreman runs the crew. Builders implement. Inspectors verify. Foreman arbitrates.

Works on **any setup** — from a single-model laptop to a full multi-provider fleet.
Auto-discovers what's available and routes each role to the best tool for the job.

## Provider Auto-Discovery

**Never assume what's installed. Always discover first.**

```bash
echo "=== Provider Discovery ==="
for c in agent cursor-agent cursor claude codex hermes ollama; do
  if command -v "$c" >/dev/null 2>&1; then
    echo "  ✓ $c"
  else
    echo "  ✗ $c (not found)"
  fi
done

agent models 2>/dev/null | head -5     # Cursor Composer versions
ollama list 2>/dev/null | head -10     # Ollama models
claude --version 2>/dev/null          # Claude Code
codex --version 2>/dev/null           # Codex CLI
```

### Role Assignment Rules

| Tier | Purpose | Cost | Selection priority (pick first available) |
|------|---------|------|------------------------------------------|
| **Inspector** | Judgment-heavy review | High | Claude Opus → Claude Sonnet → latest Composer → best Ollama → same provider, next tier up |
| **Builder** | Code implementation | Medium | Latest Cursor Composer → Claude Sonnet → Codex CLI → best Ollama |
| **Cheap** | Classification, summarization, brainstorm | Low | Ollama → Composer-fast → Claude Haiku → cheapest available |

### Same-Provider Fallback

If someone only has one provider, they still get the full feedback loop:

| Single Provider | Inspector | Builder | Cheap |
|----------------|-----------|---------|-------|
| **Claude Code only** | `claude -p --model opus` | `claude -p --model sonnet` | `claude -p --model haiku` |
| **Cursor Agent only** | `agent --model composer-2.5` | `agent --model composer-2.5-fast` | `agent --model composer-2.5-fast` (shorter prompts) |
| **Ollama only** | `ollama run <strongest>` | `ollama run <mid>` | `ollama run <cheapest>` |
| **Codex only** | `codex --model <top>` | `codex --model <default>` | `codex --model <cheap>` |

### Model Currency Rule

**Never hardcode model names. They go stale within months.**

- For Cursor: check `agent models` and use the latest Composer version
- For Claude: use `opus`, `sonnet`, `haiku` tier names (auto-resolve to current)
- For Ollama: check `ollama list` and pick strongest/mid/cheapest
- For Codex: check `codex --help` for current model flags

## Dispatch Loop (7 Steps)

1. **Frame the outcome.** Write the finish line in one sentence.
2. **Split lanes.** Create 2–6 non-overlapping parallel lanes.
3. **Assign ownership.** Each agent: lane, expected output, boundaries, stop condition, disjoint write set.
4. **Keep the main thread useful.** Do blocking work locally while agents run side lanes.
5. **Harvest and reassign.** Integrate, follow up sharper, assign next lane, or close.
6. **Repeat until done.** Spawn → harvest → reassign → integrate until finish line or blocker.
7. **Synthesize.** Decision, changes, verification, risks, agents' material findings.

### Automated Execution Engine

`foreman dispatch` and `foreman blast` run the loop automatically — no manual `--verdict` needed:

1. **Start** a run via `foreman-run.sh start` (creates the state machine entry).
2. **Invoke the builder CLI** (from `profile.json` roles.builder.command) with the task prompt.
3. **Invoke the inspector CLI** (from `profile.json` roles.inspector.command) to review builder output.
4. **Parse the inspector's verdict** (`VERDICT: pass|fail|blocked` on the last line).
5. **Feed the verdict** into `foreman-run.sh inspect --verdict <verdict>` — the existing 3-strike state machine drives termination.
6. **Loop** on fail (up to `--max-attempts`, default 3). At 3 strikes, `foreman-run.sh` escalates to `blocked`.
7. **QA gate** (if module manifest defines `qa_roles`): each QA role reviews against its checklist.
8. **Launch phase** (if manifest `launch_phase.enabled`): generates shipping assets via `foreman-brain.py`.

Use `--dry-run` to see the execution plan without invoking any agents.

## Builder / Inspector Hierarchy

```
Foreman (you)
  ├── Builders — implement bounded slices (medium-cost model)
  ├── Inspector — reviews, does NOT fix silently (high-cost model)
  └── Fix-Planner — plans fixes from inspector report (cheap model)
```

### Lean Loop (default)

```
Builder implements → Inspector reports → Foreman arbitrates → Fix if needed → Final verify
```

1. **Builder** implements assigned slice. Returns changed files + verification commands.
2. **Inspector** reviews for correctness, regressions, integration risks. **Reports first, does not fix.**
3. **Foreman** arbitrates: accept, reject, or assign fix-planner.
4. **Fix-Planner** plans the fix from inspector's report. Plan only, no implementation.
5. **Builder** applies the fix plan.
6. **Final Inspector** verifies acceptance: pass/fail with explicit blockers.

### Deluxe Loop (high-stakes)

```
Builder implements
       ↓
  ┌────┴────┐
  │         │  (parallel — neither sees the other's report)
Inspector A  Inspector B
(highest)    (different provider OR different tier if single-provider)
  │         │
  └────┬────┘
       ↓
  Foreman adjudicates → one verdict
```

**Trigger Deluxe when:** security code, public releases, production migrations, payments, anything you'd lose sleep over.

## Paperclip Integration

Foreman composes with Paperclip through the API. Not a plugin.

**Paperclip's role:** issues, agents, org chart, worktrees, run logging
**Foreman's role:** dispatch, inspect, verify, escalate, model routing

```bash
# Standalone dispatch — runs the real builder→inspector→verdict loop
foreman dispatch --task "Fix dropdown z-index using createPortal"

# Zero-friction entry — auto-detects template, then dispatches
foreman blast "Fix dropdown z-index using createPortal"

# Dry run — show the execution plan without invoking agents
foreman dispatch --task "Fix the bug" --dry-run
```

## Escalation Rule

3 strikes and you're out. When a builder fails the same problem 3 times:
1. **Stop retrying**
2. **Escalate to foreman**
3. Foreman escalates to user only if foreman can't resolve
4. Include what was tried

## Prompt Templates

### Builder Addendum
```text
You are a builder in a Foreman crew. You are not the final reviewer.
Implement only your assigned slice. Keep the write set bounded.
List changed files and exact verification commands.
Do not broaden scope. Do not revert work by others.
If you hit the same problem 3 times, STOP and report back.
```

### Inspector Prompt
```text
You are the inspector. Your job is judgment, not implementation.
Inspect for correctness, regressions, missing tests, integration risks.
Run minimum checks to confirm likely problems.
Do NOT fix. Report first.
Return: severity-ranked issues, evidence, proposed fix plan.
```

### Fix-Planner Prompt
```text
The inspector found issues. Plan the smallest safe fix.
Do NOT implement. Output: files to change, exact changes, verification commands, risk assessment.
```

## Git Worktrees

Multiple agents editing simultaneously → use worktrees.

```bash
# Native
git worktree add ../repo-agent1 feature/agent1-task

# Or via Paperclip
npx paperclipai worktree:make agent1 --start-point main
```

One branch per agent per task. Short-lived. Inspector reviews before merge.

## Good Swarm Shapes

- **Research decision:** docs agent + alternatives agent + fit agent → foreman synthesizes
- **Code feature (Lean):** UI builder + data builder + verifier → inspector reviews
- **Code feature (Deluxe):** as above + parallel inspection before merge
- **Bug hunt:** log reader + diff inspector + reproducer → foreman patches
- **Single-provider:** Opus/Sonnet/Haiku or Ollama tiers. Same loop, different models.

## Stop Conditions

Stop when: task verified, remaining work is preference, or continuing needs credentials/destructive action/money/publication.

Close with concise synthesis, not transcript.