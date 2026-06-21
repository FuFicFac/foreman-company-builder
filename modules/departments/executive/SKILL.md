# Executive / Strategy Department

Define mission, business model, goals, decision rights, escalation policy, and operating cadence.

## Universal Responsibilities

- Set and refresh company mission and priorities
- Allocate attention and budget across departments
- Resolve cross-department conflicts and escalations
- Maintain decision log and weekly operating plan
- Define what requires chairman or human approval

## Workflows

### Weekly operating cadence
Trigger: `recurring-weekly`
Stages: review-priorities → assign-work → surface-blockers → decision-log
Evidence: weekly-plan, decision-log-entry

### Quarterly strategic review
Trigger: `recurring-quarterly`
Stages: assess-metrics → revise-goals → rebalance-departments
Evidence: strategic-memo, updated-priorities

## Inspectors

### Strategic Fit
Review department work for strategic fit against inspection standards and company type expectations.

### Risk Assessment
Review department work for risk assessment against inspection standards and company type expectations.

### Prioritization Check
Review department work for prioritization check against inspection standards and company type expectations.

## Builder Prompts

### Priority Memo
You are a executive / strategy builder focused on priority memo. Follow company brief, constraints, and prior inspection results. Produce evidence-ready artifacts and note assumptions.

### Decision Brief
You are a executive / strategy builder focused on decision brief. Follow company brief, constraints, and prior inspection results. Produce evidence-ready artifacts and note assumptions.

### Weekly Plan
You are a executive / strategy builder focused on weekly plan. Follow company brief, constraints, and prior inspection results. Produce evidence-ready artifacts and note assumptions.

## Escalation Rules
- Builder fails inspection 3 times on the same task → escalate to Foreman / department lead
- Approval gate triggered → pause until human decision event is recorded
- Cross-department blocker → hand off via operations handoff workflow

## Company Type Notes

- **software** (required): Roadmap, prioritization, technical debt vs feature tradeoffs
- **physical_product** (required): SKU strategy, margin targets, supplier risk
- **local_service** (required): Service area, capacity, pricing model
- **creator** (required): Brand direction, monetization mix, platform risk
- **publishing** (required): Imprint strategy, catalog priorities, launch calendar
- **education_community** (required): Curriculum vision, community norms, certification goals
