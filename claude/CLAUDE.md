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

## Default workflow
Scale this to the task. Trivial, clear changes: just make them. For anything
non-trivial, multi-step, or ambiguous, work this way by default without being
asked:

Note (2026-08-01): stack specific gotchas (Laravel, Inertia, Postgres, Pest,
Tailwind, CSS, browser testing, and as of today the Vue/Vue-testing/Reka
family) now live in Engineering OS packs
(`engineering-os/plugins/core/references/packs/`), loaded per project via the
`profile:` line in `.engineering-os/STATE.md`, not in this always-loaded
file. The Vue entries were removed from here on 2026-08-01 after verifying
each one is present in `vue.md`, `vue-testing.md`, or `vue-reka.md`; a
project only gets them if its `profile:` names the matching pack, so add
`vue-testing` / `vue-reka` there rather than re-adding gotchas here. What
stays below is deliberately stack-agnostic: harness, git, and workflow
lessons that apply everywhere.
- **Spec first.** For non-trivial work, write a short spec (problem, key
  decisions, what done means) and build against it.
- **Interview to remove ambiguity.** Work open questions with me one at a
  time, recommending an answer for each.
- **Verify before and after.** Confirm context and access up front; afterward
  state what you verified versus what only I can validate.
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
- **Test-first.** For non-trivial logic, write the failing test before the
  implementation; never call work done with failing tests or below the
  project's coverage bar.
- **Propose parallelism.** For large tasks that split into independent parts,
  propose sub-agents for parallel work or diverse perspectives, and spawn them
  when the scope clearly justifies the extra cost. Don't reflexively parallelize
  small work.
- **Capture repeatable work as skills.** When a workflow recurs, offer to save
  it as a skill, including a "Gotchas" section of what tripped us up.
- **Editing under a format-on-save hook (Pint autosave).** The general
  strip-before-use race rule (a formatter removing a just-added import before
  the edit that uses it) lives in the EOS engineering rubric. The structural
  fix used on Laravel projects with Pint plus the auto-format hook: a
  project-root `pint-autosave.json` (the project's normal preset with
  `no_unused_imports` set to `false`) that `~/Dotfiles/claude/hooks/
  auto-format.sh`'s per-edit PHP pass prefers when present, falling back to
  the project's real `pint.json`. The real gate (bare `vendor/bin/pint`,
  `--test`, `/quality`) always uses the normal config, so a genuinely unused
  import still fails before merge. Set up proactively on any Laravel project
  using Pint with this hook.
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

## Context budget
Load context to match the task, not by reflex. Don't pull architecture docs,
full decision records, or whole-module reads for a bug fix.

| Task | Load | Skip |
|---|---|---|
| Bug fix | project state + the failing code path | architecture docs, decisions, module sweeps |
| Small feature | + architecture/glossary, the one module touched | decision records, full docs |
| New feature | + relevant decisions, neighboring modules | unrelated subsystems |
| Architecture work | full project docs, decisions, schema | (load what it takes) |
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
