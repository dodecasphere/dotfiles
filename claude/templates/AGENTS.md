# AGENTS.md

Shared, tool-agnostic conventions for any AI coding agent working in this
repo (Claude Code, Codex, Cursor, or otherwise). Claude Code also loads
`CLAUDE.md`, which imports this file (`@AGENTS.md`) and adds Claude-specific
tooling (skills, hooks, slash commands) on top - the content below applies
regardless of which agent or harness is driving.

## What this is

(one paragraph: what the project is, who it's for, current status)

## Hard rules

(the non-negotiables - ask-don't-assume, design-system-is-the-spec,
whatever this project's own equivalents are; keep this list short and
concrete, not generic advice)

1. **Ask, don't assume.** Stop and ask before guessing on anything touching
   design, product, or architecture.
2. **Before writing code**, read `docs/core/code-guidelines.md` if it
   exists - house rules distilled from real findings, not generic advice.
3. **Test-first for non-trivial logic.** Write the failing test before the
   implementation.

## Git workflow

Real enforcement for all of this already runs at the git level
(`.githooks/pre-commit`, active regardless of which tool or human is
committing) - this section just names the convention so you don't fight it.

- Never commit directly to a protected branch (see `.claude/git-guard.conf`
  for the exact list). Branch first: `<type>/<kebab-slug>`.
- **Exception (fast lane):** a commit whose staged paths are *all*
  docs/tooling (see `git-guard.conf`'s `FAST_LANE_PATHS`) may commit
  directly to a protected branch.
- Merge with `--no-ff`, delete the branch after.
- No AI-attribution lines (`Co-Authored-By`, session links, etc.) in commit
  messages, PR descriptions, or comments, unless this project's convention
  says otherwise.
- Unresolved items go in `docs/BACKLOG.md`, not scattered across PRDs or
  findings docs.

## Commands

```
(this project's actual lint/typecheck/test commands - list the raw
commands here, not tool-specific slash-command shortcuts)
```
