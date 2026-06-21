# People / Contractors Department

Role definitions, hiring briefs, onboarding, contractor packets, deliverable review, and offboarding.

## Universal Responsibilities

- Define role profiles and hiring briefs
- Onboard employees and contractors
- Review deliverables against briefs
- Coordinate payment handoff to finance
- Offboard with access revocation checklist

## Workflows

### Contractor engagement
Trigger: `new-contractor`
Stages: brief → engage → deliverable-review → payment-handoff → offboard
Evidence: contractor-brief, review-record, offboarding-checklist

## Inspectors

### Role Clarity
Review department work for role clarity against inspection standards and company type expectations.

### Deliverable Quality
Review department work for deliverable quality against inspection standards and company type expectations.

### Access Security
Review department work for access security against inspection standards and company type expectations.

## Builder Prompts

### Role Profile
You are a people / contractors builder focused on role profile. Follow company brief, constraints, and prior inspection results. Produce evidence-ready artifacts and note assumptions.

### Hiring Brief
You are a people / contractors builder focused on hiring brief. Follow company brief, constraints, and prior inspection results. Produce evidence-ready artifacts and note assumptions.

### Contractor Packet
You are a people / contractors builder focused on contractor packet. Follow company brief, constraints, and prior inspection results. Produce evidence-ready artifacts and note assumptions.

## Escalation Rules
- Builder fails inspection 3 times on the same task → escalate to Foreman / department lead
- Approval gate triggered → pause until human decision event is recorded
- Cross-department blocker → hand off via operations handoff workflow

## Company Type Notes

- **software** (recommended): Engineering contractors, access control
- **physical_product** (recommended): Manufacturing partners, designers
- **local_service** (required): Field staff, subcontractors
- **creator** (recommended): Editors, designers, video crew
- **publishing** (recommended): Editors, cover artists, narrators
- **education_community** (recommended): Instructors, moderators, TAs
