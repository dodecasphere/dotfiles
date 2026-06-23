---
name: finance-metrics-quickref
description: Fast lookup for SaaS finance metrics - formula, benchmark, and what a bad number means. Use when you need a quick metric definition, formula, benchmark, or red-flag check during analysis, a board prep, or an investor call.
---

# SaaS Finance Quickref

A cheat sheet, not a tutorial. Scan, find, apply. Benchmarks below assume a B2B SaaS business; adjust by stage (see bottom).

## Revenue and growth

| Metric | Formula | Healthy |
|---|---|---|
| MRR / ARR | Sum of recurring revenue per month / that figure x12 | trend up |
| ARPU / ARPA | MRR / active users (or / accounts) | trend up |
| Logo churn | Customers lost / customers at period start | <2%/mo SMB, <1%/mo enterprise |
| Gross revenue churn | MRR lost / MRR at period start | <2%/mo |
| NRR (net revenue retention) | (Start MRR + expansion - contraction - churn) / start MRR | >100%, great >120% |
| Quick Ratio | (New + expansion MRR) / (churned + contraction MRR) | >4 strong, <2 leaky bucket |
| Expansion share | Expansion MRR / total MRR | 10-30% |

## Unit economics

| Metric | Formula | Healthy |
|---|---|---|
| CAC | Total S&M spend / new customers acquired | context-dependent |
| LTV | (ARPA x gross margin %) / churn rate | >3x CAC |
| LTV:CAC | LTV / CAC | >3:1, <1.5:1 unsustainable |
| CAC payback | CAC / (ARPA x gross margin %) | <12 mo good, >24 mo cash trap |
| Gross margin | (Revenue - COGS) / revenue | >70%, <60% red flag |
| Contribution margin | (Revenue - variable cost) / revenue | >40% |

## Capital efficiency

| Metric | Formula | Healthy |
|---|---|---|
| Net burn | Cash out - cash in | falling as you scale |
| Runway | Cash on hand / net burn | >12 mo, <6 mo critical |
| Rule of 40 | Growth rate % + profit margin % | >=40 |
| Magic number | Net new ARR / prior-quarter S&M | >0.75 good, <0.5 broken GTM |

## Red flags and the fix

| Red flag | What it means | Action |
|---|---|---|
| NRR <100% | Base is contracting | Fix expansion or churn before scaling |
| Quick Ratio <2 | Barely outpacing losses | Fix retention before acquisition |
| Revenue churn > logo churn | Losing your big accounts | Investigate high-value departures |
| Top 10 customers >50% of revenue | Concentration risk | Diversify the base |
| LTV:CAC <1.5:1 | Buying revenue at a loss | Cut CAC or raise LTV |
| Payback >24 mo | Cash recovery too slow | Annual prepay or cut CAC |
| Runway <6 mo | Survival crisis | Raise or cut burn now |
| Rule of 40 <25 | Burning without growth | Improve growth or cut to profit |
| Magic number <0.5 | S&M engine broken | Fix GTM before spending more |

## Decision frameworks

**Should we build this feature?** Check revenue impact (direct or via retention), margin/COGS impact, and ROI. Build if year-one ROI >3x on direct monetization, or LTV impact >10x dev cost on retention, or clear strategic value. Do not build if contribution margin goes negative even on optimistic adoption, or payback exceeds average customer lifetime. (See feature-investment-advisor.)

**Should we scale this channel?** Compare CAC, LTV:CAC, payback, and NRR by channel against your best channel, not the company average. Scale only if unit economics hold at higher volume.

**Should we change pricing?** Check ARPU/ARPA lift, conversion impact, churn risk, NRR effect, and payback. Implement if net revenue is positive after modeled churn and you can test a segment first. (See finance-based-pricing-advisor.)

## Stage benchmarks

- **Pre-$10M ARR:** growth >50% YoY, LTV:CAC >3:1, gross margin >70%, runway >12 mo. Negative margins acceptable if unit economics work.
- **$10M-$50M ARR:** growth >40% YoY, NRR >100%, Rule of 40 >40, magic number >0.75.
- **$50M+ ARR:** growth >25% YoY, NRR >110%, Rule of 40 >40, near or above cash-flow positive.

## Sources

Bessemer "SaaS Metrics 2.0", David Skok (Matrix), Tomasz Tunguz (Redpoint), SaaStr benchmarking surveys.

## Provenance

Adapted from Dean Peters' Product-Manager-Skills (https://github.com/deanpeters/Product-Manager-Skills), v0.79, CC BY-NC-SA 4.0. Rewritten to house style.
