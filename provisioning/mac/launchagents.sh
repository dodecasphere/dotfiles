#!/usr/bin/env bash

#
# Symlink and (re)load all LaunchAgents from this script's launchagents/ dir.
# Resolves its own location so it works no matter the current directory.
#

LAUNCHAGENTS_SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/launchagents" && pwd)"

mkdir -p "$HOME/Library/LaunchAgents"

for agent in "$LAUNCHAGENTS_SRC"/*; do
  name="$(basename "$agent")"
  target="$HOME/Library/LaunchAgents/$name"

  # If it already exists (file or symlink), unload and remove before re-linking.
  if [ -e "$target" ] || [ -L "$target" ]; then
    launchctl unload -w "$target" 2>/dev/null
    rm -f "$target"
  fi

  echo "Creating $target"
  ln -s "$agent" "$target"
  launchctl load -w "$target"
done
