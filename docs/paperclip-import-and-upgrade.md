# Paperclip Import and Upgrade

Foreman should be Paperclip-compatible from day one.

People who already built Paperclip companies should not have to start over, rebuild org charts, rewrite agents, or manually rescue stuck tasks. They should be able to bring a Paperclip company into Foreman, preserve the useful structure, and let Foreman add the missing operating discipline.

```text
Bring your Paperclip company.
Foreman keeps the company.
Foreman adds closeout, verification, zombie-run cleanup, and one clear report to the human.
```

## Product Promise

Foreman is not just another dashboard for agents. Foreman is the operator that keeps an agent company moving until the work is verified, routed, or safely paused.

For existing Paperclip users, the promise is:

> Import your Paperclip company. Foreman preserves what you built, then makes it run with less babysitting.

For new users, the promise is simpler:

> Download Foreman, get a Paperclip-compatible company interface, and let Foreman manage the closeout discipline behind it.

## What Foreman Should Import

A Paperclip import should preserve as much company context as possible:

- companies and company metadata;
- org charts and reporting lines;
- agents, roles, instructions, adapter/runtime configuration, and budgets;
- goals, projects, tasks/issues, statuses, labels, priorities, assignments, and dependencies;
- comments, evidence, decisions, run summaries, and audit history where available;
- routines, heartbeats, schedules, and recurring work definitions;
- skills, workspace references, local paths, and template/package metadata;
- active locks, checkouts, run IDs, and execution state for migration diagnostics.

Secrets should be handled conservatively: scrubbed, re-requested, or imported only through an explicit secure migration path.

## Import Must Not Blindly Resume Work

The most dangerous migration mistake is to import active state and immediately keep executing stale loops.

Foreman should first classify imported work:

- **live** — valid active work with a recent heartbeat and clear owner;
- **in review** — work claims completion and needs evidence-based verification;
- **blocked** — work has a real external or product blocker;
- **stale** — no meaningful progress or heartbeat after a threshold;
- **zombie** — a done/cancelled/reviewed issue is still being resurrected by an old run/session;
- **invalid run state** — checkout/run IDs, locks, or assignments disagree;
- **needs human** — policy, money, publication, security, or taste decision.

Only after that classification should Foreman offer to resume, close out, cancel, or create follow-up issues.

## Status Mapping

Foreman should normalize Paperclip lifecycle states into a stricter operating model:

- `todo` → ready to dispatch;
- `in_progress` → active only if a valid current run exists;
- `in_review` → verify evidence before accepting;
- `done` → immutable unless a new defect is opened;
- `cancelled` → do not resurrect without explicit human or policy approval;
- repeated wakeups / stale checkouts → `stale` or `zombie`;
- unclear ownership / policy choices → `needs_human`.

The rule is: completed work should stay completed. Newly discovered problems should become follow-up issues, not muddy the original issue history.

## Migration Report

Every import should produce a human-readable report:

1. What was imported.
2. What was normalized or changed.
3. Which agents/routines are safe to resume.
4. Which tasks need closeout.
5. Which runs look stale or zombie.
6. Which secrets/config values must be reconnected.
7. What Foreman recommends doing next.

The ideal first button after import is:

```bash
foreman closeout --company <company-id>
```

## One Responsible Operator

The human should not feel like they are managing a swarm.

Foreman should present one responsible operator — a CEO, producer, managing editor, or foreman — who reports upward to the user. Many agents can work behind the curtain, but one accountable AI/person should summarize state, ask for decisions, and shield the human from process noise.

For Personal Publishing House:

> Drop in a manuscript. One responsible publishing operator reports to you. Behind the scenes, the company can handle editorial review, proofing, metadata, launch planning, reader follow-up, and relaunch work as far as you want to take it.

## Paperclip Compatibility Strategy

Foreman can start as a Paperclip adapter, become a Paperclip-compatible importer, and eventually ship as a Paperclip-compatible Foreman app/fork if that is the best user experience.

The user should not have to know whether the internals are original Paperclip, a fork, or a compatibility layer. The user-facing promise is:

```text
If you have a Paperclip company, Foreman can read it.
If you install Foreman fresh, you get the company model plus closeout discipline.
```

Paperclip proved the agent-company control-plane pattern. Foreman should preserve the parts people already use while fixing the operational gap: verification, closeout, zombie-run cleanup, and calm human reporting.
