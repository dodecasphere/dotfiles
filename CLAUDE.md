# CLAUDE.md

Personal dotfiles for macOS (primary) and Linux (headless Ubuntu/Debian server, CLI parity via Homebrew on Linux). Root files are symlinked into `$HOME` as hidden files by `install.sh`; provisioning scripts install apps and configure the machine.

## Scripts

| Script | Purpose |
|---|---|
| `bootstrap.sh` | Fresh machine: clones repo, runs `install.sh`. Curl-runnable. |
| `install.sh` | Symlinks every non-`.sh`/non-`.md` root file into `$HOME` as `~/.<name>` (backs up real files, replaces symlinks). Also links `claude/`, `config/` and `project-memory/`, and wires the gitleaks pre-commit hook. |
| `provision.sh --mac` | Formulae, apps, fonts, macOS defaults, Node/PHP/Claude/SSH/Git. Idempotent. |
| `provision.sh --linux` | See Provisioning. Run as a sudo user; it refuses to run as root. Idempotent. |
| `test.sh` | Clones committed HEAD into a temp dir and simulates a fresh install: checks the Claude config layer restores and no secrets leak. |
| `autoupdate.sh` | Scheduled only: daily at 23:45 (LaunchAgent on mac, also at login; cron on Linux). Re-renders the Herdr agent skills and, on Linux, runs `hc update`. Then `git pull --ff-only`, and `install.sh` only when the pull brought commits. A dirty tree skips the pull and logs `SKIP` to `~/.dotfiles-autoupdate.log` (leave it for manual cleanup; an auto-absorb workaround was tried and reverted). Never runs `provision.sh`; re-run that by hand after a provisioning change. |

## Provisioning

`provision.sh --mac` sources `provisioning/mac/` in order. Scheduled jobs on mac are always LaunchAgents (`launchagents.sh` + `launchagents/*.plist`), never cron. `provision.sh --linux` sources `provisioning/linux/` (apt, unattended-upgrades, sshd/ufw/fail2ban hardening, Tailscale, Docker, swap, Homebrew, cron) plus the portable mac scripts `helpers.sh`, `node.sh`, `claude.sh`, `secrets.sh`.

Formulae: OS-agnostic ones go in `provisioning/shared/formulae.sh` (sourced by both platforms), macOS-only ones in `provisioning/mac/formulae.sh`, casks in `provisioning/mac/apps.sh`. The install guards (`formula`, `cask`, `mas_install`, `npm_global`, `pecl_install`, `composer_global`, `add_cron`) in `provisioning/mac/helpers.sh` skip anything installed, which is what makes re-running safe; they're also on the interactive shell via `~/.provisioning`.

## Claude Code config layer (`claude/`)

`claude/` is the version-controlled Claude Code config. `~/.claude` otherwise holds machine-local state (plugins, projects, sessions) that must stay out of git, so `install.sh` links only named entries: `CLAUDE.md` and `settings.json` as files, and `agents`, `commands`, `hooks`, `rules`, `skills`, `memory`, `statusline` as whole directories (empty or missing ones are skipped). Anything written to `~/.claude/hooks` or `~/.claude/memory` lands in the repo. `mcp/` and `templates/` are reference only, not linked. A new top-level entry needs adding to the loops in `install.sh` and `test.sh`.

- Skills, commands, agents and the guardrail hooks live in plugins, not here: the private store `dodecasphere/personal-skills` (installs into Claude Code and Codex) and the builder plugin. `claude/agents/` stays empty so its link resolves.
- Don't drop skills into `claude/skills/`: `install.sh` would then replace the real `~/.claude/skills` (where the Herdr skills render) with a link into the repo, the render would dirty the tree, and autoupdate would stop pulling. Put machine-local skills in `~/.claude/skills/` directly.
- Hooks kept here (builder doesn't replace them): auto-format, context-recovery, settings-drift-check, herdr-agent-state, standing-behaviors. They're Claude Code only; Codex has no equivalent hook carrier.
- `settings.json` declares the marketplaces and enabled plugins, so a fresh machine needs no manual plugin install. Codex config (`~/.codex/config.toml`) is unmanaged and needs the store's `INSTALL.md` steps by hand.
- `project-memory/` holds this repo's Claude project memories (linked into `~/.claude/projects/<repo path, non-alphanumerics as dashes>/memory`); global memories are in `claude/memory/`.

## Durable decisions

- Third-party Claude skills are hand-ported (markdown, house-styled, selective), never installed with upstream `curl | bash` or `npx` installers, which write into machine-local `~/.claude`. Provenance lives in the store's `UPSTREAM.md`.
- `skillOverrides` in `settings.json` does not suppress a plugin skill (verified). Use `disable-model-invocation: true` in the skill's frontmatter instead; set in the store and in builder, and observed hiding those skills from the model's list on 2026-11-09.
- The Matt Pocock skills were adopted disciplines-only. The issue-tracker pipeline half (triage, to-spec, to-tickets, wayfinder, CONTEXT.md) was rejected as colliding with the owner's workflow. Don't re-propose it.
- Non-goals: multi-account `CLAUDE_CONFIG_DIR` switching, TypeScript in app-code guidance (owner uses plain JS), Filament, Capacitor.
- The statusline usage gauge reads `rate_limits` from Claude Code's stdin JSON (no cookie scraping, no cache). It follows the logged-in account and shows `~` until the first API response or on non-subscription auth.

## Shell config

Bash and zsh both source the same shared files in the same order: `colors`, `path`, `exports`, `aliases/` (one file per topic, picked up automatically), `functions`. Machine-local overrides go in untracked `~/.shell.local`, sourced last. Entry points: `zshrc`/`zprofile`, `bash_profile`/`bashrc`. Both shells also source `~/.dotfiles-secrets/secrets.env` from a separate private repo, which `provisioning/mac/secrets.sh` clones.

## Herdr

- **TUI** (`herdr`): config in `config/herdr/config.toml`, which has its own `[keys]`. The desktop app's keys are separate, so a key change may need both.
- **Desktop app** (`herdr-app`, reads `~/.config/herdr-app/`): before editing anything under `config/herdr-app/`, read `~/.config/herdr-app/AGENTS.md`. The app regenerates it for its installed version, so it's the source of truth for layouts, keys, settings and mods. Repo-specific facts:
  - Tracked: `keys.json`, `settings.json`, layout `layouts/my-herdr.json` (clone of `main`) and its tab bar mod `mods/my-tabs` (clone of `tabs`, labels unnamed tabs "folder › agent title"). The mod's generated `gpui-kit.d.ts` and `jsconfig.json` stay untracked.
  - The shown layout is machine-local (`shared.json`): a fresh machine needs `herdr-app do layout.switch --name my-herdr`; `--name main` reverts to stock.
  - The app writes `settings.json` through the symlink, so a zoom or Settings change dirties the repo.
  - Unverified: the `ctrl-alt-shift-escape` reset may replace the `keys.json` symlink with a real file until `install.sh` relinks.
- **SSH machines**: `provisioning/mac/herdr.sh` (mac only) is the source of truth, a `label|target` list replayed through `herdr machine add` and `hc machine add --install`. The hc name is the label lowercased with dashes (e.g. `agent-vps`). Already saved targets are skipped, so a relabel needs a manual remove. Edit that list, not machine-local `~/.local/state/herdr/client/endpoints.json`; sidebar order follows list order for new entries, and reordering a saved machine means editing that JSON. Crestlite Legacy and DulleCo (Ubuntu 16.04, systemd 229) can't run hc (needs systemd 236+), so they fail every provision run until upgraded.
- **Agent skills** (`herdr`, `herdr-core`, `herdr-app`) are rendered from the installed binaries' `--skill` output by `provisioning/shared/agent-skills.sh` into `~/.claude/skills/` and `~/.codex/skills/`, nightly. Machine-local so they track upgrades; don't vendor them in the store or use `npx skills add`. New ones need a new agent session.

## Key conventions

- XDG app configs live under `config/<app>/` and are linked file-by-file into `~/.config/<app>/`, never the app dir itself (herdr keeps sockets and logs there). `lazy-lock.json`, Mason packages and herdr plugin files stay machine-local. The herdr auto-title plugin is built by `provisioning/shared/formulae.sh`.
- `provision.sh` runs `chmod -R go-w "$(brew --prefix)/share"` after brew installs to stop the compinit insecure directories warning.
