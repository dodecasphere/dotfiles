---
description: Branch, commit, push, and open a PR via gh
allowed-tools: Bash(git:*), Bash(gh:*)
argument-hint: [PR title]
---
Take the current changes from commit through pull request:

1. If on the default branch (main/master), create a descriptive feature branch first.
2. Stage and commit with a conventional-commit message (never commit secrets).
3. Push the branch to origin, setting upstream.
4. Open a PR with `gh pr create` — concise title, and a body summarizing what
   changed and why.

Use "$ARGUMENTS" as the PR title if provided; otherwise derive one from the diff.
Show me the PR URL when done.
