# Department Module Schema and Capability Model

Synthesis artifact for **FCB Universal Company Departments** (FOR-18). Defines how reusable department primitives compose into any Foreman Company, aligned with existing `modules/*/module.json` conventions.

## Architecture

```text
Company template (modules/<domain>/)
  = selected departments + activated capabilities + merged tool manifests + composed roles/inspectors/gates

Department (modules/departments/<slug>/)
  = reusable business function with capabilities, workflows, roles, inspectors, gates, and evidence checks

Capability
  = atomic business function a department exposes (editorial, pipeline-management, invoicing, …)
```

**Domain modules** (`modules/software/`, `modules/publishing/`, …) remain full company templates. **Department modules** (`modules/departments/<slug>/`) are composable slices any template can import. The publishing module already demonstrates capability composition at the template level; departments decompose that pattern into reusable units.

## Module manifest layers

| Layer | Path | Purpose |
|-------|------|---------|
| Domain template | `modules/<domain>/module.json` | End-to-end company workflow |
| Department primitive | `modules/departments/<slug>/module.json` | Reusable department slice |
| Catalog | `modules/departments/catalog.json` | Research synthesis for all departments |
| Capability registry | `modules/departments/capability-registry.json` | Canonical capability IDs |

## Shared fields (all module.json)

Inherited from existing built-in modules (`modules/software/module.json`, `modules/publishing/module.json`). Validated by `tests/json/validate-module-manifests.py`.

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `name` | string | yes | Slug identifier |
| `version` | semver | yes | Manifest version |
| `description` | string | yes | One-line purpose |
| `stages` | string[] | yes | Ordered workflow stages |
| `roles` | string[] | yes | Spawnable agent roles |
| `builders` | string[] | recommended | Builder dispatch targets |
| `inspectors` | string[] | recommended | Inspector dispatch targets |
| `inspection_standards` | string[] | yes | Verdict criteria |
| `human_approval_gates` | string[] | recommended | Gates requiring human decision events |
| `context_packet_requirements` | string[] | recommended | Required context for runs |
| `loop_mode` | `lean` \| `deluxe` | recommended | Default Foreman loop |
| `high_stakes_loop` | `lean` \| `deluxe` | optional | Override for high-stakes work |
| `twelve_factor_profile` | object | yes | Must include `pause_resume_runs`, `unified_execution_and_business_state`, `stateless_reducer_loop` = true |
| `source` | string | recommended | `built-in`, `fcb-department`, `external` |

## Capability fields (department + composed templates)

Introduced in `modules/publishing/module.json`; required for department modules.

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `capabilities` | string[] | yes (dept) | Capability IDs this department exposes |
| `required_capabilities` | string[] | optional | Must be active when department is included |
| `recommended_capabilities` | string[] | optional | Suggested at onboarding |
| `conditional_capabilities` | object | optional | Map of condition → capability IDs |
| `tool_manifest` | object | recommended | Map of capability → tool slugs (Printing Press / CLI) |

Capability IDs must exist in `modules/departments/capability-registry.json`.

## Department-only fields

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `kind` | `"department"` | yes | Distinguishes from domain templates |
| `department_slug` | string | yes | Stable slug (matches catalog entry) |
| `purpose` | string | yes | Why this department exists |
| `universal_responsibilities` | string[] | yes | Cross-company duties |
| `workflows` | object[] | yes | Named workflows with stages |
| `smoke_tests` | object[] | recommended | Evidence checks for department readiness |
| `company_type_mappings` | object | yes | Per-type relevance (see below) |
| `depends_on_departments` | string[] | optional | Other department slugs |
| `domain` | string | optional | Legacy alias; prefer `department_slug` |

### Company type mapping shape

```json
{
  "software": { "relevance": "required", "notes": "Roadmap, prioritization, escalation" },
  "physical_product": { "relevance": "required", "notes": "..." },
  "local_service": { "relevance": "recommended", "notes": "..." },
  "creator": { "relevance": "recommended", "notes": "..." },
  "publishing": { "relevance": "required", "notes": "..." },
  "education_community": { "relevance": "required", "notes": "..." }
}
```

`relevance` values: `required` | `recommended` | `optional` | `not_applicable`.

## Company composition model

When onboarding a custom company, Foreman should:

1. Ask company type (or infer from template).
2. Load `catalog.json` and filter departments where `company_type_mappings[type].relevance` is `required` or `recommended`.
3. Merge `capabilities`, `roles`, `inspectors`, `human_approval_gates`, and `tool_manifest` from selected departments.
4. Resolve conflicts (duplicate gate names share one gate; role names are namespaced as `<dept>-<role>` when colliding).
5. Write composed manifest to company context / `project.json`.

```json
{
  "company_type": "publishing",
  "departments": ["executive", "product-delivery", "marketing", "finance", "quality-inspection"],
  "capabilities": ["strategic-planning", "editorial", "metadata", "launch-operations"],
  "tool_manifest": { "...": "merged from departments" }
}
```

## Workflow object shape

```json
{
  "id": "weekly-cadence",
  "name": "Weekly operating cadence",
  "stages": ["review-priorities", "assign-work", "surface-blockers", "decision-log"],
  "trigger": "recurring-weekly",
  "evidence": ["weekly-plan", "decision-log-entry"]
}
```

## Smoke test object shape

```json
{
  "id": "mission-defined",
  "check": "company-brief.mission is non-empty",
  "evidence": "company-brief artifact",
  "severity": "blocker"
}
```

## Inspector routing

Departments declare `inspectors` (dispatch targets) and `inspection_standards` (verdict rubric). The **Quality / Foreman Inspection** department owns cross-cutting routing: builder → inspector → Foreman arbitration → fix loop → evidence. Other departments reference it via `depends_on_departments: ["quality-inspection"]` when they emit inspectable work.

## Approval gates

Gates become `HumanDecision` events in the 12-Factor run ledger. Department manifests list gate IDs; company composition unions them. Gate IDs use kebab-case and are globally unique within a company (prefix with department slug on collision).

## Tool manifest standard

Shared across all departments (owned by **Tooling / IT / Security**):

- Keys = capability IDs from registry.
- Values = ordered tool slug arrays (Printing Press CLI names).
- `foreman tools doctor` verifies installation against composed manifest.

## Verification

```bash
npm test
python3 tests/json/validate-module-manifests.py modules
python3 tests/json/validate-department-primitives.py modules/departments
python3 tests/json/validate-department-catalog.py
```

## Related artifacts

- Source backlog: [company-builder-department-backlog.md](company-builder-department-backlog.md)
- Holding company model: [holding-company-architecture.md](holding-company-architecture.md)
- Department catalog: `modules/departments/catalog.json`
- Capability registry: `modules/departments/capability-registry.json`
- Reference department module: `modules/departments/quality-inspection/module.json`

## Implementation sequence (downstream)

1. One implementation issue per department → `modules/departments/<slug>/module.json` + `SKILL.md`.
2. Update `foreman chat --onboard` to compose departments instead of defaulting to `software`.
3. Keep `tests/json/validate-department-primitives.py` green as department modules are added.
