---
name: prd-writer
description: Write a rigorous product requirements document. Use when the user wants a PRD, spec, or feature definition. Asks a couple of sharp context questions, then drafts a complete PRD; never invents facts.
---

# PRD Writer

Context first: ask at most 2-3 sharp questions (target user, the problem, the outcome that defines success), then draft, leaving `(fill in)` where unknown. A PRD is a thinking tool, not paperwork.

## Structure
- **Problem** - what hurts, for whom, and the evidence it is real.
- **Target user & JTBD** - who, and the job they are hiring this to do.
- **Goals** - the outcomes (with metrics), not the features.
- **Non-goals** - what this deliberately does not do. As valuable as goals.
- **Success metrics** - leading and lagging, each with a baseline and a target.
- **Solution** - the approach at a level an engineer can build from; link mockups.
- **Scope / MVP** - the smallest version that tests the riskiest assumption.
- **Risks & dependencies** - what could kill it, what it relies on.
- **Open questions** - what you still do not know.
- **Rollout** - phasing, guardrails, and how you will know to roll back.

## Rules
- Outcomes over outputs. If a "goal" is a feature, restate it as the change it should produce.
- Every success metric needs a number and a baseline, or it is a wish.
- No invented data. Mark assumptions explicitly.

## Output
Offer to save the PRD as a Markdown file the user can open in Google Docs.

## Hardening pass
When asked to make a PRD "bulletproof," or before any non-trivial PRD goes to
engineering: launch `prd-reviewer` (gap analysis) and `product-critic`
(red-team) in parallel, and independently verify the PRD's technical claims
against the actual code yourself at the same time.

- **Verify every finding before applying it.** Both agents assert plausibly
  but don't always check the real code - a finding can be flat wrong (e.g.
  claiming a tool or API doesn't exist when it does).
- **Harden around a decision the user already made deliberately; don't
  reverse it.** A reviewer will sometimes propose undoing something the user
  chose explicitly during an earlier interview/grill pass. Name the failure
  mode the reviewer found and add a mitigation - don't silently revert the
  decision.
- **Surface strategic/portfolio-level challenges, never act on them
  silently.** A red-team question like "should any of this ship before
  launch?" goes to the user in the open-questions/summary, not into a
  unilateral scope cut.
