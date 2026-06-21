# Finance / Accounting (Universal Department)

## Purpose

Track the money: pricing, revenue, costs, margins, budgets, invoices, taxes, and the financial approval gates that keep the company solvent and honest.

This department is the **money + controls layer** that turns commercial activity into accurate records, protects cash flow, and enforces the spend and discount gates that prevent margin erosion.

Finance owns the monthly close, unit economics, invoice and payment tracking, and the approval gates for anything that moves money out of the company or changes a customer's commercial terms.

## Universal responsibilities

- **Maintain budget and unit economics**: keep the budget current, track unit economics per product/service, and surface margin drift early.
- **Record revenue and expense events**: capture every revenue and expense event in a durable ledger tied to source systems.
- **Issue invoices and track payments**: generate invoices on time, track payment status, and chase overdue accounts.
- **Enforce spend and discount approval gates**: block any spend, discount, or refund that exceeds auto-approve thresholds until a human signs off.
- **Report margin and cashflow health**: produce the monthly margin report and flag cashflow risk before it becomes a crisis.

## Core workflows

### 1) Monthly financial close

**Inputs**
- prior month's ledger and margin report
- revenue and expense feeds from sales, ops, and payroll systems
- budget and pricing assumptions
- open invoices and payment status

**Process (stages: reconcile → margin-report → flag-anomalies → approval-summary)**
- **reconcile**: match all feeds to the ledger; resolve discrepancies and missing data
- **margin-report**: compute gross and contribution margins by product/service and channel
- **flag-anomalies**: run margin-check, cashflow-risk, policy-compliance, and missing-data inspectors; surface anomalies
- **approval-summary**: summarize all spend, discount, refund, payroll, and tax items that require human approval

**Outputs (evidence artifacts)**
- `margin-report` (margins by product/service/channel vs budget)
- `expense-ledger` (reconciled revenue and expense events)

## Required capabilities (department-level)

- **finance-accounting**: pricing, revenue, costs, budgets, invoices, and unit economics — the end-to-end ability to record, reconcile, report, and gate the company's money.

## Optional capabilities

- **Cashflow forecasting** (rolling 13-week and scenario views)
- **Tax compliance management** (sales tax, VAT, income tax filings)
- **Procurement / accounts payable** (vendor management and payment runs)
- **Pricing strategy and margin modeling** (price elasticity and tier design)
- **Investor / board reporting** (KPI packs and narrative updates)
- **Multi-currency / multi-entity accounting** (consolidation and transfer pricing)

## Agents and roles (default roster)

- **Finance Lead**: owns the close, budget, approval gates, and financial reporting cadence.
- **Bookkeeper**: records revenue and expense events, reconciles feeds, issues and tracks invoices.
- **Pricing Analyst**: maintains unit economics, models pricing and margin scenarios, flags margin drift.

### Inspectors (quality gates for finance work)

- **margin-check inspector**: flags products, services, or channels whose margin has drifted below threshold or budget.
- **cashflow-risk inspector**: flags cash positions, burn rates, or receivable aging that threaten solvency.
- **policy-compliance inspector**: flags spend, discounts, refunds, payroll, or tax actions that violate policy or lack approval.
- **missing-data inspector**: flags ledger gaps, unreconciled feeds, or incomplete invoice records that block a clean close.

## Human approval gates (universal)

Human approval is required for any action that moves money out of the company or changes a customer's or employee's financial terms.

- **Spend**: any spend above the auto-approve threshold.
- **Discount**: discounts beyond the published policy.
- **Refund**: refunds outside auto-approve rules.
- **Payroll**: payroll runs and compensation changes.
- **Tax filing**: submitting tax filings and regulatory financial reports.
- **Irreversible financial actions** (write-offs, account closures, vendor termination with penalty)

## Tool manifest (minimal viable set)

This department should be able to operate with a small set of tools that provide durable state and evidence.

- **Work surface**: Paperclip (approvals, invoices, close tasks) or equivalent tracker
- **Knowledge base**: repo `docs/` (budget policy, pricing assumptions, close checklist)
- **Numbers**: accounting system or spreadsheet ledger for revenue, expenses, and reconciliation
- **Payments**: at least one payment processor connected to sales channels

If a company adopts platform-specific tooling, map it here (examples):

- **Payments / commerce**: stripe, shopify, gumroad
- **Accounting**: QuickBooks, Xero, Wave
- **Docs**: Notion, Google Docs

## Smoke tests / evidence checks

These are fast checks to prove the department is "alive" and aligned.

- **Budget policy exists**: a `budget-policy` schema is defined with thresholds and approvers.
- **Monthly close ran**: at least one `margin-report` + `expense-ledger` from the current cycle.
- **Invoice log exists**: issued invoices are tracked with status (paid/overdue).
- **Approval gates are explicit**: the list of what requires a human (spend, discount, refund, payroll, tax-filing) is documented and used.
- **Unit economics exist**: each product/service has a current margin estimate.
- **Cashflow signal exists**: a current cash position or burn-rate indicator is available.

## Cross-company mappings (how Finance / Accounting manifests by company type)

### Software company

- **Primary focus**: SaaS metrics, infra costs, contractor spend — subscription economics and burn.
- **Key decisions**: pricing tiers, infra cost limits, contractor approval thresholds, revenue recognition.
- **KPIs**: MRR, gross margin, burn rate, CAC payback, NRR, cash runway.
- **Extra gates**: infra spend above threshold; contractor and vendor agreements; revenue recognition policy.

### Physical product company

- **Primary focus**: COGS, inventory, shipping costs — unit economics and cash conversion.
- **Key decisions**: vendor payment terms, inventory purchase approvals, shipping cost thresholds, margin floors.
- **KPIs**: gross margin, COGS %, inventory turns, cash conversion cycle, return cost.
- **Extra gates**: purchase orders above threshold; vendor agreements; freight and duty spend.

### Local service company

- **Primary focus**: labor, materials, local tax — service-delivery cost control.
- **Key decisions**: labor cost limits, material spend thresholds, pricing by service, local tax handling.
- **KPIs**: gross margin per job, labor utilization, material cost %, cash position.
- **Extra gates**: payroll and contractor pay; material purchase approvals; local tax filings.

### Creator company

- **Primary focus**: ad spend, platform revenue, sponsorship income — creator economics and spend discipline.
- **Key decisions**: ad-spend thresholds, sponsorship pricing, platform payout timing, production cost limits.
- **KPIs**: net revenue, ad ROAS, sponsorship revenue, production cost %, cash position.
- **Extra gates**: ad-spend approvals; sponsorship contract terms; production spend above threshold.

### Publishing company

- **Primary focus**: royalties, print costs, direct sales — catalog-level margin and cash management.
- **Key decisions**: print run approvals, royalty splits, ad-spend thresholds, direct-vs-platform margin.
- **KPIs**: gross margin per title, royalty cost %, print cost %, sell-through, cash position.
- **Extra gates**: print run spend; royalty and rights payments; ad-spend approvals.

### Education / community company

- **Primary focus**: course revenue, platform fees, refunds — learning-product economics.
- **Key decisions**: course pricing, platform-fee tolerance, refund policy thresholds, instructor pay.
- **KPIs**: course margin, refund rate, platform-fee %, instructor cost %, cash position.
- **Extra gates**: instructor and partner pay; refund approvals; platform and tooling spend.

## Foreman integration notes (recommended)

### Stage model for Finance / Accounting tasks

```text
reconcile → margin-report → flag-anomalies → approval-summary
```

> Finance runs in **deluxe** (high-stakes) loop mode: the close is pause/resume-capable, and every approval item is a human-decision event before the close can finalize.

### Context packet requirements (finance runs)

- company-brief (company type, model, pricing, budget policy)
- active-task (which close, invoice, or approval batch is being worked)
- role-instructions (finance lead vs bookkeeper vs pricing analyst)
- relevant-artifacts (prior `margin-report`, `expense-ledger`, budget, invoice log)
- constraints (approval thresholds, tax deadlines, cash position, accounting policy)
- prior-inspection-results (last margin-check, cashflow-risk, policy-compliance, missing-data outcomes)
- human-decisions (approved spend, discounts, refunds, payroll, tax-filing items)
- expected-output-schema (`margin-report`, `expense-ledger`, `invoice`, or `budget-memo`)