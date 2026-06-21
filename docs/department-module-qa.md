# Department Module QA Report

Issue: **FOR-20 — QA inspect department modules and run Foreman tests**

Result: **PASS** on 2026-06-19.

## Scope

This QA pass inspected the reusable FCB department primitive surface and the existing Foreman module conventions:

- 17 department manifests under `modules/departments/*/module.json`
- `modules/departments/catalog.json`
- `modules/departments/capability-registry.json`
- existing domain manifests under `modules/*/module.json`
- Foreman lifecycle and invalid-transition smoke tests

The department set covers:

- `executive`
- `product-delivery`
- `operations`
- `marketing`
- `sales`
- `customer-success`
- `finance`
- `legal-compliance`
- `people`
- `analytics`
- `tooling-it`
- `quality-inspection`
- `research`
- `procurement`
- `distribution`
- `risk-continuity`
- `knowledge`

## Checks Performed

The QA validator now covers:

- capability registry presence and non-empty registered capability IDs
- department catalog presence, unique slugs, default department sets, and six company-type mappings
- every concrete department module's `kind`, `department_slug`, purpose, responsibilities, workflows, capabilities, roles, inspectors, approval gates, smoke tests, and mappings
- capability references from `capabilities`, `required_capabilities`, `recommended_capabilities`, `conditional_capabilities`, and `tool_manifest`
- shared manifest conventions: `name`, `version`, `description`, `stages`, `inspection_standards`, and required 12-factor profile flags
- link between each department module and its catalog slug

## Test Evidence

Command:

```bash
npm test
```

Observed result:

```text
run lifecycle smoke passed
invalid transition smoke passed
module manifests valid
department primitives valid (17 department manifests, 17 catalog departments, 26 capabilities)
department catalog valid (17 departments, 26 capabilities)
```

## Findings

- PASS: all 17 department module manifests validate against reusable department primitive requirements.
- PASS: the catalog includes all six required company mappings: software, physical product, local service, creator, publishing, and education/community.
- PASS: catalog default department sets reference known department slugs only.
- PASS: capability references resolve to the registry.
- PASS: existing domain modules still pass the existing module manifest validator.
- PASS: Foreman run lifecycle, pause/resume/inspect, and invalid transition checks are green.

## Residual Notes

- `docs/departments/` currently contains detailed prose for `executive-strategy`; the machine-readable catalog and manifests cover all 17 departments.
- Runtime company onboarding/composition is downstream from this QA pass; this report verifies the department primitive data and test harness, not an interactive onboarding flow.

## Closeout

No blockers remain for this QA card.
