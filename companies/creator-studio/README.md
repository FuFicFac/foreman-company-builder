# Creator Studio

Creator Studio is a **Foreman Company** package for solo creators and small content teams.

It turns a creator's current content situation into a visible, accountable creator company: roles, workspace, workflows, approval gates, daily status, and closeout discipline.

> Start where you are. Build the creator company around the content you already have.

## What It Encompasses

Creator Studio absorbs the creator-specific work that would otherwise sprawl across Foreman docs and generic modules:

- content intake and current-state discovery;
- angle and platform strategy;
- script, post, and caption drafting;
- brand voice and audience-fit checks;
- sponsor pitch and monetization planning;
- cross-platform packaging and publishing;
- audience follow-up and analytics review;
- community and patron relations;
- launch and relaunch operations;
- daily/weekly heartbeat reports;
- closeout verification so "done" means done.

## Two Operating Modes

Creator Studio should work whether a tester wants everything inside Hermes or wants Paperclip as an external board.

### 1. Hermes-only Mode

Best for solo creators who want the simplest path.

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

A creator must not have to start at step one.

```text
Discover current state -> infer stage -> confirm with human -> start from there -> preserve prior work
```

Supported entry states:

- only an idea;
- notes and research;
- partial script or draft;
- finished draft needing edit;
- platform package stage;
- scheduling/publishing stage;
- post-publish analytics and follow-up;
- relaunch or back-catalog cleanup.

## Package Files

- `COMPANY.md` -- company promise, operating rules, and modes.
- `TEAM.md` -- default roles and who reports to the human.
- `WORKFLOWS.md` -- stage-based content workflows.
- `APPROVAL_GATES.md` -- what requires human approval.
- `HEARTBEAT.md` -- daily/weekly reporting contract.
- `workspace-template/` -- starting folder structure for one content project.

## First Tester Promise

For the first testers, this should not be sold as "a finished creator automation platform."

It should be framed as:

> A guided agent-company kit for turning your current content project into a visible creator workflow, with a human-readable board/report and a daily closeout discipline.

The early win is clarity and momentum, not total automation.