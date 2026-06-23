# [AR] Architecture

**Stack:** Bash scripts, macOS defaults, Homebrew provisioning. No app runtime.

**Key components:**
- `bootstrap.sh` (fresh machine), `install.sh` (symlinks repo files into `~/.<name>`), `provision.sh --mac` (apps, defaults, MCP).
- `claude/` subtree: the canonical Claude Code config, symlinked into `~/.claude` per file/dir by a dedicated block in `install.sh`.
- `provisioning/mac/*.sh` sourced in order; idempotent install guards in `helpers.sh`.
- `.githooks/` gitleaks pre-commit secret scan; global `gitignore`.

**Data model / important entities:** none (file-based config).

**External dependencies:** Homebrew, Claude Code CLI, a private `~/.dotfiles-secrets` repo, GitHub remote `dodecasphere/dotfiles`.

**How things connect:** `install.sh` symlinks repo entries to `~/.name`; `claude/` files become `~/.claude/*`; provisioning registers user-scope MCP (playwright).
