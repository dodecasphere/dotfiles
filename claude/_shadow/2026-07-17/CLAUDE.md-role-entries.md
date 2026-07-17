# Shadowed 2026-07-17: global CLAUDE.md discipline entries subsumed into EOS role rubrics

Source: `claude/CLAUDE.md` (Core rule 6 plus Default workflow section). Shadowed per
IDEA-013 stage 3, approved by Mike 2026-07-17. 17 entries, each verified present in the
EOS rubric copies before this cut (two gaps filled same day: case rename collision into
engineering.md, security flag skepticism plus human validation zones into
verification.md, plugin 0.4.2).

Destinations: `engineering-os/plugins/core/references/roles/` engineering.md (9),
verification.md (7), challenge.md (1). The four discipline verbs (spec first,
interview, verify before and after, test first) keep compressed one line versions in
the live file; the format on save entry keeps its Pint autosave hook half.

Restore: paste any entry back, or `git revert` the commit that added this file.

Removal eligible after 14 clean days: 2026-07-31.

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
- **Spec first.** Before building, write a short implementation spec: the
  problem, who it is and isn't for, the key decisions, and what "done" means.
  Build against it. (Use the task-planner agent for larger efforts.)
- **Interview to remove ambiguity.** When intent or requirements are unclear,
  work through the open questions with me one at a time, recommending an answer
  for each, then summarize back as the spec. (This is the grill-me skill.)
- **Verify before and after.** Up front, confirm the right context, tools, and
  access are in place. Afterward, state plainly what you verified versus what
  only I can validate (the human validation zones).
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
- **Bash tool calls don't share shell state.** An env var exported via
  `source ~/.zshrc` (or similar) in one Bash call is gone by the next call —
  the harness resets shell state between invocations even though the working
  directory persists. If the user says they just fixed/exported an env var,
  re-source **and** run the dependent command in the *same* Bash invocation
  (`source ~/.zshrc; npm install ...`), not two separate calls. Caught this on
  CrestLite: a re-sourced `FONTAWESOME_PACKAGE_TOKEN` vanished before the very
  next `npm install` call, which then failed with the same auth error as
  before the fix, looking like the fix hadn't worked.
