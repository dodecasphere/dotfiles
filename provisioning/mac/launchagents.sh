#!/usr/bin/env bash

#
# Symlink and (re)load all LaunchAgents from this script's launchagents/ dir.
# Rewrites the placeholder username in each source plist to the current user before symlinking (plist files can't use env vars).
# Resolves its own location so it works no matter the current directory.
# BASH_SOURCE is bash-only; zsh sets $0 to the sourced file instead.
#

LAUNCHAGENTS_SRC="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/launchagents" && pwd)"

mkdir -p "$HOME/Library/LaunchAgents"

for agent in "$LAUNCHAGENTS_SRC"/*; do
  name="$(basename "$agent")"
  target="$HOME/Library/LaunchAgents/$name"

  # If it already exists (file or symlink), unload and remove before re-installing.
  if [ -e "$target" ] || [ -L "$target" ]; then
    launchctl unload -w "$target" 2>/dev/null
    rm -f "$target"
  fi

  echo "Creating $target"
  sed -i '' "s/michaeldulle/$(whoami)/g" "$agent"
  ln -s "$agent" "$target"
  launchctl load -w "$target"
done
