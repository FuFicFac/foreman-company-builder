# People / Contractors (Universal Department)

## Purpose

Define roles, hire and onboard employees and contractors, review deliverables against briefs, coordinate payment handoff to Finance, and offboard with a clean access-revocation checklist. This department owns the human layer of the company: who does what, under what brief, with what access, and how their work is reviewed and closed out.

It is the **workforce + accountability layer** that makes sure every role has a clear profile, every engagement has a written brief, and every departure leaves no orphaned access or unfinished deliverable. Where other departments specify the work, People / Contractors specifies who is authorized and equipped to do it.

This department defaults to a lean loop: brief the role, engage the person, review the deliverable, hand off payment, and offboard cleanly — with human gates at hire, engagement, termination, and any access grant.

## Universal responsibilities

- **Define role profiles and hiring briefs**: maintain role-profile, hiring-brief, and contractor-packet templates so every engagement starts with a written scope.
- **Onboard employees and contractors**: run access provisioning, context handoff, and first-deliverable setup against the role profile.
- **Review deliverables against briefs**: inspect each deliverable for role-clarity, deliverable-quality, and access-security before acceptance.
- **Coordinate payment handoff to finance**: pass accepted deliverables and engagement terms to Finance for payment processing.
- **Offboard with access revocation checklist**: revoke access, close accounts, and archive artifacts when an engagement ends.

## Core workflows

### 1) Contractor engagement

**Inputs**
- a new-contractor trigger (role needed, project scoped)
- role profile and hiring brief
- budget / rate constraints
- access and tooling requirements (depends on Tooling / IT)

**Process (stages)**
- `brief`: produce the contractor-brief from the role profile and hiring brief; confirm scope, rate, and success criteria.
- `engage`: human gate on `contractor-engagement` and `hire`; provision access (human-gated `access-grant`) via Tooling / IT.
- `deliverable-review`: inspect deliverables against role-clarity and deliverable-quality; route revisions or accept.
- `payment-handoff`: pass accepted deliverables and terms to Finance for payment.
- `offboard`: run the offboarding-checklist (access revocation, account closure, artifact archive); human gate on `termination`.

**Outputs (evidence artifacts)**
- contractor-brief (scope, rate, success criteria, access list)
- review-record (deliverable verdicts, revision history, acceptance)
- offboarding-checklist (access revoked, accounts closed, artifacts archived)

## Required capabilities (department-level)

- **people-contractors**: Hiring, onboarding, contractor management, offboarding — the core capability that authorizes this department to define roles, engage workers, review deliverables, and run offboarding.

## Optional capabilities

- **tooling-it**: access provisioning and revocation, identity management, and onboarding tooling (this department depends on Tooling / IT).
- **legal-compliance**: worker-classification and contractor-agreement checks (overlaps with Legal / Compliance).
- **finance-ops**: payment-handoff coordination and contractor invoicing (overlaps with Finance / Ops).
- **analytics-reporting**: time-to-hire, deliverable-quality trends, and contractor performance tracking.
- **research-intelligence**: market rate benchmarking and talent sourcing intelligence.
- **executive-strategy**: org design and hiring plan alignment with company priorities.

## Agents and roles (default roster)

- **People Lead**: owns the workforce plan, role-profile library, and offboarding discipline; triggers human gates.
- **Hiring Manager**: defines the hiring brief, evaluates candidates, and owns the engagement decision for a given role.
- **Contractor Coordinator**: runs the day-to-day engagement — onboarding, deliverable tracking, payment handoff, and offboarding execution.

### Inspectors (quality gates for people / contractors work)

- **role-clarity**: verifies the role profile and brief are unambiguous — scope, success criteria, and authority limits are defined.
- **deliverable-quality**: verifies submitted work meets the brief and the acceptance criteria before payment handoff.
- **access-security**: verifies access provisioning and revocation match the role profile and the offboarding checklist.

## Human approval gates (universal)

Human approval is required for any action that materially changes who can act on behalf of the company or access its systems.

- **hire**: any employee or contractor engagement decision.
- **contractor-engagement**: confirming scope, rate, and terms before work begins.
- **termination**: ending an engagement, with offboarding checklist enforced.
- **access-grant**: granting access to systems, data, or accounts (provisioned via Tooling / IT).

## Tool manifest (minimal viable set)

This department should be able to operate with a small set of tools that provide durable state and evidence.

- **Work surface**: Linear, Notion (role profiles, engagements, deliverable tracking, offboarding checklists) or equivalent
- **Knowledge base**: repo `docs/people/` (role-profile library, hiring-brief templates, offboarding-checklist template)
- **Access coordination**: integration with Tooling / IT for provisioning and revocation
- **Payment handoff**: shared record with Finance for accepted deliverables and terms

If a company adopts platform-specific tooling, map it here (examples):

- **HRIS / contractor management**: Notion, Linear, Rippling, Deel, Oyster
- **Access management**: 1Password, Okta, Google Workspace admin
- **Comms**: Slack, email
- **Docs**: Notion, Google Docs, GitHub

## Smoke tests / evidence checks

These are fast checks to prove the department is "alive" and aligned.

- **Core role profiles exist**: a role-profile-index exists covering the company's core roles.
- **Contractor-brief exists**: at least one recent contractor-brief with scope, rate, and success criteria.
- **Review records logged**: recent deliverable-quality and role-clarity verdicts archived for active engagements.
- **Offboarding checklist used**: at least one completed offboarding-checklist with access revoked and artifacts archived.
- **Approval gates are explicit**: hire, contractor-engagement, termination, and access-grant gates are listed and used.
- **Payment handoff working**: accepted deliverables have a corresponding handoff record to Finance.

## Cross-company mappings (how People / Contractors manifests by company type)

### Software company

- **Primary focus**: engineering contractors and access control for code, infra, and data.
- **Key decisions**: contractor vs employee, access scope, onboarding to repos and deploy pipelines.
- **KPIs**: time-to-first-deliverable, deliverable-quality pass rate, access-revocation latency, contractor retention.
- **Extra gates**: access-grant on production systems; termination with full revocation sweep.

### Physical product company

- **Primary focus**: manufacturing partners, designers, and product-development contractors.
- **Key decisions**: partner vs in-house, IP ownership, sample/prototype review cadence.
- **KPIs**: deliverable-quality pass rate, on-time sample delivery, partner retention, IP-handoff clarity.
- **Extra gates**: contractor-engagement with IP assignment; termination with file and sample return.

### Local service company

- **Primary focus**: field staff and subcontractors covering service delivery capacity.
- **Key decisions**: subcontractor vs employee, geographic coverage, scheduling authority.
- **KPIs**: on-time arrival, service-quality pass rate, subcontractor retention, complaint rate.
- **Extra gates**: access-grant on customer scheduling and PII; termination with route/customer access revoked.

### Creator company

- **Primary focus**: editors, designers, and video crew supporting content production.
- **Key decisions**: crew vs solo, project-rate vs retainer, footage/IP ownership.
- **KPIs**: deliverable-quality pass rate, turnaround time, crew retention, brand-fit consistency.
- **Extra gates**: contractor-engagement with footage rights; termination with asset handover.

### Publishing company

- **Primary focus**: editors, cover artists, and narrators for book production.
- **Key decisions**: freelancer vs in-house, rights scope, per-title vs series engagement.
- **KPIs**: deliverable-quality pass rate, on-time manuscript/audio delivery, contributor retention.
- **Extra gates**: contractor-engagement with copyright/license terms; termination with work-product handover.

### Education / community company

- **Primary focus**: instructors, moderators, and teaching assistants for courses and community.
- **Key decisions**: TA vs instructor, cohort vs evergreen coverage, moderation authority.
- **KPIs**: deliverable-quality pass rate, response time, learner satisfaction, moderator retention.
- **Extra gates**: access-grant on learner data and community moderation tools; termination with community access revoked.

## Foreman integration notes (recommended)

### Stage model for People / Contractors tasks

```text
brief → engage (human gate) → deliverable-review → payment-handoff → offboard (human gate)
```

### Context packet requirements (people / contractors runs)

- company-brief (org structure, role library, tooling posture)
- active-task (the role to fill or the engagement under review)
- role-instructions (which inspector runs: role-clarity, deliverable-quality, access-security)
- relevant-artifacts (role profile, hiring brief, contractor-brief, review records, offboarding checklist)
- constraints (budget, rate, access scope, deadlines)
- prior-inspection-results (recent role-clarity / deliverable-quality / access-security verdicts)
- human-decisions (outstanding approvals: hire, contractor-engagement, termination, access-grant)
- expected-output-schema (contractor-brief, review-record, offboarding-checklist, payment-handoff record)