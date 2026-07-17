# Shadowed 2026-07-17: global CLAUDE.md stack gotchas subsumed into Engineering OS packs

Source: `claude/CLAUDE.md` (Default workflow section). Shadowed per IDEA-013 stage 2
(engineering-os repo, plan `.engineering-os/evidence/IDEA-013/global-namespace-plan.md`),
approved by Mike 2026-07-17. 24 entries, verified line by line as present with evidence
tags in the EOS pack copies before this cut.

Destinations: packs laravel (8), laravel-inertia (3), postgres (1), laravel-pest (1),
tailwind (2), css (4), browser-testing (5) at
`engineering-os/plugins/core/references/packs/`.

Restore: paste any entry back into the Default workflow list of `claude/CLAUDE.md`,
or `git revert` the commit that added this file.

Removal eligible after 14 clean days: 2026-07-31.

- **Browser-verifying Livewire/Inertia via Playwright MCP.** The MCP
  `browser_click` often does not fire Livewire/Inertia actions (form submits,
  checkbox toggles, Filament row actions) — it reports success but no request
  goes out. Use `browser_evaluate` with a native `.click()` or
  `form.requestSubmit()` instead. The app is usually fine; it's a harness quirk,
  so confirm via the network/DOM before declaring a real bug. This isn't
  Livewire/Inertia-specific either — Reka UI / Radix-style listbox and combobox
  components (e.g. a `ComboboxItem`'s `role="option"`) have the same problem:
  MCP's synthetic `click()` on the option doesn't always register the
  library's pointer-driven select handler, even though the click visibly
  lands. Same fix: `browser_evaluate` with a native `element.click()`. Also:
  `browser_file_upload` only accepts paths inside the allowed roots (the project
  dir / `.playwright-mcp`), not the scratchpad or `/tmp` — copy the fixture into
  the repo (e.g. a gitignored `.playwright-mcp/`) first. Trigger the chooser with
  a native `.click()` on the file input, then call `browser_file_upload`.
- **Inertia cancels an in-flight visit when a new one starts.** Looping
  `router.post`/`router.visit` calls back to back (e.g. one POST per item in a
  batch operation) fires them from the browser in quick succession, but Inertia
  only tracks one active visit — each new call aborts the previous, so only the
  last one in the loop actually completes; the rest silently vanish with no
  error surfaced anywhere. Never fire a second Inertia request before the first
  has finished: resolve a promise from the request's own `onFinish` callback
  and `await` it inside a `for...of` loop (not `.forEach`, which can't await).
  Caught by reasoning through Inertia's visit-cancellation behavior before
  shipping a CrestLite batch-copy feature, not from a bug report — worth
  checking for this pattern any time a loop fires more than one `router.*`
  call.
- **Tailwind CSS v4 ships `animate-in`/`animate-out` plus the `fade-in`/
  `fade-out`/`zoom-in-N`/`zoom-out-N`/`slide-in-from-*`/`slide-out-to-*`
  modifier utilities natively** (this was a separate community
  `tailwindcss-animate` plugin dependency in v3) — no plugin install needed
  to add an enter/exit transition to a Reka/Radix-style overlay or dialog
  content element via `data-[state=open]:`/`data-[state=closed]:` variants.
  Don't assume a plugin is missing just because the utility isn't obviously
  documented in v4's core docs; check whether it's already core before
  reaching for `tw-animate-css` or similar.
- **Laravel queued jobs inside `DB::transaction`:** events implementing
  `ShouldDispatchAfterCommit` defer safely, but queued JOBS don't get that
  contract — with `after_commit => false` on the connection (the default), a
  job dispatched mid-transaction pushes before the commit it depends on. Fix
  per job: set `$this->afterCommit = true` **in the constructor body**. Do NOT
  redeclare it as a typed class property (`public bool $afterCommit = true;`)
  — that fatally conflicts with `Illuminate\Bus\Queueable`'s own untyped
  `public $afterCommit;` (a compile-time trait-property conflict that can
  present as a zero-output silent crash of the whole test run, not a readable
  error).
- **Laravel migrations on Postgres:** `Blueprint::after('column')` for column
  positioning is a MySQL-only feature — Laravel's Postgres grammar silently
  ignores it (no error, no warning). A new column always lands at the end of
  the table on Postgres regardless of `after()`. Don't trust that clause's
  intent to hold true in a Postgres-backed project.
- **`php artisan <command> --env=testing` does NOT guarantee isolation from
  the real database.** Laravel only loads a separate `.env.testing` file if
  one actually exists in the project root; if it doesn't, Artisan silently
  falls back to plain `.env` — which normally points at the real local dev
  database. `phpunit.xml`/Pest test runs are unaffected (they set
  `DB_CONNECTION=sqlite`/`:memory:` as env vars directly in the XML,
  bypassing dotenv). The danger is specifically a manual `artisan
--env=testing` sanity check outside the real test suite. Wiped a real local
  Postgres database this way on a project with no `.env.testing` file.
  Before ever running `--env=testing` (or any `--env=X`), check `ls .env.X`
  first; if it's absent, don't run the command that way — rely on the real
  test suite instead, or point at an explicitly separate, verified
  connection.
- **CSS stacking contexts and negative z-index.** `position: relative` alone
  does NOT establish a new stacking context for its children — only adding an
  explicit `z-index` (or `opacity<1`/`transform`/`filter`) does. A child given
  a negative z-index (e.g. `-z-10`, common for "background image behind
  text") on a plain-relative parent escapes to the nearest real ancestor
  stacking context instead of stacking locally, and can end up painting
  behind unrelated content elsewhere on the page — invisible with no console
  error, no failed network request, nothing wrong in isolated inspection of
  the element itself (opacity/src/geometry all correct via
  `getComputedStyle`/`getBoundingClientRect`). Cost real debugging time
  before catching it via an actual rendered screenshot, not code review.
  Prefer the standard pattern instead: background layers get `z-0`,
  foreground content gets `relative z-10`, both inside a parent that itself
  has an explicit `z-index` (or otherwise establishes its own stacking
  context).
- **A flex row with `items-center` and no explicit height takes its height
  from whichever child is tallest at that moment.** A conditionally-rendered
  sibling (e.g. a clear button shown only once a search box has text) that's
  taller than the row's baseline content (icon/text line-height) grows the
  whole row the instant it mounts — no error, just a visible layout jump.
  Root-caused via plain Tailwind class arithmetic (button height vs. line-
  height), no browser needed. Give the row an explicit height matching the
  tallest state instead of relying on implicit content-driven height whenever
  any child's presence or size is conditional.
- **Chrome's Local Network Access (LNA) superseded Private Network Access
  (PNA) as of Chrome 142, Oct 2025.** A cross-origin fetch from a public page
  into a private/loopback-resolving address (a local `*.test` dev domain
  included — LNA classifies by *resolved IP*, not domain name) is now gated
  behind a native one-time browser permission prompt, not just response
  headers. `Access-Control-Allow-Private-Network: true` (the old PNA header)
  is still correct to send — some enforcement modes still check for it, and
  it's harmless either way — but it can no longer fully explain or fix "this
  cross-origin request to my own local dev server is silently failing"; the
  browser's own permission gate is a separate, unavoidable layer on top. A
  real production domain (public IP) shouldn't trigger it at all, so this is
  primarily a local-dev-testing wrinkle for anything that injects a script or
  fetches cross-origin into an app running on a `*.test`/loopback address
  (bookmarklets, browser extensions, local API testing from an external
  page) — don't burn a debugging session assuming a header-only fix will
  close the loop; verify in a real (non-headless) browser whether the
  permission prompt itself is the remaining blocker.
- **Laravel `Route::prefix(x)->options(uri, action)` (or any single
  route-registering call) chained directly as a bare statement — not
  wrapped in `->group()` — merges an enclosing route-group's own prefix in
  the wrong order.** Registering a lone OPTIONS route this way inside a
  file already wrapped in an outer group (e.g. `routes/api.php`'s automatic
  `prefix('api')` wrapper) produced `v1/bookmarklet/api/{any}` instead of
  `api/v1/bookmarklet/{any}` — the outer prefix landed in the middle of the
  URI, not the front. The identical prefix chain ending in
  `->group(fn () => Route::options(...))` composed correctly. Confirmed via
  `php artisan route:list -v` before and after, not assumed. Fix: always
  wrap a `Route::prefix()` chain in `->group()` before registering routes
  inside it, even for just one route — never chain a route-registering
  method directly off `prefix()` as a bare statement.
- **Laravel's bare `throttle:N,1` middleware shares one bucket per user across
  every route using it**, not per-route — the default key is `domain+user_id`
  only, no route/path component. When writing a test that expects two
  different throttled endpoints to rate-limit independently, don't combine
  them in one test; test each route's throttle in its own `it()`, or the
  first route's requests will exhaust the second's budget too.
- **Laravel `Gate::define` closures need a nullable-typed first parameter to
  ever run for a guest.** A gate meant to allow unauthenticated access (e.g.
  `Gate::define('viewApiDocs', fn (): bool => true)`) silently denies every
  guest caller regardless of what the closure returns, if the closure takes
  zero parameters. `Gate::callbackAllowsGuests()` only evaluates the callback
  for an unauthenticated request when its first parameter exists and is
  nullable-typed (`?User $user`) — `isset($parameters[0])` gates the whole
  guest path. No error, no log line; `Gate::allows(...)` just returns `false`.
  Confirmed via `php artisan tinker` isolating the exact zero-arg-vs-nullable-
  arg behavior before trusting a fix. Caught by a failing Pest test
  (`assertOk()` got a 403), not by inspection — worth writing that test
  whenever a gate is meant to gate a *public* route.
- **An Inertia `HandleInertiaRequests::share()` entry runs on every single
  page load, including ones that have nothing to do with it.** Adding a
  per-feature check there (e.g., a feature-flag lookup only two pages
  actually use) silently adds that check's queries to the *entire app*, not
  just the pages that need it. Caught via 3 unrelated query-count regression
  tests going red by exactly the number of queries added. Compute
  feature-specific data in that feature's own controller action/
  `Inertia::render()` props instead of the global `share()`, unless the data
  is genuinely needed on every page (auth user, flash messages).
- **Laravel Pennant's `Feature::deactivateForEveryone()`/`activateForEveryone()`
  only `UPDATE`s scope rows that have already been resolved at least once**
  (`Drivers\DatabaseDriver::setForAllScopes()` is an `UPDATE ... WHERE name =
  ...`, not an upsert) — a scope that has never touched the flag yet (a
  brand-new user, or any scope after `Feature::purge()`) still falls back to
  the class's own `resolve()` default on its next read, silently un-killing a
  "global" deactivate for that one scope. Airtight only when the scope never
  varies (e.g. an unauthenticated route's shared null/guest scope, which
  always resolves to the same single row); for a per-user-scoped flag, a
  "deactivate for everyone" click is not a durable guarantee against future
  users without additional design (e.g. `resolve()` itself consulting a
  separate, always-checked durable global toggle). Confirmed against the
  vendored driver source, not just the docs, before relying on it.
- **Tailwind CSS v4's `z-index` utility isn't capped at the classic v3 scale
  (0/10/20/30/40/50/auto)** — a bare integer class like `z-60`/`z-70`/`z-80`
  compiles fine (`.z-70{z-index:70}`), confirmed by inspecting real generated
  CSS in `public/build/assets/*.css`, not assumed. No `theme.extend` or
  arbitrary-bracket syntax (`z-[70]`) needed for a custom stacking tier —
  useful when a design system needs more than 6 z-index tiers (e.g. a
  confirm-dialog-over-dialog case).
- **A rounded-corner or bordered element that is also its own native scroll
  container (`overflow-y-auto`/`scroll` on the same element as
  `rounded-*`/`border`) leaks a thin sliver of the page's background through
  the corner/border during momentum/rubber-band overscroll** — a real
  WebKit/Blink scroll-compositing artifact, not a CSS mistake in the
  element's own styling (`border-radius`/background/`overflow` are all
  individually correct; it only shows up during the bounce animation). Fix:
  never let the rounded/bordered element scroll itself — wrap its content in
  a plain, unrounded, unbordered inner `div` that owns `overflow-y-auto`,
  while the outer element only clips via `overflow-hidden`. Any rubber-band
  bounce inside the inner wrapper then gets clipped by the outer's boundary
  instead of painting past it. This can't be verified via headless/automated
  browser tools (real trackpad/touch momentum physics); needs a real device
  to confirm the fix.
- **A real Inertia visit (`router.post`/`.patch`/`.delete`/etc.) always sends
  `Accept: text/html, application/xhtml+xml`, never `application/json`**
  (confirmed in `@inertiajs/core`'s own source, not assumed) — so
  `$request->wantsJson()` reliably distinguishes a real Inertia visit from a
  plain `fetch()` call to the same Laravel route, useful when one route must
  serve both a full-page Inertia flow and a modal's fetch()-based flow with
  different response shapes (redirect+session-flash vs. real JSON).
  Separately: once a Laravel app registers
  `$exceptions->shouldRenderJsonWhen($callback)`, that callback becomes
  **authoritative** for every exception app-wide — it replaces
  `expectsJson()`'s default check entirely rather than supplementing it, so
  a route left out of the callback never gets JSON error rendering
  regardless of the request's actual Accept header, and a route inside it
  needs its own `wantsJson()`-style condition if it must still serve
  non-JSON callers correctly.
- **A Laravel validation rule that isn't `required`/implicit (e.g. bare
  `array`) is silently *skipped* — not run, not failed — whenever the raw
  input value is a literal empty string, regardless of whether `nullable`
  is also present.** Confirmed by reading
  `Illuminate\Validation\Validator::presentOrRuleIsImplicit()`:
  `is_string($value) && trim($value) === ''` short-circuits straight to
  `$this->isImplicit($rule)`, which is `false` for `array` (and most other
  type rules), so the rule never actually executes and the empty string
  passes through unchanged into `validated()`. This does **not** reproduce
  on a normal web route via a `FormRequest`, because Laravel's own
  `ConvertEmptyStringsToNull` middleware — still part of the stock `web`
  middleware group by default, even under Laravel 11+'s slim
  `bootstrap/app.php` config style, easy to assume it's gone — converts
  `''` to `null` before validation ever runs, and a bare `array` rule
  *does* correctly reject `null`. The gap is real only for entry points
  that bypass the HTTP kernel entirely: an MCP/JSON-RPC request object, a
  queued job reading raw array input, a console command, any hand-rolled
  `Validator::make()` call fed data that skipped the kernel. A client that
  sends `""` for an unused array-typed field instead of omitting it (or
  sending `[]`/`null`) will crash a downstream `array_map()`/`array_flip()`
  with a raw `TypeError` instead of a clean validation error. Before
  assuming a `FormRequest`-guarded route shares a bug found on a non-HTTP
  entry point, reproduce it there directly — don't extrapolate from one
  path to the other.
- **A visually "covered by something with higher z-index" symptom is often
  actually `overflow: hidden` clipping on an ancestor, not a stacking-order
  bug.** When an element is deliberately positioned to straddle or extend past
  a container's boundary (e.g. a handle/badge meant to overlap an edge), check
  whether any ancestor has `overflow-hidden` (often present for an unrelated
  reason, like clipping content during a width/height transition) before
  assuming z-index needs adjusting. The visual symptom — part of the element
  silently disappearing past a boundary — looks identical to the naked eye
  whether it's clipping or genuine stacking, but only one has a z-index fix;
  the other requires moving the element outside the clipping ancestor (a
  sibling wrapper) instead of nesting it inside.
- **Verifying CSS `:hover`/`:focus-visible` behavior needs Playwright's real
  `hover()`/keyboard actions, not synthetic JS events.** Dispatching a
  synthetic `MouseEvent('mouseover')` via `element.dispatchEvent()` does NOT
  trigger real CSS `:hover` (that requires the browser's actual pointer
  state) — use Playwright's `browser_hover` (a real mouse move) instead.
  Similarly, calling `element.focus()` programmatically doesn't reliably
  trigger `:focus-visible` in all cases — verify with
  `element.matches(':focus-visible')` after focusing, or drive real keyboard
  Tab navigation, before trusting a hover/focus-only style actually applies.
- **`document.elementFromPoint(x,y) === targetElement` gives false negatives
  when checking for overlap/clipping bugs, if the target has its own child
  content at that point** (e.g. an icon SVG centered inside a button) —
  `elementFromPoint` returns the deepest element, which is legitimately a
  child, not something external covering it. Check
  `targetElement.contains(elementFromPoint(x, y))` instead of strict `===` to
  correctly distinguish "my own child is on top here" (fine) from "something
  else is covering this" (the actual bug).
- **Playwright MCP blocks `file://` URLs entirely.** For a quick static
  HTML/CSS layout check that doesn't need the full app (e.g. verifying a
  Tailwind class's rendered box size before wiring it into a real component),
  copy the throwaway HTML file into the project's own `public/` dir
  temporarily and serve it via the local dev domain (e.g.
  `https://project.test/tmp-check.html`) instead of `file://` — then delete
  it afterward. Confirmed via Herd; likely applies to any local dev server.
- **Rector's `AddArrowFunctionReturnTypeRector` can mis-infer Pest's
  `fn () => expect(...)->toBeFalse()` (or any `expect()`-returning arrow fn)
  as returning `Pest\Mixins\Expectation`** — an IDE-helper mixin class, not
  the real runtime return type `Pest\Expectation`. Applying it fatals every
  affected test with a return-type mismatch (`TypeError: ... must be of type
  Pest\Mixins\Expectation, Pest\Expectation returned`), not a silent no-op.
  Confirmed by re-running `vendor/bin/rector --dry-run` after manually
  reverting the closure — it reliably re-proposes the same broken rewrite,
  not a one-off fluke. Fix: skip `AddArrowFunctionReturnTypeRector` for the
  specific file(s) via `rector.php`'s `withSkip()`; don't leave the type hint
  in place or try to correct it to `Pest\Expectation` (Pest's actual return
  type isn't guaranteed stable enough to hardcode).
- **Larastan (`treatPhpDocTypesAsCertain`, on by default) treats a vendor
  package's own `@property` docblock as ground truth even when the
  property's real magic-accessor logic can return a different value.** Hit
  with `Laravel\Passport\AccessToken`: its docblock claims
  `oauth_access_token_id` is always a non-null `string`, but `__get()`
  genuinely returns `null` when there's no backing `Token` row (e.g.
  `Passport::actingAs()`'s transient mock) — confirmed by reading the vendor
  source, not assumed. Whichever way the null-guard is written, Larastan
  flags it (`=== null` as always-false, `is_string()` as always-true)
  because it never considers the runtime path, only the docblock. No
  restructuring of the check fixes this — it needs a scoped `ignoreErrors`
  entry (or equivalent ignore mechanism) for that exact line/message, with a
  comment citing the vendor source checked.
