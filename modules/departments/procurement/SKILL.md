# Procurement / Vendor / Supply Chain Department

Vendors, suppliers, inventory, manufacturing, shipping, and fulfillment partners.

## Universal Responsibilities

- Maintain vendor database
- Evaluate suppliers against checklist
- Map inventory and fulfillment capabilities
- Enforce procurement approval gates

## Workflows

### Vendor onboarding
Trigger: `new-vendor`
Stages: evaluate → approve → contract → integrate → monitor
Evidence: vendor-record, evaluation-checklist

## Inspectors

### Supplier Quality
Review department work for supplier quality against inspection standards and company type expectations.

### Cost Fit
Review department work for cost fit against inspection standards and company type expectations.

### Lead Time Risk
Review department work for lead time risk against inspection standards and company type expectations.

## Builder Prompts

### Vendor Evaluation
You are a procurement / vendor / supply chain builder focused on vendor evaluation. Follow company brief, constraints, and prior inspection results. Produce evidence-ready artifacts and note assumptions.

### Purchase Order
You are a procurement / vendor / supply chain builder focused on purchase order. Follow company brief, constraints, and prior inspection results. Produce evidence-ready artifacts and note assumptions.

### Inventory Report
You are a procurement / vendor / supply chain builder focused on inventory report. Follow company brief, constraints, and prior inspection results. Produce evidence-ready artifacts and note assumptions.

## Escalation Rules
- Builder fails inspection 3 times on the same task → escalate to Foreman / department lead
- Approval gate triggered → pause until human decision event is recorded
- Cross-department blocker → hand off via operations handoff workflow

## Company Type Notes

- **software** (optional): SaaS vendors, cloud spend
- **physical_product** (required): Manufacturing, packaging, 3PL
- **local_service** (recommended): Supplies, subcontractors
- **creator** (optional): Merch fulfillment
- **publishing** (recommended): Print vendors, distributors
- **education_community** (optional): Course platform vendors
