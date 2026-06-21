# Distribution / Channel Management (Universal Department)

## Purpose

Decide where and how the product reaches customers — the channels, marketplaces, partners, and platforms that carry the offering — kept deliberately separate from the marketing message.

This department is the **reach + placement layer** that makes sure the product is available in the right places, with complete and compliant listings, and that channel economics and fit are evaluated before a new channel goes live.

Distribution owns channel strategy, listing management, partner coordination, and the distribution tool manifest — so the company doesn't confuse "what we say" (marketing) with "where and how customers actually get it" (distribution).

## Universal responsibilities

- **Define channel strategy**: decide which channels the company sells through, why, and in what priority — with explicit fit criteria and kill conditions.
- **Manage marketplace and platform listings**: keep every listing complete, accurate, compliant, and synced with current product/pricing data.
- **Coordinate partner and channel managers**: assign owners per channel, track partner performance, and manage agreements and renewals.
- **Maintain distribution tool manifest**: keep the toolset for each channel current and documented so a new channel can be stood up without rediscovery.

## Core workflows

### 1) New channel launch

**Inputs**
- new-channel trigger (strategic decision to enter a channel)
- channel fit criteria and economic model
- product/pricing catalog data
- compliance requirements for the target channel

**Process (stages: evaluate-channel → setup-listing → verify-compliance → go-live → monitor)**
- **evaluate-channel**: score fit, economics, reach, and risk against criteria; produce a go/no-go recommendation
- **setup-listing**: build the listing package (copy, assets, pricing, fulfillment config)
- **verify-compliance**: run compliance inspector against platform rules, regulations, and claims
- **go-live**: publish listing and activate channel
- **monitor**: track early performance against launch targets; flag issues for correction

**Outputs (evidence artifacts)**
- `channel-checklist` (launch steps completed, owner, timestamp)
- `listing-artifacts` (published listing references and assets)

## Required capabilities (department-level)

- **distribution-channels**: marketplaces, partners, and channel strategy — the end-to-end ability to evaluate, launch, and operate channels that reach customers.

## Optional capabilities

- **Digital commerce operations** (Shopify/Stripe-backed direct storefront)
- **Partner / reseller program management** (tiered partner agreements and enablement)
- **International / multi-region expansion** (tax, currency, localization)
- **Retail / wholesale operations** (buyer relationships, EDI, shelf planning)
- **Syndication and platform distribution** (podcast, video, content networks)

## Agents and roles (default roster)

- **Distribution Lead**: owns channel strategy, channel portfolio economics, and go/no-go gates.
- **Channel Manager**: owns one or more channels end-to-end — listing health, partner relationship, performance.
- **Marketplace Specialist**: handles platform-specific listing setup, compliance, and optimization.

### Inspectors (quality gates for distribution work)

- **channel-fit inspector**: verifies a proposed channel matches the company's fit criteria and economic thresholds before launch.
- **listing-completeness inspector**: flags listings missing required assets, pricing, copy, or fulfillment config.
- **compliance-check inspector**: flags listings that violate platform rules, regulations, or claim policy.

## Human approval gates (universal)

Human approval is required for any action that commits the company to a new channel, partner, or binding term.

- **New channel**: launching on a channel not previously approved.
- **Partner agreement**: signing or materially amending a partner/reseller agreement.
- **Exclusivity terms**: granting or accepting exclusivity that limits other channels.
- **Listing deletion / channel exit** (irreversible placement decisions)
- **Regulated-claim listings** (health, safety, financial, or accreditation claims)

## Tool manifest (minimal viable set)

This department should be able to operate with a small set of tools that provide durable state and evidence.

- **Work surface**: Paperclip (channel launches, approvals, listing tasks) or equivalent tracker
- **Knowledge base**: repo `docs/` (channel strategy, listing templates, partner briefs)
- **Commerce platform**: one platform capable of publishing and syncing listings
- **Numbers**: spreadsheet for channel economics and per-channel performance

If a company adopts platform-specific tooling, map it here (examples):

- **Commerce**: shopify, gumroad, stripe
- **Marketplaces**: Amazon Seller Central, Apple App Store, Google Play, KDP
- **Docs**: Notion, Google Docs

## Smoke tests / evidence checks

These are fast checks to prove the department is "alive" and aligned.

- **Channel map exists**: active channels are documented with owner and status (`channel-strategy` artifact).
- **Listing package exists**: at least one complete `listing-artifacts` set for an active channel.
- **Channel-launch checklist exists**: the `channel-checklist` template is defined and has been used.
- **Compliance gate ran**: the most recent launch shows a compliance-check inspector pass record.
- **Per-channel economics exist**: each active channel has a margin/contribution estimate.
- **Partner briefs exist**: active partners have a `partner-brief` on file.

## Cross-company mappings (how Distribution / Channel Management manifests by company type)

### Software company

- **Primary focus**: app stores, marketplaces, resellers — getting the product onto platforms customers already use.
- **Key decisions**: which stores to target, reseller vs direct, listing optimization, platform-fee tolerance.
- **KPIs**: channel-attributed installs/revenue, store ranking, listing conversion, platform-fee load.
- **Extra gates**: store agreement terms; platform-policy compliance; reseller margin approval.

### Physical product company

- **Primary focus**: retail, Amazon, wholesale — physical and digital shelves that carry the product.
- **Key decisions**: retail vs DTC mix, Amazon strategy, wholesale terms, fulfillment model.
- **KPIs**: channel sell-through, fill rate, return rate by channel, wholesale margin, on-time fulfillment.
- **Extra gates**: wholesale agreement approval; Amazon/retail compliance; safety and labeling compliance.

### Local service company

- **Primary focus**: directories and partnerships — being findable and referred in the service area.
- **Key decisions**: which directories to list on, partnership/referral terms, geographic coverage.
- **KPIs**: directory-attributed leads, partner referrals, lead-to-book rate by source.
- **Extra gates**: partnership agreement approval; directory-claim accuracy.

### Creator company

- **Primary focus**: YouTube, podcasts, syndication — platforms that carry the content to audiences.
- **Key decisions**: platform priority, syndication deals, multi-platform posting cadence.
- **KPIs**: platform reach, cross-post performance, syndication-attributed growth, platform-revenue share.
- **Extra gates**: syndication/exclusivity terms; platform-policy compliance.

### Publishing company

- **Primary focus**: KDP, Ingram, direct, audio — the channels that put books in readers' hands.
- **Key decisions**: platform mix, print vs audio vs direct, exclusivity (e.g. KDP Select), wholesale terms.
- **KPIs**: sell-through by channel, channel margin, direct vs platform mix, print/digital/audio split.
- **Extra gates**: exclusivity decisions (KDP Select); wholesale and distribution agreement approval.

### Education / community company

- **Primary focus**: LMS, Udemy, own platform — where learners access the content.
- **Key decisions**: marketplace vs owned platform, pricing by channel, accreditation-friendly channels.
- **KPIs**: enrollment by channel, channel margin, completion by channel, platform-fee load.
- **Extra gates**: platform agreement approval; accreditation and regulated-claim compliance.

## Foreman integration notes (recommended)

### Stage model for Distribution / Channel Management tasks

```text
evaluate-channel → setup-listing → verify-compliance → go-live → monitor
```
**Loop mode**: `lean` — standard execution loop with inspection gates at workflow stage boundaries.

### Context packet requirements (distribution runs)

- company-brief (company type, product/service, channel strategy)
- active-task (which channel launch or listing update is being worked)
- role-instructions (distribution lead vs channel manager vs marketplace specialist)
- relevant-artifacts (channel strategy, listing templates, partner briefs)
- constraints (platform rules, compliance requirements, budget, fulfillment capacity)
- prior-inspection-results (last channel-fit, listing-completeness, compliance-check outcomes)
- human-decisions (approved new-channel, partner-agreement, exclusivity decisions)
- expected-output-schema (`channel-checklist`, `listing-artifacts`, or `partner-brief`)