# Legal / Compliance (Universal Department)

## Purpose

Own contracts, licenses, privacy, terms, regulated claims, warranties, and legal escalation across the company. This department keeps every external-facing promise and internal agreement defensible by maintaining durable templates, classifying legal and compliance risk, and gating any claim, contract, or policy change before it ships.

It is the **risk + governance layer** that prevents the rest of the organization from making promises the company cannot keep, signing obligations it cannot meet, or shipping claims regulators will reject. Where other departments move fast, Legal / Compliance supplies the checkpoints that make speed safe.

This department is not a law firm — it is an operating discipline that turns "should we say this / sign this / store this?" into structured records, inspection verdicts, and human-approval gates before anything irreversible happens.

## Universal responsibilities

- **Maintain terms, privacy, and contract templates**: keep current, version-controlled templates for terms of service, privacy policy, vendor and contractor agreements, NDAs, and warranty language.
- **Classify legal and compliance risks**: tag every claim, contract, and data flow with a risk tier and a defined escalation path.
- **Gate regulated claims and ad compliance**: run the regulated claim review before any external-facing claim, guarantee, or health/safety/financial statement is published.
- **Review IP, license, and employment/contractor risk**: inspect open-source licenses, third-party content, IP ownership, and worker classification before reuse or engagement.
- **Route human/legal escalation when needed**: stop the line and hand off to a human approver or external counsel for anything beyond the department's authority.

## Core workflows

### 1) Regulated claim review

**Inputs**
- the external-facing claim (copy, ad, label, guarantee, certification statement)
- current terms + privacy posture
- jurisdiction and audience (consumer / business / regulated industry)
- prior claim-review records and redlines

**Process (stages)**
- `submit-claim`: intake the claim with source material, intended channel, and target audience.
- `risk-classify`: tag the claim against inspection standards (`claims-check`, `ip-license-check`, `privacy-check`, `contract-risk`) and assign a risk tier.
- `approve-or-revise`: either approve with conditions, request revisions, or escalate to a human gate (`regulated-claim`, `legal-escalation`).
- `log-decision`: write a claim-review-record with decision, rationale, conditions, and review date.

**Outputs (evidence artifacts)**
- claim-review-record (decision + rationale + conditions + review date)
- redlines / revised claim copy returned to the requesting department
- updated legal-checklist entry

## Required capabilities (department-level)

- **legal-compliance**: Contracts, privacy, terms, regulated claims, licenses — the core capability that authorizes this department to draft, review, gate, and log legal artifacts.

## Optional capabilities

- **analytics-reporting**: tracking claim-review throughput, time-to-decision, and recurring risk patterns.
- **research-intelligence**: jurisdictional and regulatory landscape scanning for new markets or product categories.
- **people-contractors**: worker classification and contractor agreement checks (overlaps with the People department).
- **procurement-supply**: vendor and supply-contract review (overlaps with Procurement).
- **marketing**: ad-compliance review against channel and platform rules (overlaps with Marketing).
- **tooling-it**: access control and data-retention enforcement for PII handling.

## Agents and roles (default roster)

- **Compliance Lead**: owns the legal/compliance posture, maintains templates, sets risk tiers, and triggers human escalation gates.
- **Contract Reviewer**: runs contract-risk and ip-license-check inspections on vendor, contractor, and partner agreements; produces redlines and contract checklists.
- **Privacy Officer**: runs privacy-check inspections on data flows, cookie/banner posture, retention, and PII handling; owns privacy policy changes (human-gated).

### Inspectors (quality gates for legal / compliance work)

- **claims-check**: verifies external-facing claims against regulated-language rules and prior claim-review records.
- **ip-license-check**: verifies IP ownership, open-source license compatibility, and third-party content rights.
- **privacy-check**: verifies data collection, retention, and disclosure against the privacy policy and applicable regulation.
- **contract-risk**: verifies contract terms against templates, authority limits, and redline thresholds.

## Human approval gates (universal)

Human approval is required for any action that materially changes the company's legal exposure, obligations, or privacy posture.

- **regulated-claim**: any external claim touching health, safety, financial outcomes, certifications, or regulated industry language.
- **contract-signature**: any binding agreement (vendor, customer, partner, employment/contractor) above authority threshold.
- **privacy-policy-change**: any change to the privacy policy, data retention, or PII handling.
- **legal-escalation**: any matter the department classifies as beyond its authority, including disputes, regulatory contact, or litigation risk.

## Tool manifest (minimal viable set)

This department should be able to operate with a small set of tools that provide durable state and evidence.

- **Work surface**: Paperclip (issues, approvals, claim-review records) or equivalent task tracker
- **Knowledge base**: repo `docs/legal/` (templates, decision log, risk register, claim-review records)
- **Template store**: Notion (or equivalent) for versioned terms, privacy, and contract templates
- **Evidence archive**: file store for signed contracts, redlines, and inspection verdicts

If a company adopts platform-specific tooling, map it here (examples):

- **Docs / templates**: Notion, Google Docs, GitHub
- **E-signature**: DocuSign, HelloSign
- **Compliance tracking**: Vanta, Drata, Secureframe
- **Comms**: Slack, email

## Smoke tests / evidence checks

These are fast checks to prove the department is "alive" and aligned.

- **Terms / privacy checklist started**: a legal-checklist exists covering terms, privacy, and core contract templates.
- **Claim-review record exists**: at least one recent regulated-claim review with decision, rationale, and review date.
- **Templates versioned**: terms, privacy, and contractor agreement templates exist with version markers.
- **Risk classification in use**: active artifacts are tagged with a risk tier and escalation path.
- **Approval gates are explicit**: the four human-approval gates are listed and referenced from claim/contract workflows.
- **Inspector verdicts logged**: recent claims-check / ip-license-check / privacy-check / contract-risk verdicts are archived.

## Cross-company mappings (how Legal / Compliance manifests by company type)

### Software company

- **Primary focus**: SaaS terms, data privacy, OSS license compliance, security and data-handling posture.
- **Key decisions**: terms of service scope, data processing terms, DPA obligations, open-source license selection.
- **KPIs**: claim-review turnaround, contract-review turnaround, open license violations, privacy-gap closures.
- **Extra gates**: regulated-claim before any uptime/SLA or security promise; privacy-policy-change on any new data flow.

### Physical product company

- **Primary focus**: warranties, safety labeling, regulated product claims, and consumer-protection compliance.
- **Key decisions**: warranty terms, safety disclaimer language, labeling claims, returns/liability policy.
- **KPIs**: claim-review turnaround, labeling-compliance pass rate, warranty-claim exposure, recall readiness.
- **Extra gates**: regulated-claim on any health/safety/performance claim; contract-signature on manufacturing agreements.

### Local service company

- **Primary focus**: licensing, liability, local regulations, and subcontractor coverage.
- **Key decisions**: licensing scope, liability disclaimers, insurance requirements, local-ad compliance.
- **KPIs**: license currency, claim-review turnaround, complaint/escalation closure time.
- **Extra gates**: regulated-claim on guaranteed-outcome ads; legal-escalation on liability incidents.

### Creator company

- **Primary focus**: platform terms of service, sponsorship disclosures, and IP ownership of derivative content.
- **Key decisions**: sponsorship disclosure language, platform-policy compliance, music/clip licensing, brand-safety boundaries.
- **KPIs**: disclosure-compliance rate, platform-policy violation count, claim-review turnaround.
- **Extra gates**: regulated-claim on any earnings or results claim in sponsored content.

### Publishing company

- **Primary focus**: copyright, ISBN, and distribution agreements; author/publisher rights.
- **Key decisions**: rights reversion, distribution terms, copyright registration, pen-name/liability language.
- **KPIs**: contract-review turnaround, rights-ownership accuracy, distribution-agreement coverage.
- **Extra gates**: contract-signature on distribution and translation deals; ip-license-check on cover/interior art.

### Education / community company

- **Primary focus**: COPPA/FERPA-adjacent privacy, certification and outcome claims, refund/access policy.
- **Key decisions**: data handling for minors/students, certification claim language, refund policy, accreditation claims.
- **KPIs**: privacy-gap closures, certification-claim pass rate, policy-update turnaround.
- **Extra gates**: regulated-claim on any job-placement or salary outcome claim; privacy-policy-change on new student data flows.

## Foreman integration notes (recommended)

### Stage model for Legal / Compliance tasks

```text
submit-claim → risk-classify → approve-or-revise (human gate as needed) → log-decision
```

For contract and privacy work, mirror the same shape: intake → risk-classify → approve-or-revise (human gate) → log-decision.

### Context packet requirements (legal / compliance runs)

- company-brief (jurisdiction, industry, audience)
- active-task (the claim, contract, or policy change under review)
- role-instructions (which inspector runs first, authority limits)
- relevant-artifacts (current terms/privacy templates, prior claim-review records, redlines)
- constraints (jurisdiction, deadlines, authority thresholds)
- prior-inspection-results (recent claims-check / ip-license-check / privacy-check / contract-risk verdicts)
- human-decisions (outstanding approvals and their owners)
- expected-output-schema (claim-review-record, contract checklist, risk memo, revised template)