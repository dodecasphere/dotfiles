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
# Logs every run to LOG_FILE for manual review; no notifications. Prunes
# entries older than 180 days on every run so the log doesn't grow forever.
#

set -uo pipefail

DOTFILES_DIR="$HOME/Dotfiles"
LOG_FILE="$HOME/.dotfiles-autoupdate.log"

log() { printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" >> "$LOG_FILE"; }

# Lines are timestamped `[YYYY-MM-DD ...]` from log(), except raw git/install.sh
# output appended between them; those inherit the timestamp of the log() line
# above them. -v-180d is BSD date (mac); -d is the GNU fallback (Linux).
prune_log() {
  [ -f "$LOG_FILE" ] || return 0
  local cutoff
  cutoff=$(date -v-180d '+%Y-%m-%d' 2>/dev/null || date -d '180 days ago' '+%Y-%m-%d')
  awk -v cutoff="$cutoff" '
    /^\[[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] / {
      ts = substr($0, 2, 10)
      keep = (ts >= cutoff)
    }
    keep { print }
  ' "$LOG_FILE" > "$LOG_FILE.tmp" && mv "$LOG_FILE.tmp" "$LOG_FILE"
}
prune_log

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
