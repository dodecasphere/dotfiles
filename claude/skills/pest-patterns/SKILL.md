---
name: pest-patterns
description: Pest 4 testing idioms for a Laravel + Inertia app - datasets, higher-order expectations, architecture tests, mocking/fakes, query-count assertions, and Inertia response assertions. Use when writing or improving Pest tests, setting up architecture tests, or asserting query counts.
---

# Pest Patterns

Idioms for writing good Pest 4 tests on a Laravel + Inertia (plain JS front end) stack. Pairs with the `tdd` skill (test behavior, not implementation).

## Architecture tests (underused, high value)
Pest's `arch()` enforces rules across the codebase with no runtime cost. Add a `tests/Arch` test:
- Ban debug helpers: `arch('no debug')->expect(['dd','dump','ray','var_dump','ds'])->not->toBeUsed();`
- Start from the Laravel preset: `arch()->preset()->laravel();` and `->preset()->security();`
- Enforce layering: `arch('actions')->expect('App\\Actions')->toBeClasses()->toHaveSuffix('Action');`
- Keep models lean / controllers thin by constraining what each namespace may depend on.

## Datasets (parameterized tests)
```php
it('validates email', function (string $email, bool $valid) {
    // ...
})->with([
    ['a@b.com', true],
    ['nope', false],
]);
```
Use named datasets for shared cases; bound datasets for model variants.

## Higher-order expectations
Chain expectations fluently: `expect($user)->name->toBe('Jo')->email->toContain('@');`
Use `expect()->each()` for collections, and define custom expectations in `Pest.php` for domain assertions.

## Query counts (catch N+1 in tests)
- Built in: `$this->expectsDatabaseQueryCount(3);` at the top of a test, or assert a route stays flat as data grows.
- For N+1 specifically, seed multiple rows and assert the count does not scale with row count. Consider mattiasgeniar/phpunit-query-count-assertions for richer checks.

## Inertia responses
```php
$response->assertInertia(fn (Assert $page) =>
    $page->component('Users/Index')->has('users', 3)
);
```
Assert the component and the props shape, not the rendered HTML.

## Mocking and fakes
- Fake the boundaries, not your own code: `Http::fake()`, `Queue::fake()`, `Mail::fake()`, `Event::fake()`, `Storage::fake()`, `Notification::fake()`.
- Use real factories and the Postgres database for feature tests (`RefreshDatabase`). Do not mock Eloquent.
- **Never let a test write directly into a real, shared filesystem path** (`public_path(...)`, or any directory the app itself reads from) via raw `File::put()`/`file_put_contents()`. `--parallel` (paratest) gives each worker its own database but NOT its own filesystem - they all share the same real disk, so a test that drops a real file into a shared directory races against a *different* test asserting a file count in that same directory, intermittently failing depending on process scheduling, not on a real bug (invisible running either file alone). If the code under test needs disk access, give it a named disk in `config/filesystems.php` and have both the app and the tests go through `Storage::disk('name')` - tests then call `Storage::fake('name')` for full isolation. Also check for orphaned real files left by an earlier, pre-fix version of a disk-touching test after a red→green cycle.

## Structure
- `describe()` / `it()` with behavior-named tests; `beforeEach()` for shared setup.
- Feature tests through HTTP/actions by default; unit tests for pure logic.
- Never leave a focused test (`->only()`) behind - it disables the rest of the suite.
