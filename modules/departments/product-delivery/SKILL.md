# Product / Service Delivery Department

Define how the company creates and ships what it sells — software, physical goods, services, content, courses, or local work.

## Universal Responsibilities

- Intake and scope new deliverables
- Run delivery stages from idea to shipped
- Define acceptance criteria and evidence rules
- Coordinate builders and handoffs to QA
- Track delivery blockers and customer promise fit
- Maintain ship/fulfillment checklists and post-ship learning loop

## Workflows

### Standard delivery pipeline
Trigger: `new-deliverable`
Stages: intake → scope → build → verify → ship → post-ship-check
Evidence: acceptance-criteria, ship-artifact, post-ship-verdict

### Scope and change control
Trigger: `scope-change-request`
Stages: detect-change → assess-impact → approve-or-reject → update-scope → re-baseline-acceptance
Evidence: change-request, updated-acceptance-criteria, human-decision

### Ship / fulfill / handoff
Trigger: `ready-to-ship`
Stages: release-plan → go-live-checklist → handoff → monitor → rollback-or-repair
Evidence: release-notes, handoff-checklist, monitoring-notes

## Inspectors

### Quality Check
Review department work for quality check against inspection standards and company type expectations.

### Customer Promise Fit
Review department work for customer promise fit against inspection standards and company type expectations.

### Acceptance Verification
Review department work for acceptance verification against inspection standards and company type expectations.

### Operational Readiness
Review department work for operational readiness against inspection standards and company type expectations.

## Builder Prompts

### Intake Triage
You are a product / service delivery builder focused on intake triage. Follow company brief, constraints, and prior inspection results. Produce evidence-ready artifacts and note assumptions.

### Spec Brief
You are a product / service delivery builder focused on spec brief. Follow company brief, constraints, and prior inspection results. Produce evidence-ready artifacts and note assumptions.

### Feature Implementation
You are a product / service delivery builder focused on feature implementation. Follow company brief, constraints, and prior inspection results. Produce evidence-ready artifacts and note assumptions.

### Content Draft
You are a product / service delivery builder focused on content draft. Follow company brief, constraints, and prior inspection results. Produce evidence-ready artifacts and note assumptions.

### Service Package
You are a product / service delivery builder focused on service package. Follow company brief, constraints, and prior inspection results. Produce evidence-ready artifacts and note assumptions.

### Prototype Build
You are a product / service delivery builder focused on prototype build. Follow company brief, constraints, and prior inspection results. Produce evidence-ready artifacts and note assumptions.

### Release Plan
You are a product / service delivery builder focused on release plan. Follow company brief, constraints, and prior inspection results. Produce evidence-ready artifacts and note assumptions.

## Escalation Rules
- Builder fails inspection 3 times on the same task → escalate to Foreman / department lead
- Approval gate triggered → pause until human decision event is recorded
- Cross-department blocker → hand off via operations handoff workflow

## Company Type Notes

- **software** (required): Features, bugs, releases, deploy readiness
- **physical_product** (required): Design, manufacturing, QC, packaging
- **local_service** (required): Service packages, scheduling, fulfillment
- **creator** (required): Content production, formats, publishing cadence
- **publishing** (required): Manuscript pipeline, editorial stages
- **education_community** (required): Curriculum, lessons, assessments, cohort materials
