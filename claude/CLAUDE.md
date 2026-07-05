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
- **Laravel migrations on Postgres:** `Blueprint::after('column')` for column
  positioning is a MySQL-only feature — Laravel's Postgres grammar silently
  ignores it (no error, no warning). A new column always lands at the end of
  the table on Postgres regardless of `after()`. Don't trust that clause's
  intent to hold true in a Postgres-backed project.
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
- **Keep one backlog file, not several.** A deferred requirement, an
  accepted-not-fixed finding, a descoped bug, or a feature idea that isn't
  ready to build all go in one prioritized `docs/BACKLOG.md` (or equivalent),
  never scattered across a PRD's Open Questions, a findings doc, and a
  project-brain open-questions file. Once a backlog file exists for a
  project, default to using it rather than parking the item wherever the
  current conversation happens to be.
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
