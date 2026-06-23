---
description: Stage and commit changes with a conventional-commit message
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git add:*), Bash(git commit:*)
---
Review the working changes and create one or more focused commits.

Current state:
- Status: !`git status --short`
- Unstaged diff summary: !`git diff --stat`
- Recent commits (match this message style): !`git log --oneline -10`

Rules:
- Use conventional-commit format consistent with the repo's existing history.
- Group related changes into one commit; never bundle unrelated changes.
- Never stage or commit secrets (.env, *.key, *.pem, credentials.json, etc.).
- Show me the proposed message and exactly what will be staged, then commit
  once it's clearly correct.
