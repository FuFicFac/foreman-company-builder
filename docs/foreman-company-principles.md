# Foreman Company Principles

A **Foreman Company** is a specialized AI company package with operating discipline.

It is not just a set of agents. It is a company-shaped workflow with roles, tools, state, inspections, escalations, daily check-ins, and a visible interface.

## Brand hierarchy

```text
Foreman = parent product / operating discipline layer
A Foreman Company = branded company package/category
Personal Publishing House = flagship Foreman Company for writers
```

A Foreman Company should be able to launch around a domain-specific process without making the user become an operator first.

## Operating spine

Foreman incorporates the [12-Factor Agents](foreman-12-factor-agents.md) reliability doctrine as product architecture, not as decorative theory.

A Foreman Company should behave like:

```text
Company state + incoming event + focused role context
→ controlled agent step
→ deterministic execution
→ inspection
→ updated company state + evidence
```

Core implications:

1. **Company-shaped, not chatbot-shaped** — the company owns roles, stages, tools, state, approvals, and inspections.
2. **Structured actions under natural language** — users speak normally; Foreman records explicit company operations.
3. **Owned prompts and context** — role prompts and context packets are versioned product assets.
4. **State is the source of truth** — chat transcripts are not project state.
5. **Runs can pause and resume** — long-running company work needs stable run IDs and durable ledgers.
6. **Humans are first-class participants** — approval, ambiguity, credentials, and judgment become explicit human-decision events.
7. **Small role agents do clear jobs** — no giant generalist blob pretending to be a company.
8. **Every action leaves evidence** — artifacts, verdicts, blockers, decisions, and tool status must be inspectable.

## The Drop-In Anywhere Principle

A Foreman Company must not assume every user starts at step one.

Users can enter the workflow wherever they actually are.

For Personal Publishing House, the user might have:

- only an idea
- an outline
- a partial draft
- a finished draft
- a revised draft
- a manuscript already edited
- metadata already prepared
- cover direction already done
- a launch plan in motion
- a published book that now needs reader follow-up, analytics, or relaunch work

The company should be intelligent enough to ask or infer:

> Where are you in the process, what already exists, and what needs to happen next?

Then it should place the project into the right stage instead of forcing a linear intake flow.

## Universal rule

Every Foreman Company should support:

```text
Discover current state → infer stage → confirm with human → start from there → preserve prior work
```

This applies beyond publishing.

Examples:

- A Software Company should accept a project that is already designed, already coded, already failing tests, or already deployed.
- A Newsletter Company should accept an idea, a draft issue, a finished issue, or an archive needing analysis.
- A Course Company should accept a raw topic, a curriculum outline, recorded lessons, or an existing course needing launch/support.
- A Research Company should accept a question, a pile of sources, a partially written memo, or a finished report needing review.

## Operating requirement

Each Foreman Company template should define:

1. its canonical workflow stages,
2. the evidence that indicates each stage,
3. the questions to ask when state is ambiguous,
4. the tasks to generate for each possible entry point,
5. the prior work that must be preserved,
6. the next best action after the entry point is confirmed.

## Personal Publishing House stages

Personal Publishing House should support entry at any of these stages:

```text
Idea / premise
Outline
Partial draft
Finished draft
Developmental edit
Revision
Copyedit
Proofread
Metadata / positioning
Cover / creative direction
Storefront / distribution
Launch
Reader follow-up
Analytics / relaunch
```

A simple public workflow may still show:

```text
Draft → Intake → Edit → Proof → Metadata → Launch → Reader follow-up
```

But the internal system must understand that users can begin at any point along that path.

## Product copy

Use:

> Start where you are.

Use:

> Whether you have an idea, a rough draft, a finished manuscript, or a book already moving toward launch, Personal Publishing House meets you at the right stage and builds the next workflow around it.

Avoid:

> Drop in a draft and start at intake.

That is too narrow.
