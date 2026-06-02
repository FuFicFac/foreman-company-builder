# Little Publishing House

Little Publishing House is the first branded **Foreman Company** package.

It turns a writer's current book situation into a visible, accountable publishing company: roles, workspace, workflows, approval gates, daily status, and closeout discipline.

> Start where you are. Build the publishing company around the book you already have.

## What It Encompasses

Little Publishing House absorbs the publishing-specific work that would otherwise sprawl across Foreman docs and generic modules:

- manuscript intake and current-state discovery;
- developmental/editorial review coordination;
- revision planning and proofing;
- style, continuity, and voice checks;
- metadata, blurb, category, keyword, and positioning work;
- cover/art direction handoff;
- EPUB/PDF/print package preparation;
- direct-sales setup where relevant;
- product pages, checkout, delivery, and customer support planning;
- newsletter/audience/follow-up workflows;
- launch and relaunch operations;
- daily/weekly heartbeat reports;
- closeout verification so “done” means done.

## Two Operating Modes

Little Publishing House should work whether a tester wants everything inside Hermes or wants Paperclip as an external board.

### 1. Hermes-only Mode

Best for solo writers and Patreon testers who want the simplest path.

```text
Strong README + local project workspace + Hermes skills/tools/cron + Foreman closeout
```

In this mode, the README and workspace are the source of truth. Hermes runs the operator, skills, scheduled checks, and reports. Foreman verifies, drains queues, and prevents zombie work.

### 2. Paperclip-board Mode

Best for users who want visible Kanban and company structure.

```text
Strong README + Paperclip Kanban/org chart + Hermes runtime + Foreman closeout
```

In this mode, Paperclip is the external company board: issues, roles, routines, evidence, approvals, and manual override. Hermes still runs the agent work. Foreman still enforces verification and closeout.

## Drop-In Anywhere Rule

A writer must not have to start at step one.

```text
Discover current state → infer stage → confirm with human → start from there → preserve prior work
```

Supported entry states:

- only an idea;
- notes/research/dossier;
- outline;
- partial draft;
- complete rough draft;
- already-edited manuscript;
- proofing stage;
- metadata/package stage;
- launch preparation;
- post-launch follow-up;
- relaunch or backlist cleanup.

## Package Files

- `COMPANY.md` — company promise, operating rules, and modes.
- `TEAM.md` — default roles and who reports to the human.
- `WORKFLOWS.md` — stage-based publishing workflows.
- `APPROVAL_GATES.md` — what requires human approval.
- `HEARTBEAT.md` — daily/weekly reporting contract.
- `PATREON_TEST_PLAN.md` — early tester shape for Patreon access.
- `workspace-template/` — starting folder structure for one book.

## First Tester Promise

For the first Patreon testers, this should not be sold as “a finished publishing automation platform.”

It should be framed as:

> A guided agent-company kit for turning your current book project into a visible publishing workflow, with a human-readable board/report and a daily closeout discipline.

The early win is clarity and momentum, not total automation.
