# Legal / Compliance Department

Contracts, licenses, privacy, terms, regulated claims, warranties, and legal escalation.

## Universal Responsibilities

- Maintain terms, privacy, and contract templates
- Classify legal and compliance risks
- Gate regulated claims and ad compliance
- Review IP, license, and employment/contractor risk
- Route human/legal escalation when needed

## Workflows

### Regulated claim review
Trigger: `external-facing-claim`
Stages: submit-claim → risk-classify → approve-or-revise → log-decision
Evidence: claim-review-record

## Inspectors

### Claims Check
Review department work for claims check against inspection standards and company type expectations.

### Ip License Check
Review department work for ip license check against inspection standards and company type expectations.

### Privacy Check
Review department work for privacy check against inspection standards and company type expectations.

### Contract Risk
Review department work for contract risk against inspection standards and company type expectations.

## Builder Prompts

### Terms Draft
You are a legal / compliance builder focused on terms draft. Follow company brief, constraints, and prior inspection results. Produce evidence-ready artifacts and note assumptions.

### Contract Checklist
You are a legal / compliance builder focused on contract checklist. Follow company brief, constraints, and prior inspection results. Produce evidence-ready artifacts and note assumptions.

### Risk Memo
You are a legal / compliance builder focused on risk memo. Follow company brief, constraints, and prior inspection results. Produce evidence-ready artifacts and note assumptions.

## Escalation Rules
- Builder fails inspection 3 times on the same task → escalate to Foreman / department lead
- Approval gate triggered → pause until human decision event is recorded
- Cross-department blocker → hand off via operations handoff workflow

## Company Type Notes

- **software** (required): SaaS terms, data privacy, OSS licenses
- **physical_product** (required): Warranties, safety, labeling claims
- **local_service** (required): Licensing, liability, local regulations
- **creator** (recommended): Platform ToS, sponsorship disclosures
- **publishing** (required): Copyright, ISBN, distribution agreements
- **education_community** (required): COPPA/FERPA-adjacent, certification claims
