---
description: Bootstrap a fresh (or existing) project with the standard Dotfiles tooling - Project Brain, test gate, git-workflow guard, code-guidelines gate, backlog. Idempotent - safe to run against a project that already has some pieces.
allowed-tools: Bash(readlink:*), Bash(mkdir:*), Bash(cp:*), Bash(chmod:*), Bash(test:*), Bash(ls:*), Bash(cat:*), Bash(git config:*), Read, AskUserQuestion
---
Install this project's standard tooling kit so it gets the same sophistication
of process as every other project - test gate, branch protection, code
guidelines, backlog - with no hooks/settings.json editing required (the
global hooks already activate themselves purely by these files' presence).

This must be safe to run against a project that's brand new OR one that
already has some of these pieces installed - never clobber an existing file
silently.

## 0. Resolve the templates root

`tpl="$(dirname "$(readlink "$HOME/.claude/settings.json")")/templates"`

If that directory doesn't exist, stop and tell me the dotfiles repo couldn't
be located (the symlink may not be installed here).

## 1. Project Brain

If a `brain/` directory doesn't already exist here, copy the whole template
directory: `cp -r "$tpl/brain" brain`. If `brain/` already exists, leave it
alone entirely - don't touch any file inside it.

## 2. Test gate (`.claude/verify.sh`)

Same as `/add-test-gate`: if `.claude/verify.sh` already exists, show me its
current coverage threshold and ask before overwriting. Otherwise:
`mkdir -p .claude && cp "$tpl/verify.sh" .claude/verify.sh && chmod +x .claude/verify.sh`.
Remind me afterward to tune `MIN_PHP_COVERAGE` and the actual test commands
for this project's stack (the template defaults to Pest/Vitest).

## 3. Git-workflow guard (`.claude/git-guard.conf` + `.githooks/pre-commit`)

If `.claude/git-guard.conf` already exists, leave it alone and skip to step 4.
Otherwise:

```
cp "$tpl/git-guard.conf" .claude/git-guard.conf
mkdir -p .githooks
cp "$tpl/pre-commit" .githooks/pre-commit
chmod +x .githooks/pre-commit
git config core.hooksPath .githooks
```

Then ask me (AskUserQuestion) to confirm/adjust the defaults in the copied
`git-guard.conf`: protected branch names, allowed branch-name types, and
whether to enable `BRAIN_SYNC_ENFORCE` (only meaningful if step 1 installed
Project Brain).

## 4. Code guidelines (`docs/core/code-guidelines.md`)

If that file already exists, leave it alone. Otherwise:
`mkdir -p docs/core && cp "$tpl/code-guidelines.md" docs/core/code-guidelines.md`.
Tell me it's a skeleton - the placeholder sections need this project's actual
findings, not generic advice, and the `code-guidelines-gate` hook will start
pointing new sessions at it immediately regardless of whether it's filled in
yet.

## 5. Backlog (`docs/BACKLOG.md`)

If that file already exists, leave it alone. Otherwise:
`mkdir -p docs && cp "$tpl/BACKLOG.md" docs/BACKLOG.md`.

## 6. Cross-tool parity (`AGENTS.md`)

So Codex/Cursor/other agents get the same conventions as Claude Code, not
just a bootstrap script that only helps *this tool*. If `AGENTS.md` doesn't
already exist at the repo root: `cp "$tpl/AGENTS.md" AGENTS.md`, then fill in
its placeholder sections with this project's actual specifics (same
"real findings, not generic advice" rule as code-guidelines.md). Then, if
`CLAUDE.md` exists and doesn't already reference `AGENTS.md`, add `@AGENTS.md`
as the first line after its title, with a short note that everything below it
is Claude-Code-specific on top. (Claude Code doesn't natively read
`AGENTS.md` - this import is the documented way to share it without
duplicating content; expect a one-time approval dialog for the import on
this project's next session.) If `AGENTS.md` already exists, leave it alone.

## 7. Local CI mirror (optional)

Ask me (AskUserQuestion) whether this project should get a `local-ci.sh`
(worth it once the project has real GitHub Actions workflows; skip for
brand-new repos with no CI yet). If yes:
`cp "$tpl/local-ci.sh" local-ci.sh && chmod +x local-ci.sh`, then remind me
the template is a skeleton - its suites must be edited to mirror
`.github/workflows/` exactly (same tools, flags, order), and kept in sync
whenever CI changes.

## 8. Report

List exactly what was installed vs. what already existed and was left alone.
For anything installed, name the one or two things I still need to tune
(coverage threshold, branch names, guideline content) rather than assuming
the defaults are right for this project.
