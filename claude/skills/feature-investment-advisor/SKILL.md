---
name: feature-investment-advisor
description: Evaluate whether a feature is worth building using a financial lens - revenue connection, cost structure, ROI, and strategic value. Use when prioritizing expensive features, defending a call to leadership, or choosing direct monetization vs retention. Complements RICE; it is the money view, not a replacement for discovery.
---

# Feature Investment Advisor

A financial lens on a single feature decision. Assumes the problem is already validated; this answers "does the money work?" Deliver a build / build-for-strategy / validate-first / do-not-build call with the math shown.

## The four checks

1. **Revenue connection.** Direct (new tier, add-on, usage charge) or indirect (retention, conversion, expansion enablement)? Name the mechanism.
2. **Cost structure.** Development (one-time), plus ongoing COGS (infra, processing) and OpEx (support, maintenance). Flag if COGS >20% of projected revenue: it dilutes margin.
3. **ROI.** Direct: revenue impact / dev cost. Retention: LTV impact across the affected base / dev cost. Always use gross profit, not top-line revenue.
4. **Strategic value.** Moat, platform enabler, enterprise-deal requirement, or compliance. This can override a weak ROI, but only if you can name which one.

Pull baselines (ARPU/ARPA, churn, gross margin) via [[finance-metrics-quickref]] and model conservative / base / optimistic adoption.

## Decision patterns

- **Build now:** ROI >3:1 in year one (direct) or >10x LTV-to-dev-cost (retention), payback shorter than average customer lifetime.
- **Build for strategy:** ROI marginal but a named strategic reason holds. Ship, but set a 90-day adoption and churn check to re-evaluate.
- **Validate first:** revenue rests on unproven adoption or churn-reduction assumptions. Survey demand, test willingness-to-pay, interview churned customers, then decide against explicit criteria.
- **Do not build:** negative contribution margin even on optimistic adoption, or payback exceeds customer lifetime.

## Watch for

- ROI that ignores payback period: a 5:1 return is worthless if customers churn before you recover the cost.
- "Strategic" used as a catch-all for low-value work. If it is not moat, platform, deal-requirement, or compliance, it is not strategic.
- Building for loud minorities: 50 requests out of 10,000 is 0.5% of the base. Weight requests by revenue and segment.
- Engagement framed as the outcome. Tie the case to revenue or retention; engagement is a leading indicator.

## Provenance

Adapted from Dean Peters' Product-Manager-Skills (https://github.com/deanpeters/Product-Manager-Skills), v0.79, CC BY-NC-SA 4.0. Rewritten to house style.
