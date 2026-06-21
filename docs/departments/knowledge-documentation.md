# Knowledge / Documentation (Universal Department)

## Purpose

Maintain the living source of truth: SOPs, decisions, customer insights, product facts, tool docs, and runbooks — the durable knowledge every other department depends on.

This department is the **memory + findability layer** that prevents the company from re-answering the same questions, re-deciding settled decisions, or operating from stale facts.

Knowledge owns the wiki structure, the artifact index, the decision log, and the freshness cadence that keeps documentation from rotting — so a new agent, employee, or partner can get up to speed from written evidence instead of tribal memory.

## Universal responsibilities

- **Maintain company wiki structure**: own the top-level wiki structure and naming conventions so artifacts are predictable and discoverable.
- **Index artifacts and decision log**: keep an index of every canonical artifact and a decision log that records what was decided, why, and by whom.
- **Run documentation freshness checks**: on a recurring cadence, scan for stale docs, assign owners, and verify the index still resolves.
- **Connect knowledge to department workflows**: make sure each department's workflows reference the right artifacts and that new evidence flows back into the wiki.

## Core workflows

### 1) Documentation freshness sweep

**Inputs**
- current artifact index and wiki structure
- last-modified timestamps across docs
- department workflow references
- owner roster per artifact

**Process (stages: scan-stale → assign-owners → update → verify-index)**
- **scan-stale**: identify artifacts past their freshness threshold or missing owners
- **assign-owners**: route stale artifacts to the correct owner for review or rewrite
- **update**: owners refresh, merge, archive, or rewrite stale content
- **verify-index**: confirm the artifact index still resolves and links are intact

**Outputs (evidence artifacts)**
- `artifact-index` (current list of canonical artifacts with owners and freshness)
- `freshness-report` (what was stale, what was fixed, what remains open)

## Required capabilities (department-level)

- **knowledge-documentation**: wiki, SOPs, decision log, and artifact index — the end-to-end ability to structure, maintain, index, and verify the company's written knowledge.

## Optional capabilities

- **Search / findability engineering** (indexed search across the wiki)
- **Onboarding / enablement docs** (role-specific ramp guides)
- **Runbook automation** (executable runbooks wired to tools)
- **Customer-facing help center** (public docs synced from internal source)
- **Decision-log governance** (ADR standards and review cadence)
- **Multi-format publishing** (docs rendered to site, PDF, or API reference)

## Agents and roles (default roster)

- **Knowledge Lead**: owns wiki structure, freshness cadence, inspector gates, and the artifact index.
- **Doc Owner**: owns one or more artifacts end-to-end — content accuracy, freshness, and index status.
- **Wiki Curator**: handles structure, links, categorization, and the mechanics of the freshness sweep.

### Inspectors (quality gates for knowledge work)

- **freshness-check inspector**: flags artifacts past their freshness threshold or missing a last-reviewed date.
- **link-integrity inspector**: flags broken links, dangling references, and orphaned artifacts in the index.
- **findability inspector**: flags artifacts that are hard to locate because of poor naming, missing categorization, or absent index entries.

## Human approval gates (universal)

Human approval is required for any action that changes what the company treats as canonical or removes durable knowledge.

- **Canonical doc change**: altering a document the company treats as the source of truth (SOP, policy, spec, ADR).
- **Archive doc**: removing an artifact from the live wiki (even if retained in archive).
- **Wiki restructure** (large-scale moves that break existing references)
- **Public publish of internal docs** (leaking internal knowledge externally)

## Tool manifest (minimal viable set)

This department should be able to operate with a small set of tools that provide durable state and evidence.

- **Work surface**: Paperclip (freshness tasks, approvals, doc owners) or equivalent tracker
- **Knowledge base**: repo `docs/` or wiki platform (wiki structure, artifact index, decision log)
- **Index**: a searchable index of artifacts with owners and last-reviewed dates
- **Versioning**: git or equivalent change history for canonical docs

If a company adopts platform-specific tooling, map it here (examples):

- **Wiki / docs**: Notion, Wikipedia-style internal wiki, GitBook
- **Decisions**: ADR files in repo, Notion database
- **Search**: native wiki search or a dedicated index

## Smoke tests / evidence checks

These are fast checks to prove the department is "alive" and aligned.

- **Wiki structure exists**: a defined `wiki-index` shows top-level structure and categories.
- **Decision log accessible**: the `decision-log` is reachable and has recent entries.
- **Artifact index exists**: an `artifact-index` lists canonical artifacts with owners.
- **Freshness sweep ran**: at least one `freshness-report` from the current cycle.
- **Link-integrity gate ran**: the most recent sweep shows a link-integrity inspector pass record.
- **Owners assigned**: stale artifacts from the last sweep have named owners, not "unassigned".

## Cross-company mappings (how Knowledge / Documentation manifests by company type)

### Software company

- **Primary focus**: architecture docs, runbooks, ADRs — engineering source of truth.
- **Key decisions**: ADR standards, runbook ownership, architecture-doc freshness, onboarding docs.
- **KPIs**: doc coverage, stale-doc rate, onboarding time, runbook usage, incident-doc linkage.
- **Extra gates**: canonical architecture or runbook changes; publishing internal docs externally.

### Physical product company

- **Primary focus**: specs, supplier docs, compliance — product and supply-chain source of truth.
- **Key decisions**: spec ownership, supplier-doc freshness, compliance-doc retention, BOM accuracy.
- **KPIs**: spec freshness, supplier-doc coverage, compliance-doc completeness, stale-doc rate.
- **Extra gates**: canonical spec changes; compliance and safety doc changes; archive of regulated docs.

### Local service company

- **Primary focus**: service playbooks and customer notes — repeatable service delivery.
- **Key decisions**: playbook ownership, customer-note retention, SOP freshness, safety doc handling.
- **KPIs**: playbook coverage, SOP freshness, onboarding time, customer-note completeness.
- **Extra gates**: canonical playbook or safety-doc changes; archive of customer notes.

### Creator company

- **Primary focus**: brand bible and content calendar archive — creative consistency and history.
- **Key decisions**: brand-bible ownership, content-archive structure, style-guide freshness.
- **KPIs**: brand-bible freshness, archive completeness, style-guide adoption, stale-doc rate.
- **Extra gates**: canonical brand-bible or style-guide changes; archive of published content.

### Publishing company

- **Primary focus**: series bible, style guide, canon — editorial continuity across titles.
- **Key decisions**: series-bible ownership, canon decisions, style-guide freshness, continuity log.
- **KPIs**: series-bible freshness, style-guide coverage, continuity-error rate, stale-doc rate.
- **Extra gates**: canonical series-bible or canon changes; style-guide changes affecting in-flight titles.

### Education / community company

- **Primary focus**: curriculum docs and community guidelines — learning and community source of truth.
- **Key decisions**: curriculum-doc ownership, guideline freshness, moderation-policy versioning, learner-facing docs.
- **KPIs**: curriculum-doc freshness, guideline coverage, onboarding time, stale-doc rate.
- **Extra gates**: canonical curriculum or guideline changes; archive of community guidelines.

## Foreman integration notes (recommended)

### Stage model for Knowledge / Documentation tasks

```text
scan-stale → assign-owners → update → verify-index
```

### Context packet requirements (knowledge runs)

- company-brief (company type, wiki structure, artifact index)
- active-task (which freshness sweep or doc update is being worked)
- role-instructions (knowledge lead vs doc owner vs wiki curator)
- relevant-artifacts (current `artifact-index`, `freshness-report`, decision log)
- constraints (freshness thresholds, owner availability, publishing rules)
- prior-inspection-results (last freshness-check, link-integrity, findability outcomes)
- human-decisions (approved canonical-doc-change or archive-doc decisions)
- expected-output-schema (`artifact-index`, `freshness-report`, `wiki-page`, `decision-log-entry`, or `artifact-index-update`)