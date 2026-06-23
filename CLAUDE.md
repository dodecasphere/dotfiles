# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Personal dotfiles for macOS (primary) and Linux (partial). Files are symlinked into `$HOME` as hidden files by `install.sh`. Provisioning scripts install apps and configure the machine.

## Scripts

| Script | Purpose |
|---|---|
| `bootstrap.sh` | Fresh machine: clones repo + runs `install.sh`. Curl-runnable. |
| `install.sh` | Symlinks every non-`.sh`/non-`.md` file in the repo root into `$HOME` as `~/.<name>`. Backs up real files, replaces existing symlinks. Also wires up the gitleaks pre-commit hook. |
| `provision.sh --mac` | Installs formulae, apps, fonts, configures macOS defaults, sets up Node/PHP/Claude/SSH/Git. Safe to re-run (all steps are idempotent). |
| `test.sh` | Dry-run restore test: clones committed HEAD into a temp dir and simulates a fresh-machine install, verifying the Claude config layer restores and no secrets leak. |

## Provisioning architecture

`provision.sh` sources scripts from `provisioning/mac/` in order. The install guards (`formula`, `cask`, `mas_install`, `npm_global`, `pecl_install`, `composer_global`, `add_cron`) live in `provisioning/mac/helpers.sh` and skip anything already installed. That is what makes re-running safe. The helpers are also symlinked into interactive shells via `~/.provisioning`, so commands like `cask foo` work at the prompt.

## Claude Code config layer (`claude/`)

The `claude/` subtree is the canonical, version-controlled Claude Code config (agents, commands, hooks, skills, rules, mcp, templates, plus `settings.json` and the statusline). `install.sh` handles it separately from the generic root-file loop: it symlinks the individual files into `~/.claude`, which is otherwise full of machine-local state (plugins, projects, sessions) that must stay out of git. `test.sh` verifies this restore on a simulated fresh machine.

`brain/` (repo root, not symlinked) is this project's Project Brain: the `0N-XX-*.md` files auto-loaded each session by `claude/hooks/brain-loader.sh`. Treat them as authoritative project grounding.

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
