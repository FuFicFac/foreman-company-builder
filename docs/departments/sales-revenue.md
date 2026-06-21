# Sales / Revenue (Universal Department)

## Purpose

Handle leads, pipeline, qualification, proposals, pricing presentation, closing, CRM hygiene, and account expansion — converting demand into booked revenue and clean handoffs to delivery and success.

This department is the **revenue execution layer** that turns marketing-sourced and partner-sourced demand into closed deals. It does not set pricing strategy (that is executive), but it presents pricing, prepares proposals, negotiates within approved bounds, and routes any deviation to a human approval gate.

Sales is a continuous pipeline function. Every lead is staged, every deal has a qualification record, every close produces a handoff checklist, and every partnership or referral is tracked so revenue attribution stays clean and expansion is not left to chance.

## Universal responsibilities

- **Lead qualification + staging**: qualify and stage every lead against a defined pipeline schema; no deal advances without a qualification record.
- **Proposals + pricing presentation**: prepare proposals and pricing presentations that reflect approved pricing; route any custom pricing to a human gate.
- **Pipeline + follow-up cadence**: manage pipeline health and follow-up cadence so deals do not go cold or silent.
- **Clean handoffs**: hand off closed deals to delivery and success with a handoff checklist — no deal closes without a documented handoff.
- **Partnerships + referrals**: track partnerships and referrals so attributed revenue is visible and expansion loops are maintained.
- **CRM hygiene**: keep CRM records current so pipeline reporting reflects reality, not optimism.

## Core workflows

### 1) Lead to close

**Trigger**: `new-lead`

**Inputs**
- a new lead (marketing-sourced, partner-sourced, inbound, or outbound)
- approved pricing and packaging
- qualification criteria and pipeline schema
- prior proposal and objection-handling artifacts

**Process (stages)**
1. `lead-intake` — capture the lead in CRM, assign source and owner, confirm contactability.
2. `qualify` — run qualification against defined criteria; advance, park, or disqualify with a reason.
3. `proposal` — prepare proposal and pricing presentation from approved pricing; route custom pricing to a human gate.
4. `negotiate` — handle objections and term discussions within approved bounds; route discounts, custom pricing, and partnership terms to human gates.
5. `close` — finalize terms, capture signature approval, and confirm CRM record completeness.
6. `handoff` — produce the handoff checklist and transfer the account to delivery and success.

**Outputs (evidence artifacts)**
- `crm-record` — staged deal with qualification, owner, and status.
- `proposal` — the proposal and pricing presentation delivered to the prospect.
- `handoff-checklist` — the signed-off handoff to delivery and success.
- supporting builders: `proposal-draft`, `pricing-sheet`, `follow-up-sequence`.

## Required capabilities (department-level)

- **sales-revenue**: leads, pipeline, proposals, closing, CRM, and partnerships — the core capability that converts demand into booked revenue with clean handoffs.

## Optional capabilities

- **Account expansion / upsell** (post-close expansion and renewal management)
- **Channel + partnership sales** (reseller, distributor, and referral program execution)
- **Sales enablement** (battle cards, objection-handling scripts, demo assets)
- **Forecasting + pipeline analytics** (deal-stage probability, cohort conversion)
- **Outbound prospecting** (SDR-led cold outreach and sequence management)
- **Enterprise / custom deal structuring** (complex multi-term and multi-stakeholder deals)

## Agents and roles (default roster)

- **Sales Lead**: owns pipeline health, quota and forecast, pricing-bound enforcement, and cross-department handoffs.
- **Account Executive**: owns deals end-to-end from qualification through close; prepares proposals and runs negotiations within approved bounds.
- **SDR (Sales Development Rep)**: owns lead intake, outbound prospecting, and early-stage qualification; hands qualified leads to account executives.
- **Partnerships Manager**: owns partnership and referral pipelines, partner terms routing, and attributed revenue tracking.

### Inspectors (quality gates for sales work)

- **qualification-check**: verifies every staged deal has a qualification record meeting defined criteria; flags unqualified advances.
- **offer-fit**: checks that proposals and pricing presentations align with approved pricing and the prospect's qualified need.
- **objection-coverage**: flags deals moving to close without documented objection handling.
- **handoff-quality**: verifies every closed deal has a complete handoff checklist before transfer to delivery and success.

## Human approval gates (universal)

Human approval is required for any action that changes pricing, terms, or commitments beyond approved bounds.

- **discount**: any discount beyond the approved discount policy requires human approval.
- **custom-pricing**: any non-standard pricing structure requires human approval before it is presented.
- **partnership-terms**: any partnership or referral terms require human approval before commitment.
- **contract-signature**: final contract signature on any deal requires human approval.

## Tool manifest (minimal viable set)

This department should be able to operate with a small set of tools that provide pipeline state and evidence.

- **CRM / pipeline**: a structured pipeline tool (`linear`, `notion`, or equivalent) with stage definitions and owner fields
- **Knowledge base**: repo `docs/` for proposal templates, qualification criteria, and handoff checklists
- **Work surface**: Paperclip (issues, approvals, follow-ups) or equivalent task tracker
- **Comms**: email and/or messaging for prospect and partner contact

If a company adopts platform-specific tooling, map it here (examples):

- **CRM**: HubSpot, Salesforce, Pipedrive, Attio
- **Pipeline / tasks**: Linear, Jira, Notion
- **Proposals**: PandaDoc, Google Docs, Notion
- **Comms**: Slack, email, Zoom

## Smoke tests / evidence checks

These are fast checks to prove the department is "alive" and aligned.

- **Pipeline stage definitions exist**: a documented pipeline schema with named stages and qualification criteria (`pipeline-schema` artifact).
- **CRM has live deals**: at least one staged deal with an owner and current status in CRM.
- **Qualification records exist**: recent deals have qualification records, not just stage moves.
- **Proposal template exists**: a current proposal template reflecting approved pricing.
- **Handoff checklist exists**: at least one completed handoff checklist for a closed deal.
- **Approval gates are explicit**: "what requires a human" is listed and used for discounts, custom pricing, partnership terms, and signature.

## Cross-company mappings (how Sales / Revenue manifests by company type)

### Software company

- **Primary focus**: B2B pipeline, demos, and enterprise deal management.
- **Key decisions**: qualification criteria, demo scripting, enterprise deal structuring, discount bounds.
- **KPIs**: pipeline coverage, lead-to-close rate, ACV, sales cycle length, discount leakage.
- **Extra gates**: enterprise contract signature; custom pricing for multi-year deals.

### Physical product company

- **Primary focus**: wholesale and retail partnership sales, channel development.
- **Key decisions**: wholesale pricing, retail partner terms, MOQ negotiation, channel conflict policy.
- **KPIs**: wholesale pipeline coverage, partner close rate, sell-through at partner, margin retention.
- **Extra gates**: wholesale discount approval; retail partner contract signature.

### Local service company

- **Primary focus**: estimates, booking conversion, and local B2B account development.
- **Key decisions**: estimate policy, booking flow, local B2B pricing, service-area sales scope.
- **KPIs**: lead-to-book rate, estimate-to-close rate, repeat rate, local B2B pipeline value.
- **Extra gates**: custom estimate approval; local B2B contract signature.

### Creator company

- **Primary focus**: sponsorships and brand deal sales.
- **Key decisions**: sponsorship pricing, brand-fit criteria, deal terms, exclusivity.
- **KPIs**: sponsor close rate, sponsorship revenue, repeat-sponsor rate, deal cycle length.
- **Extra gates**: sponsorship terms approval; exclusivity and brand-alignment approval.

### Publishing company

- **Primary focus**: rights, bulk, and institutional sales.
- **Key decisions**: rights pricing, bulk discount policy, institutional terms, territory deals.
- **KPIs**: rights revenue, bulk deal count, institutional close rate, revenue per title.
- **Extra gates**: rights terms approval; bulk discount approval; institutional contract signature.

### Education / community company

- **Primary focus**: course sales and cohort enrollment.
- **Key decisions**: cohort pricing, enrollment criteria, scholarship policy, group/institutional enrollment terms.
- **KPIs**: enrollment conversion, cohort fill rate, scholarship utilization, institutional enrollment revenue.
- **Extra gates**: scholarship approval; institutional enrollment terms; cohort pricing changes.

## Foreman integration notes (recommended)

### Stage model for Sales / Revenue tasks

```text
lead-intake → qualify → proposal → negotiate → close → handoff
```

### Context packet requirements (sales runs)

- company-brief
- active-task (the lead, deal, or partnership in flight)
- role-instructions
- relevant-artifacts (CRM record, prior proposals, qualification criteria, pricing sheet, handoff checklist)
- constraints (approved pricing, discount policy, authority limits)
- prior-inspection-results (qualification-check, offer-fit, objection-coverage, handoff-quality)
- human-decisions (approval state for discount, custom-pricing, partnership-terms, contract-signature)
- expected-output-schema (crm-record, proposal, handoff-checklist, follow-up-sequence)