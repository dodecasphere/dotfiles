---
paths:
  - "**/database/migrations/**/*.php"
---

# Laravel Migration Rules (Postgres)

- Every migration needs a working `down()`. Destructive operations (drop
  table/column, data-losing type changes) require explicit user approval
  before writing.
- `Blueprint::after('column')` is MySQL-only; Laravel's Postgres grammar
  silently ignores it. New columns always land at the end of the table.
- Assume zero-downtime deploys against real data: backwards-compatible
  first (add column nullable, backfill, then constrain in a later
  migration), and prefer `->index()` additions that won't lock hot tables
  (see the postgres-performance skill for concurrent index strategy).
- Bounded numeric casts on computed rate/ratio columns overflow on real
  data shapes local seeds never produce. Use unbounded `numeric` unless the
  range is proven.
- Before shipping a non-trivial migration, offer to run the
  db-migration-reviewer agent on it.
