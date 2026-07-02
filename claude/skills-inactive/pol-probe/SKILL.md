---
name: pol-probe
description: Define a Proof of Life (PoL) probe - a lightweight, disposable validation to surface harsh truth before expensive development. Use when a specific risk blocks a decision and you need to test one narrow hypothesis cheaply, not build production software. Probes are reconnaissance, meant to be deleted, not scaled.
---

# Proof of Life (PoL) Probe

A deliberate, disposable experiment that answers one specific question as cheaply and fast as possible. Not a product, MVP, or pilot: a targeted truth-seeking mission. It prevents prototype theater (expensive demos that impress stakeholders but teach nothing) and forces you to match the validation method to the real learning goal. Builds on Cagan's prototype flavors and Patton's line: the most expensive way to test an idea is to build production-quality software.

## Probe vs MVP

| | PoL probe | MVP |
|---|---|---|
| Purpose | De-risk a decision, test a narrow hypothesis | Ship the smallest real increment |
| Scope | One question, one risk | Smallest shippable product |
| Lifespan | Hours to days, then deleted | Weeks to months, then iterated |
| Audience | Internal team plus a narrow user sample | Real customers in production |
| Fidelity | Just enough illusion to catch signal | Production-quality or close |
| Teaches | What does not work | What does work, then you ship it |

A probe is pre-MVP reconnaissance: you run it to decide *whether* to build an MVP.

## Use a probe when

- You have a specific, falsifiable hypothesis.
- A particular risk blocks your next decision (technical feasibility, user task completion, stakeholder support).
- You need harsh truth in days, not weeks.
- Building production software would be premature.
- You can describe what "failure" looks like before you start.

## Do not use one when

- You are trying to impress executives (that is prototype theater).
- You already know the answer and want validation (confirmation bias).
- You cannot state a clear hypothesis or a disposal plan.
- The learning goal is too broad ("will customers like this?").
- You are using it to avoid a hard decision.

## Quality checklist

Before launching, confirm every box. If any is "no", revise the probe or reconsider whether you need one.

- [ ] Lightweight: buildable in 1 to 3 days.
- [ ] Disposable: a committed disposal date.
- [ ] Narrow: tests exactly one hypothesis.
- [ ] Brutally honest: the data will hurt if you are wrong.
- [ ] Smaller than an MVP.
- [ ] Falsifiable: you can describe failure.
- [ ] Clear owner: one person accountable for running and disposing of it.

## Provenance

Adapted from Dean Peters' Product-Manager-Skills (https://github.com/deanpeters/Product-Manager-Skills), v0.79, CC BY-NC-SA 4.0. Rewritten to house style.
