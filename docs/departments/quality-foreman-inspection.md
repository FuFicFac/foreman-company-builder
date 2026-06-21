# Quality / Foreman Inspection (Universal Department)

## Purpose

Run the core Foreman discipline across every department: builder → inspector → Foreman arbitration → fix loop → evidence. This department is the quality spine of the company — it routes work to the right inspectors, enforces evidence standards on all deliverables, arbitrates inspector disagreements, runs the three-strike escalation protocol, and performs a closeout sweep before any work is marked done.

It is the **inspection + evidence layer** that makes the rest of the company's output trustworthy. Where other departments produce, Quality / Foreman Inspection verifies — and where inspectors disagree, the Foreman arbitrates so work is never blocked silently or approved without evidence.

This department is universal and required across every company type. It owns no builders of its own; instead it owns the inspection loop, the verdict protocol, and the evidence archive that every other department's work passes through.

## Universal responsibilities

- **Route work to appropriate inspectors**: dispatch each piece of inspectable work to the inspectors defined on the producing module.
- **Enforce evidence standards on all deliverables**: require inspection verdicts and artifact-index entries before any deliverable is accepted.
- **Run three-strike escalation protocol**: escalate to a human after three failed inspection passes on the same work.
- **Arbitrate inspector disagreements**: when inspectors conflict, the Foreman arbitrates and records the verdict and rationale.
- **Perform closeout sweep before marking work done**: verify all inspectors have passed, all evidence is archived, and no open fixes remain.

## Core workflows

### 1) Foreman inspection loop

**Inputs**
- an inspectable-work trigger (any deliverable produced by any department)
- the producing module's `inspection_standards`
- prior inspection verdicts and fix history for the work

**Process (stages)**
- `dispatch-builder`: hand the work to the producing department's builder with its role-instructions.
- `dispatch-inspector`: route the produced work to the inspectors declared on the module.
- `verdict`: collect inspector verdicts; if they agree, record the verdict; if they disagree, run Foreman arbitration.
- `fix-or-approve`: if fixes are required, loop back to the builder; if approved, proceed; three-strike escalation triggers a human gate.
- `evidence-capture`: archive the inspection-verdict and update the artifact-index; run closeout-sweep before marking done.

**Outputs (evidence artifacts)**
- inspection-verdict (pass/fail per inspector, arbitration record if any, fix history)
- artifact-index (evidence pointers for every accepted deliverable)

## Required capabilities (department-level)

- **quality-inspection**: Builder-inspector loops, evidence, Foreman arbitration — the core capability that authorizes this department to route, inspect, arbitrate, and close out work.

## Optional capabilities

- **analytics-reporting**: inspection pass rates, fix-loop length, and three-strike escalation frequency across departments.
- **research-intelligence**: inspection-standard benchmarking and best-practice capture across company types.
- **legal-compliance**: evidence-retention policy and regulated-record inspection (overlaps with Legal / Compliance).
- **tooling-it**: inspection tooling integration and evidence-archive plumbing.
- **executive-strategy**: quality posture and stop-the-line policy alignment with company risk appetite.
- **people-contractors**: inspector roster management and inspector-quality review (overlaps with People / Contractors).

## Agents and roles (default roster)

- **Foreman**: owns the inspection loop, arbitrates inspector disagreements, triggers three-strike escalation, and runs closeout-sweep.
- **Inspector Router**: dispatches work to the correct inspectors based on the producing module's `inspection_standards`.
- **Evidence Auditor**: verifies evidence standards are met, maintains the artifact-index, and flags gaps before closeout.

### Inspectors (quality gates for quality / foreman inspection work)

- **foreman-arbitrator**: arbitrates when inspectors disagree and records the verdict with rationale.
- **evidence-auditor**: verifies every accepted deliverable has complete evidence and an artifact-index entry.
- **closeout-sweep**: verifies all inspectors passed, no open fixes remain, and the work is safe to mark done.

## Human approval gates (universal)

Human approval is required for any action that overrides the inspection loop or forces a deliverable through without evidence.

- **three-strike-escalation**: after three failed inspection passes, escalate to a human before another fix attempt.
- **force-close**: forcing a deliverable to "done" despite unresolved inspector findings.
- **waive-inspection**: waiving an inspector for a specific deliverable (exception, not default).

## Tool manifest (minimal viable set)

This department should be able to operate with a small set of tools that provide durable state and evidence. It has no department-specific tool manifest — it runs on the inspection infrastructure shared across the company.

- **Work surface**: Paperclip (inspection verdicts, fix loops, escalations) or equivalent task tracker
- **Knowledge base**: repo `docs/quality/` (inspection-standards index, escalation-protocol, verdict archive)
- **Evidence archive**: file store for inspection-verdict records and the artifact-index
- **Module introspection**: access to each module's `module.json` to read declared `inspection_standards`

If a company adopts platform-specific tooling, map it here (examples):

- **Issue tracking**: Linear, Jira, GitHub Issues
- **Code review**: GitHub, GitLab (for software-company inspection)
- **Docs / evidence**: Notion, Google Docs, GitHub
- **QA / test**: custom harnesses, CI, manual checklists

## Smoke tests / evidence checks

These are fast checks to prove the department is "alive" and aligned.

- **Inspection standards defined**: every active module has `inspection_standards` declared in its `module.json`.
- **Three-strike policy referenced**: the escalation-protocol is linked from the inspection loop and known to the Foreman.
- **Inspection-verdict archived**: at least one recent inspection-verdict with per-inspector results and (if any) arbitration record.
- **Artifact-index current**: the artifact-index has entries for recently accepted deliverables.
- **Closeout-sweep run**: recent done-work has a closeout-sweep record confirming all inspectors passed.
- **Approval gates are explicit**: three-strike-escalation, force-close, and waive-inspection gates are listed and used.

## Cross-company mappings (how Quality / Foreman Inspection manifests by company type)

### Software company

- **Primary focus**: code review, security inspection, and test gates before deploy.
- **Key decisions**: which inspectors run per deliverable, three-strike threshold for broken builds, force-close policy on hotfixes.
- **KPIs**: inspection pass rate, fix-loop length, three-strike frequency, defect escape rate.
- **Extra gates**: three-strike-escalation on repeatedly failing PRs; waive-inspection only with security sign-off.

### Physical product company

- **Primary focus**: QC and spec-compliance inspection on production and incoming goods.
- **Key decisions**: sample size, inspection cadence, accept/reject thresholds, rework loop.
- **KPIs**: defect rate, rework rate, inspection pass rate, three-strike frequency on recurring defects.
- **Extra gates**: three-strike-escalation on recurring vendor defects; force-close only with quality-lead sign-off.

### Local service company

- **Primary focus**: service-quality inspection against the customer promise and delivery standard.
- **Key decisions**: inspection points in the service flow, customer-promise checklist, complaint-triggered re-inspection.
- **KPIs**: service-quality pass rate, complaint rate, rework/revisit rate, three-strike frequency.
- **Extra gates**: three-strike-escalation on repeated service failures; force-close on disputed jobs.

### Creator company

- **Primary focus**: content-quality and brand-fit inspection before publishing.
- **Key decisions**: brand-check thresholds, editorial inspection personas, rework loop on brand misalignment.
- **KPIs**: content pass rate, rework rate, brand-fit pass rate, three-strike frequency.
- **Extra gates**: three-strike-escalation on repeated brand misalignment; waive-inspection only for low-risk repurposed content.

### Publishing company

- **Primary focus**: editorial inspection personas for manuscripts, covers, and metadata.
- **Key decisions**: which editorial inspectors run per title, cover-approval gate, metadata-accuracy gate.
- **KPIs**: editorial pass rate, revision rounds per title, three-strike frequency, post-publication error rate.
- **Extra gates**: three-strike-escalation on repeated editorial failures; force-close only with editor-in-chief sign-off.

### Education / community company

- **Primary focus**: curriculum quality and accuracy inspection for courses and learning materials.
- **Key decisions**: accuracy-inspector scope, curriculum-review cadence, community-content spot checks.
- **KPIs**: curriculum pass rate, accuracy-error rate, three-strike frequency, learner-reported error rate.
- **Extra gates**: three-strike-escalation on repeated accuracy failures; waive-inspection only on low-stakes supplementary material.

## Foreman integration notes (recommended)

### Stage model for Quality / Foreman Inspection tasks

```text
dispatch-builder → dispatch-inspector → verdict → fix-or-approve (human gate on three-strike) → evidence-capture
```
**Loop mode**: `deluxe` — high-stakes department. Every action runs through enhanced verification gates with mandatory human approval before commit.

### Context packet requirements (quality / foreman inspection runs)

- company-brief (quality posture, stop-the-line policy, risk appetite)
- active-task (the inspectable work and its producing module)
- role-instructions (which inspectors run, in what order, per the module's `inspection_standards`)
- relevant-artifacts (the deliverable under inspection, prior inspection-verdicts, fix history)
- constraints (deadlines, three-strike threshold, force-close policy)
- prior-inspection-results (recent verdicts for this work and similar work)
- human-decisions (outstanding approvals: three-strike-escalation, force-close, waive-inspection)
- expected-output-schema (inspection-verdict, artifact-index entry, closeout-sweep record)