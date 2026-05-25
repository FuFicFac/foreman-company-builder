# Holding Company Architecture

> **For Hermes:** Use subagent-driven-development skill to implement this plan task-by-task.

**Goal:** Turn Foreman into the shared discipline layer for Paperclip-managed companies: each company is a context with capabilities, tool manifests, CEO/worker/inspector agents, and Foreman verification loops.

**Architecture:** Paperclip acts as the multi-company registry/control plane. Hermes provides the runtime and spawnable agents. Foreman provides company onboarding, role assignment, inspection loops, 3-strike escalation, and tool-manifest verification. Printing Press supplies agent-native CLI tools matched to company capabilities.

**Tech Stack:** zsh CLI scripts today, JSON module manifests, Hermes profiles/skills, Paperclip API adapter, Printing Press via `npx -y @mvanhorn/printing-press`.

---

## Product Model

Do not duplicate a full Paperclip + Hermes + Foreman stack for every company at first. Use one command center and many company contexts.

```text
Hank / Butch / Chairman Hermes
        ↓
Paperclip Holding Company Control Plane
        ↓
Company contexts and tasks
        ↓
Shared Foreman plugin / discipline loop
        ↓
Spawned CEO, worker, and inspector agents
        ↓
Printing Press CLI tools + local/API tools
```

## New Product Concepts

### Company

A company is a durable context with its own:

- name / slug
- mission
- company type
- selected capabilities
- tool manifest
- CEO agent
- worker agents
- inspector agents
- tasks / issues
- recurring jobs
- escalation policy
- heartbeat policy / office hours
- audit/event log

### Capability

A capability is a business function, not a rigid domain. Examples:

- editorial
- digital-commerce
- email-marketing
- audience-growth
- analytics
- customer-support
- launch-operations
- software-development
- security-review
- deployment

### Tool Manifest

A company’s tool manifest maps capabilities to tools:

```json
{
  "company": "publishing",
  "capabilities": {
    "editorial": ["storycraft", "epub-export", "pdf-tools"],
    "digital-commerce": ["shopify", "stripe", "gumroad"],
    "email-marketing": ["klaviyo", "mailchimp", "beehiiv"],
    "research": ["wikipedia", "company-goat"]
  }
}
```

Foreman should compare this manifest to installed tools and use Printing Press where possible.

### CEO Agent

A CEO agent is a spawnable role tied to a company context:

- reads company mission and current priorities
- can create/triage tasks
- can invoke Foreman loops
- can request tool installs
- reports exceptions/escalations to Hank/chairman

### Foreman Run

A Foreman run records:

- company
- task
- domain/capabilities
- loop mode: lean or deluxe
- builder
- inspector(s)
- attempts
- verdict
- blockers
- artifacts
- escalation state

### Resolution Heartbeat

A resolution heartbeat is Foreman's recurring company-health and queue-drain loop. It is not only a status check. It inspects review, approval, blocked, failed, stale, waiting-on-human, waiting-on-agent, waiting-on-tool, and support queues, then acts according to company policy.

Foreman should classify each queue item as one of:

- auto-resolve
- safe retry
- needs context
- needs tool repair
- needs agent review
- needs human judgment
- critical escalation
- hold until office hours

Paperclip can display the queues, but Foreman must be able to run the heartbeat headlessly through Hermes cron or another scheduler. If Paperclip is not installed, Foreman should still inspect local company state and deliver digests/escalations.

### Office Hours Policy

Every company should define office hours and off-hours behavior. This is a quality-of-life feature, not merely scheduling.

```json
{
  "heartbeat_policy": {
    "office_hours": {
      "timezone": "America/Los_Angeles",
      "days": ["Mon", "Tue", "Wed", "Thu", "Fri"],
      "start": "09:30",
      "end": "16:30"
    },
    "frequency": {
      "office_hours": "every 20m",
      "off_hours": "every 4h"
    },
    "interruptions": {
      "office_hours": ["normal", "urgent", "critical"],
      "off_hours": ["critical"]
    },
    "digests": {
      "morning": true,
      "overnight": true
    }
  }
}
```

Some companies are always open. Others should be quiet by default. A publishing company may let agents work overnight but should hold routine creative updates until morning. A customer support or launch company may escalate urgent failures after hours.

Critical events can route through multiple escalation channels: Telegram, SMS, email, webhooks, Paperclip alerts, or smart-home signals such as Home Assistant/HomeKit lights.

## Printing Press Integration

Foreman should discover Printing Press and its installed CLIs:

```bash
npx -y @mvanhorn/printing-press list
npx -y @mvanhorn/printing-press search <query>
npx -y @mvanhorn/printing-press install <name> --cli-only
```

Known implementation detail from canary test:

- Printing Press requires Go for binary installs.
- Go can be installed with Homebrew on macOS: `brew install go`.
- Printing Press Go binaries land in `~/go/bin` by default.
- Foreman should set `GOBIN=$HOME/.local/bin` or verify `~/go/bin` is on PATH.

Canary verified 2026-05-21:

```bash
npx -y @mvanhorn/printing-press install wikipedia --cli-only
wikipedia-pp-cli page get-summary 'Artificial intelligence' --agent --select title,extract
```

## Implementation Plan

### Task 1: Add capability-aware module manifests

**Objective:** Extend built-in modules to include `capabilities`, `required_capabilities`, `recommended_capabilities`, `conditional_capabilities`, and `tool_manifest`.

**Files:**

- Modify: `modules/*/module.json`
- Test: `python3 -m json.tool modules/publishing/module.json`

**Verification:** All module manifests parse as valid JSON.

### Task 2: Add publishing module

**Objective:** Add the first capability-composed company template.

**Files:**

- Create: `modules/publishing/module.json`
- Create: `modules/publishing/SKILL.md`

**Acceptance:** Module includes editorial, commerce, email, analytics, launch, and customer-support capability bundles.

### Task 3: Add tool manifest command

**Objective:** Add a `foreman tools` command that can list/search/install Printing Press CLIs and verify company tool manifests.

**Files:**

- Create: `scripts/foreman-tools.sh`
- Modify: `README.md`

**Commands:**

```bash
./scripts/foreman-tools.sh list
./scripts/foreman-tools.sh search wikipedia
./scripts/foreman-tools.sh doctor
```

### Task 4: Update onboarding to ask capability questions

**Objective:** Update `foreman chat --onboard` so company type selection includes publishing and saves business-model answers to `project.json`.

**Files:**

- Modify: `scripts/foreman-chat.sh`

**Publishing questions:**

- project/imprint name
- publishing mode
- formats
- direct sales yes/no
- storefront/payment tools
- email marketing yes/no
- human approval gates

### Task 5: Add Paperclip holding-company adapter spec

**Objective:** Document the Paperclip API concepts Foreman needs before writing runtime code.

**Files:**

- Create: `docs/paperclip-holding-company-adapter.md`

**Acceptance:** Spec includes company context, CEO agent, tool manifest, Foreman run, event/audit log, and escalation objects.

### Task 5B: Add resolution heartbeat + office hours policy

**Objective:** Define company-level heartbeat policies so Foreman can drain review/blocker queues without forcing humans to live in Paperclip.

**Files:**

- Create: `docs/resolution-heartbeat-office-hours.md`
- Modify: `README.md`
- Modify: `docs/what-is-foreman.md`
- Modify: `docs/holding-company-architecture.md`

**Acceptance:** Docs cover queue-draining heartbeat behavior, office-hours vs off-hours protocols, severity levels, critical escalation examples, and Paperclip-optional operation.

### Task 6: Add canary end-to-end test script

**Objective:** Prove Foreman can install/use one Printing Press CLI.

**Files:**

- Create: `scripts/canary-printing-press.sh`

**Verification:** Script installs/verifies `wikipedia-pp-cli` and performs a live summary query.

## Product Rule

Templates must model **business capabilities**, not stereotypes.

A publishing company may need Shopify and Stripe. A YouTube company may need sponsor/affiliate tools. A software company may need customer support and billing. Foreman should ask the business-model questions before choosing tool bundles.
