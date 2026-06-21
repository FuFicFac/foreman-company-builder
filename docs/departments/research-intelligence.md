# Research / Intelligence (Universal Department)

## Purpose

Run the standing research function that gives every other department a grounded, evidence-based view of the market, competitors, and customer language — before strategy and go-to-market decisions are made.

This department is the **sense-making layer** that prevents the company from acting on assumptions. It converts raw sources (reviews, support transcripts, competitor surfaces, public data) into scored, synthesized intelligence that executive, product, marketing, and sales can act on with confidence.

Research is not a one-off activity. It is a recurring capability that feeds prioritization, positioning, pricing, launch sequencing, and risk decisions — and it keeps a durable source index so conclusions can be audited and revisited.

## Universal responsibilities

- **Market + competitor research**: run structured research protocols that answer defined business questions, not open-ended browsing.
- **Customer language mining**: extract real phrases, pain points, and value language from reviews, support tickets, sales calls, and community channels.
- **Source quality scoring**: every source used in a memo is scored for recency, authority, and relevance; weak sources are flagged, not buried.
- **Synthesis memos**: produce concise research memos and competitor briefs for executive and GTM consumers, with citations and a source index.
- **Recommendation discipline**: research outputs end with explicit, actionable recommendations tied to the originating question.
- **Evidence durability**: maintain a source index and research protocol so prior work can be re-run, audited, and updated.

## Core workflows

### 1) Research sprint

**Trigger**: `research-request`

**Inputs**
- a defined research question (from executive, GTM, product, or risk)
- company brief and current priorities
- constraints (time budget, source access, geography)
- prior research artifacts and inspection results

**Process (stages)**
1. `question` — refine the request into a sharp, answerable question with success criteria.
2. `gather-sources` — collect candidate sources across public data, competitor surfaces, reviews, support, and community.
3. `score-quality` — score each source for recency, authority, and relevance; discard or flag weak sources.
4. `synthesize` — combine surviving sources into findings, themes, and customer-language artifacts.
5. `recommend` — produce explicit recommendations tied back to the originating question.

**Outputs (evidence artifacts)**
- `research-memo` — findings, themes, recommendations, citations.
- `source-index` — scored source list with quality flags and access notes.
- supporting builders: `competitor-brief`, `customer-language-report`.

## Required capabilities (department-level)

- **research-intelligence**: market, competitor, and customer research synthesis — the core capability that turns raw sources into scored, actionable intelligence for downstream consumers.

## Optional capabilities

- **Pricing & packaging research** (competitor price surfaces, willingness-to-pay signals)
- **Audience / niche trend research** (creator and publishing contexts)
- **Comp-title analysis** (publishing-specific competitive positioning)
- **Local market mapping** (geographic competitor and demand mapping for local services)
- **Learner-needs research** (curriculum and course-competitor analysis for education)
- **Regulatory landscape scanning** (for regulated claims and compliance-adjacent research)

## Agents and roles (default roster)

- **Research Lead**: owns the research protocol, question refinement, source-quality standard, and final memo sign-off.
- **Market Analyst**: runs market sizing, demand signals, and segment-level research; produces market-facing findings.
- **Competitive Analyst**: maps competitor surfaces, pricing, positioning, and moves; produces competitor briefs.

### Inspectors (quality gates for research work)

- **source-quality**: verifies sources are scored, current, authoritative, and relevant; flags unscored or weak sources used in conclusions.
- **conclusion-support**: checks that every recommendation is backed by cited, scored sources — no unsupported leaps.
- **actionability**: flags memos that end in description without explicit, decision-relevant recommendations.

## Human approval gates (universal)

Human approval is required when research output crosses into external publication or competitive claims.

- **publish-external-research**: any research artifact published outside the company (blog post, report, public memo).
- **competitive-claim**: any public or partner-facing claim about a named competitor requires human review for accuracy and legal exposure.

## Tool manifest (minimal viable set)

This department should be able to operate with a small set of tools that provide source access and durable evidence.

- **Source access**: web search + reference sources (`wikipedia`, `hackernews`, `company-goat` or equivalents)
- **Knowledge base**: repo `docs/` for research memos, competitor briefs, and the source index
- **Work surface**: Paperclip (issues, research requests, approvals) or equivalent task tracker
- **Customer-language archive**: a store for mined review/support/community language

If a company adopts platform-specific tooling, map it here (examples):

- **Research capture**: Notion, Google Docs, Obsidian
- **Source archive**: Pinboard, Raindrop, Zotero
- **Comms intake**: Slack, email, support tool exports

## Smoke tests / evidence checks

These are fast checks to prove the department is "alive" and aligned.

- **Research protocol exists**: a documented protocol defining question refinement, source scoring, and memo structure (`research-protocol` artifact).
- **Source index exists**: at least one scored source index accompanying a recent memo.
- **Recent memo exists**: at least one research memo with citations and recommendations in the last cycle.
- **Question-to-recommendation trace**: a sample memo shows a defined question, scored sources, and recommendations tied to that question.
- **Customer-language artifact exists**: a customer-language report or phrase bank mined from real reviews/support.
- **Approval gates are explicit**: "what requires a human" is listed and used for external publication and competitive claims.

## Cross-company mappings (how Research / Intelligence manifests by company type)

### Software company

- **Primary focus**: competitive features, pricing surfaces, positioning, and adoption signals.
- **Key decisions**: which competitors to track, which feature gaps to prioritize, which claims are safe to make.
- **KPIs**: source coverage, memo throughput, recommendation adoption rate, time-to-memo.
- **Extra gates**: competitive-claim approval before public comparisons; pricing-research accuracy checks.

### Physical product company

- **Primary focus**: market sizing, competitor products, pricing tiers, and channel landscape.
- **Key decisions**: which markets to enter, which competitor products to benchmark, which claims require evidence.
- **KPIs**: market sizing accuracy, competitor coverage, source quality distribution.
- **Extra gates**: regulatory and safety-claim evidence; vendor and supply-market research approvals.

### Local service company

- **Primary focus**: local market demand, competitor services, pricing, and geographic scope.
- **Key decisions**: service area boundaries, competitor benchmarking, local demand signals.
- **KPIs**: local competitor coverage, review-mining volume, demand-signal freshness.
- **Extra gates**: claims about named local competitors; service-area expansion evidence.

### Creator company

- **Primary focus**: niche trends, audience research, platform dynamics, and sponsor landscape.
- **Key decisions**: which niches/trends to chase, audience segmentation, sponsor-fit research.
- **KPIs**: trend coverage, audience-language artifacts, sponsor research throughput.
- **Extra gates**: sponsor-claim accuracy; platform-policy research before strategy shifts.

### Publishing company

- **Primary focus**: genre trends, comp titles, pricing benchmarks, and reader-language mining.
- **Key decisions**: comp-title selection, genre positioning evidence, pricing research inputs.
- **KPIs**: comp-title coverage, genre-trend freshness, reader-language artifact volume.
- **Extra gates**: comp-title claim accuracy; metadata positioning evidence before launch.

### Education / community company

- **Primary focus**: learner needs, competitor courses, pricing tiers, and outcome language.
- **Key decisions**: curriculum scope evidence, competitor course benchmarking, pricing research.
- **KPIs**: learner-needs coverage, competitor course tracking, recommendation adoption.
- **Extra gates**: outcome and accreditation-claim evidence; regulated-curriculum research approvals.

## Foreman integration notes (recommended)

### Stage model for Research / Intelligence tasks

```text
question → gather-sources → score-quality → synthesize → recommend
```

### Context packet requirements (research runs)

- company-brief
- active-task (the research request and refined question)
- role-instructions
- relevant-artifacts (prior memos, source index, customer-language archive)
- constraints (time budget, source access, geography)
- prior-inspection-results (source-quality, conclusion-support, actionability)
- human-decisions (approval state for external publication / competitive claims)
- expected-output-schema (research-memo, source-index, competitor-brief, customer-language-report)