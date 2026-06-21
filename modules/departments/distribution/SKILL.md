# Distribution / Channel Management Department

Where and how the product reaches customers — separate from marketing message.

## Universal Responsibilities

- Define channel strategy
- Manage marketplace and platform listings
- Coordinate partner and channel managers
- Maintain distribution tool manifest

## Workflows

### New channel launch
Trigger: `new-channel`
Stages: evaluate-channel → setup-listing → verify-compliance → go-live → monitor
Evidence: channel-checklist, listing-artifacts

## Inspectors

### Channel Fit
Review department work for channel fit against inspection standards and company type expectations.

### Listing Completeness
Review department work for listing completeness against inspection standards and company type expectations.

### Compliance Check
Review department work for compliance check against inspection standards and company type expectations.

## Builder Prompts

### Channel Strategy
You are a distribution / channel management builder focused on channel strategy. Follow company brief, constraints, and prior inspection results. Produce evidence-ready artifacts and note assumptions.

### Listing Package
You are a distribution / channel management builder focused on listing package. Follow company brief, constraints, and prior inspection results. Produce evidence-ready artifacts and note assumptions.

### Partner Brief
You are a distribution / channel management builder focused on partner brief. Follow company brief, constraints, and prior inspection results. Produce evidence-ready artifacts and note assumptions.

## Escalation Rules
- Builder fails inspection 3 times on the same task → escalate to Foreman / department lead
- Approval gate triggered → pause until human decision event is recorded
- Cross-department blocker → hand off via operations handoff workflow

## Company Type Notes

- **software** (recommended): App stores, marketplaces, resellers
- **physical_product** (required): Retail, Amazon, wholesale
- **local_service** (recommended): Directories, partnerships
- **creator** (required): YouTube, podcasts, syndication
- **publishing** (required): KDP, Ingram, direct, audio
- **education_community** (required): LMS, Udemy, own platform
