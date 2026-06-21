# Tooling / IT / Security (Universal Department)

## Purpose

Own the company's tool manifest, accounts, integrations, credentials, environments, automations, access control, and smoke tests — the shared infrastructure every other department runs on.

This department is the **tooling + access layer** that keeps the company's working surface coherent: the right tools exist, they are approved, credentials are scoped, integrations are healthy, and readiness is verified before any department depends on a tool.

Tooling/IT is not optional plumbing. It owns the shared tool-manifest standard for all departments, enforces access scope and backup policies, and runs readiness and integration-health checks so that when a department says "we need tool X," the path from request to documented, smoke-tested, access-scoped tooling is explicit and auditable.

## Universal responsibilities

- **Company tool manifest**: maintain the authoritative tool manifest that every department references; no tool is "in use" unless it is in the manifest.
- **Credential + access requests**: process credential and access requests through a defined workflow with human approval gates for sensitive grants.
- **Tool readiness + integration health**: run readiness checks before a tool is adopted and integration-health checks on an ongoing basis.
- **Access scope + backup policies**: enforce access scope (least privilege) and backup policies so tooling state is recoverable.
- **Shared tool-manifest standard**: own the standard format and entry schema every department uses to declare its tools.
- **Smoke tests**: run tool doctor and smoke-test checks so tooling failures surface before they block work.

## Core workflows

### 1) Tool onboarding

**Trigger**: `new-tool-request`

**Inputs**
- a tool request from any department (with use case and requested scope)
- current tool manifest and access policies
- security and integration constraints
- prior tool-readiness and integration-health results

**Process (stages)**
1. `request` — capture the tool request with use case, requested scope, and requesting department.
2. `approve` — route to the appropriate human approval gate (credential-grant, production-access, new-integration).
3. `install` — provision accounts, credentials, and integrations with least-privilege scope.
4. `smoke-test` — run tool readiness and integration-health checks; block on failure.
5. `document` — add the tool-manifest entry and publish the smoke-test result.

**Outputs (evidence artifacts)**
- `tool-manifest-entry` — the authoritative manifest entry for the new tool.
- `smoke-test-result` — the recorded readiness and integration-health check output.
- supporting builders: `access-request`, `integration-setup`, `backup-checklist`.

## Required capabilities (department-level)

- **tooling-it-security**: accounts, integrations, credentials, access, and smoke tests — the core capability that keeps the company's tooling surface approved, scoped, healthy, and recoverable.

## Optional capabilities

- **Secrets management** (credential rotation, vaulting, and audit)
- **CI / environment provisioning** (build pipelines, staging/production environments)
- **Identity + access management** (SSO, role-based access, provisioning/deprovisioning)
- **Security hardening + audits** (access reviews, vulnerability scanning, policy enforcement)
- **Automation platform** (workflow automation, webhook and event routing)
- **Asset + inventory management** (device and software inventory, license tracking)

## Agents and roles (default roster)

- **IT Lead**: owns the tool manifest, onboarding workflow, access policies, and cross-department tooling standard.
- **Security Reviewer**: reviews credential grants, production access, and new integrations; enforces least-privilege and backup policies.
- **Integration Owner**: owns integration setup, health checks, and environment readiness for specific tools and platforms.

### Inspectors (quality gates for tooling/IT work)

- **tool-readiness**: verifies a tool is provisioned, accessible, and functional before it is added to the manifest.
- **security-scope**: checks that credentials and access are least-privilege and scoped to the requesting department's need.
- **access-scope**: verifies access grants match approved scope and that excess access is flagged or revoked.
- **integration-health**: checks that integrations are functional, monitored, and documented; flags broken or undocumented integrations.

## Human approval gates (universal)

Human approval is required for any action that grants sensitive access or introduces a new integration.

- **credential-grant**: issuing any credential requires human approval.
- **production-access**: granting access to production systems or data requires human approval.
- **new-integration**: connecting a new third-party integration requires human approval before provisioning.

## Tool manifest (minimal viable set)

This department should be able to operate with a small set of tools that provide manifest state and verification.

- **Manifest + docs**: repo `docs/` for the tool manifest, access policies, and backup checklists (`printing-press` or equivalent document/publishing tool)
- **Work surface**: Paperclip (issues, access requests, approvals, smoke-test records) or equivalent task tracker
- **Verification**: tool doctor / smoke-test runner for readiness and integration-health checks
- **Secrets**: a credential store (vault, password manager, or platform secret manager)

If a company adopts platform-specific tooling, map it here (examples):

- **Identity / access**: Okta, Google Workspace, Microsoft Entra
- **Secrets**: 1Password, Doppler, AWS Secrets Manager, HashiCorp Vault
- **CI / environments**: GitHub Actions, GitLab CI, Cloudflare, AWS/GCP/Azure
- **Monitoring**: Datadog, Grafana, platform-native dashboards

## Smoke tests / evidence checks

These are fast checks to prove the department is "alive" and aligned.

- **Tool doctor passes**: `foreman tools doctor` passes for the composed manifest (`doctor-output` artifact, blocker severity).
- **Tool manifest exists**: a current tool manifest with entries for tools in active use.
- **Access requests are tracked**: recent access requests have approval records, not ad-hoc grants.
- **Smoke-test results exist**: at least one recent smoke-test result for an onboarded tool.
- **Backup checklists exist**: backup checklists are documented for recoverable tooling state.
- **Approval gates are explicit**: "what requires a human" is listed and used for credential-grant, production-access, and new-integration.

## Cross-company mappings (how Tooling / IT / Security manifests by company type)

### Software company

- **Primary focus**: repos, CI, cloud infrastructure, and secrets management.
- **Key decisions**: repo and branch policy, CI/CD pipeline design, cloud provider selection, secrets posture.
- **KPIs**: tool-doctor pass rate, integration-health uptime, access-request cycle time, secrets rotation compliance.
- **Extra gates**: production access; new cloud integration; secrets and key rotation approvals.

### Physical product company

- **Primary focus**: e-commerce and inventory systems, integration health, and access scope.
- **Key decisions**: e-commerce platform, inventory system integration, payment and shipping integrations.
- **KPIs**: integration-health uptime, tool-doctor pass rate, access-request cycle time, backup verification rate.
- **Extra gates**: payment integration approval; inventory system production access; vendor API integration.

### Local service company

- **Primary focus**: booking, payments, and communications tooling.
- **Key decisions**: booking platform, payment processor, comms and scheduling integrations.
- **KPIs**: integration-health uptime, tool-doctor pass rate, booking/payment uptime, access-scope compliance.
- **Extra gates**: payment integration approval; booking system production access; customer-data access grants.

### Creator company

- **Primary focus**: platform APIs, analytics, and asset storage.
- **Key decisions**: platform API access, analytics stack, asset storage and backup, automation platform.
- **KPIs**: API integration health, asset backup verification, tool-doctor pass rate, access-request cycle time.
- **Extra gates**: platform API credential grant; analytics integration; asset storage production access.

### Publishing company

- **Primary focus**: storefront, email, and export tooling.
- **Key decisions**: storefront platform, email platform, export/distribution integrations, backup policy.
- **KPIs**: storefront integration health, email platform uptime, export-tool readiness, backup verification rate.
- **Extra gates**: storefront integration approval; email platform production access; distribution integration.

### Education / community company

- **Primary focus**: LMS, community platform, and payments tooling.
- **Key decisions**: LMS platform, community platform, payments integration, learner-data access scope.
- **KPIs**: LMS uptime, community platform integration health, payments integration health, access-scope compliance.
- **Extra gates**: LMS production access; community platform integration; payments integration; learner-data access grants.

## Foreman integration notes (recommended)

### Stage model for Tooling / IT / Security tasks

```text
request → approve → install → smoke-test → document
```

### Context packet requirements (tooling/IT runs)

- company-brief
- active-task (the tool request, access request, or integration in flight)
- role-instructions
- relevant-artifacts (current tool manifest, access policies, backup checklists, prior smoke-test results)
- constraints (security policy, least-privilege standard, budget, platform limits)
- prior-inspection-results (tool-readiness, security-scope, access-scope, integration-health)
- human-decisions (approval state for credential-grant, production-access, new-integration)
- expected-output-schema (tool-manifest-entry, smoke-test-result, access-request, integration-setup, backup-checklist)