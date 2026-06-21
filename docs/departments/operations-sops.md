# Operations / SOPs (Universal Department)

## Purpose

Turn repeated work into **procedures, checklists, schedules, handoffs, vendor coordination, and repair loops** so delivery stays consistent, low-drama, and scalable as volume grows.

This department is the company’s **repeatability + reliability layer**: it converts “tribal knowledge” into durable runbooks, prevents work from getting stuck between teams, and ensures recurring work happens on time.

## Universal responsibilities

- **SOP library**: author, maintain, and retire SOPs and runbooks.
- **Recurring operations**: define recurring task schedules (daily/weekly/monthly) and ensure ownership.
- **Handoffs**: define and enforce handoff packets between departments (what must be true before transfer).
- **Fulfillment + vendor coordination**: manage operational steps that bridge internal work to external execution.
- **Blockers + escalations**: detect stuck work early; escalate with clear unblock owner and next action.
- **Operational learning loop**: after incidents or misses, update SOPs, checklists, and schedules.

## Core workflows

### 1) SOP authoring and refresh

**Trigger**: `new-or-stale-sop`

**Process**
- draft SOP with clear preconditions, steps, and exit criteria
- review for clarity and company-type fit
- publish to the canonical SOP library
- schedule refresh (review date + owner)

**Outputs (evidence artifacts)**
- SOP document (versioned)
- refresh date + owner

### 2) Cross-department handoff

**Trigger**: `stage-complete`

**Process**
- prepare handoff packet (required artifacts + status + open risks)
- transfer ownership (explicit, not implied)
- acknowledge receipt (receiver confirms they can proceed)
- verify complete (handoff checklist satisfied)

**Outputs**
- completed handoff checklist
- updated owner of record (task tracker)

### 3) Recurring task scheduling and coverage

**Trigger**: new recurring work identified, or missed recurring work detected.

**Process**
- define the recurring task cadence and SLA (what “on time” means)
- assign an owner and backup owner
- attach the SOP/runbook and evidence requirements
- add monitoring for “missed cadence” alerts

**Outputs**
- recurring task schedule record
- evidence checklist + definition of done

### 4) Blocked work escalation (stop-the-line for ops)

**Trigger**: work is blocked beyond threshold (time, dependency, missing approval, missing input).

**Process**
- classify blocker type (input missing / dependency / tool failure / approval gate / vendor delay)
- assign unblock owner + deadline
- if approval gate: pause until human decision event is recorded
- if cross-department: route via handoff workflow with explicit acceptance

**Outputs**
- escalation record with unblock owner + next action
- decision event reference if human gate triggered

## Required capabilities (department-level)

- **operations-sop**: write procedures, define checklists, schedule recurring work, run handoffs, and keep runbooks current.

## Optional capabilities (common extensions)

- **knowledge-documentation**: SOP library hygiene, indexing, and freshness sweeps.
- **tooling-it-security**: operational tooling, access requests, integration health.
- **quality-inspection**: inspection routing for evidence completeness and handoff correctness.
- **procurement-supply**: vendor procurement, inventory, and fulfillment partners.
- **analytics-reporting**: operational metrics (SLA adherence, cycle time, missed cadence rate).

## Agents and roles (default roster)

- **Operations lead**: owns operational system design, escalation rules, and cross-department reliability.
- **SOP author**: drafts and maintains SOPs/runbooks; captures learnings after misses/incidents.
- **Scheduler**: defines and monitors recurring cadences; ensures coverage and follow-ups.
- **Vendor coordinator**: coordinates vendors/partners, tracks SLAs, and escalates delays.

### Inspectors (operations quality gates)

- **SOP clarity inspector**: SOPs have unambiguous steps, preconditions, and exit criteria.
- **Handoff completeness inspector**: handoff packets include required artifacts and explicit ownership transfer.
- **Schedule coverage inspector**: recurring work has owners, cadences, and evidence requirements; misses are caught.

## Human approval gates (universal)

- **sop-publish**: publishing or materially changing a SOP that affects risk, spend, or customer promise.
- **vendor-contract**: vendor contract commitments, spend thresholds, or exclusivity terms.
- **process-change**: changes that alter operational risk posture, customer promise, or compliance requirements.

## Tool manifest (minimal viable set)

Operations can run with a small, durable tool set:

- **SOP library**: repo `docs/` and/or a doc system (Notion/Docs)
- **Task tracking**: Paperclip issues or Linear/Jira
- **Comms + escalation**: Slack/email
- **Scheduling**: calendar tooling for recurring reviews and operational cadences

Map capability→tool choices (examples):

- `operations-sop`: Notion, Linear, Slack

## Smoke tests / evidence checks

Fast checks that prove Operations / SOPs is “alive”:

- **Core SOPs exist**: at least one SOP per recurring workflow (or per high-volume workflow).
- **Handoff checklists exist**: at least one handoff checklist used between major departments.
- **Recurring schedule exists**: a schedule record with owner + cadence for recurring work.
- **Escalation rules exist**: blocked-work threshold and escalation owner routing is documented and used.
- **Refresh dates set**: SOPs have owners and review dates (staleness doesn’t silently accumulate).

## Cross-company mappings (how Operations / SOPs manifests by company type)

### Software company

- **Primary focus**: release ops, incident response, on-call runbooks, support handoffs.
- **Typical SOPs**: deploy checklist, rollback, incident triage, escalation policy, support-to-engineering handoff.
- **Extra gates**: production change management; security and data-handling approvals when applicable.

### Physical product company

- **Primary focus**: fulfillment, inventory, shipping, returns, vendor SLAs.
- **Typical SOPs**: pick/pack/ship, inventory counts, returns processing, supplier escalation, QC checklists.
- **Extra gates**: purchase orders beyond threshold; warranty/claims policy changes.

### Local service company

- **Primary focus**: booking, dispatch, service delivery consistency, rework loops.
- **Typical SOPs**: scheduling and routing, arrival checklist, job closeout, customer follow-up, incident/safety escalation.
- **Extra gates**: refunds/guarantees policy changes; safety/liability escalations.

### Creator company

- **Primary focus**: production cadence, asset management, sponsorship ops handoffs.
- **Typical SOPs**: publishing checklist, thumbnail/title review, sponsor insertion workflow, asset naming/storage rules.
- **Extra gates**: sponsor claims, sensitive-topic handling, platform compliance escalations.

### Publishing company

- **Primary focus**: editorial handoffs, vendor coordination (cover, formatting, audio), release calendars.
- **Typical SOPs**: draft→edit→proof handoffs, metadata QA checklist, vendor packet templates, launch readiness checklist.
- **Extra gates**: cover direction approvals; vendor contract and rights decisions as applicable.

### Education / community company

- **Primary focus**: cohort ops, moderation runbooks, event logistics, support load management.
- **Typical SOPs**: cohort kickoff, office hours, moderation escalation, incident response, student support handoff.
- **Extra gates**: moderation policy changes; certification/regulated claims approvals.

## Foreman integration notes (recommended)

### Stage model for Operations / SOPs tasks

```text
detect-repeatable-work → draft → review → publish → rollout → audit → refresh
```

### Context packet requirements (operations runs)

- company brief (company type + customer promise)
- the triggering workflow (what repeats / what broke / what’s blocked)
- existing SOPs/runbooks (if any) and prior inspection results
- constraints (tools, staffing, SLAs, vendor realities)
- required evidence artifacts (checklists, schedules, handoff packets)
- human decisions (approval gates) relevant to process/vendor changes

