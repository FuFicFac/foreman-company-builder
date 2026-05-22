# Product Architecture — Personal Publishing House

This document separates the public product from the underlying stack.

The public product should feel simple:

> **Give your manuscript a publishing house.**

The implementation may involve Paperclip, Hermes, Foreman, Printing Press, Agent Companies, and a local workspace. Those pieces matter, but they should not be presented as a hodgepodge of coequal brands.

## Layer model

```text
Foreman = parent product / operating discipline layer
A Foreman Company = branded specialized company package/category
Personal Publishing House = flagship Foreman Company for writers
  ↓
Paperclip = company-internal interface / visibility layer
  ↓
Hermes = recommended runtime for agents, tools, skills, cron, follow-up
  ↓
Foreman = domain operating discipline and verification layer
  ↓
Printing Press = agent tool supply chain
  ↓
Book workspace + living wiki = simple project memory/context
```

Optional:

```text
OpenClaw = alternate advanced runtime path
```

Out of scope:

```text
Super Hank Chat = not part of this product architecture
Second Brain = not required for users
```

## User-facing product

The product is **Personal Publishing House**: a calm AI publishing company for a manuscript.

It helps the author move from:

```text
I have a draft and a pile of intimidating publishing tasks.
```

to:

```text
My manuscript has a visible publishing workflow with agents, stages, blockers, and daily check-ins.
```

## Paperclip's role

Paperclip is the preferred interface for seeing inside each company.

Paperclip should track company-internal state:

- book workspace
- manuscript stage
- agents
- queues
- tasks
- approvals
- blockers
- daily heartbeat
- tool readiness
- “what needs the author”

Paperclip is not the brand headline for authors; it is the window into the Personal Publishing House.

## Hermes' role

Hermes is the recommended runtime.

Hermes should run:

- agents
- skills
- tool calls
- scheduled heartbeat checks
- follow-up tasks
- document/wiki management
- messaging/report delivery

Hermes may have its own native dashboard/Kanban for higher-level runtime or board work, but Paperclip should remain the preferred place for detailed company-internal state.

## Foreman's role

Foreman provides the domain operating discipline.

A Foreman Company should not assume the user starts at step one. Foreman should discover current state, infer the stage, confirm with the human, start from there, and preserve prior work.

For Personal Publishing House, Foreman defines what a publishing workflow means:

- manuscript intake
- editing stages
- metadata tasks
- launch tasks
- reader follow-up
- verification and escalation rules
- domain-specific heartbeat checks

Foreman is the reason Paperclip can support specialized companies beyond generic software/project teams.

## Printing Press' role

Printing Press gives agents hands.

It should check, install, and smoke-test external tools needed by a company workflow.

For Personal Publishing House, that may eventually include tools for:

- document conversion
- metadata generation
- publishing APIs
- storefront/distribution workflows
- newsletter tools
- analytics
- research

## Book workspace and living wiki

Do not require a full Second Brain.

The product should create or use a simple book workspace:

```text
Book Workspace
  Manuscript/
  Notes/
  Research/
  Outputs/
  Company/
  Wiki/
  Heartbeats/
```

The living wiki gives agents durable context without making the user operate a knowledge-management system.

Suggested explanation:

> Each book gets a small living wiki so the agents remember what matters: summary, characters, themes, style notes, publishing decisions, and open questions.

Hermes can manage this in the background.

SQLite or another database may exist behind the scenes for structured task state, but the author-facing model is documents plus a living wiki plus a visible workflow.

## Daily heartbeat

The heartbeat is the trust layer.

It should produce a plain-language report:

- what is ready
- what is blocked
- what needs the author
- whether tools/runtime/workspace are healthy
- whether the company can operate today

The heartbeat can start as a Hermes cron job and later surface inside Paperclip.

## Website / onboarding rule

Do not start with the layer model.

Start with the manuscript.

Correct order:

1. manuscript problem
2. Personal Publishing House promise
3. publishing workflow
4. Paperclip visibility
5. daily check-in
6. Hermes install
7. advanced stack

## Brand guardrail

If a sentence has more than two product names in it, it probably belongs in technical docs, not the landing page.
