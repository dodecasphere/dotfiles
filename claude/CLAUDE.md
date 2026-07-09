# Global instructions

These apply to every project. Project-specific context — stack, conventions,
build commands — lives in each repo's own CLAUDE.md, not here.

## How to work with me
- Be direct and critical. Don't be sycophantic, don't pad with praise, don't
  soften honest disagreement. If I'm wrong, say so and say why.
- Assert only what you've verified. Don't state how code behaves, what an API
  returns, or what a file contains from assumption — check the actual code or
  output first, and flag when you're inferring versus confirming.
- Default to concise, paste-ready output. Skip preamble and don't restate my
  question back to me.
- When you have questions for me and the answers form discrete choices (two to
  four enumerable options), ask through the AskUserQuestion interface, with your
  recommended option listed first, rather than posing the question in prose. Use
  plain prose only for genuinely open-ended questions that cannot be enumerated
  into options (freeform text, pasting a spec).

## Core rules
1. **Ask, don't assume.** If something is unclear, ask before writing a single
   line — never make silent assumptions about intent, architecture, or
   requirements. When running unattended, pick the most reasonable
   interpretation, proceed, and record the assumption rather than blocking.
2. **Match the solution to the problem.** Implement the simplest thing that
   works for simple problems and a more robust solution for harder ones. Don't
   over-engineer or add flexibility that isn't needed yet.
3. **Stay in scope, surface what you find.** Don't touch unrelated code — but
   do flag bad code or design smells you discover, so we can address them as a
   separate issue.
4. **Flag uncertainty explicitly.** If you're unsure, see rule 1. Where it
   makes sense, run a small, localized, low-risk experiment and bring me the
   hypothesis and results to discuss. Confidence without certainty causes more
   damage than admitting a gap.
5. **Suggest better ways.** I'm always open to them — don't hesitate to propose
   a different approach, especially one with lasting impact over a tactical fix.
6. **Read the real error before theorizing.** When a reported failure has an
   actual error you can capture — a server log, the network response, a stack
   trace, or a temporary `Log` line in the exception handler — get that first,
   before reasoning about the symptom. Guessing causes from the symptom alone is
   the expensive failure mode (it once burned three debugging rounds on a
   "passkey not recognized" symptom when the true error, a `remember` field
   validation failure, was one `grep` away). A stray background process
   masquerading as "it's just flaky" is often literally an orphan: `ps -o
   pid,ppid,stat,lstart,command -p <pid>` — a PPID of 1 means its real parent
   already died and it got reparented to launchd/init, so it's still fully
   alive and holding resources (a port, a file watcher) with nobody left to
   kill it on the next normal shutdown. Caught a week-old zombie `vite`
   process this way instead of guessing at HMR/websocket causes.

## Default workflow
Scale this to the task. Trivial, clear changes: just make them. For anything
non-trivial, multi-step, or ambiguous, work this way by default without being
asked:
- **Spec first.** Before building, write a short implementation spec: the
  problem, who it is and isn't for, the key decisions, and what "done" means.
  Build against it. (Use the task-planner agent for larger efforts.)
- **Interview to remove ambiguity.** When intent or requirements are unclear,
  work through the open questions with me one at a time, recommending an answer
  for each, then summarize back as the spec. (This is the grill-me skill.)
- **Verify before and after.** Up front, confirm the right context, tools, and
  access are in place. Afterward, state plainly what you verified versus what
  only I can validate (the human validation zones).
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
- **Testing Reka UI (or other Radix-style) dialogs/popovers in Vitest.** Their
  content teleports outside the mounted component's own DOM tree via a
  Teleport/Portal — `wrapper.findAll()` won't see it even with
  `attachTo: document.body`. Query `document.body.querySelectorAll(...)`
  directly instead, and prefer a native `.click()` over `.trigger('click')` on
  a `wrapper.find()` result that will come back empty. Reka's `SelectItem`/
  listbox options also ignore a synthetic `click()` — even a native one. Open
  the listbox via `.trigger('keydown', { key: 'ArrowDown' })` on the trigger,
  then commit the choice by dispatching a native `pointerup` event on the
  option (`option.dispatchEvent(new Event('pointerup', { bubbles: true }))`),
  not `click`. Also: when more than one test in the same `describe` mounts
  with `attachTo: document.body` and asserts against Portal-teleported content
  (Dialog, Select, Tooltip), unmount or clear `document.body.innerHTML`
  between tests — otherwise the next test's `document.body.querySelector`
  picks up the previous test's still-attached portal content and produces
  confusing false positives/negatives. One more VTU fragment gotcha: an inline
  template comment directly above a `v-if` ROOT element makes that branch
  render as a two-node fragment (comment + element), so `wrapper.classes()`/
  `wrapper.element` resolve to the comment node instead of the element — keep
  explanatory comments out of a conditional root's template (put them in the
  script block) or query past the root explicitly.
- **An inline Vue template event handler that references `window`/`document`
  directly** (e.g. `@click="() => (window.location.href = '/foo')"`) throws
  `TypeError: Cannot read properties of undefined` at click time when mounted
  under Vitest/jsdom (Vue Test Utils `mount()` + `.trigger('click')`) — the
  inline expression's compiled render-function scope doesn't reliably fall
  back to the true global in this environment, even though `window` is a real
  global everywhere else in the same test file. Never write an inline arrow
  touching a true global directly in a template; define a named function in
  `<script setup>` instead (normal JS closure scope, no special casing
  needed) and bind the template to that.
- **A Vue `ref` flipped true-then-false synchronously in one tick (no
  `await`/tick between the two assignments) never fires its `watch()`
  callback at all** — Vue's default `flush: 'pre'` batches same-tick
  mutations into one flush job and diffs against the value *before* the
  first mutation in that batch, so a net-zero round-trip looks like "no
  change" and the callback is skipped entirely. Reproduces in a bare
  `ref`+`watch()` pair outside any component, not a Vitest- or
  composable-specific quirk. Cost real debugging time isolating a
  `selectMode` clear-on-toggle-off watcher that looked correct by every
  inspection, purely because the test drove two `ref.value = x`
  assignments back to back with no tick between them — not something a
  real UI interaction (two separate clicks) would ever produce. When a
  Vitest test needs a `watch()` side effect to fire on an intermediate
  transition, `await nextTick()` between each mutation that should
  independently trigger it.
- **Nesting one Reka `as-child` trigger directly inside another collides
  their `data-state`/ARIA writers on the shared DOM element.** Two shapes:
  (1) a Toggle inside a Tooltip — the Tooltip's `data-state="closed"`
  overwrites the Toggle's own `data-state="on"/"off"`, breaking
  `data-[state=on]` CSS; (2) a component that always wraps its own trigger in
  a Tooltip (e.g. an icon-button) used as a Popover/DropdownMenu trigger —
  three as-child layers stack on one button. For a **decorative** outer
  trigger (Tooltip, no real DOM semantics), span-wrap the inner component
  inside the Tooltip so `as-child` merges onto the span instead. For an
  **interactive** outer trigger (Popover, DropdownMenu — `aria-expanded`/
  `aria-haspopup` must live on the real focusable control per WAI-ARIA
  disclosure-pattern semantics), span-wrapping is wrong (a real a11y
  regression) — don't nest at all; build a plain one-level trigger instead of
  reusing a component that carries its own internal Tooltip.
- **Reka UI's `Combobox` defaults `resetSearchTermOnBlur` to `true`, and
  `ComboboxInput.resetSearchTerm()` always takes the `displayValue(modelValue)`
  branch whenever a `displayValue` prop is passed at all — even a caller's own
  no-op default (`() => ''`).** In a server-search/typeahead mode where nothing
  is ever "selected" (the caller owns the debounced fetch and just passes an
  already-filtered `items` list), `modelValue` stays `null`, so every blur
  silently wipes whatever the user had typed back to `''` — no error, easy to
  misdiagnose as "the search is broken" rather than "the input got cleared."
  Root-caused by reading Reka's own source (`ComboboxInput.vue`/
  `ComboboxRoot.vue`), not by guessing. Fix: bind `:reset-search-term-on-blur`
  to `false` specifically in that server-search branch (e.g.
  `!ignoreFilter`) so a normal client-filtered, single-select Combobox
  elsewhere in the same app keeps Reka's default (and desirable)
  reset-to-selected-label-on-blur behavior. A minimal Vitest repro needs a real
  two-way-bound host component (`query` prop fed back via `@update:query`) —
  a bare `setProps()` after typing doesn't reproduce the bug, since Reka's
  internal `useVModel` shadow-state masks it.
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
- **Reviewer-agent findings are hypotheses, not facts.** Before acting on a
  finding from a code-review/security/perf agent pass (especially "dead code,
  delete it"), re-verify the premise against the live code — grep for real
  callers, check routes. A repo-wide sweep caught two false findings this way:
  a "never instantiated" Resource that backed a live API route (deleting it
  would have broken 9 tests), and a "missing" validation rule that had shipped
  days earlier. The verify-before-fix step is where those get caught; skipping
  it turns a reviewer hallucination into a regression.
- **A backlog/round checklist item checked off as "done" can describe a fix
  that was never actually implemented.** A prior `/feature-round` marked a
  drag-handle-column bug fixed by describing a `data-disabled` attribute the
  component would stamp when dragging was disabled — re-verifying the next
  round found that attribute didn't exist anywhere in the repo; the intended
  approach was written down but never coded. Verify a claimed fix against
  live code (grep for the described mechanism) before treating a checkmark as
  settled prior art — same caution as the reviewer-findings rule above, but
  for your own team's past checkmarks too, not just automated review passes.
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
- **Branch-protection hooks under git worktree isolation.** A `PreToolUse`
  hook that enforces "no commits on develop/main" by resolving the current
  branch via a fixed project-directory env var (e.g. `git -C
  "$CLAUDE_PROJECT_DIR" rev-parse --abbrev-ref HEAD`) will misjudge any Bash
  call executing inside a linked git worktree — it checks whatever branch the
  *main* checkout happens to be on, not the worktree's own branch. If a
  background agent's `git commit` gets denied with a branch-protection
  message despite being correctly checked out on a properly-named feature
  branch in its own worktree, this is the first thing to check, not a sign
  the agent did something wrong. Fix (with the project owner's explicit
  sign-off, since it's editing a guardrail): resolve the branch against the
  repo the git command's own `cd <path> &&` prefix targets, when present —
  that only covers commands with an explicit textual `cd`, not ones relying
  on a shell's persisted cwd from an earlier separate call, which remains a
  gap worth investigating further before treating any one workaround as
  proven. **Confirmed the gap is wider still**: even from the *main* checkout,
  neither `cd <worktree-path> && git commit` nor `git -C <worktree-path>
  commit` resolves correctly when that worktree is on a different branch than
  the main checkout — the hook still checks the main checkout's own branch,
  not the target path's. The only workaround that reliably worked: `git
  worktree remove` the (idle) worktree, `git checkout <branch>` directly in
  the main checkout, resolve/commit there, then merge back into
  develop/main. Don't spend more than one retry on `cd`/`-C` variants before
  falling back to this.
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
- **Verify before trusting an auto-mode "SECURITY WARNING" flag on a
  subagent.** Legitimate read-only diagnostic commands (e.g. checking branch
  state across several worktrees while debugging a hook) can trip a false
  "reconnaissance for circumventing guardrails" flag. Before reacting to one,
  check the actual git state (`git log`, `git reflog`, `git status`) in the
  flagged location for real evidence — stray commits, branch changes,
  pushes — rather than assuming the flag is correct or assuming the
  subagent's own denial is trustworthy either. Caught one false positive this
  way: an agent's cross-worktree `git rev-parse`/`git branch` reads, done
  purely to diagnose the branch-protection bug above, got flagged as evasion
  reconnaissance; the git history proved it was clean.
- **Gitignored build output breaks tests in fresh git worktrees.** If a
  project's build directory (`public/build/`, `dist/`, etc.) is gitignored, a
  newly created isolated worktree starts with no built frontend assets. Any
  backend test that renders a page depending on that manifest (e.g. Laravel +
  Vite's `ViteManifestNotFoundException`) will fail with what looks like —
  and is easy to mistake for — a bug in the agent's own diff, when it's
  really just a missing build step. Run the project's build command in the
  worktree before trusting a wall of red test failures there.
- **Test-first.** For non-trivial logic, write the failing test before the
  implementation (the `tdd` skill), unit and feature, PHP and JS. Never call
  work done with failing tests or below the project's coverage bar; where a
  project ships `.claude/verify.sh`, that gate is enforced automatically, and
  where a test suite exists, changing app code without touching a test is
  blocked (the require-tests hook).
- **Propose parallelism.** For large tasks that split into independent parts,
  propose sub-agents for parallel work or diverse perspectives, and spawn them
  when the scope clearly justifies the extra cost. Don't reflexively parallelize
  small work.
- **Capture repeatable work as skills.** When a workflow recurs, offer to save
  it as a skill, including a "Gotchas" section of what tripped us up.
- **Editing under a format-on-save hook.** When a hook reformats files after
  each edit (e.g. Pint with `no_unused_imports`), add a new `use` import and its
  first usage in the *same* edit — otherwise the formatter strips the "unused"
  import before a later edit references it, breaking the file. The symptom can
  be a *silent* fatal (a segfault or a test run that prints nothing) when the
  stripped import is a trait `use` in a class or a class reference in a
  routes/config file — not always an obvious "class not found". Same goes for
  config files that reference a class only via `::class`. When the import and
  its first usage genuinely can't land in the same `Edit` call (e.g. the usage
  site is far from the top-of-file import block), sidestep the strip-before-use
  race entirely by referencing the class fully-qualified inline
  (`\Illuminate\Support\Str::isUrl(...)`) instead of adding a `use` import. No
  import to strip, no race. **This recurred enough on one project (CrestLite,
  three times in one session, despite knowing the rule above) to warrant a
  structural fix instead of relying on remembering it under pressure**: a
  project-root `pint-autosave.json` (the project's normal `preset` with
  `no_unused_imports` set to `false`) that `~/Dotfiles/claude/hooks/
  auto-format.sh`'s per-edit PHP formatting pass prefers when present,
  falling back to the project's real `pint.json` otherwise. The real gate
  (bare `vendor/bin/pint`, `--test`, `/quality`) always uses the project's
  normal config unchanged, so a genuinely unused import still fails before
  merge — only the *per-edit, mid-sequence* autosave pass gets the looser
  rule. Worth setting up proactively on any Laravel project using Pint +
  this same auto-format hook, rather than waiting to get bitten first.
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
- **A Reka-UI Portal-based component (Dialog's `DialogPortal`, Select's
  `SelectContent`, etc.) teleports its content to `document.body` by
  default — inside a Vue app mounted into a Shadow DOM root (a bookmarklet
  or embeddable widget bundle), that escapes the shadow boundary entirely
  and loses every inlined style**, since the portaled content now lives in
  the host page's light DOM instead of the shadow tree. No `to`-target
  override existed on one project's own `Dialog.vue`/`SelectMenu.vue`
  wrappers to redirect the portal into the shadow root instead. Building
  any Vue UI meant to run standalone inside a Shadow DOM means either
  hand-rolling that one component instead of reusing the app's normal
  Reka-based primitives, or explicitly passing the shadow root as the
  portal's target if the underlying library supports it.
- **Check branch staleness before reusing.** If a branch name for a task
  already exists, don't assume it's a fresh start — run
  `git log --oneline <branch>..develop` (or main) first. A same-named leftover
  branch from an already-shipped feature can be hundreds of commits stale;
  building on it silently reintroduces old code/config. If it's stale and
  already merged, delete and recreate fresh rather than reusing.
- **Laravel's bare `throttle:N,1` middleware shares one bucket per user across
  every route using it**, not per-route — the default key is `domain+user_id`
  only, no route/path component. When writing a test that expects two
  different throttled endpoints to rate-limit independently, don't combine
  them in one test; test each route's throttle in its own `it()`, or the
  first route's requests will exhaust the second's budget too.
- **A new file meant to replace/rename an old one can silently collide on
  macOS's default case-insensitive filesystem.** `docs/backlog.md` and a new
  `docs/BACKLOG.md` are the *same file* on a stock Mac (APFS
  case-insensitive, case-preserving) — a `Write` to the new name overwrites
  the old one's content in place rather than creating a second file, and
  tools that track "have I read this file" get confused by the case
  difference. Before renaming-by-case, delete the old file first (or verify
  with `touch a && test -f A` in the target directory), then create the new
  one fresh.
- **When merging or editing PreToolUse/guardrail hook scripts, verify
  behavioral parity via side-by-side scenario testing before deleting the
  originals.** Feed identical simulated stdin JSON to the old script(s) and
  the new one across every real code path (allow cases, each deny case, edge
  cases like an opt-in config file's presence/absence) and diff the outputs.
  This is cheap insurance against silently loosening a security/workflow
  guardrail during a "purely mechanical" consolidation — caught zero
  regressions this way across 20 scenarios merging 4 hooks into 2
  dispatchers on a real project, but the point is confirming that, not
  assuming it.
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
- **Commit every slice, unprompted.** Before committing, sync whatever the
  slice touched first (Project Brain, docs, CLAUDE.md, agent memory), then
  commit with a conventional message. Don't wait to be asked, and don't batch
  multiple slices into one commit — a granular, reviewable history with a
  green checkpoint after each slice is the point.
- **Be judicious about testing cost.** Browser tests (Playwright MCP/similar)
  and screenshots are token-intensive — use them sparingly, only when there's
  no cheaper way to verify. Prefer fast unit/feature suites plus reading the
  code/DOM directly. When a browser check is genuinely needed, do one
  targeted verification, not a broad exploratory pass.
- **Run the full test suite after a rewrite or deletion, not just the
  touched spec.** A targeted run greens the new code but can silently leave a
  *pre-existing* spec — one that asserted the old shape — broken, since nothing
  ran it. This is judicious, not wasteful: run both full suites once at the
  end of any slice that rewrites or removes a file with external references,
  even under the "be judicious about testing cost" rule above.
- **Verify PDF/image/other binary-rendered output by actually rendering it,
  not just code review.** A change to a dompdf view, a generated image, or
  similar binary output can't be fully confirmed by reading the
  Blade/CSS/template source alone. Generate a real instance with test data
  (e.g. `php artisan tinker` calling the real `build()`/`render()` path,
  writing the result to the scratchpad) and use the Read tool directly on
  the output file — it renders PDFs/images natively — rather than trusting
  the source alone. Cheap insurance for exactly the class of change code
  review can't fully verify; caught nothing wrong doing this on a CrestLite
  PDF-export styling pass, but that's the point — confirming instead of
  assuming.
- **Keep one backlog file, not several.** A deferred requirement, an
  accepted-not-fixed finding, a descoped bug, or a feature idea that isn't
  ready to build all go in one prioritized `docs/BACKLOG.md` (or equivalent),
  never scattered across a PRD's Open Questions, a findings doc, and a
  project-brain open-questions file. Once a backlog file exists for a
  project, default to using it rather than parking the item wherever the
  current conversation happens to be.
- **Bash tool calls don't share shell state.** An env var exported via
  `source ~/.zshrc` (or similar) in one Bash call is gone by the next call —
  the harness resets shell state between invocations even though the working
  directory persists. If the user says they just fixed/exported an env var,
  re-source **and** run the dependent command in the *same* Bash invocation
  (`source ~/.zshrc; npm install ...`), not two separate calls. Caught this on
  CrestLite: a re-sourced `FONTAWESOME_PACKAGE_TOKEN` vanished before the very
  next `npm install` call, which then failed with the same auth error as
  before the fix, looking like the fix hadn't worked.
- **`@sentry/vue`'s Vue integration captures whatever `app.config.errorHandler`
  is already set before `Sentry.init()` runs, and calls through to it after
  capturing** (confirmed by reading `errorhandler.js` in the installed
  package, not assumed). Set a custom errorHandler *before* calling
  `Sentry.init({ app, ... })`, or Sentry's wrapping silently replaces it
  instead of chaining — the custom handler would still be present in code but
  never actually invoked.
- **In Vitest, an attribute-value DOM query
  (`document.body.querySelector('img[src="..."]')` etc.) can silently match
  the wrong element when the same value legitimately renders twice on one
  page** — e.g. a list-row thumbnail and a detail-view/dialog preview sharing
  one image `src`. Scope the query to the specific container first (e.g.
  `'[role="dialog"] img[src="..."]'`), don't query `document.body` broadly.
  Caught this exact false-pass on CrestLite testing a dialog's image
  treatment: the assertion "passed" against the row thumbnail's class list,
  not the dialog's.
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
- **Automate with restraint** (this governs the rest): only fully automate
  tasks that don't require taste and where roughly 80%-good output is
  acceptable. Otherwise keep me in the loop and augment my judgment rather than
  replace it.

## Project brain
Some projects keep a Project Brain: the canonical `0N-XX-*.md` files (Overview,
Goals, Architecture, Decisions, State, Glossary, Open Questions), auto-loaded at
session start by the brain-loader hook. When one is loaded, treat it as
authoritative grounding for the project. As the session runs, proactively offer
to update it at the moments that matter, without being asked:
- a real decision is made: offer to log it to Decisions (DC)
- something starts working or breaks: offer to update Current State (ST)
- the stack or structure changes: update Architecture (AR), plus a DC note on why
- an open question gets answered: move it from OQ into DC
Suggest, do not edit the brain without my go-ahead. `/brain-sync` refreshes the
brain anytime; `/wrap` runs it as part of closing the session.

## Writing docs
- Never use dashes (— or -) as punctuation in documentation or README files.
  Rephrase using periods, commas, or parentheses instead.

## Using GitHub
- Use the `gh` CLI for GitHub operations rather than raw API calls or guessing
  at git state.
- Never mention Claude Code (no attribution or co-author lines) in commit
  messages, PR descriptions, PR comments, or issue comments.
- Don't include a "Test plan" section in PR descriptions.

## Working within my guardrails
- When one of my hooks blocks a protected file (e.g. `.env`,
  `.github/workflows/*`), don't retry the blocked tool. Surface a ready-to-paste
  `! …` command for me to run, or ask for one-time permission to run it via Bash.
  When `.env` changes, keep `.env.example` in sync (the env-drift hook enforces it).
- **Non-blocking hook reminders are instructions, not noise.** When a hook
  injects a checklist or reminder into context (e.g. an end-of-slice sync
  prompt), act on it or make a conscious, stated decision to skip it — don't
  silently ignore it repeatedly. (A reminder ignored often enough tends to get
  promoted to a hard block.)
- **If a git commit is unexpectedly blocked by a branch-protection hook** even
  though the branch/files look correct, check whether `git add && git commit`
  was chained in one Bash call — some PreToolUse hooks only see the compound
  command and refuse it outright. Split into two separate tool calls before
  assuming the hook itself is misconfigured.
