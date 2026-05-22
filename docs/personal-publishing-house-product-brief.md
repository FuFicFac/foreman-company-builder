# Personal Publishing House Product Brief

Personal Publishing House is the flagship **Foreman Company** and the first creator-oriented company suite.

It is **not** a page about every internal component in the stack. It is a focused promise for writers:

> **Start where you are. Get a visible publishing workflow around it.**

## What this is

Personal Publishing House is an author-friendly agent company that helps writers move a manuscript through the publishing workflow without becoming project managers.

It gives a manuscript a visible AI-assisted publishing operation for:

- manuscript intake
- editorial workflow
- developmental editing coordination
- copyedit / proof stages
- metadata preparation
- cover and creative-direction tasks
- launch planning
- newsletter / reader follow-up
- daily status and blocker reporting

The product is best summarized as:

> **A calm AI publishing company for your manuscript.**

## Primary audience

Personal Publishing House is for:

- authors
- introverted writers
- solo creators
- newsletter/book people
- people with a manuscript, draft, outline, serial, or book project
- people who want help with the publishing operation around the writing

It should **not** feel like a developer framework or infrastructure dashboard.

The user is not buying “agent runtime + protocol + dashboard + toolchain.”

The user is trying to solve:

> “I wrote something. Now there are a hundred publishing tasks.”

## Core promise

Use this as the north star:

> **Give your manuscript a publishing house.**

Expanded:

> Personal Publishing House gives your manuscript a small AI-powered publishing team. It helps organize editing, metadata, launch planning, reader follow-up, and daily status so you can stay focused on the writing.

## Product hierarchy

The public website and onboarding should introduce the product in this order:

1. **The writer’s problem** — I wrote something; now there are a hundred publishing tasks.
2. **The product promise** — Give the manuscript a Personal Publishing House.
3. **The visible workflow** — draft, intake, edit, proof, metadata, launch, follow-up.
4. **The daily check-in** — every morning the company says what is ready, blocked, or waiting for the author.
5. **The interface** — Paperclip shows the company working.
6. **The install path** — Hermes is recommended; OpenClaw is advanced/DIY.
7. **The underlying stack** — explain only after the promise is clear.

The stack supports the brand; it is not the brand.

## Workflow model

The public workflow should be easy to understand visually:

```text
Draft → Intake → Edit → Proof → Metadata → Launch → Reader follow-up
```

But this is not a mandatory linear intake path. A writer does **not** have to start by dropping in a draft.

## Drop-in-anywhere rule

Personal Publishing House must meet the author wherever they already are.

The user might arrive with:

- only an idea or premise,
- an outline,
- a partial draft,
- a finished manuscript,
- a manuscript that has already been developmentally edited,
- copyedits or proofing already complete,
- metadata already drafted,
- a cover direction already chosen,
- a launch already in motion,
- a published book that needs reader follow-up, analytics, or relaunch work.

Hermes should be intelligent enough to talk with the user, inspect the available documents, infer the current stage, confirm that stage with the human, and then start the Foreman Company from the appropriate point in the workflow.

Universal Foreman Company rule:

```text
Discover current state → infer stage → confirm with human → start from there → preserve prior work
```

This rule should apply to every Foreman Company, not just Personal Publishing House.

A more detailed publishing template can expand this into:

```text
Manuscript
  ↓
Intake and project dossier
  ↓
Developmental edit
  ↓
Revision plan
  ↓
Copyedit
  ↓
Proofread
  ↓
Metadata and positioning
  ↓
Cover / creative direction
  ↓
Storefront / distribution prep
  ↓
Launch plan
  ↓
Newsletter / reader follow-up
```

## What the user should see in Paperclip

Paperclip is the preferred company-internal interface.

It should show:

- company / book workspace
- agents and roles
- manuscript pipeline stage
- task queues
- approvals
- blockers
- what needs the author today
- daily heartbeat status
- tool readiness
- recent agent activity

Suggested copy:

> Paperclip is the window into your Personal Publishing House. It shows agents, queues, approvals, blockers, and where your manuscript is in the process.

## What Hermes does

Hermes is the recommended runtime. It should not be treated as a minor dependency.

Suggested copy:

> Hermes runs the company behind the scenes: agents, tools, skills, scheduled checks, and follow-up.

Install CTA:

> **Start with Hermes**

or:

> **Install with Hermes**

## OpenClaw positioning

OpenClaw can be supported as an alternate runtime path, but it should not be the recommended first impression for this product.

OpenClaw copy:

> OpenClaw is supported as an alternate path, but it may require more assembly. If OpenClaw does not automatically include a tool, connector, skill, or runtime component you need, you may have to add it yourself.

Tone rule:

- Do not insult OpenClaw.
- Do not frame OpenClaw as bad.
- Frame Hermes as the recommended, batteries-included Paperclip path.
- Frame OpenClaw as compatible but more DIY.

## Storage / context model

Do **not** require a user to have a “Second Brain.”

Second Brain is relevant to ej’s personal environment, but it is too heavy and confusing as a product requirement. **Second Brain is optional, not required.**

For the product, use a simpler model:

> Each book gets a local project workspace with documents, tasks, outputs, and a small living wiki.

Example project structure:

```text
PersonalPublishingHouse/<book-slug>/
  Manuscript/
  Notes/
  Research/
  Outputs/
  Company/
    COMPANY.md
    AGENTS.md
    PROJECT.md
    TASKS.md
  Wiki/
    index.md
    manuscript-summary.md
    character-notes.md
    style-notes.md
    publishing-decisions.md
    open-questions.md
  Heartbeats/
```

Hermes can manage these documents in the background.

SQLite or another database may exist internally for task IDs, statuses, queues, timestamps, approvals, and run history, but the public model should stay simple:

> **Documents + living wiki + visible workflow.**

Avoid making “database,” “SQLite,” or “Second Brain” part of the author-facing pitch.

## Living wiki

A lightweight LLM wiki is the right mental model for book context.

Suggested copy:

> Each book gets a small living wiki so the agents remember what matters: summary, characters, themes, style notes, publishing decisions, and open questions.

The wiki is not a separate product the author has to maintain. It is the memory the company writes down while it works.

## Daily heartbeat

The heartbeat is the trust layer.

It is not merely a system health check. It tells the author whether the company is alive and what needs them.

Suggested headline:

> Every morning, your company checks in.

The heartbeat should answer:

- Is Hermes running?
- Is Paperclip reachable?
- Is the book workspace readable?
- Are required company manifests present?
- Are required skills and tools available?
- Are task queues stuck?
- Is anything waiting on the author?
- What can the company do today?

Status model:

- **Green** — ready
- **Yellow** — usable, but optional/supporting pieces need attention
- **Red** — required piece missing or blocked

## Visual and voice direction

Tone:

- warm
- literary
- calm
- practical
- empowering
- never condescending

Visual style:

- soft pastels plus earth tones
- warm ivory / paper backgrounds
- sage
- dusty rose
- muted terracotta
- soft lavender
- powder blue
- clay brown
- warm charcoal
- subtle paper grain
- manuscript cards
- editorial margin notes
- calm progress ribbons

Avoid:

- black hacker-dashboard energy
- terminal-first visuals
- dense protocol diagrams above the fold
- corporate SaaS blue
- “10x productivity” bro language

## Website must include

- Hero: “Give your manuscript a publishing house.”
- Subhead focused on manuscript → publishing workflow.
- Manuscript workflow visual.
- “What needs you today?” status card.
- Daily check-in / heartbeat section.
- Paperclip interface preview.
- Install section with Hermes primary and OpenClaw advanced/DIY.
- FAQ for nontechnical writers.

## Non-goals

- Do not lead with Foreman, Paperclip, Hermes, Printing Press, Agent Companies, and OpenClaw all as coequal product names.
- Do not make Super Hank Chat part of the product story.
- Do not require Second Brain.
- Do not make SQLite or database architecture part of the pitch.
- Do not frame the system as replacing the author.

## One-line brand correction

The product is not “all the infrastructure.”

The product is:

> **A publishing workflow your manuscript can live inside.**
