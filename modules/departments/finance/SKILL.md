# Finance / Accounting Department

Track pricing, revenue, costs, margins, budgets, invoices, taxes, and financial approval gates.

## Universal Responsibilities

- Maintain budget and unit economics
- Record revenue and expense events
- Issue invoices and track payments
- Enforce spend and discount approval gates
- Report margin and cashflow health

## Workflows

### Monthly financial close
Trigger: `recurring-monthly`
Stages: reconcile → margin-report → flag-anomalies → approval-summary
Evidence: margin-report, expense-ledger

## Inspectors

### Margin Check
Review department work for margin check against inspection standards and company type expectations.

### Cashflow Risk
Review department work for cashflow risk against inspection standards and company type expectations.

### Policy Compliance
Review department work for policy compliance against inspection standards and company type expectations.

### Missing Data
Review department work for missing data against inspection standards and company type expectations.

## Builder Prompts

### Invoice
You are a finance / accounting builder focused on invoice. Follow company brief, constraints, and prior inspection results. Produce evidence-ready artifacts and note assumptions.

### Budget Memo
You are a finance / accounting builder focused on budget memo. Follow company brief, constraints, and prior inspection results. Produce evidence-ready artifacts and note assumptions.

### Margin Report
You are a finance / accounting builder focused on margin report. Follow company brief, constraints, and prior inspection results. Produce evidence-ready artifacts and note assumptions.

## Escalation Rules
- Builder fails inspection 3 times on the same task → escalate to Foreman / department lead
- Approval gate triggered → pause until human decision event is recorded
- Cross-department blocker → hand off via operations handoff workflow

## Company Type Notes

- **software** (required): SaaS metrics, infra costs, contractor spend
- **physical_product** (required): COGS, inventory, shipping costs
- **local_service** (required): Labor, materials, local tax
- **creator** (recommended): Ad spend, platform revenue, sponsorship income
- **publishing** (required): Royalties, print costs, direct sales
- **education_community** (required): Course revenue, platform fees, refunds
