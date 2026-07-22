---
name: claude-config-layer
description: "How the portable ~/.claude config is version-controlled in Dotfiles, and the secret landmine to avoid"
metadata: 
  node_type: memory
  type: project
  originSessionId: a828f7c1-d77a-45fd-8b99-3f2823003504
  modified: 2026-07-22T02:51:26.060Z
---

The global Claude Code config is version-controlled in the Dotfiles repo under
`claude/` and symlinked into `~/.claude` by a dedicated block in `install.sh`
(top-level files linked individually; agents/commands/hooks/rules/skills linked
wholesale). Machine-local state (plugins/, projects/, caches, credentials,
session/daemon files) is deliberately left out of git.

**Statusline usage (reworked 2026-07-21):** the usage gauge now reads
`rate_limits` (five_hour + seven_day, each used_percentage + resets_at epoch)
straight from the JSON Claude Code pipes to `claude/statusline/statusline.sh` on
stdin. No cookie, no cache, no `curl-impersonate`, no Claude Usage app, zero
external deps. It follows whatever account Claude Code is logged into, so
account-switching needs nothing. Shows `~` until the first API response of a
session and on non-subscription auth. This retired the old cookie-scraping path:
the `~/.claude/fetch-claude-usage.swift` landmine (a LIVE claude.ai sessionKey in
source) and `fetch-usage.sh` are both gone, along with their gitignore guards.
Any old `.gitignore` entry or memory mentioning that swift file is stale.

Scope decisions (locked): single account, plain `~/.claude` config dir (the old
`CLAUDE_CONFIG_DIR` multi-account scheme is abandoned — do not reintroduce).
Global CLAUDE.md holds behavioral rules only; stack/project context lives in each
repo's own CLAUDE.md. dumbometer (third-party plugin) was removed.

Memory architecture: global cross-project memories (career-product-manager,
tech-stack) live in `claude/memory/` → symlinked to `~/.claude/memory/`.
Dotfiles-specific project memory lives in `brain/memory/` → symlinked to
`~/.claude/projects/-Users-michaeldulle-Dotfiles/memory/`. Both wired by
`install.sh`.
