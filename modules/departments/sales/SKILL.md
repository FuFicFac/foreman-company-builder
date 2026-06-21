# Sales / Revenue Department

Handle leads, pipeline, qualification, proposals, pricing presentation, closing, CRM, and account expansion.

## Universal Responsibilities

- Qualify and stage leads
- Prepare proposals and pricing presentations
- Manage pipeline and follow-up cadence
- Hand off closed deals to delivery and success
- Track partnerships and referrals

## Workflows

### Lead to close
Trigger: `new-lead`
Stages: lead-intake → qualify → proposal → negotiate → close → handoff
Evidence: crm-record, proposal, handoff-checklist

## Inspectors

### Qualification Check
Review department work for qualification check against inspection standards and company type expectations.

### Offer Fit
Review department work for offer fit against inspection standards and company type expectations.

### Objection Coverage
Review department work for objection coverage against inspection standards and company type expectations.

### Handoff Quality
Review department work for handoff quality against inspection standards and company type expectations.

## Builder Prompts

### Proposal Draft
You are a sales / revenue builder focused on proposal draft. Follow company brief, constraints, and prior inspection results. Produce evidence-ready artifacts and note assumptions.

### Pricing Sheet
You are a sales / revenue builder focused on pricing sheet. Follow company brief, constraints, and prior inspection results. Produce evidence-ready artifacts and note assumptions.

### Follow Up Sequence
You are a sales / revenue builder focused on follow up sequence. Follow company brief, constraints, and prior inspection results. Produce evidence-ready artifacts and note assumptions.

## Escalation Rules
- Builder fails inspection 3 times on the same task → escalate to Foreman / department lead
- Approval gate triggered → pause until human decision event is recorded
- Cross-department blocker → hand off via operations handoff workflow

## Company Type Notes

- **software** (recommended): B2B pipeline, demos, enterprise deals
- **physical_product** (recommended): Wholesale, retail partnerships
- **local_service** (required): Estimates, booking, local B2B
- **creator** (optional): Sponsorships, brand deals
- **publishing** (optional): Rights, bulk, institutional sales
- **education_community** (required): Course sales, cohort enrollment
