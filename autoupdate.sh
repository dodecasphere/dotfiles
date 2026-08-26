#!/usr/bin/env bash
#
# autoupdate.sh — daily unattended pull + relink, run from cron.
#
# Pulls the latest master and re-runs install.sh (fast, idempotent symlinks
# only) when new commits land. Never touches uncommitted local changes: if the
# working tree isn't clean, it skips the pull and logs a warning instead of
# stashing, so in-progress edits on a given machine are never silently moved.
#
# The one exception is claude/settings.json. Claude Code writes to that file
# itself (marketplace declarations, enabledPlugins, the plugin auto-update
# toggle), so on any machine that runs Claude Code the tree goes dirty on its
# own and the skip above would silently stop updates forever, logging only
# here where nobody looks. When settings.json is the ONLY dirty path and it
# still parses as JSON, this script commits it with a machine tag and carries
# on, so Claude's own state becomes history instead of a roadblock. Anything
# else dirty still takes the conservative skip.
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

dirty=$(git status --porcelain)

# Absorb Claude Code's own writes to settings.json (see header). Only when that
# file is the sole dirty path, so a genuine in-progress edit still blocks.
if [ "$dirty" = " M claude/settings.json" ] || [ "$dirty" = "M  claude/settings.json" ]; then
  if jq empty claude/settings.json >/dev/null 2>&1; then
    machine=$(scutil --get ComputerName 2>/dev/null || hostname -s)
    if git add claude/settings.json &&
       git commit -qm "chore(claude): sync settings.json written by Claude Code on $machine" >> "$LOG_FILE" 2>&1; then
      log "COMMIT: absorbed Claude Code settings.json changes ($machine)"
      dirty=""
    else
      log "SKIP: could not commit settings.json, not pulling"
      exit 0
    fi
  else
    # Mid-write or corrupted; leave it alone and try again tomorrow.
    log "SKIP: claude/settings.json is not valid JSON, not pulling"
    exit 0
  fi
fi

if [ -n "$dirty" ]; then
  log "SKIP: working tree dirty, not pulling"
  exit 0
fi

before=$(git rev-parse HEAD)

if ! git pull --ff-only origin master >> "$LOG_FILE" 2>&1; then
  # Both sides moved, so this is not a fast-forward. If every local commit
  # touches nothing but claude/settings.json, they are this script's own syncs
  # and rebasing them is safe, so do it rather than stalling updates forever.
  # Anything else is real work: stop and say so.
  local_commits=$(git log origin/master..HEAD --oneline 2>/dev/null)
  if [ -z "$local_commits" ]; then
    log "ERROR: git pull failed"
    exit 1
  fi
  touched=$(git diff --name-only origin/master...HEAD | sort -u)
  if [ "$touched" = "claude/settings.json" ]; then
    if git pull --rebase origin master >> "$LOG_FILE" 2>&1; then
      log "REBASED: settings.json sync replayed onto upstream"
    else
      git rebase --abort >/dev/null 2>&1 || true
      log "DIVERGED: settings.json rebase failed; reconcile by hand"
      exit 1
    fi
  else
    log "DIVERGED: local commits touch more than settings.json; reconcile by hand"
    exit 1
  fi
fi

after=$(git rev-parse HEAD)

# Push the settings.json commit (if any) so the other machine gets it. Not
# fatal: a laptop that is offline or unauthenticated just carries it forward
# to the next run.
if [ -n "$(git log origin/master..HEAD --oneline 2>/dev/null)" ]; then
  if git push origin master >> "$LOG_FILE" 2>&1; then
    log "OK: pushed local commits"
  else
    log "WARN: push failed, local commits will retry next run"
  fi
fi

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
