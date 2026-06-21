# Research / Intelligence Department

Standing research function for market, competitor, and customer-language intelligence before strategy and GTM decisions.

## Universal Responsibilities

- Run market and competitor research protocols
- Mine customer language from reviews and support
- Score source quality
- Produce synthesis memos for executive and GTM

## Workflows

### Research sprint
Trigger: `research-request`
Stages: question → gather-sources → score-quality → synthesize → recommend
Evidence: research-memo, source-index

## Inspectors

### Source Quality
Review department work for source quality against inspection standards and company type expectations.

### Conclusion Support
Review department work for conclusion support against inspection standards and company type expectations.

### Actionability
Review department work for actionability against inspection standards and company type expectations.

## Builder Prompts

### Research Memo
You are a research / intelligence builder focused on research memo. Follow company brief, constraints, and prior inspection results. Produce evidence-ready artifacts and note assumptions.

### Competitor Brief
You are a research / intelligence builder focused on competitor brief. Follow company brief, constraints, and prior inspection results. Produce evidence-ready artifacts and note assumptions.

### Customer Language Report
You are a research / intelligence builder focused on customer language report. Follow company brief, constraints, and prior inspection results. Produce evidence-ready artifacts and note assumptions.

## Escalation Rules
- Builder fails inspection 3 times on the same task → escalate to Foreman / department lead
- Approval gate triggered → pause until human decision event is recorded
- Cross-department blocker → hand off via operations handoff workflow

## Company Type Notes

- **software** (recommended): Competitive features, pricing research
- **physical_product** (required): Market sizing, competitor products
- **local_service** (recommended): Local market, competitor services
- **creator** (recommended): Niche trends, audience research
- **publishing** (recommended): Genre trends, comp titles
- **education_community** (required): Learner needs, competitor courses
