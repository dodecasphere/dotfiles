---
name: finance-based-pricing-advisor
description: Evaluate the financial impact of a specific pricing change (increase, new tier, add-on, discount) using ARPU, conversion, churn risk, NRR, and payback. Use when you have a pricing move in mind and need a go/no-go with the math. Not for designing pricing strategy or willingness-to-pay research.
---

# Finance-Based Pricing Advisor

Use when a pricing change is already on the table and you need to judge its financial viability. This is impact evaluation, not strategy design: it assumes you know what change you want to make and have baseline metrics.

## The five impacts

1. **Revenue.** ARPU/ARPA lift from the change, minus revenue lost to lower conversion or higher churn. Net it out.
2. **Conversion.** Higher price usually lowers trial-to-paid or sales conversion; better packaging can raise it. Treat the estimate as a hypothesis to test.
3. **Churn risk.** Will existing customers leave? Grandfather existing accounts to protect them. Risk varies by segment (SMB more elastic than enterprise).
4. **Expansion.** Does the change open an upsell path (new tier, usage-based growth, add-on) or block one? Estimate the NRR effect.
5. **Payback.** Higher ARPU speeds payback; lower conversion raises effective CAC. Net effect on LTV:CAC.

Model conservative / base / optimistic. Pull baselines via [[finance-metrics-quickref]].

## Decision patterns

- **Implement:** net revenue positive after modeled churn, risk low (e.g. new customers only, existing grandfathered).
- **Test first:** wide confidence interval or medium churn/conversion risk. Run a 60-90 day cohort A/B on conversion, ARPU, retention, and NRR with pre-set roll-out criteria.
- **Do not change:** net revenue negative or marginal, or high churn risk without offsetting expansion. Redirect to retention, expansion, or CAC efficiency instead, which often deliver the same lift at lower risk.

## Watch for

- Raising prices for everyone immediately: grandfather existing customers or expect a churn spike.
- Price increases with no added value: tie every increase to new features, support, or outcomes.
- Annual discounts >15%: they help cash flow but erode LTV.
- Micro-optimizing price points while ignoring bigger packaging and tier changes that move more revenue.
- No communication plan: announce 30-60 days ahead and lead with value.

## Provenance

Adapted from Dean Peters' Product-Manager-Skills (https://github.com/deanpeters/Product-Manager-Skills), v0.79, CC BY-NC-SA 4.0. Rewritten to house style.
