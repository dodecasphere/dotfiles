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
- **Testing Reka UI (or other Radix-style) dialogs/popovers in Vitest.** Their
  content teleports outside the mounted component's own DOM tree via a
  Teleport/Portal — `wrapper.findAll()` won't see it even with
  `attachTo: document.body`. Query `document.body.querySelectorAll(...)`
  directly instead, and prefer a native `.click()` over `.trigger('click')` on
  a `wrapper.find()` result that will come back empty.
- **Laravel migrations on Postgres:** `Blueprint::after('column')` for column
  positioning is a MySQL-only feature — Laravel's Postgres grammar silently
  ignores it (no error, no warning). A new column always lands at the end of
  the table on Postgres regardless of `after()`. Don't trust that clause's
  intent to hold true in a Postgres-backed project.
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
  config files that reference a class only via `::class`.
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
