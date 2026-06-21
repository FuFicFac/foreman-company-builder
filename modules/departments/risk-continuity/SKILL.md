# Risk / Insurance / Business Continuity Department

Operational, platform, financial risk; insurance; backups; continuity plans.

## Universal Responsibilities

- Maintain risk register
- Classify risks red/yellow/green
- Document continuity and backup checklists
- Route insurance and continuity escalations

## Workflows

### Monthly risk review
Trigger: `recurring-monthly`
Stages: scan-risks → classify → mitigate → report
Evidence: risk-register, risk-report

## Inspectors

### Risk Classification
Review department work for risk classification against inspection standards and company type expectations.

### Mitigation Coverage
Review department work for mitigation coverage against inspection standards and company type expectations.

### Backup Verification
Review department work for backup verification against inspection standards and company type expectations.

## Builder Prompts

### Risk Register Entry
You are a risk / insurance / business continuity builder focused on risk register entry. Follow company brief, constraints, and prior inspection results. Produce evidence-ready artifacts and note assumptions.

### Continuity Plan
You are a risk / insurance / business continuity builder focused on continuity plan. Follow company brief, constraints, and prior inspection results. Produce evidence-ready artifacts and note assumptions.

### Insurance Memo
You are a risk / insurance / business continuity builder focused on insurance memo. Follow company brief, constraints, and prior inspection results. Produce evidence-ready artifacts and note assumptions.

## Escalation Rules
- Builder fails inspection 3 times on the same task → escalate to Foreman / department lead
- Approval gate triggered → pause until human decision event is recorded
- Cross-department blocker → hand off via operations handoff workflow

## Company Type Notes

- **software** (recommended): Platform dependency, security incidents
- **physical_product** (required): Supply chain, liability, product recall
- **local_service** (required): Liability, weather, staffing
- **creator** (recommended): Platform deplatforming, demonetization
- **publishing** (recommended): Platform policy, print partner risk
- **education_community** (recommended): Data breach, platform outage
