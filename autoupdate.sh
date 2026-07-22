#!/usr/bin/env bash
#
# autoupdate.sh — daily unattended pull + relink, run from cron.
#
# Pulls the latest master and re-runs install.sh (fast, idempotent symlinks
# only) when new commits land. Never touches uncommitted local changes: if the
# working tree isn't clean, it skips the pull and logs a warning instead of
# stashing, so in-progress edits on a given machine are never silently moved.
#
# Deliberately does NOT run provision.sh — that installs new formulae/casks
# and can touch macOS defaults, too heavy/risky to run unattended every day.
# Re-run `./provision.sh --mac` (or `--linux`) by hand when formulae.sh changes.
#
# Logs every run to LOG_FILE for manual review; no notifications.
#

set -uo pipefail

DOTFILES_DIR="$HOME/Dotfiles"
LOG_FILE="$HOME/.dotfiles-autoupdate.log"

log() { printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" >> "$LOG_FILE"; }

cd "$DOTFILES_DIR" || { log "ERROR: cannot cd to $DOTFILES_DIR"; exit 1; }

if [ -n "$(git status --porcelain)" ]; then
  log "SKIP: working tree dirty, not pulling"
  exit 0
fi

before=$(git rev-parse HEAD)

if ! git pull --ff-only origin master >> "$LOG_FILE" 2>&1; then
  log "ERROR: git pull failed"
  exit 1
fi

after=$(git rev-parse HEAD)

if [ "$before" = "$after" ]; then
  log "OK: already up to date ($after)"
  exit 0
fi

log "UPDATE: $before -> $after, running install.sh"

if ./install.sh >> "$LOG_FILE" 2>&1; then
  log "OK: install.sh completed"
else
  log "ERROR: install.sh failed"
  exit 1
fi
