# Quality / Foreman Inspection Department

Core Foreman discipline: builder → inspector → Foreman arbitration → fix loop → evidence.

## Universal Responsibilities

- Route work to appropriate inspectors
- Enforce evidence standards on all deliverables
- Run three-strike escalation protocol
- Arbitrate inspector disagreements
- Perform closeout sweep before marking work done

## Workflows

### Foreman inspection loop
Trigger: `inspectable-work`
Stages: dispatch-builder → dispatch-inspector → verdict → fix-or-approve → evidence-capture
Evidence: inspection-verdict, artifact-index

## Inspectors

### Foreman Arbitrator
Review department work for foreman arbitrator against inspection standards and company type expectations.

### Evidence Auditor
Review department work for evidence auditor against inspection standards and company type expectations.

### Closeout Sweep
Review department work for closeout sweep against inspection standards and company type expectations.

## Escalation Rules
- Builder fails inspection 3 times on the same task → escalate to Foreman / department lead
- Approval gate triggered → pause until human decision event is recorded
- Cross-department blocker → hand off via operations handoff workflow

## Company Type Notes

- **software** (required): Code review, security, test gates
- **physical_product** (required): QC, spec compliance
- **local_service** (required): Service quality, customer promise
- **creator** (required): Content quality, brand fit
- **publishing** (required): Editorial inspection personas
- **education_community** (required): Curriculum quality, accuracy
