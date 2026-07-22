# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Personal dotfiles for macOS (primary) and Linux (headless Ubuntu/Debian server, CLI parity via Homebrew on Linux). Files are symlinked into `$HOME` as hidden files by `install.sh`. Provisioning scripts install apps and configure the machine.

## Scripts

| Script | Purpose |
|---|---|
| `bootstrap.sh` | Fresh machine: clones repo + runs `install.sh`. Curl-runnable. |
| `install.sh` | Symlinks every non-`.sh`/non-`.md` file in the repo root into `$HOME` as `~/.<name>`. Backs up real files, replaces existing symlinks. Also wires up the gitleaks pre-commit hook. |
| `provision.sh --mac` | Installs formulae, apps, fonts, configures macOS defaults, sets up Node/PHP/Claude/SSH/Git. Safe to re-run (all steps are idempotent). |
| `test.sh` | Dry-run restore test: clones committed HEAD into a temp dir and simulates a fresh-machine install, verifying the Claude config layer restores and no secrets leak. |

## Provisioning architecture

`provision.sh --mac` sources scripts from `provisioning/mac/` in order. `provision.sh --linux` sources `provisioning/linux/` (apt base packages, unattended-upgrades for OS patching, VPS hardening with sshd/ufw/fail2ban, Tailscale, Docker engine, a swapfile, Homebrew on Linux, Linux ports of git/php/crons) plus the portable mac scripts directly (`helpers.sh`, `node.sh`, `claude.sh`, `secrets.sh`). The OS-agnostic formula list lives in `provisioning/shared/formulae.sh`, sourced by both platforms so the two never drift; macOS-only formulae stay in `provisioning/mac/formulae.sh`. The install guards (`formula`, `cask`, `mas_install`, `npm_global`, `pecl_install`, `composer_global`, `add_cron`) live in `provisioning/mac/helpers.sh` and skip anything already installed. That is what makes re-running safe. The helpers are also symlinked into interactive shells via `~/.provisioning`, so commands like `cask foo` work at the prompt.

## Claude Code config layer (`claude/`)

The `claude/` subtree is the canonical, version-controlled Claude Code config (agents, commands, hooks, skills, rules, mcp, templates, plus `settings.json` and the statusline). `install.sh` handles it separately from the generic root-file loop: it symlinks the individual files into `~/.claude`, which is otherwise full of machine-local state (plugins, projects, sessions) that must stay out of git. `test.sh` verifies this restore on a simulated fresh machine.

`project-memory/` (repo root) holds this repo's Claude project memories, symlinked by `install.sh` into `~/.claude/projects/-Users-<user>-Dotfiles/memory`. Global cross-project memories live in `claude/memory/`, symlinked to `~/.claude/memory/`. (The old `brain/` Project Brain was retired 2026-07-17, EOS IDEA-014 slice 6; durable content was distilled below, full history in git.)

## Durable decisions (distilled from the retired brain)

- Third-party Claude skills are always hand-ported into `claude/` (markdown, house-styled, selective), never installed via upstream `curl | bash` or `npx` installers: those write into machine-local `~/.claude` and fight the symlink-restore model. Provenance and refresh steps for vendored skills live in `claude/skills/UPSTREAM.md`.
- The Matt Pocock skills adoption (2026-07-09) was deliberately disciplines-only: the issue-tracker delivery pipeline half (triage, to-spec, to-tickets, wayfinder, CONTEXT.md domain models) was rejected because it collides with the owner's own workflow systems. Do not re-propose adopting it wholesale.
- Non-goals: multi-account `CLAUDE_CONFIG_DIR` switching (deliberately abandoned), TypeScript in app-code guidance (owner uses plain JS), Filament and Capacitor (not part of the stack).
- The statusline usage gauge reads `rate_limits` straight from the JSON Claude Code pipes to it on stdin (no cookie, no cache, no `curl-impersonate`, no Claude Usage app). It follows whatever account Claude Code is logged into, so switching accounts needs nothing. The numbers are absent until the first API response of a session and on non-subscription auth, where the gauge shows `~`. This replaced the old cookie-scraping approach (retired 2026-07-21).

## Shell config architecture

Both bash and zsh are fully configured. Shared files are sourced by both shells:

- `colors`: terminal color variables
- `path`: `$PATH` extensions and `brew shellenv`
- `exports`: environment variables
- `aliases/`: alias files split by topic (`git`, `brew`, `docker`, `directories`, `mac`, etc.)
- `functions`: shell functions
- `extra`: machine-local overrides, not committed

Shell-specific entry points: `zshrc` / `zprofile` (zsh), `bash_profile` / `bashrc` (bash). Both source the shared files above in the same order.

## Private secrets

A separate private repo is expected at `~/.dotfiles-secrets/` containing `secrets.env`. The `zshrc` sources it if present. `provisioning/mac/secrets.sh` handles cloning it during provisioning.

## Key conventions

- Adding a new alias: create or edit a file in `aliases/` (picked up automatically by both shells).
- Adding a new formula/cask: add a `formula "name"` or `cask "name"` call in `provisioning/mac/formulae.sh` or `apps.sh`.
- The `zsh-completions` fix (`chmod -R go-w "$(brew --prefix)/share"`) runs in `provision.sh` after all brew installs to prevent the compinit insecure directories warning.
- The gitleaks pre-commit hook (`.githooks/`) scans for secrets on every commit.
