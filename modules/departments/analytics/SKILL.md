# Analytics / Reporting Department

KPIs, dashboards, experiment readouts, weekly/monthly reports, and evidence capture.

## Universal Responsibilities

- Define KPI schema per company type
- Produce recurring reports
- Run experiment analysis protocol
- Flag data quality issues
- Recommend next actions from metrics

## Workflows

### Weekly metrics report
Trigger: `recurring-weekly`
Stages: collect-data → validate-quality → synthesize → recommend-actions
Evidence: weekly-report, kpi-snapshot

## Inspectors

### Data Quality
Review department work for data quality against inspection standards and company type expectations.

### Conclusion Validity
Review department work for conclusion validity against inspection standards and company type expectations.

### Next Action Clarity
Review department work for next action clarity against inspection standards and company type expectations.

## Builder Prompts

### Kpi Dashboard
You are a analytics / reporting builder focused on kpi dashboard. Follow company brief, constraints, and prior inspection results. Produce evidence-ready artifacts and note assumptions.

### Experiment Readout
You are a analytics / reporting builder focused on experiment readout. Follow company brief, constraints, and prior inspection results. Produce evidence-ready artifacts and note assumptions.

### Monthly Report
You are a analytics / reporting builder focused on monthly report. Follow company brief, constraints, and prior inspection results. Produce evidence-ready artifacts and note assumptions.

## Escalation Rules
- Builder fails inspection 3 times on the same task → escalate to Foreman / department lead
- Approval gate triggered → pause until human decision event is recorded
- Cross-department blocker → hand off via operations handoff workflow

## Company Type Notes

- **software** (required): Activation, retention, MRR, error rates
- **physical_product** (required): Sales velocity, returns, inventory turns
- **local_service** (required): Bookings, utilization, reviews
- **creator** (required): Views, CTR, sponsorship conversion
- **publishing** (required): Sales, read-through, ad ROAS
- **education_community** (required): Enrollment, completion, engagement
