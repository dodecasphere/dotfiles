---
name: postgres-performance
description: Postgres performance guidance for a Laravel app - reading EXPLAIN, index strategy, jsonb, and safe index creation. Use when diagnosing slow queries, deciding on indexes, designing schema for scale, or interpreting query plans.
---

# Postgres Performance

Practical guidance for keeping a Laravel + Postgres app fast.

## Reading EXPLAIN
- Use `EXPLAIN (ANALYZE, BUFFERS)` to see actual time and rows, not just estimates.
- Watch for: **Seq Scan** on a large table where a filter should use an index; a big gap between estimated and actual rows (stale stats, run `ANALYZE`); **Nested Loop** over many rows (often the query-level shape of an N+1).
- Read inside-out: the most indented node runs first.

## Indexing
- Index foreign keys, and columns used in `WHERE`, `JOIN`, and `ORDER BY`.
- **Composite index column order:** equality columns first, then the range/sort column. An index on `(status, created_at)` serves `where status = ? order by created_at`.
- **Partial indexes** for skewed predicates: `CREATE INDEX ... WHERE deleted_at IS NULL` (or `status = 'active'`).
- **GIN indexes** for `jsonb` containment and full-text search.
- **Covering indexes** with `INCLUDE` to answer a query from the index alone.
- More indexes slow writes and cost storage - index for real query patterns, not hypotheticals.

## jsonb
- Use `jsonb`, never `json`, for anything you query. Index with GIN; query with `@>`, `->>`, and path operators.
- If you filter on one key constantly, consider a generated column + btree index on it.

## Safe schema changes (live DB)
- Create indexes on big tables with `CREATE INDEX CONCURRENTLY` to avoid locking writes. It cannot run inside a transaction, so in Laravel use a dedicated migration with `Schema::withoutTransaction()` (see the db-migration-reviewer agent).
- Adding a `NOT NULL` column with a default rewrites/locks on large tables - prefer add-nullable, backfill in batches, then add the constraint.

## Query habits
- Avoid `SELECT *`; select the columns you use.
- For large result sets, prefer **keyset (cursor) pagination** over `OFFSET` (offset scans and discards rows).
- Push aggregation into SQL rather than looping in PHP. Consider a materialized view for expensive, read-heavy aggregates.

## Connections
- On Forge/DigitalOcean, watch connection counts under load; a pooler (PgBouncer) in transaction mode helps when you have many short requests.
