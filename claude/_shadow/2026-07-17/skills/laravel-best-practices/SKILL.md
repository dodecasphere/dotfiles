---
name: laravel-best-practices
description: Conventions for writing Laravel (PHP) backend code on a Postgres database. Use when creating or changing controllers, models, migrations, queries, validation, jobs, or services in a Laravel app.
---

# Laravel Best Practices

Backend guidance for a Laravel + Postgres app. Match the project's existing patterns first; this is the default when none is set.

## Controllers stay thin
- Validate with Form Request classes, not inline `$request->validate()` in big actions. Put `authorize()` there too.
- Push business logic into Action or Service classes (single public method, e.g. `CreateInvoice::handle()`). Controllers orchestrate, they do not contain domain logic.
- Prefer single-action invokable controllers for one-off endpoints.
- Authorize every state-changing or owner-scoped endpoint with a Policy or Gate. Never trust the route alone.

## Eloquent and queries
- Kill N+1: eager-load with `with()` / `load()`, guard relations in resources with `whenLoaded()`. Never query inside a loop.
- Select only the columns you need; avoid `SELECT *` on wide tables.
- Use `chunk()` / `chunkById()` / `cursor()` / lazy collections for large sets, never `all()` then iterate.
- Wrap multi-write operations in `DB::transaction()`.
- Keep models lean: relationships, casts, scopes, accessors/mutators, and `booted()` only. No query-returning helper methods on the model.
- Use casts and enums (`enum` casts, native PHP enums) instead of magic strings.

## Postgres specifics
- Use real types: `jsonb` (not `json`) for queryable JSON, `timestamptz` for timestamps, proper numeric/decimal for money.
- Add indexes for foreign keys and frequent filters; consider partial and GIN indexes (jsonb, full-text) where they pay off.
- Use `citext` or normalized casing for case-insensitive uniqueness rather than `LOWER()` everywhere.

## Validation, serialization, config
- Form Requests for input rules; API Resources (or Inertia props) for output shaping. Respect `$hidden` / never leak secrets or tokens.
- Read config via `config()`, not `env()`, outside `config/*` files (env returns null once config is cached).
- Offload slow work (mail, external APIs, image processing) to queued jobs.

## Testing
- Pest by default. Test behavior through the public surface (HTTP/feature tests), not implementation. Use factories; avoid asserting on internal query shapes.

## Things to avoid
- Mass-assignment holes: keep `$fillable` tight; never `Model::unguard()`.
- Raw unbound SQL (`whereRaw`/`DB::raw`) with user input.
- Fat models, fat controllers, and logic duplicated across both.

## Finishing a slice
A slice isn't ready for the user to test locally just because the code is
done. When it **adds/changes a migration**, run `php artisan migrate` against
the local dev DB. When it **touches `resources/` (Vue/CSS/JS) or front-end
deps**, run the build (`npm run build`) so the app doesn't serve stale
assets. A `post-merge` git hook can automate this on merge, but don't rely on
it alone - run both proactively before telling the user to verify, especially
right after a DB/frontend-touching slice.
