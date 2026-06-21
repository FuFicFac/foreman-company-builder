# Risk / Insurance / Business Continuity (Universal Department)

## Purpose

Own the company's operational, platform, and financial risk posture: maintain the risk register, classify risks, document continuity and backup checklists, and route insurance and continuity escalations to the right human decision points.

This department is the **risk + continuity layer** that makes sure the company can see, classify, and respond to threats before they become incidents — and recover quickly when they do. It does not own every risk action, but it owns the register, the classification standard, and the escalation routing.

Risk/continuity is a recurring function, not a one-time audit. It runs on a monthly review cadence and feeds executive prioritization, finance planning, and operational readiness decisions with a current, classified view of what could go wrong and what is being done about it.

## Universal responsibilities

- **Risk register maintenance**: maintain a living risk register with owners, severity, mitigations, and review dates.
- **Risk classification**: classify every risk red / yellow / green using a consistent severity standard, not ad-hoc judgment.
- **Continuity + backup checklists**: document and verify continuity plans and backup checklists so recovery is rehearsed, not improvised.
- **Escalation routing**: route insurance, continuity-activation, and risk-acceptance decisions to the correct human approval gate.
- **Cross-department risk visibility**: ensure executive, ops, finance, legal, and tooling/IT are working from the same classified risk picture.
- **Continuity readiness**: keep continuity plans testable and ensure backups are verified, not just documented.

## Core workflows

### 1) Monthly risk review

**Trigger**: `recurring-monthly`

**Inputs**
- current risk register
- recent incidents, escalations, and near-misses
- changes in operations, platform dependencies, vendors, or staffing
- prior risk report and mitigation status

**Process (stages)**
1. `scan-risks` — survey the organization for new and changed risks across ops, platform, finance, and supply.
2. `classify` — score each risk red / yellow / green against the classification standard; confirm or update severity.
3. `mitigate` — assign or update mitigations, owners, and review dates; escalate red risks to approval gates.
4. `report` — publish the risk report and updated register to executive and department leads.

**Outputs (evidence artifacts)**
- `risk-register` — updated register with classifications, owners, and mitigations.
- `risk-report` — monthly summary of new, changed, and resolved risks plus open red items.
- supporting builders: `risk-register-entry`, `continuity-plan`, `insurance-memo`.

## Required capabilities (department-level)

- **risk-continuity**: risk register, insurance, and business continuity — the core capability that keeps the company's risk picture classified, owned, and recoverable.

## Optional capabilities

- **Insurance portfolio management** (policy selection, renewal tracking, claims routing)
- **Vendor / supply-chain risk** (concentration, dependency, and counterparty risk)
- **Platform dependency risk** (deplatforming, API changes, outage exposure)
- **Crisis communications readiness** (pre-drafted response templates and owner assignments)
- **Compliance risk tracking** (regulatory exposure and audit-readiness)
- **Financial risk modeling** (cash flow, FX, credit exposure)

## Agents and roles (default roster)

- **Risk Lead**: owns the risk register, classification standard, monthly review cadence, and escalation routing.
- **Continuity Owner**: owns continuity plans, backup checklists, and recovery verification; ensures plans are testable, not theoretical.

### Inspectors (quality gates for risk-continuity work)

- **risk-classification**: verifies every risk is classified red / yellow / green against the standard; flags unclassified or inconsistent ratings.
- **mitigation-coverage**: checks that red and yellow risks have assigned mitigations, owners, and review dates; flags gaps.
- **backup-verification**: confirms backups and continuity checklists are present, current, and verified — not just documented.

## Human approval gates (universal)

Human approval is required for any action that commits the company to a risk, insurance, or recovery position.

- **insurance-purchase**: any new or renewed insurance policy requires human approval before binding.
- **continuity-activation**: activating a continuity plan (failover, disaster recovery, alternate operations) requires human decision.
- **risk-acceptance**: formally accepting a red or high-impact risk (instead of mitigating) requires human sign-off.

## Tool manifest (minimal viable set)

This department should be able to operate with a small set of tools that provide durable state and evidence.

- **Risk register**: structured document or database (`notion` or equivalent) with classification, owner, mitigation, and review-date fields
- **Knowledge base**: repo `docs/` for continuity plans, backup checklists, and insurance memos
- **Work surface**: Paperclip (issues, escalations, approvals) or equivalent task tracker
- **Calendar**: monthly review cadence with reminder triggers

If a company adopts platform-specific tooling, map it here (examples):

- **Risk register**: Notion, Airtable, Jira, Google Sheets
- **Docs**: Notion, Google Docs, Confluence
- **Comms**: Slack, email
- **Backup verification**: cloud provider dashboards, backup tool reports

## Smoke tests / evidence checks

These are fast checks to prove the department is "alive" and aligned.

- **Risk register initialized**: a risk register exists with at least the current top risks (`risk-register` artifact).
- **Classification standard exists**: a documented red / yellow / green classification rubric is in use.
- **Monthly review ran**: a risk report from the most recent month exists with new, changed, and resolved risks.
- **Red risks have owners**: every red risk has a named owner, mitigation, and review date.
- **Continuity plan exists**: at least one continuity plan and backup checklist are documented and dated.
- **Backups verified**: a backup-verification record exists showing the most recent check, not just a checklist.

## Cross-company mappings (how Risk / Insurance / Business Continuity manifests by company type)

### Software company

- **Primary focus**: platform dependency risk, security incidents, outage and data-loss exposure.
- **Key decisions**: incident response posture, backup/restore policy, vendor and cloud dependency acceptance.
- **KPIs**: time-to-detect, time-to-restore, red-risk count, backup verification pass rate.
- **Extra gates**: security incident escalation; production data handling and deletion approvals.

### Physical product company

- **Primary focus**: supply chain risk, liability exposure, product recall readiness, and vendor concentration.
- **Key decisions**: vendor risk thresholds, recall plan, insurance coverage levels, liability acceptance.
- **KPIs**: supplier risk distribution, recall readiness, liability claim rate, insurance coverage ratio.
- **Extra gates**: product recall activation; vendor termination; safety/liability insurance purchase.

### Local service company

- **Primary focus**: liability, weather and staffing disruption, and continuity of service delivery.
- **Key decisions**: liability insurance levels, staffing contingency, weather cancellation policy, backup routing.
- **KPIs**: service disruption incidents, staffing continuity rate, liability claim rate, insurance coverage ratio.
- **Extra gates**: liability claim escalation; continuity plan activation for weather or staffing loss.

### Creator company

- **Primary focus**: platform deplatforming, demonetization, and platform-policy risk.
- **Key decisions**: platform diversification, backup channel strategy, demonetization contingency.
- **KPIs**: platform dependency ratio, demonetization incidents, backup-channel readiness.
- **Extra gates**: platform exit or diversification decision; content takedown response.

### Publishing company

- **Primary focus**: platform policy risk, print partner risk, and distribution dependency.
- **Key decisions**: platform diversification, print partner backup, distribution channel risk acceptance.
- **KPIs**: platform/vendor dependency ratio, print partner disruption incidents, distribution continuity readiness.
- **Extra gates**: print partner change; platform policy response; distribution channel exit.

### Education / community company

- **Primary focus**: data breach risk, platform outage exposure, and learner-data handling.
- **Key decisions**: data handling policy, platform backup, community moderation crisis plan.
- **KPIs**: breach incidents, platform outage recovery time, data-handling audit pass rate.
- **Extra gates**: data breach response activation; platform migration; moderation crisis escalation.

## Foreman integration notes (recommended)

### Stage model for Risk / Insurance / Business Continuity tasks

```text
scan-risks → classify → mitigate → report
```

### Context packet requirements (risk-continuity runs)

- company-brief
- active-task (the risk review or escalation in flight)
- role-instructions
- relevant-artifacts (current risk register, prior risk reports, continuity plans, insurance memos)
- constraints (budget, authority limits, review cadence)
- prior-inspection-results (risk-classification, mitigation-coverage, backup-verification)
- human-decisions (approval state for insurance-purchase, continuity-activation, risk-acceptance)
- expected-output-schema (risk-register-entry, continuity-plan, insurance-memo, risk-report)