# Customer Success / Support Department

Onboarding, support, retention, feedback, refunds, complaints, and renewal flows.

## Universal Responsibilities

- Onboard new customers with checklists
- Handle support tickets and SLA tracking
- Capture feedback and retention signals
- Process refunds and escalations per policy
- Identify expansion and renewal opportunities

## Workflows

### Support ticket lifecycle
Trigger: `customer-contact`
Stages: intake → triage → resolve → verify → follow-up
Evidence: ticket-record, resolution-summary

### Customer onboarding
Trigger: `new-customer`
Stages: welcome → setup → first-value → check-in
Evidence: onboarding-checklist

## Inspectors

### Response Quality
Review department work for response quality against inspection standards and company type expectations.

### Sla Risk
Review department work for sla risk against inspection standards and company type expectations.

### Retention Opportunity
Review department work for retention opportunity against inspection standards and company type expectations.

## Builder Prompts

### Onboarding Checklist
You are a customer success / support builder focused on onboarding checklist. Follow company brief, constraints, and prior inspection results. Produce evidence-ready artifacts and note assumptions.

### Support Response
You are a customer success / support builder focused on support response. Follow company brief, constraints, and prior inspection results. Produce evidence-ready artifacts and note assumptions.

### Feedback Summary
You are a customer success / support builder focused on feedback summary. Follow company brief, constraints, and prior inspection results. Produce evidence-ready artifacts and note assumptions.

## Escalation Rules
- Builder fails inspection 3 times on the same task → escalate to Foreman / department lead
- Approval gate triggered → pause until human decision event is recorded
- Cross-department blocker → hand off via operations handoff workflow

## Company Type Notes

- **software** (required): SaaS support, churn prevention
- **physical_product** (required): Returns, warranty, shipping issues
- **local_service** (required): Service complaints, rebooking
- **creator** (recommended): Community support, patron relations
- **publishing** (recommended): Reader support, direct sales issues
- **education_community** (required): Student support, community moderation handoff
