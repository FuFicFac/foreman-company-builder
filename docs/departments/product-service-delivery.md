# Product / Service Delivery (Universal Department)

## Purpose

Define and operate the company’s “how we ship” system: turn customer or internal demand into scoped deliverables, build them with predictable stages, verify quality + acceptance, ship through the right channels, and learn post-ship so promises stay true over time.

This department is the **delivery engine** for whatever the company sells: software, physical goods, local services, content/publishing, or education/community offerings.

## Universal responsibilities

- **Intake + triage**: capture requests, classify deliverable type, and decide “now / later / never” with reasons.
- **Scope + spec**: define what “done” means (acceptance + evidence) and bound scope to capacity.
- **Plan + sequence**: pick the next slice, align dependencies, and coordinate handoffs.
- **Build + produce**: create the deliverable (or coordinate builders/contractors) with visible progress.
- **Verification**: ensure quality standards and acceptance criteria are met (or explicitly waived via gate).
- **Ship + fulfill**: release/launch/hand off delivery in the correct channel with rollback/repair posture.
- **Post-ship learning**: capture what happened, what broke, and what to change in the pipeline.
- **Promise integrity**: keep the customer promise aligned with reality; escalate when promise vs capacity diverges.

## Core workflows

### 1) Deliverable intake and triage

**Trigger**: new deliverable request (customer, executive priority, bug report, content opportunity, service inquiry).

**Minimum intake schema (evidence)**:
- requestor + channel + date
- deliverable type (software / physical product / local service / content / publishing / course/community)
- desired outcome (customer value)
- constraints (deadline, budget, tools, dependencies)
- risk flags (legal/compliance, safety, privacy/PII, platform policy)
- acceptance criteria + evidence checklist (draft)

**Outputs**:
- intake record (durable)
- triage decision (do / defer / reject) + rationale
- initial scope hypothesis + owner

### 2) Scope and acceptance definition

**Trigger**: triage accepted.

**Process**:
- define “definition of done” as verifiable checks + artifacts
- identify dependencies and cross-department handoffs (ops, legal, tooling, marketing, finance)
- set explicit non-goals and out-of-scope items
- set delivery stages and target ship window (or explicitly “no date”)

**Outputs**:
- scoped spec / brief
- acceptance checklist + evidence requirements
- approval gates flagged (scope-change, ship-date, promise-change, major-spec-change)

### 3) Build / produce (iterative)

**Trigger**: scoped deliverable ready to build.

**Process**:
- build in small slices; keep artifacts inspectable
- capture assumptions; keep rollback/repair posture for high-stakes changes
- keep progress and blockers visible; escalate at defined thresholds

**Outputs**:
- increment artifacts (code, assets, drafts, service runbook, manufacturing packet, lesson plan)
- change log + decision log entries for major trade-offs

### 4) Verification and acceptance

**Trigger**: “candidate” deliverable ready for verification.

**Process**:
- run quality checks appropriate to company type
- verify acceptance criteria; record explicit waivers with owner + reason
- ensure evidence packet is complete (what shipped, where, when, how to validate)

**Outputs**:
- verification verdict + evidence
- acceptance sign-off record (human gate if required)

### 5) Ship / fulfill / handoff

**Trigger**: accepted deliverable.

**Process**:
- ship through channel (deploy, publish, manufacture/fulfill, schedule service delivery, launch course/cohort)
- complete handoff checklist (ops, customer success, distribution, marketing) as applicable
- prepare rollback/recovery plan for high-stakes launches

**Outputs**:
- ship artifact + release notes / delivery packet
- handoff checklist completion
- post-ship monitoring notes

### 6) Post-ship learning loop

**Trigger**: after ship window / initial usage.

**Process**:
- review outcomes vs acceptance criteria
- capture defects/complaints/returns/incidents
- update pipeline standards (templates, SOPs, gates) based on lessons learned

**Outputs**:
- post-ship verdict memo (what happened, what to change)
- backlog entries (fixes, SOP updates, quality checks)

## Required capabilities (department-level)

- **product-delivery**: reliable end-to-end delivery pipeline from intake → ship → post-ship learning.

## Optional capabilities (common extensions)

These are often activated conditionally by company type:

- **software-development** + **deployment**: software build + release.
- **editorial** + **metadata**: content/publishing pipelines.
- **launch-operations**: coordinated launches (go-live checklists, sequencing, comms).
- **operations-sop**: handoffs, fulfillment SOPs, scheduling, runbooks.
- **quality-inspection**: inspector routing and evidence enforcement.
- **procurement-supply**: vendor/manufacturing/3PL coordination for physical goods.
- **distribution-channels**: channel packaging, listings, partner distribution.
- **digital-commerce**: storefront setup, payments, product pages for direct sales.

## Agents and roles (default roster)

- **Product lead**: owns scope, sequencing, customer promise integrity, and ship decisions within gates.
- **Producer / program manager**: owns schedule, dependencies, status, and cross-department handoffs.
- **Delivery coordinator**: maintains intake, evidence packets, acceptance templates, and stage checklists.
- **Builder**: produces the deliverable artifacts (engineering, design, writing, manufacturing packet, service runbook).
- **Release / fulfillment owner** (optional): owns go-live, rollback, and channel-specific shipping mechanics.

### Inspectors (delivery quality gates)

- **Quality check**: overall quality against standards for the deliverable type.
- **Acceptance verification**: confirms acceptance criteria and evidence are satisfied.
- **Customer promise fit**: checks the output matches the promise, constraints, and customer expectations.
- **Operational readiness** (optional): flags missing runbooks, handoffs, monitoring, or fulfillment gaps.

## Human approval gates (universal)

Human approval is required for decisions that materially change what’s promised, when it ships, or the risk posture:

- **scope-change**: any change that affects acceptance criteria, budget, or major effort.
- **ship-date**: committing or changing a ship/release/delivery date (esp. externally).
- **customer-promise-change**: changes in what’s being promised (features, outcomes, guarantees, claims).
- **major-spec-change**: changes that invalidate prior acceptance decisions or require re-verification.

## Tool manifest (minimal viable set)

This department needs (1) durable state, (2) work tracking, (3) artifact storage, (4) verification evidence.

- **Work tracking**: Linear / Jira / Paperclip issues
- **Artifacts**: GitHub (software), Google Drive/Notion (docs), asset storage
- **Comms + handoff**: Slack / email
- **Verification**: test runner / checklist system; inspector verdict capture

Map common capability→tool choices:

- `product-delivery`: Linear, GitHub, Notion
- `software-development`: GitHub
- `deployment`: GitHub Actions, Vercel, Fly.io
- `editorial` / `metadata`: Storycraft, Notion
- `launch-operations`: Notion, calendar tooling

## Smoke tests / evidence checks

Fast checks that prove delivery is “alive” and inspectable:

- **Intake schema exists**: deliverable intake fields are defined and used.
- **Acceptance template exists**: a reusable acceptance + evidence checklist template exists.
- **Stage checklist exists**: delivery stages are named with exit criteria for each stage.
- **Handoff checklist exists**: delivery→ops/support handoff packet template exists.
- **Rollback/repair posture**: for high-stakes work, a rollback or repair plan is defined before ship.
- **Post-ship verdict**: every shipped deliverable produces a short verdict memo within a fixed window.

## Cross-company mappings (how Product / Service Delivery manifests by company type)

### Software company

- **Primary focus**: roadmap slices, bugfixes, releases, reliability.
- **Typical deliverables**: features, fixes, migrations, internal tooling.
- **Verification**: tests, lint/typecheck, staging validation, rollout/monitoring.
- **Extra gates**: production deploy policy; security and data-handling approvals (when applicable).

### Physical product company

- **Primary focus**: product spec, manufacturing readiness, QC, packaging, returns posture.
- **Typical deliverables**: SKU design packet, BOM, supplier spec, packaging, fulfillment plan.
- **Verification**: QC checklist, sample approval, compliance checks, packaging test.
- **Extra gates**: supplier selection, purchase orders, safety/compliance sign-off.

### Local service company

- **Primary focus**: service menu, scheduling, fulfillment consistency, customer experience.
- **Typical deliverables**: service package, SOP/runbook, pricing sheet, booking flow.
- **Verification**: checklist-driven fulfillment, review/NPS monitoring, rework policy.
- **Extra gates**: policy changes for refunds/guarantees; liability/safety escalation.

### Creator company

- **Primary focus**: consistent production cadence and format fit across platforms.
- **Typical deliverables**: video episode, newsletter issue, podcast, social series.
- **Verification**: brand consistency, title/thumbnail/copy checks, platform compliance.
- **Extra gates**: sponsor claim approvals; sensitive-topic review.

### Publishing company

- **Primary focus**: manuscript pipeline, editorial stages, format conversions, metadata accuracy.
- **Typical deliverables**: draft→edit→proof→publish; cover + blurb + metadata package.
- **Verification**: editorial QA, formatting checks, metadata completeness, proof review.
- **Extra gates**: cover direction, category/positioning changes, platform policy compliance.

### Education / community company

- **Primary focus**: learning outcomes, curriculum integrity, cohort operations, community health.
- **Typical deliverables**: course modules, lessons, assessments, cohort runbooks.
- **Verification**: accuracy review, outcome alignment, accessibility checks, moderation readiness.
- **Extra gates**: certification/regulated claims; policy changes (moderation/refunds).

## Foreman integration notes (recommended)

### Stage model for delivery work

```text
intake → scope → build → verify → ship → post-ship-check
```

### Context packet requirements (delivery runs)

- company brief + customer promise
- deliverable intake record
- constraints (time/budget/tools/dependencies)
- acceptance criteria + evidence checklist
- definition of done / stage exit criteria
- prior inspection results + known defects/incidents
- human decisions (gates + waivers) to date
- expected output schema (ship artifact, release notes, handoff packet, verdict memo)

