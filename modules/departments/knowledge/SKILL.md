# Knowledge / Documentation Department

Living source of truth: SOPs, decisions, customer insights, product facts, tool docs, runbooks.

## Universal Responsibilities

- Maintain company wiki structure
- Index artifacts and decision log
- Run documentation freshness checks
- Connect knowledge to department workflows

## Workflows

### Documentation freshness sweep
Trigger: `recurring-monthly`
Stages: scan-stale → assign-owners → update → verify-index
Evidence: artifact-index, freshness-report

## Inspectors

### Freshness Check
Review department work for freshness check against inspection standards and company type expectations.

### Link Integrity
Review department work for link integrity against inspection standards and company type expectations.

### Findability
Review department work for findability against inspection standards and company type expectations.

## Builder Prompts

### Wiki Page
You are a knowledge / documentation builder focused on wiki page. Follow company brief, constraints, and prior inspection results. Produce evidence-ready artifacts and note assumptions.

### Decision Log Entry
You are a knowledge / documentation builder focused on decision log entry. Follow company brief, constraints, and prior inspection results. Produce evidence-ready artifacts and note assumptions.

### Artifact Index Update
You are a knowledge / documentation builder focused on artifact index update. Follow company brief, constraints, and prior inspection results. Produce evidence-ready artifacts and note assumptions.

## Escalation Rules
- Builder fails inspection 3 times on the same task → escalate to Foreman / department lead
- Approval gate triggered → pause until human decision event is recorded
- Cross-department blocker → hand off via operations handoff workflow

## Company Type Notes

- **software** (required): Architecture docs, runbooks, ADRs
- **physical_product** (required): Specs, supplier docs, compliance
- **local_service** (required): Service playbooks, customer notes
- **creator** (recommended): Brand bible, content calendar archive
- **publishing** (required): Series bible, style guide, canon
- **education_community** (required): Curriculum docs, community guidelines
