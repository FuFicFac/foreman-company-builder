# Tooling / IT / Security Department

Accounts, tools, integrations, credentials, environments, automations, access control, and smoke tests.

## Universal Responsibilities

- Maintain company tool manifest
- Process credential and access requests
- Run tool readiness and integration health checks
- Enforce access scope and backup policies
- Own shared tool manifest standard for all departments

## Workflows

### Tool onboarding
Trigger: `new-tool-request`
Stages: request → approve → install → smoke-test → document
Evidence: tool-manifest-entry, smoke-test-result

## Inspectors

### Tool Readiness
Review department work for tool readiness against inspection standards and company type expectations.

### Security Scope
Review department work for security scope against inspection standards and company type expectations.

### Access Scope
Review department work for access scope against inspection standards and company type expectations.

### Integration Health
Review department work for integration health against inspection standards and company type expectations.

## Builder Prompts

### Access Request
You are a tooling / it / security builder focused on access request. Follow company brief, constraints, and prior inspection results. Produce evidence-ready artifacts and note assumptions.

### Integration Setup
You are a tooling / it / security builder focused on integration setup. Follow company brief, constraints, and prior inspection results. Produce evidence-ready artifacts and note assumptions.

### Backup Checklist
You are a tooling / it / security builder focused on backup checklist. Follow company brief, constraints, and prior inspection results. Produce evidence-ready artifacts and note assumptions.

## Escalation Rules
- Builder fails inspection 3 times on the same task → escalate to Foreman / department lead
- Approval gate triggered → pause until human decision event is recorded
- Cross-department blocker → hand off via operations handoff workflow

## Company Type Notes

- **software** (required): Repos, CI, cloud, secrets
- **physical_product** (recommended): E-commerce, inventory systems
- **local_service** (recommended): Booking, payments, comms
- **creator** (required): Platform APIs, analytics, asset storage
- **publishing** (required): Storefront, email, export tools
- **education_community** (required): LMS, community platform, payments
