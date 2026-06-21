# Analytics / Reporting (Universal Department)

## Purpose

Turn raw operational and product data into durable evidence: KPIs, dashboards, experiment readouts, weekly/monthly reports, and the supporting artifacts that let every other department reason from the same set of truths.

This department is the **measurement + learning layer** that keeps the company honest about whether its strategy, marketing, sales, ops, and product work are actually moving the metrics that matter.

Analytics owns metric definitions, data-quality signals, experiment analysis protocol, and the recurring cadence that produces reports on a predictable rhythm — so decisions are grounded in fresh, validated evidence rather than anecdote or stale snapshots.

## Universal responsibilities

- **Define KPI schema per company type**: establish which metrics are canonical for the company's model, how they are calculated, where the source data lives, and what counts as a material change.
- **Produce recurring reports**: ship weekly and monthly reports on a predictable cadence with the same structure each cycle so deltas are comparable.
- **Run experiment analysis protocol**: apply a consistent readout method to tests and launches — hypothesis, metric, expected delta, observed delta, significance, and next action.
- **Flag data quality issues**: surface missing sources, broken pipelines, schema drift, and implausible numbers before they pollute downstream reports.
- **Recommend next actions from metrics**: every report ends with explicit, owner-assigned recommendations — not just charts.

## Core workflows

### 1) Weekly metrics report

**Inputs**
- prior week's KPI snapshot
- source data feeds (product, sales, support, ops)
- active experiment list
- known data-quality issues and gaps

**Process (stages: collect-data → validate-quality → synthesize → recommend-actions)**
- **collect-data**: pull all configured sources into a working snapshot
- **validate-quality**: run data-quality inspector; flag gaps, nulls, and implausible deltas
- **synthesize**: compute KPI deltas vs prior period and targets; produce chart set
- **recommend-actions**: translate deltas into 1–3 owner-assigned next actions

**Outputs (evidence artifacts)**
- `weekly-report` (narrative + charts)
- `kpi-snapshot` (machine-readable current values)

## Required capabilities (department-level)

- **analytics-reporting**: KPIs, dashboards, experiments, and operational metrics — the end-to-end ability to define, collect, validate, synthesize, and recommend from data.

## Optional capabilities

- **Cohort + retention analysis** (deeper SaaS and product analytics)
- **Funnel + attribution modeling** (marketing-spend optimization)
- **Forecasting / scenario modeling** (revenue and demand planning)
- **Self-serve BI enablement** (dashboards other departments can query)
- **Experimentation platform management** (A/B test infrastructure)

## Agents and roles (default roster)

- **Analytics Lead**: owns KPI schema, report cadence, inspector gates, and the analytics roadmap.
- **Data Analyst**: pulls sources, validates quality, builds dashboards and reports, runs experiment readouts.
- **Experiment Owner**: defines hypotheses and success metrics for tests, interprets readouts, recommends ship/hold decisions.

### Inspectors (quality gates for analytics work)

- **data-quality inspector**: flags missing sources, schema drift, nulls, and implausible deltas before a report ships.
- **conclusion-validity inspector**: checks that conclusions follow from the data and that significance and caveats are stated honestly.
- **next-action-clarity inspector**: flags reports that end in charts without explicit, owner-assigned recommendations.

## Human approval gates (universal)

Human approval is required for any action that changes what the company measures or ships based on a test result.

- **Metric definition change**: altering a canonical KPI's formula, source, or threshold.
- **Experiment ship**: rolling a tested change to 100% based on a readout.
- **Dashboard/schema deletion** (irreversible data artifact removal)
- **Public claims derived from data** (investor, marketing, or regulatory numbers)

## Tool manifest (minimal viable set)

This department should be able to operate with a small set of tools that provide durable state and evidence.

- **Work surface**: Paperclip (issues, approvals, decisions) or equivalent task tracker
- **Knowledge base**: repo `docs/` (KPI schema, report archive, experiment log)
- **Numbers**: spreadsheet tool for scorecards and ad-hoc analysis
- **Data sources**: native connectors to the company's product, billing, and support systems

If a company adopts platform-specific tooling, map it here (examples):

- **Analytics**: GA4, PostHog, google-ads, dub, company-goat
- **Commerce**: Stripe, Shopify dashboards
- **Docs**: Notion, Google Docs

## Smoke tests / evidence checks

These are fast checks to prove the department is "alive" and aligned.

- **KPI schema exists**: canonical KPI definitions exist for the company type (`kpi-schema` artifact).
- **Weekly report shipped**: at least one `weekly-report` + `kpi-snapshot` from the current cycle.
- **Data-quality gate ran**: the most recent report shows a data-quality inspector pass/fail record.
- **Experiment log exists**: active experiments with hypothesis, metric, owner, and status.
- **Next-actions are owner-assigned**: the latest report lists 1–3 recommendations with named owners.
- **Source map exists**: each KPI traces to a named source and refresh cadence.

## Cross-company mappings (how Analytics / Reporting manifests by company type)

### Software company

- **Primary focus**: activation, retention, MRR, error rates — product health and subscription economics.
- **Key decisions**: which activation metric is canonical, experiment ship/hold, error-budget spend.
- **KPIs**: activation, retention, MRR, churn, uptime, defect rates, cycle time.
- **Extra gates**: experiment ship approval; metric-definition changes that affect investor reporting.

### Physical product company

- **Primary focus**: sales velocity, returns, inventory turns — unit economics and supply health.
- **Key decisions**: which channels to double down on, returns threshold alerts, inventory turn targets.
- **KPIs**: gross margin, return rate, on-time fulfillment, defect rate, inventory turns, cash conversion cycle.
- **Extra gates**: data used for regulatory or safety claims; reconciliation with finance close.

### Local service company

- **Primary focus**: bookings, utilization, reviews — capacity and reputation signals.
- **Key decisions**: utilization targets, review-response triggers, rebooking incentives.
- **KPIs**: utilization, lead-to-book rate, on-time arrival, NPS/reviews, repeat rate.
- **Extra gates**: review-derived public claims; geo-expansion justification from data.

### Creator company

- **Primary focus**: views, CTR, sponsorship conversion — reach and monetization efficiency.
- **Key decisions**: which platforms to prioritize, sponsor-performance thresholds, posting cadence.
- **KPIs**: reach, watch time/opens, subscriber growth, RPM/CPM, sponsor conversion.
- **Extra gates**: sponsor performance claims; platform policy compliance flags.

### Publishing company

- **Primary focus**: sales, read-through, ad ROAS — catalog performance and paid-media efficiency.
- **Key decisions**: which titles to promote, ad-spend allocation, series continuation.
- **KPIs**: sell-through, conversion rate, refund rate, read-through (series), ad ROAS.
- **Extra gates**: royalty and sales reconciliation with finance; platform-reported vs direct sales.

### Education / community company

- **Primary focus**: enrollment, completion, engagement — learning outcomes and community health.
- **Key decisions**: completion-target setting, engagement interventions, cohort sizing.
- **KPIs**: enrollment, completion rate, retention, referrals, community engagement, support burden.
- **Extra gates**: outcome claims used in marketing; completion data shared with partners or accreditors.

## Foreman integration notes (recommended)

### Stage model for Analytics / Reporting tasks

```text
collect-data → validate-quality → synthesize → recommend-actions
```

### Context packet requirements (analytics runs)

- company-brief (company type, model, canonical KPIs)
- active-task (which report or readout is being produced)
- role-instructions (analyst vs experiment owner)
- relevant-artifacts (prior `kpi-snapshot`, active experiment list)
- constraints (data-source availability, refresh cadence, budget)
- prior-inspection-results (last data-quality and conclusion-validity outcomes)
- human-decisions (approved metric-definition or experiment-ship decisions)
- expected-output-schema (`weekly-report`, `kpi-snapshot`, or `experiment-readout`)