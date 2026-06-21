# Operations / SOPs Department

Turn repeated work into procedures, checklists, schedules, handoffs, vendor coordination, and repair loops.

## Universal Responsibilities

- Author and maintain SOPs and runbooks
- Define recurring task schedules
- Manage handoff checklists between departments
- Coordinate vendors and fulfillment flows
- Escalate blocked operational work

## Workflows

### SOP authoring and refresh
Trigger: `new-or-stale-sop`
Stages: draft → review → publish → schedule-refresh
Evidence: sop-document, refresh-date

### Cross-department handoff
Trigger: `stage-complete`
Stages: prepare-packet → transfer → acknowledge → verify-complete
Evidence: handoff-checklist

## Inspectors

### Sop Clarity
Review department work for sop clarity against inspection standards and company type expectations.

### Handoff Completeness
Review department work for handoff completeness against inspection standards and company type expectations.

### Schedule Coverage
Review department work for schedule coverage against inspection standards and company type expectations.

## Builder Prompts

### Sop Draft
You are a operations / sops builder focused on sop draft. Follow company brief, constraints, and prior inspection results. Produce evidence-ready artifacts and note assumptions.

### Runbook
You are a operations / sops builder focused on runbook. Follow company brief, constraints, and prior inspection results. Produce evidence-ready artifacts and note assumptions.

### Recurring Task Setup
You are a operations / sops builder focused on recurring task setup. Follow company brief, constraints, and prior inspection results. Produce evidence-ready artifacts and note assumptions.

## Escalation Rules
- Builder fails inspection 3 times on the same task → escalate to Foreman / department lead
- Approval gate triggered → pause until human decision event is recorded
- Cross-department blocker → hand off via operations handoff workflow

## Company Type Notes

- **software** (recommended): Release ops, on-call, incident response
- **physical_product** (required): Fulfillment, inventory, shipping SOPs
- **local_service** (required): Booking, dispatch, service delivery checklists
- **creator** (recommended): Publishing cadence, asset management
- **publishing** (required): Editorial handoffs, vendor coordination
- **education_community** (required): Cohort ops, moderation, event runbooks
