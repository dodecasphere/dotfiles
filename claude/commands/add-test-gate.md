---
description: Install the test + coverage gate (.claude/verify.sh) in the current project
allowed-tools: Bash(readlink:*), Bash(mkdir:*), Bash(cp:*), Bash(chmod:*), Bash(test:*), Bash(ls:*), Bash(cat:*), Read
---
Install this project's test gate so the `verify-done` Stop hook enforces that tests pass and coverage clears the bar before any work can finish.

Steps:
1. Resolve the template from the dotfiles repo via an installed symlink:
   `tpl="$(dirname "$(readlink "$HOME/.claude/settings.json")")/templates/verify.sh"`
   If that file does not exist, stop and tell me the dotfiles repo could not be located (the symlink may not be installed here).
2. If `.claude/verify.sh` already exists in this project, show me its current coverage threshold and ask before overwriting. Do not clobber it silently.
3. Otherwise install it:
   `mkdir -p .claude && cp "$tpl" .claude/verify.sh && chmod +x .claude/verify.sh`
4. Confirm it is present and executable. Then remind me to tune `MIN_PHP_COVERAGE` (and the Vitest thresholds in `vitest.config`), and note that it runs on every finish, so scope it (`pest --dirty`, `vitest --changed`) if the suite is slow.
