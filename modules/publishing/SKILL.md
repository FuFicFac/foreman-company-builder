# Publishing Company Swarm Template

A publishing company is not just a writing room. It is an operating company that acquires, edits, packages, prices, sells, markets, supports, analyzes, and repeats.

This template composes **business capabilities** instead of assuming that “publishing = writing tools.” If the company sells ePubs or PDFs directly, it needs commerce tools like Shopify, Stripe, Gumroad, email marketing, customer support, and sales analytics alongside editorial agents.

## Core Principle

Foreman should ask what the publishing business actually does, then load the right capabilities.

```text
Publishing company
├── Editorial / production
├── Metadata / packaging
├── Direct commerce, if selling direct
├── Audience growth / email marketing
├── Launch operations
├── Analytics
└── Customer support / fulfillment
```

## Capability Bundles

### Required: Editorial

Use the StoryCraft Machine editorial room as publishing inspectors.

- **VEGA — Voice:** authorial voice, rhythm, diction, register, personality on the page
- **RIFF — Pacing:** narrative momentum, scene/sequel balance, paragraph rhythm, information flow
- **IRIS — Character:** motivation, relationship logic, character-specific voice
- **FINCH — Continuity:** timeline, facts, names, locations, plot logic
- **STORM — Structure:** scene purpose, dramatic question, stakes, thematic coherence
- **ZIGGY — Market:** genre promise, reader expectations, hook, commercial viability

### Required: Metadata / Packaging

Publishing work must leave the writing cave and become a product.

Inspectors check:

- title/subtitle clarity
- series naming
- author name / imprint consistency
- book description / sales copy
- BISAC/category fit
- keyword strategy
- ISBN / edition metadata
- format readiness: ePub, PDF, print, audiobook, serial
- cover/package alignment with genre promise

### Conditional: Digital Commerce

If selling direct from the publisher’s own site, enable commerce capability.

Recommended tools:

- Shopify — storefront, products, bundles, discount codes
- Stripe — payments, subscriptions, invoices, direct checkout
- Gumroad / Lemon Squeezy — simple digital delivery and fallback storefront

Commerce inspectors check:

- checkout path works
- product page matches metadata
- digital delivery is configured
- tax/VAT risk is noted
- refund/support path exists
- discount codes and bundles do not undercut launch strategy

### Recommended: Audience Growth / Email Marketing

A publishing company needs readers it can reach again.

Recommended tools:

- Klaviyo
- Mailchimp
- Beehiiv
- Substack / newsletter platform, if used

Inspectors check:

- reader magnet clarity
- list segment logic
- launch email sequence
- preorder / release cadence
- call-to-action quality
- promise-to-product alignment

### Recommended: Analytics

Inspectors check:

- sales by title
- conversion rates
- email performance
- ad ROI
- refunds / chargebacks
- series read-through
- preorder performance
- launch-week deltas

### Optional: Operations / Support

For fulfillment, contractors, reader support, and repeatable production.

Recommended tools:

- Linear / Notion / Airtable for production tracking
- Slack / email for support and contractor coordination
- Calendar for launch and production milestones

## Onboarding Questions

Foreman should ask:

1. Are you publishing fiction, nonfiction, comics, courses, or mixed?
2. Are you selling direct from your own site?
3. Are you also publishing through marketplaces?
   - Amazon KDP
   - Apple Books
   - Kobo
   - Google Play Books
4. What formats are you producing?
   - ePub
   - PDF
   - print
   - audiobook
   - serialized web fiction
5. Do you need payments or storefront tools?
   - Shopify
   - Stripe
   - Gumroad
   - Lemon Squeezy
6. Do you need email marketing?
   - Klaviyo
   - Mailchimp
   - Beehiiv
7. Do you need reader/community management?
8. Do you need contractor workflow?
9. What must be human-approved?
   - price changes
   - publishing/distribution
   - ad spend
   - customer refunds
   - email blasts

## Builder Prompts

### Manuscript / Chapter Draft

You are a publishing builder drafting or revising manuscript text. Follow the outline, author voice, genre promise, and editorial constraints. Do not over-explain. Deliver clean manuscript prose.

### Metadata Package

You are a publishing metadata builder. Produce a complete product metadata package: title, subtitle, series, author/imprint, categories, keywords, short description, long description, content warnings if needed, and format notes.

### Product Page

You are a direct-commerce product page builder. Write a Shopify/Gumroad-ready product page for the book or bundle. Include hook, benefits, format/delivery notes, price framing, FAQs, refund/support language, and clear CTA.

### Launch Plan

You are a publishing launch operator. Build a launch plan with dates, assets, email beats, social beats, review/ARC milestones, marketplace/direct-sales steps, and human approval gates.

### Email Sequence

You are an email marketing builder for a publishing company. Draft a concise sequence with subject lines, audience segment, send timing, CTA, and purpose for each email.

## Inspector Routing

### Lean Mode

Use two inspectors based on task type:

- Manuscript draft → VEGA + STORM
- Scene revision → triggering editor + FINCH
- Metadata/package → Metadata + ZIGGY
- Product page → Commerce + ZIGGY
- Launch plan → Launch + Analytics
- Email sequence → Audience Growth + ZIGGY

### Deluxe Mode

Use independent inspectors, then Foreman synthesizes:

- Editorial work → all six StoryCraft inspectors
- Commerce work → Commerce + Metadata + ZIGGY
- Launch work → Launch + Audience Growth + Analytics
- High-stakes money/publishing decisions → two independent inspectors plus Foreman adjudication

## Acceptance Rules

Foreman only accepts publishing work when:

- the product matches the intended reader promise
- the metadata/package is coherent
- direct-sales paths are explicitly checked when relevant
- tool requirements are listed, not guessed
- risky actions are marked for human approval
- inspectors agree there are no blocking editorial/commercial issues

## Escalation Rules

Escalate to the human/chairman when:

- price, discount, refund, or ad-spend decisions exceed the approved policy
- publishing/distribution would go live
- the builder fails the same issue 3 times
- inspectors disagree on creative direction rather than correctness
- commerce setup requires credentials or platform access not yet granted
