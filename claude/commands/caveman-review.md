---
description: One-line caveman-style code review comments
allowed-tools: Bash(git status:*), Bash(git diff:*)
---
Review the current code changes.

Changes:
- !`git diff --stat`
- !`git diff`

Rules:
- One line per finding. Format: `L<line>: <severity> <problem>. <fix>`.
- Severity: bug, risk, nit, q.
- Skip praise. Skip the obvious.
- If the code looks good, say `LGTM` and stop.
