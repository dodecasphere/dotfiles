# [GO] Goals & Non-Goals

## Goals
- Portable, version-controlled config restored by `git clone` + `./install.sh`.
- A maximal Claude Code power-user layer (hooks, agents, commands, skills) that travels.
- Secrets excluded by construction (gitignore + gitleaks + the restore test).

## Non-Goals
- Multi-account `CLAUDE_CONFIG_DIR` switching (deliberately abandoned).
- TypeScript in app-code guidance (owner uses plain JS).
- Committing secrets, caches, or plugin/venv/session state.
- Filament or Capacitor (not part of the owner's stack).
