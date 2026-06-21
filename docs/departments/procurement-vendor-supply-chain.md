# Procurement / Vendor / Supply Chain (Universal Department)

## Purpose

Manage vendors, suppliers, inventory, manufacturing, shipping, and fulfillment partners. This department owns the supply layer of the company: who builds, stores, moves, and delivers the physical (and some digital) goods and services the company sells, and whether each link in that chain meets cost, quality, and lead-time standards.

It is the **supply + vendor-governance layer** that turns "we need this made / stored / shipped" into evaluated vendors, approved contracts, integrated workflows, and monitored performance. Where other departments specify the offer, Procurement specifies the partners and capacity that make delivery possible.

This department enforces approval gates at every financially or operationally material step — vendor approval, purchase orders, and inventory write-offs — so that spend and supply risk never move without a human checkpoint.

## Universal responsibilities

- **Maintain vendor database**: keep a current, structured vendor record (contact, capability, terms, performance) for every active supplier and partner.
- **Evaluate suppliers against checklist**: run supplier-quality, cost-fit, and lead-time-risk inspections before any vendor is approved.
- **Map inventory and fulfillment capabilities**: track what can be made, stored, and shipped, by whom, on what timeline, at what cost.
- **Enforce procurement approval gates**: gate vendor approval, purchase orders, and inventory write-offs behind human approval.

## Core workflows

### 1) Vendor onboarding

**Inputs**
- a new-vendor trigger (new product, capacity gap, replacement supplier)
- vendor candidate details (capability, capacity, cost, lead time, references)
- evaluation checklist and company constraints (quality floor, cost ceiling, lead-time max)

**Process (stages)**
- `evaluate`: run vendor-evaluation against supplier-quality, cost-fit, and lead-time-risk inspections.
- `approve`: human gate on `vendor-approval`; record decision and conditions.
- `contract`: route to Legal / Compliance for contract-signature; confirm terms and SLAs.
- `integrate`: wire the vendor into inventory, ordering, and fulfillment workflows; produce inventory-report baseline.
- `monitor`: track ongoing performance against the evaluation checklist; flag drift for re-evaluation.

**Outputs (evidence artifacts)**
- vendor-record (capability, terms, performance baseline, approval state)
- evaluation-checklist (supplier-quality, cost-fit, lead-time-risk verdicts + rationale)

## Required capabilities (department-level)

- **procurement-supply**: Vendors, inventory, manufacturing, fulfillment partners — the core capability that authorizes this department to evaluate, approve, contract, integrate, and monitor supply partners.

## Optional capabilities

- **legal-compliance**: contract review and terms negotiation for vendor agreements (overlaps with Legal / Compliance).
- **finance-ops**: purchase-order budgeting, invoice matching, and payment coordination (overlaps with Finance / Ops).
- **quality-inspection**: incoming-goods inspection and vendor-quality arbitration (overlaps with Quality / Foreman Inspection).
- **analytics-reporting**: vendor performance dashboards, spend analysis, and lead-time trends.
- **research-intelligence**: supplier market scanning and alternative-source identification.
- **people-contractors**: contractor vs vendor classification and engagement boundary checks.

## Agents and roles (default roster)

- **Procurement Lead**: owns the vendor portfolio, approval gates, and supply strategy; sets evaluation thresholds.
- **Vendor Manager**: runs the vendor-onboard workflow — evaluation, contracting coordination, integration, and monitoring.
- **Inventory Coordinator**: maps inventory and fulfillment capabilities, produces inventory reports, and flags capacity gaps.

### Inspectors (quality gates for procurement / vendor / supply chain work)

- **supplier-quality**: verifies the vendor can meet the company's quality floor and spec compliance.
- **cost-fit**: verifies vendor pricing fits the cost ceiling and unit-economics constraints.
- **lead-time-risk**: verifies the vendor's lead time fits the fulfillment schedule and flags concentration / single-source risk.

## Human approval gates (universal)

Human approval is required for any action that materially changes the company's spend, supply exposure, or inventory position.

- **vendor-approval**: confirming a new vendor after evaluation passes.
- **purchase-order**: any PO above the defined threshold.
- **inventory-writeoff**: writing off, disposing of, or deeply discounting inventory.

## Tool manifest (minimal viable set)

This department should be able to operate with a small set of tools that provide durable state and evidence.

- **Work surface**: Notion (vendor database, POs, evaluation checklists, inventory reports) or equivalent
- **Knowledge base**: repo `docs/procurement/` (vendor-record template, evaluation checklist, inventory-report template)
- **Spreadsheet**: unit economics, cost-fit models, lead-time tracking
- **Contract coordination**: integration with Legal / Compliance for vendor contracts

If a company adopts platform-specific tooling, map it here (examples):

- **Procurement / inventory**: Notion, Airtable, NetSuite, Cin7
- **3PL / fulfillment**: ShipBob, ShipMonk, Fulfillment by Amazon
- **Comms**: Slack, email
- **Analytics**: custom dashboards, spreadsheets

## Smoke tests / evidence checks

These are fast checks to prove the department is "alive" and aligned.

- **Vendor schema defined**: a vendor database schema exists and is in use.
- **Vendor-record exists**: at least one active vendor-record with capability, terms, and approval state.
- **Evaluation checklist used**: at least one completed evaluation-checklist with supplier-quality, cost-fit, and lead-time-risk verdicts.
- **Inventory report exists**: a current inventory-report mapping active inventory and fulfillment capabilities.
- **Approval gates are explicit**: vendor-approval, purchase-order, and inventory-writeoff gates are listed and used.
- **Monitoring in place**: active vendors have performance tracking against the evaluation checklist.

## Cross-company mappings (how Procurement / Vendor / Supply Chain manifests by company type)

### Software company

- **Primary focus**: SaaS vendors and cloud spend management.
- **Key decisions**: vendor consolidation, cloud cost tiers, data-residency vendor selection.
- **KPIs**: vendor spend, cloud unit cost, vendor uptime/SLA compliance, cost-fit pass rate.
- **Extra gates**: vendor-approval on data-handling vendors; purchase-order on annual cloud commitments.

### Physical product company

- **Primary focus**: manufacturing, packaging, and 3PL / fulfillment partners.
- **Key decisions**: manufacturer selection, MOQ/lead-time trade-offs, 3PL selection, packaging vendors.
- **KPIs**: on-time delivery, defect rate, unit cost, inventory turnover, vendor-quality pass rate.
- **Extra gates**: vendor-approval on manufacturers; purchase-order on production runs; inventory-writeoff on dead stock.

### Local service company

- **Primary focus**: supplies and subcontractors for field service delivery.
- **Key decisions**: supply source, subcontractor vs in-house, bulk vs just-in-time purchasing.
- **KPIs**: supply availability, subcontractor cost-fit, on-time service delivery, supply-quality pass rate.
- **Extra gates**: vendor-approval on subcontractors; purchase-order on bulk supply buys.

### Creator company

- **Primary focus**: merch fulfillment and production vendors for creator-branded products.
- **Key decisions**: print-on-demand vs inventory, fulfillment partner, merch vendor quality.
- **KPIs**: fulfillment on-time rate, merch defect rate, cost-fit pass rate, reorder readiness.
- **Extra gates**: vendor-approval on merch partners; purchase-order on inventory merch runs.

### Publishing company

- **Primary focus**: print vendors and distribution partners.
- **Key decisions**: print-on-demand vs offset, distributor selection, warehousing, returns handling.
- **KPIs**: print on-time rate, distribution coverage, defect rate, cost-fit pass rate, returns rate.
- **Extra gates**: vendor-approval on print/distribution partners; purchase-order on print runs.

### Education / community company

- **Primary focus**: course-platform vendors and community-tooling partners.
- **Key decisions**: platform vendor selection, community hosting, integration vendors.
- **KPIs**: platform uptime, vendor cost-fit, integration reliability, vendor-quality pass rate.
- **Extra gates**: vendor-approval on platforms handling learner data; purchase-order on annual platform contracts.

## Foreman integration notes (recommended)

### Stage model for Procurement / Vendor / Supply Chain tasks

```text
evaluate → approve (human gate) → contract → integrate → monitor
```
**Loop mode**: `lean` — standard execution loop with inspection gates at workflow stage boundaries.

For purchase-order and inventory work, mirror the same shape: evaluate need → approve PO (human gate) → place order → receive/inspect → log.

### Context packet requirements (procurement runs)

- company-brief (product, supply posture, spend thresholds)
- active-task (the vendor, PO, or inventory decision under work)
- role-instructions (which inspector runs: supplier-quality, cost-fit, lead-time-risk)
- relevant-artifacts (vendor database, evaluation checklist, inventory report, current contracts)
- constraints (cost ceiling, lead-time max, quality floor, budget)
- prior-inspection-results (recent supplier-quality / cost-fit / lead-time-risk verdicts)
- human-decisions (outstanding approvals: vendor-approval, purchase-order, inventory-writeoff)
- expected-output-schema (vendor-record, evaluation-checklist, inventory-report, purchase-order)