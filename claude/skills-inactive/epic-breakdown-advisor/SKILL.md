---
name: epic-breakdown-advisor
description: Break an epic into vertical-slice user stories using Richard Lawrence's Humanizing Work method - INVEST validation then 9 splitting patterns applied in order. Use when an epic is too large to estimate or sequence and you want to split it interactively without losing user value. Companion to the prd-to-stories agent (that batch-converts a finished PRD; this thinks through a fuzzy epic).
---

# Epic Breakdown Advisor

Methodical splitting, not arbitrary slicing. Every story must be a vertical slice (touches multiple layers, delivers observable user value), never a horizontal one ("front-end story" + "back-end story"). Three steps: validate, apply patterns in order, evaluate the result.

## Step 1: Pre-split validation (INVEST, minus Small)

Before splitting, check the story is:

- **Independent:** no hard blocking dependency (flag if there is one).
- **Negotiable:** scope can flex.
- **Valuable:** a user sees or experiences something different. If not, stop. Do not split a technical task; combine it into a meaningful increment or reframe it.
- **Estimable:** the team can size it.
- **Testable:** concrete, verifiable acceptance criteria. If not, refine before splitting.

(Small is the one you are about to fix by splitting.)

## Step 2: Apply the 9 patterns in order

Walk through these until one fits:

1. **Workflow steps:** thin end-to-end slices, not step-by-step phases.
2. **Operations (CRUD):** words like "manage", "handle", "maintain" signal bundled Create/Read/Update/Delete. Split them.
3. **Business-rule variations:** different rules become different stories.
4. **Data variations:** different data types or structures.
5. **Data-entry methods:** simple input first, rich UI later.
6. **Major effort:** "implement one, then add the rest."
7. **Simple/complex:** core simplest version first, variations later.
8. **Defer performance:** make it work before making it fast.
9. **Break out a spike:** time-box investigation when uncertainty blocks the split.

**Meta-pattern across all nine:** identify the core complexity, list the variations, reduce to one complete slice, make the other variations their own stories.

## Step 3: Evaluate the split

Choose the split that either reveals low-value work you can now deprioritize, or produces roughly equal-sized stories. A good split exposes waste; that is part of the payoff, not a side effect.

## Where this fits

Use this upstream, when you have a fuzzy epic and need to think through the cut. Once the PRD is clean and approved, hand off to the `prd-to-stories` agent to batch-generate the full story set with Given/When/Then and a build sequence.

## Provenance

Adapted from Dean Peters' Product-Manager-Skills (https://github.com/deanpeters/Product-Manager-Skills), v0.79, CC BY-NC-SA 4.0. Rewritten to house style.
