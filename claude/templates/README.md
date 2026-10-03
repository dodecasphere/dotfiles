# Project templates

Files to copy into individual projects. These are not deployed into `~/.claude`;
they are starting points you drop into a repo.

## Verify gate and code guidelines (now builder)

The verify gate and the code guidelines gate moved to the builder plugin
(retired here 2026-10-03). In a repository with builder state, set
`verify_command` (builder's `verify-done` Stop hook runs it before Claude can
finish, when code changed) and `code_guidelines` (builder's `code-guidelines-gate` points the
first code edit of a session at that file) in `.builder/config.yml`. Install
builder state with `/builder:install`.

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

`.githooks/pre-commit` reads `.claude/git-guard.conf`: branch protection, a
fast lane for docs and tooling only commits on a protected branch, and the
branch naming convention, at the git level (it catches commits made directly
in a terminal, where Claude's hooks never run). The Claude layer check is
builder's `git-guard.sh`, configured by `.builder/config.yml`
(`protected_branches`, `branch_types`, `fast_lane_paths`); keep the two
policies in step.

Tune the values in the copied `git-guard.conf` for this project (protected
branch names, allowed branch-name types, what counts as "fast lane").

The two gotchas below were observed with the retired Claude layer dispatcher;
the git level half still applies, and builder's guard has not been checked
against them.

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
