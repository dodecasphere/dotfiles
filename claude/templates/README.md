# Project templates

Files to copy into individual projects. These are not deployed into `~/.claude`;
they are starting points you drop into a repo.

## verify.sh (test + coverage gate)

The global `verify-done` Stop hook runs `./.claude/verify.sh` (when present and
executable) before Claude can finish, and blocks on a non-zero exit. Use this to
enforce that tests pass and coverage clears a threshold for both PHP (Pest) and
JS (Vitest).

Install it in a project:

```bash
mkdir -p .claude
cp ~/Dotfiles/claude/templates/verify.sh .claude/verify.sh
chmod +x .claude/verify.sh
```

Then tune the threshold at the top of the copied file. It already runs scoped
by default (`pest --dirty`, `vitest --changed`, no coverage) so it's cheap on
every Stop; set `VERIFY_FULL=1` to run the full suite plus the coverage bar as
an explicit pre-merge/pre-deploy check, not on every finish. Pest runs
`--parallel` by default (a real win once the suite has more than a couple
dozen tests; time it both ways on a very small suite before assuming it helps
- see the comment in the file).

This enforces tests-pass-and-covered, not test-first ordering. Ordering is a
discipline carried by the `tdd` skill and the CLAUDE.md workflow, not something
a hook can prove.

## git-guard.conf + pre-commit (branch protection, fast lane, naming)

Two files, install together - both read the same conf:

```bash
cp ~/Dotfiles/claude/templates/git-guard.conf .claude/git-guard.conf
mkdir -p .githooks/lib
cp ~/Dotfiles/claude/templates/pre-commit .githooks/pre-commit
cp ~/Dotfiles/claude/templates/githooks-lib/*.sh .githooks/lib/
chmod +x .githooks/pre-commit .githooks/lib/*.sh
git config core.hooksPath .githooks
```

The wall scripts (debug-scrubber, require-tests, focused-test-guard,
env-drift, product-doc-lint) are project owned: `pre-commit` calls them from
the project's own `.githooks/lib/`, never from `~/.claude/hooks` (those
global copies were retired 2026-07-17, EOS IDEA-014 slice 6). The
`githooks-lib/` copies here are seeds for new projects; an adopted project's
`.githooks/lib/` is authoritative for that project.

`.claude/git-guard.conf`'s mere presence activates the global, opt-in
`git-workflow-guard` in `bash-pretooluse-dispatcher.sh` (the Claude-layer
check, runs before a `Bash` tool call) - branch protection, a fast lane for
docs/tooling-only commits on a protected branch, branch-naming convention,
and (opt-in via `BRAIN_SYNC_ENFORCE`) a nudge to sync the Project Brain
alongside app-code commits. `.githooks/pre-commit` is the same policy at the
git level (catches commits made directly in a terminal, where Claude's hook
never runs) - it has no brain-sync check, since that needs to see the commit
message before the commit runs, which `pre-commit` structurally can't do.

Tune the values in the copied `git-guard.conf` for this project (protected
branch names, allowed branch-name types, what counts as "fast lane").

**Gotcha - `git commit --amend` on a clean tree can't pass the fast lane.**
Both layers determine the fast lane from the *actual staged diff*
(`git diff --cached --name-only`) or a `git add` token found in the same
command string. A message-only `--amend` with an already-clean working tree
(identical to HEAD) has neither, so both layers see zero paths and deny
defensively, even for a genuinely fast-lane-eligible commit. Working fix (with
the user's one-time explicit permission, since it needs `--no-verify`, which
CLAUDE.md otherwise forbids): `git add <the exact fast-lane files> && git
commit --amend -m "..." --no-verify` in one command - the `git add` satisfies
the Claude-layer textual parse (even as a no-op against the index), and
`--no-verify` skips the git-level hook that would otherwise fail on the empty
real diff. Only for unpushed, content-safe amends (`git status -sb` shows
`ahead N`, not already pushed).

**Gotcha - chain `git add`/`git commit` on one line, not across two.** A
genuinely fast-lane-eligible commit sent as one Bash call with a **newline**
between `git add ...` and `git commit -m ...` can get denied by the
Claude-layer hook even though the same two commands **`&&`-joined on one
line** succeed immediately, same files, same message. Root cause not fully
isolated - the fix is just to always chain with `&&` on one line, never split
across lines or across two separate tool calls, for a fast-lane commit.

## code-guidelines.md + the code-guidelines gate

The global `code-guidelines-gate` hook (wired in `settings.json`'s
`PreToolUse`/`Edit|Write|MultiEdit`) denies the first code edit of a session
with a pointer to `docs/core/code-guidelines.md`, once, if that file exists -
silent no-op in any project that doesn't have one. "Code" is defined as "not
a fast-lane path" (reusing `git-guard.conf`'s `FAST_LANE_PATHS` if present,
same default otherwise), so it needs no separate per-language extension list.

```bash
mkdir -p docs/core
cp ~/Dotfiles/claude/templates/code-guidelines.md docs/core/code-guidelines.md
```

Fill in the placeholder sections with this project's *actual* findings, not
generic advice - the whole point is house rules distilled from something
that really happened (a sweep, an incident, a review comment), not invented
up front.
