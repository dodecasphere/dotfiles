---
name: context-engineering-advisor
description: Diagnose context stuffing vs context engineering in an AI workflow and fix it - bounded domains, just-in-time retrieval, and the Research/Plan/Reset/Implement cycle. Use when an AI workflow feels bloated or brittle, you are pasting whole PRDs or codebases and getting vague output, or results are inconsistent run to run.
---

# Context Engineering Advisor

Context stuffing assumes volume equals quality ("paste the whole PRD"). Context engineering treats AI attention as a scarce resource and allocates it deliberately. This is about the information architecture that grounds a model in reality, not prompt wording.

## Why stuffing fails

LLMs hold static, non-attributable parametric knowledge from training. Context bridges to current and proprietary reality, but more context is not better context:

- **Reasoning noise:** irrelevant material competes for attention and degrades multi-hop logic.
- **Context rot:** dead ends, past errors, and stale data accumulate and drift the goal.
- **Lost in the middle:** models weight the beginning and end and skim the middle.
- **Degradation at scale:** accuracy falls off sharply once context grows large.
- **Economic waste:** every query gets more expensive with no accuracy gain.

## Five markers of stuffing

1. Reflexively expanding the context window ("just add more tokens").
2. Persisting everything "just in case" with no retention criteria.
3. Chaining agents that pass everything downstream with no boundaries.
4. Adding evals to mask inconsistency instead of fixing it.
5. Normalized retries ("it works if you run it three times").

## Five diagnostic questions (Context Hoarding check)

1. What specific decision does this support? If you cannot answer, you do not need it.
2. Can retrieval replace persistence? Just-in-time beats always-available.
3. Who owns this context boundary? If no one, it grows forever.
4. What fails if we exclude this? If nothing breaks, delete it.
5. Are we fixing structure or avoiding it? Stuffing often masks bad information architecture.

## The fix: Research, Plan, Reset, Implement

1. **Research:** the agent gathers data into a large, noisy context window.
2. **Plan:** synthesize it into a high-density SPEC or PLAN as the source of truth.
3. **Reset:** clear the entire context window to prevent rot.
4. **Implement:** start a fresh session using only the compressed plan.

This eliminates rot by starting clean with high-signal context. Combine with bounded domains (scope each agent to one job) and episodic retrieval (pull facts when needed, do not preload).

## Provenance

Adapted from Dean Peters' Product-Manager-Skills (https://github.com/deanpeters/Product-Manager-Skills), v0.79, CC BY-NC-SA 4.0. Rewritten to house style.
