---
name: pre-mortem
description: Structured pre-mortem before declaring an epic or big feature done. Assume it shipped and failed badly in production, work backwards to find what went wrong, output a ranked risk list with mitigations and a go/no-go call. Use before the final merge/deploy of epic-sized work, when the user says "pre-mortem", or before calling a large feature complete. Skip for bug fixes and small changes.
---

# Pre-Mortem

Run this as the LAST step before an epic or big feature is declared done
(final slice, PR to merge, or deploy). The method: assume the work has already
shipped and failed badly in production. Work backwards and ask "what went
wrong?" It surfaces risks that forward-looking review misses, because you are
explaining a failure instead of defending a design.

Scope guard: epics and big features only. For a bug fix or small change, say
pre-mortem is overkill and stop.

## 1. Ground yourself in what actually shipped

Before imagining failures, know the real surface area:

- `git diff` the full branch against its base (or the set of merged PRs that
  make up the epic). List what changed: routes, jobs, migrations, frontend
  surfaces, config, infra.
- Check test coverage of the changed paths. Note anything that shipped without
  a test touching it (these feed the "untested paths" lens below).
- If the project has a Project Brain, read `05-ST-state.md` and any relevant
  decision records so known constraints inform the analysis.

## 2. Work the failure lenses

For each lens, name concrete failures for THIS change, not generic risks.
"Queue worker retries the webhook job and double-charges" is a finding;
"there could be race conditions" is not.

- **Failure modes.** What breaks under load, bad input, partial failure,
  retries, concurrency? Queued jobs mid-transaction, idempotency of
  webhooks/retries, N+1s that only show at production volume.
- **Security / authz.** Missing Gate/Policy checks, IDOR on new endpoints,
  mass assignment, data exposed through Inertia props or API resources.
  (For a deep pass, spawn the security-reviewer agent instead of redoing its
  job here; fold its verdict in.)
- **Data & migrations.** Irreversible changes, missing rollback path, columns
  that need backfill, constraints that fail on real production data shapes
  that local seeds never produce (empty strings, nulls, extreme values,
  ratios outside expected ranges).
- **Observability.** If this fails in production, how do we find out? Logs,
  error tracking, alerts. "A user emails us" is a finding, not an answer.
- **Blast radius.** Who and what else is affected when this fails? Shared
  middleware, `HandleInertiaRequests::share()`, shared throttle buckets,
  other features reading the same tables, background jobs.
- **Untested paths.** From step 1: what shipped with no test? Rank by how bad
  the silent failure would be, not by how easy the test is to write.

## 3. Output

Produce a ranked risk list. For each risk:

- **Risk** (one sentence, concrete)
- **Likelihood x impact** (low/med/high each)
- **Mitigation** (specific action: a test to add, a guard to write, an alert
  to create, or an explicit accept-with-reasoning)

End with a single clear call: **GO** or **NO-GO** for merge/deploy, with the
one or two risks that drove the call. A NO-GO must name exactly what has to
change to flip it.

## 4. Record it

- Offer to log accepted-not-fixed risks to the project's `docs/BACKLOG.md`
  (one backlog file rule) so they are tracked, not lost.
- If the project keeps a Project Brain, offer a one-line Current State (ST)
  note: "pre-mortem run on <epic>, verdict GO/NO-GO, watching <top risk>".
- If a risk was mitigated on the spot (test added, guard written), that work
  follows the normal slice rules: tests green before done.

## Gotchas

- Do not let the pre-mortem become a second code review. Its value is the
  backwards framing (assume failure, explain it), production-shaped thinking
  (load, retries, real data), and the explicit go/no-go. If you catch
  yourself line-commenting, go back up a level.
- Local integration tests seed well-behaved data; production does not. The
  known burn: a materialized view rate column cast to bounded
  `numeric(7,6)` overflowed in production because real data had
  engagements > impressions. Ask "what data shape have we never seen
  locally?" for every new computed column or constraint.
- A GO with unlogged risks is worse than a NO-GO. If nothing gets recorded,
  the pre-mortem was theater.
