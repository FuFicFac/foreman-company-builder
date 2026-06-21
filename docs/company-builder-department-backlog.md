# Foreman Company Builder — universal department backlog

Purpose: turn Foreman Company Builder from a domain-template tool into a universal company-builder that can compose any company from departments, capabilities, tools, roles, inspectors, and approval gates.

Status: draft backlog for Paperclip issue creation. **Synthesis complete** — see [department-module-schema.md](department-module-schema.md) and `modules/departments/catalog.json` (FOR-18).

## North-star architecture

```text
Company = template + departments + capabilities + tools + roles + inspectors + evidence + approvals
```

Templates describe the business type. Departments describe reusable company functions. Capabilities describe what the company can actually do. Tools attach execution surfaces. Inspectors define quality checks. Approval gates define what requires a human.

## Universal departments

### 1. Executive / Strategy
Research and define mission, business model, goals, decision rights, escalation policy, and company operating cadence.

Paperclip card deliverables:
- `departments/executive/module.json`
- `departments/executive/SKILL.md`
- standard artifacts: mission, priorities, decision log, weekly plan, escalation rules
- inspectors: strategic-fit, risk, prioritization

### 2. Product / Service Delivery
Define how the company creates the thing it sells, whether software, service, product, content, course, publishing, or local work.

Deliverables:
- product/service intake schema
- delivery stages
- acceptance/evidence rules
- role templates for builder/operator/producer
- inspectors for quality and customer promise fit

### 3. Operations / SOPs
Turn repeated work into procedures, checklists, schedules, handoffs, vendor coordination, fulfillment flows, and repair loops.

Deliverables:
- SOP template
- operations runbook
- recurring task model
- handoff checklist
- blocked-work escalation rules

### 4. Marketing
Seed/resource base: Corey Haines `coreyhaines31/marketingskills`, pulled under `Builder/Foreman Company Builder/Resources/marketingskills`.

Deliverables:
- marketing department module composed from market research, positioning, SEO, copy, email, social, ads, launch, CRO, analytics
- map external marketing skills into FCB-compatible capabilities
- inspectors: brand, clarity, conversion, compliance, channel-fit

### 5. Sales / Revenue
Handle leads, pipeline, qualification, proposals, pricing presentation, closing, CRM, partnerships, referrals, and account expansion.

Deliverables:
- sales department module
- lead/prospect schema
- pipeline stages
- offer/proposal templates
- CRM/tool manifest
- inspectors: qualification, offer-fit, objection coverage, handoff quality

### 6. Customer Success / Support
Handle onboarding, support, retention, feedback, refunds, complaints, customer education, and renewal/repeat purchase flows.

Deliverables:
- support module
- customer state model
- ticket/intake schema
- onboarding checklist
- refund/escalation policy
- inspectors: response quality, SLA/risk, retention opportunity

### 7. Finance / Accounting
Track pricing, revenue, costs, margins, budgets, invoices, taxes, payroll/contractor costs, unit economics, and financial approval gates.

Deliverables:
- finance department module
- budget policy schema
- revenue/expense event schema
- invoice/payment tool manifest
- approval gates for spend, discounting, refunds, payroll, taxes
- inspectors: margin, cashflow, policy, missing data

### 8. Legal / Compliance
Handle contracts, licenses, privacy, terms, regulated claims, warranties, employment/contractor risk, ad/platform compliance, and human/legal escalation.

Deliverables:
- legal/compliance module
- legal-risk taxonomy
- terms/privacy/contract checklist
- regulated-claims approval gate
- inspectors: claims, IP/license, privacy, contract-risk

### 9. People / Contractors
Manage role definitions, hiring briefs, onboarding, contractor packets, deliverable review, performance notes, payment coordination, and offboarding.

Deliverables:
- people/contractor module
- role profile schema
- hiring/onboarding checklist
- contractor brief template
- review/offboarding checklist
- inspectors: role clarity, deliverable quality, access/security

### 10. Analytics / Reporting
Define KPIs, dashboards, experiment readouts, weekly/monthly reports, funnel metrics, revenue metrics, operational metrics, and evidence capture.

Deliverables:
- analytics department module
- KPI schema
- report templates
- dashboard/tool manifest
- experiment analysis protocol
- inspectors: data quality, conclusion validity, next-action clarity

### 11. Tooling / IT / Security
Manage accounts, tools, integrations, credentials, environments, automations, access control, backups, and smoke tests.

Deliverables:
- tooling/IT module
- tool manifest standard shared by all departments
- credential/access request flow
- smoke-test protocol
- backup/recovery checklist
- inspectors: tool readiness, security, access scope, integration health

### 12. Quality / Foreman Inspection
The core Foreman discipline layer: builder → inspector → Foreman arbitration → fix loop → final verification → evidence.

Deliverables:
- reusable QA module
- inspector routing rules
- evidence standards
- three-strike escalation
- closeout/sweep procedures
- health warning classification rules

## Additional cross-company sections worth adding

### 13. Research / Intelligence
A standing research function is needed before strategy, product, marketing, and sales can make good decisions.

Deliverables:
- market research protocol
- competitor research protocol
- customer-language mining
- source-quality scoring
- synthesis memo template

### 14. Procurement / Vendor / Supply Chain
Needed for physical products, local services, publishing vendors, contractors, inventory, shipping, manufacturing, and fulfillment.

Deliverables:
- vendor database schema
- supplier evaluation checklist
- inventory/fulfillment capability mapping
- procurement approval gates

### 15. Distribution / Channel Management
Separate from marketing: where/how the company gets the product into customer hands.

Deliverables:
- channel strategy template
- marketplace/platform checklist
- partner/channel manager role
- distribution tool manifest

### 16. Risk / Insurance / Business Continuity
Useful for real-world businesses: operational risk, platform risk, financial risk, insurance needs, backups, continuity plans.

Deliverables:
- risk register
- continuity checklist
- insurance/escalation note templates
- red/yellow/green risk reports

### 17. Knowledge / Documentation
Every company needs a living source of truth: SOPs, decisions, customer insights, product facts, tool docs, and runbooks.

Deliverables:
- company wiki structure
- decision log
- SOP library
- artifact index
- documentation freshness check

## Paperclip implementation sequence

1. Create parent issue: `FCB Universal Company Departments`
2. Create one research child issue per department above.
3. Each research issue must produce:
   - department purpose
   - universal responsibilities
   - common workflows
   - required/optional capabilities
   - roles/builders/inspectors
   - approval gates
   - tool manifest
   - smoke tests / evidence checks
   - example mapping for software, physical product, local service, creator, publishing, and education businesses
4. After research, create implementation issues to add `departments/<name>/module.json` and `departments/<name>/SKILL.md`.
5. Update onboarding so custom companies compose departments instead of defaulting to `software`.
6. Final verification gate: after research and implementation complete, use GPT-5.5 to inspect the repo, run `npm test`, and triage/fix-loop any failures until green.

## Model routing note

- Cursor implementation/research lanes should use **Composer 2.5** (`composer-2.5`), not Composer 2.
- The GLM research lane should use **Ollama GLM 5.2** (`glm-5.2:cloud`) through a Paperclip process adapter, not Cursor's model list.
- GPT-5.5 is the final verifier/triage model after the swarm completes its first pass.

## Immediate blocker

Paperclip CLI is installed (`paperclipai` version `2026.618.0`), but the API was not reachable at `http://localhost:3100` when checked. Start Paperclip before creating live cards:

```bash
npm exec --yes paperclipai -- run
# then verify
npm exec --yes paperclipai -- health
```
