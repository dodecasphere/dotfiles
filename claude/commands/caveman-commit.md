---
description: Generate a terse caveman-style conventional commit message
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git log:*)
---
Generate a terse commit message for the current staged changes.

Current state:
- Staged diff: !`git diff --cached --stat`
- Recent commits (match this style): !`git log --oneline -10`

Rules:
- Conventional Commits format.
- Subject: 50 chars or fewer, imperative, lowercase after the type, no trailing period.
- Body only when the "why" isn't obvious from the subject. Why over what.
