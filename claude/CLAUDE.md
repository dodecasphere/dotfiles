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

Note (2026-07-17): stack specific gotchas (Laravel, Inertia, Postgres, Pest,
Tailwind, CSS, browser testing) moved into Engineering OS packs
(`engineering-os/plugins/core/references/packs/`), loaded per project via the
`profile:` line in `.engineering-os/STATE.md`. Shadow copies live in
`_shadow/2026-07-17/` until 2026-07-31. Vue family entries remain below
pending their pack's first real load.
- **Spec first.** Before building, write a short implementation spec: the
  problem, who it is and isn't for, the key decisions, and what "done" means.
  Build against it. (Use the task-planner agent for larger efforts.)
- **Interview to remove ambiguity.** When intent or requirements are unclear,
  work through the open questions with me one at a time, recommending an answer
  for each, then summarize back as the spec. (This is the grill-me skill.)
- **Verify before and after.** Up front, confirm the right context, tools, and
  access are in place. Afterward, state plainly what you verified versus what
  only I can validate (the human validation zones).
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
- **Branch-protection hooks under git worktree isolation.** A `PreToolUse`
  hook that enforces "no commits on develop/main" must resolve the branch of
  the repo the git command actually targets — the `cd <path> &&` prefix, a
  `git -C <path>` flag, or the call's own `cwd` — never a fixed
  project-directory env var, or it misjudges every linked-worktree call (false
  denies on legal feature branches, silent allows on protected ones). FIXED
  2026-07-13 in `bash-pretooluse-dispatcher.sh` (IDEA-003 wave 5e): it now
  parses `cd` and `git -C` targets and guards out-of-project paths when
  `rev-parse --path-format=absolute --git-common-dir` proves they are linked
  worktrees of the same repo. Verified by a 20-scenario side-by-side stdin
  parity harness (16 identical, 4 intentionally corrected). If a worktree
  commit is denied unexpectedly, check the worktree's own branch first, not
  the main checkout's.
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
- **A worktree-isolated background agent's checkout can be silently stale —
  verify its base before trusting its gates or code-reading claims.** On
  CrestLite (2026-07-13), two agents launched with `isolation: worktree` got
  worktrees cut from a ref 487 commits behind `develop`; their full test
  suites ran green against that ancient tree, and one agent confidently
  "verified" a component didn't exist in the repo — true only in the stale
  checkout. After any worktree agent reports, run `git -C <worktree>
  merge-base HEAD <target-branch>` and compare against the target's tip
  BEFORE merging its branch or acting on its claims; if stale, cherry-pick
  the agent's commits onto a fresh branch off the current target and re-run
  every gate in the main checkout (worked cleanly). Two setup corollaries:
  symlinking `vendor/` into a worktree breaks Pest's path resolution (do a
  real `composer install`), and an agent running `npm install` against a
  stale manifest mutates a shared symlinked `node_modules` — re-verify the
  main checkout's suites afterward.
- **Test-first.** For non-trivial logic, write the failing test before the
  implementation (the `tdd` skill), unit and feature, PHP and JS. Never call
  work done with failing tests or below the project's coverage bar; where a
  project ships `.claude/verify.sh`, that gate is enforced automatically, and
  in projects with the `.githooks/pre-commit` wall installed, changing app
  code without touching a test is blocked at commit time (the require-tests
  hook; it is NOT wired globally — elsewhere this is a norm, not a gate).
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

## Context budget
The brain auto-loads cheap summaries; everything beyond that should match the
task, not reflex-load. Don't pull architecture docs, full decision records, or
whole-module reads for a bug fix.

| Task | Load | Skip |
|---|---|---|
| Bug fix | ST + the failing code path | AR, decisions, module sweeps |
| Small feature | + AR/GL, the one module touched | decision records, full docs |
| New feature | + relevant decisions, neighboring modules | unrelated subsystems |
| Architecture work | full brain, decisions, schema | (load what it takes) |
| Spike/research | minimal; explore as you go | heavy docs upfront |

Rule: start minimal, load more only when the task proves it needs it.

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
  When `.env` changes, keep `.env.example` in sync (the env-drift hook enforces
  this only in projects with the `.githooks/pre-commit` wall installed; elsewhere
  do it as a matter of course).
- **Non-blocking hook reminders are instructions, not noise.** When a hook
  injects a checklist or reminder into context (e.g. an end-of-slice sync
  prompt), act on it or make a conscious, stated decision to skip it — don't
  silently ignore it repeatedly. (A reminder ignored often enough tends to get
  promoted to a hard block.)
- **If a git commit is unexpectedly blocked by a branch-protection hook** even
  though the branch/files look correct, check what the guard actually saw.
  Chained `git add && git commit` in one Bash call is handled since 2026-07-16
  (the dispatcher enumerates the add via `git add --dry-run`), but a dry-run
  that errors (bad pathspec, incompatible flags) still falls back to a
  conservative deny — split into two separate tool calls in that case before
  assuming the hook itself is misconfigured.
