---
name: agent-capability-tiers
description: Classify an AI agent product's tools/actions into capability tiers (read, reversible write, approve-gated) to design safe autonomy boundaries. Use when designing what an AI agent may do without human approval, auditing an agent's tool surface, deciding which actions need a human in the loop, or when the user mentions "agent permissions", "tool tiers", "autonomy boundaries", or "human in the loop design".
---

# Agent Capability Tiers

A product-design method for deciding what an AI agent in your product may do
autonomously versus what needs human approval. The output is a tier
classification of every tool/action the agent can reach, which becomes both a
permission model (enforced in code) and a trust story (explained to users).

## The three tiers

- **Tier 1: Read.** Auto-execute, no approval, no proposal. Queries, lookups,
  dashboards, status checks. Constraint: reads must still respect data
  boundaries (an agent principal sees only its own tenant/account, tier has
  nothing to do with scope).
- **Tier 2: Reversible draft writes.** Auto-execute, but rate-limited. No
  customer-visible side effect, no spend, easily undone: drafts, internal
  notes, proposals, staging changes, its own memory. The undo path must
  actually exist and be tested, "conceptually reversible" does not count.
- **Tier 3: Externally visible or irreversible.** Approve-gated. Anything a
  customer could see, anything that spends money, anything without a clean
  undo: sending, publishing, deleting, purchasing, changing access. The agent
  may only PROPOSE these; a human fires the action under their own identity
  and session, so the audit trail shows who really approved.

## How to classify

Work through the full tool list, one row per tool. For each, ask in order:

1. **Side effect, not verb.** Classify by what the action does, not what
   it is called. An "update" that flips a published flag is tier 3; a
   "create" that only makes a draft is tier 2.
2. **Reversibility.** Is there a real, tested undo? Who runs it, and does it
   restore state completely (including downstream effects)?
3. **Visibility.** Can anyone outside the building see the result before a
   human approves it?
4. **Spend and blast radius.** Does it consume budget, send to a delivery
   channel, or touch other tenants' data?

Any "worse" answer bumps the tier up. When two answers conflict, the higher
tier wins.

## State-conditional tiers

Some tools change tier with the target's state: editing a draft is tier 2,
but the same edit on an approved/published entity is tier 3 (it silently
changes something a human signed off on). For every mutating tool, ask "does
this entity have a lifecycle?" and if so, define the tier per status value,
resolved at request time. This is the most commonly missed class; a flat
tool-to-tier table quietly misclassifies these.

## Enforcement principles

- The tier model must be enforced server-side in the permission layer, never
  by prompt instructions alone. The agent principal simply lacks tier 3
  execute permissions; it gets propose-only equivalents.
- Rate-limit tier 2. Reversible at unit scale can still be damaging at
  volume (a thousand drafts, an overwritten memory store).
- Audit all tiers, not just tier 3. Tier 1 read patterns are how you detect
  a misbehaving or compromised agent early.
- Approval UX matters: a tier 3 proposal should show the human exactly what
  will happen (a diff, a preview, the spend), not a summary they must trust.

## Output format

A table per tier: tool, notes (scope caveats, rate limit), plus a separate
state-conditional section listing each lifecycle-dependent tool with its
per-status tier. Flag every tool you could not classify confidently as an
open question rather than guessing it into tier 1 or 2.

## Gotchas

- The dangerous misclassifications are always in tier 2. Pressure-test every
  tier 2 entry with "what is the worst thing 500 of these in an hour does?"
  and "walk me through the undo, step by step".
- Bulk/batch variants of a tier 2 tool are usually tier 3 in practice; list
  them separately.
- "List" endpoints that cross tenant boundaries are a scoping bug wearing a
  tier 1 costume; tiering does not substitute for row-level authorization.
