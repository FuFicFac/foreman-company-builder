# What is Foreman?

Foreman is the dispatch, verification, and follow-through runtime for AI agent companies.

**Paperclip is the company. Foreman runs the crew.**

## The Problem

Paperclip calls itself a company. It has org charts, agents, issues, and a process
that spawns agents to work on those issues. But it's missing the most important thing
a real company has: **someone who checks the work.**

In a real company, when a worker finishes a task, someone reviews it. If it's bad,
it goes back. If the worker keeps failing, they escalate to their manager. Nobody
just keeps retrying the same broken deploy 8 times.

Paperclip doesn't do this. It assigns a task, an agent runs it, and the task gets
marked done. Whether the work is good, bad, or broken — same outcome. This is how
Alice ran 8 failed Vercel deployments without anyone noticing.

## The Solution

Foreman adds the feedback loop that Paperclip (and any issue source) is missing:

1. **Builder** — implements the work (medium-cost model)
2. **Inspector** — reviews the work (high-cost model, independent context)
3. **Foreman** — arbitrates, accepts, rejects, or assigns fixes

This is the same pattern as a real construction crew. The builder frames the house.
The inspector checks the framing. The foreman decides what to fix and what to accept.

Foreman also owns the resolution heartbeat: the recurring loop that checks whether review, approval, blocked, failed, stale, or waiting-on-human work has actually been resolved. A dashboard can show that a task is stuck. A foreman keeps pushing until it is unstuck, safely retried, escalated, or deliberately held for office hours.

The product promise is simple:

> People do not want a dashboard. They want the dashboard emptied.

## Office Hours and Human Attention

Foreman companies need humane operating schedules. Some companies are 24/7. Others, like an author or publishing company, should work quietly overnight and only interrupt the human for true emergencies.

During office hours, Foreman can run a frequent heartbeat — for example every 20 minutes — and ask normal questions. Off hours, Foreman should switch protocols: continue safe work if allowed, hold noncritical reports for the morning, and only escalate critical events such as paid customer access failures, broken public launches, refund/payment problems, data exposure, runaway spend, or security incidents.

Foreman must separate work execution from human interruption. Agents can keep working without making the owner live inside the company.

## Provider-Agnostic

Foreman doesn't care what CLIs you have. It auto-discovers your fleet and routes
roles to the best available provider:

- Full fleet? Claude inspects, Cursor builds, Ollama handles cheap tasks.
- Just Claude Code? Opus inspects, Sonnet builds, Haiku does cheap work.
- Just Ollama? Strongest model inspects, mid builds, cheapest handles small tasks.

The feedback loop works regardless.

## Standalone or Composed

Foreman works standalone — you can dispatch tasks directly from the CLI.

It also composes with Paperclip through the API (not a plugin). Read issues,
dispatch work, write status back. If Paperclip updates, you update one thin
adapter layer, not the whole Foreman.

Paperclip is optional visibility, not a requirement. If you want the cockpit, use Paperclip. If you only want the work handled, Foreman should be enough.
