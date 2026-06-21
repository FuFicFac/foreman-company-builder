# Customer Success / Support (Universal Department)

## Purpose

Own the post-purchase customer relationship end to end: onboarding, support, retention, feedback, refunds, complaints, and renewals. Make sure every customer has a clear path to first value and a reliable channel when something goes wrong.

This department is the **trust + retention layer** that protects revenue, captures the voice of the customer, and feeds product, marketing, and ops with real-world signal.

Customer Success converts first impressions into durable relationships — structured onboarding, predictable support SLAs, proactive retention signals, and clean refund/escalation handling that respects both the customer and the company's margins.

## Universal responsibilities

- **Onboard new customers with checklists**: walk every new customer through welcome, setup, first-value, and check-in so time-to-value is short and measurable.
- **Handle support tickets and SLA tracking**: intake, triage, resolve, verify, follow-up — with SLA clocks and escalation paths that are visible.
- **Capture feedback and retention signals**: log complaints, churn signals, expansion asks, and NPS-style feedback in a structured form other departments can use.
- **Process refunds and escalations per policy**: apply the published refund/complaint policy exactly; route exceptions to a human approval gate.
- **Identify expansion and renewal opportunities**: flag accounts ready for upsell, cross-sell, or renewal outreach before the renewal window closes.

## Core workflows

### 1) Support ticket lifecycle

**Inputs**
- inbound customer contact (email, chat, in-app, phone log)
- customer account context and prior ticket history
- active SLA policy and escalation rules
- refund/exception policy

**Process (stages: intake → triage → resolve → verify → follow-up)**
- **intake**: capture structured ticket record with category, severity, and SLA clock start
- **triage**: classify, route, and prioritize; identify policy-bound cases (refund, exception)
- **resolve**: apply fix, response, or escalation; record resolution summary
- **verify**: confirm with customer that the issue is actually resolved
- **follow-up**: close ticket, capture feedback, log retention/expansion signal

**Outputs (evidence artifacts)**
- `ticket-record` (structured case with timestamps and SLA)
- `resolution-summary` (what was done, why, and follow-up owner)

### 2) Customer onboarding

**Inputs**
- new-customer signal (purchase, signup, contract start)
- onboarding checklist template for the product/service
- account context (segment, plan, goals)

**Process (stages: welcome → setup → first-value → check-in)**
- **welcome**: send welcome message and confirm access/details
- **setup**: guide customer through configuration or first setup step
- **first-value**: get the customer to their first meaningful outcome
- **check-in**: verify satisfaction, capture early feedback, flag retention risk

**Outputs (evidence artifacts)**
- `onboarding-checklist` (completed steps, timestamps, owner)

## Required capabilities (department-level)

- **customer-success**: onboarding, support, retention, feedback, refunds — the end-to-end ability to move a customer from purchase to renewal while protecting trust and margin.

## Optional capabilities

- **Self-serve help center / knowledge base** (deflect tier-1 tickets)
- **NPS / CSAT program management** (structured satisfaction measurement)
- **Customer health scoring** (predictive churn and expansion models)
- **Community moderation handoff** (coordination with community-led support)
- **Renewals + contract management** (commercial renewal negotiation)
- **Voice-of-customer program** (systematic feedback routing to product/ops)

## Agents and roles (default roster)

- **Support Lead**: owns SLA policy, ticket lifecycle, escalation paths, and inspector gates.
- **Onboarding Specialist**: runs the onboarding workflow, owns time-to-first-value, flags at-risk new accounts.
- **Retention Analyst**: monitors churn/expansion signals, owns feedback summary, recommends retention actions.

### Inspectors (quality gates for customer-success work)

- **response-quality inspector**: checks that responses are accurate, on-policy, and genuinely resolve the customer's issue.
- **sla-risk inspector**: flags tickets approaching or breaching SLA, and missing escalation paths.
- **retention-opportunity inspector**: flags accounts showing churn risk or expansion readiness that no one has picked up.

## Human approval gates (universal)

Human approval is required for any action that spends company money or changes a customer's commercial relationship.

- **Refund**: any refund outside auto-approve rules.
- **Exception policy**: granting a one-off policy exception (credit, extended trial, SLA waiver).
- **Account credit**: issuing credit to a customer account.
- **Account closure / data deletion** (irreversible customer-facing action)
- **Public response to a complaint** (review reply, social response, regulator-facing letter)

## Tool manifest (minimal viable set)

This department should be able to operate with a small set of tools that provide durable state and evidence.

- **Work surface**: Paperclip (tickets, approvals, onboarding checklists) or equivalent ticket tracker
- **Knowledge base**: repo `docs/` (policies, onboarding templates, FAQ)
- **Comms**: shared inbox or chat workspace for customer contact
- **Numbers**: spreadsheet for SLA and retention tracking

If a company adopts platform-specific tooling, map it here (examples):

- **Support**: Zendesk, Intercom, Front
- **Comms**: slack, email
- **Docs**: Notion, Google Docs

## Smoke tests / evidence checks

These are fast checks to prove the department is "alive" and aligned.

- **Intake schema exists**: support intake fields are defined (`ticket-schema` artifact).
- **Onboarding checklist exists**: a template checklist exists and has been used at least once.
- **SLA policy exists**: documented SLA targets per ticket category.
- **Recent tickets have resolution summaries**: last 5 closed tickets each have a `resolution-summary`.
- **Feedback summary exists**: at least one structured `feedback-summary` from the current cycle.
- **Refund/exception log exists**: refunds and exceptions are logged with approver and amount.

## Cross-company mappings (how Customer Success / Support manifests by company type)

### Software company

- **Primary focus**: SaaS support and churn prevention — keep accounts active and expanding.
- **Key decisions**: SLA tiers by plan, churn-save playbook, in-app support vs human support.
- **KPIs**: ticket volume, first-response time, resolution time, NRR, churn, CSAT.
- **Extra gates**: refund and exception approvals; churn-save offers that affect pricing.

### Physical product company

- **Primary focus**: returns, warranty, shipping issues — post-purchase physical fulfillment.
- **Key decisions**: returns policy thresholds, replacement vs refund, warranty claim handling.
- **KPIs**: return rate, issue resolution time, replacement cost, review impact, repeat rate.
- **Extra gates**: refund and replacement approvals; safety-related complaint escalation.

### Local service company

- **Primary focus**: service complaints and rebooking — protect reputation and utilization.
- **Key decisions**: rebooking incentives, complaint escalation to operator, refund thresholds.
- **KPIs**: complaint rate, rebooking rate, review score, repeat rate, time-to-resolve.
- **Extra gates**: refund and complaint policy changes; liability/safety escalation.

### Creator company

- **Primary focus**: community support and patron relations — audience trust and retention.
- **Key decisions**: community moderation handoff, patron-tier support, refund/chargeback handling.
- **KPIs**: patron retention, community health, response time, chargeback rate.
- **Extra gates**: refund and exception approvals; public response to audience complaints.

### Publishing company

- **Primary focus**: reader support and direct-sales issues — purchase and access problems.
- **Key decisions**: refund window, format/access fixes, review-response policy.
- **KPIs**: refund rate, support volume, review score, direct-sales issue rate.
- **Extra gates**: refund approvals; platform-dispute handling for retail sales.

### Education / community company

- **Primary focus**: student support and community moderation handoff — learning outcomes and community health.
- **Key decisions**: refund policy, moderation escalation, instructor-vs-community support split.
- **KPIs**: completion-adjacent support burden, refund rate, community health, student satisfaction.
- **Extra gates**: refund and policy-change approvals; moderation escalation to human.

## Foreman integration notes (recommended)

### Stage model for Customer Success / Support tasks

```text
Support: intake → triage → resolve → verify → follow-up
Onboarding: welcome → setup → first-value → check-in
```
**Loop mode**: `lean` — standard execution loop with inspection gates at workflow stage boundaries.

### Context packet requirements (customer-success runs)

- company-brief (company type, product/service, customer segment)
- active-task (which ticket or onboarding case is being worked)
- role-instructions (support lead vs onboarding specialist vs retention analyst)
- relevant-artifacts (ticket history, onboarding checklist, feedback summary)
- constraints (SLA policy, refund/exception policy, channel limits)
- prior-inspection-results (last response-quality, sla-risk, retention-opportunity outcomes)
- human-decisions (approved refunds, exceptions, account credits)
- expected-output-schema (`ticket-record`, `resolution-summary`, or `onboarding-checklist`)