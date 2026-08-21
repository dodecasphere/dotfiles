#!/usr/bin/env bash

#
# Symlink and (re)load all LaunchAgents from this script's launchagents/ dir.
# Plist files can't use env vars, so each source plist carries a __USER__ placeholder.
# The placeholder is substituted into a rendered copy under launchagents/.rendered/
# (gitignored) and the symlink points there, so the committed sources stay pristine.
# Resolves its own location so it works no matter the current directory.
# BASH_SOURCE is bash-only; zsh sets $0 to the sourced file instead.
#

LAUNCHAGENTS_SRC="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/launchagents" && pwd)"
LAUNCHAGENTS_RENDERED="$LAUNCHAGENTS_SRC/.rendered"

mkdir -p "$HOME/Library/LaunchAgents" "$LAUNCHAGENTS_RENDERED"

for agent in "$LAUNCHAGENTS_SRC"/*.plist; do
  [ -f "$agent" ] || continue
  name="$(basename "$agent")"
  target="$HOME/Library/LaunchAgents/$name"
  rendered="$LAUNCHAGENTS_RENDERED/$name"

  # If it already exists (file or symlink), unload and remove before re-installing.
  if [ -e "$target" ] || [ -L "$target" ]; then
    launchctl unload -w "$target" 2>/dev/null
    rm -f "$target"
  fi

  echo "Creating $target"
  sed "s/__USER__/$(whoami)/g" "$agent" > "$rendered"
  ln -s "$rendered" "$target"
  launchctl load -w "$target"
done
