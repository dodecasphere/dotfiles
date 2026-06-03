#!/usr/bin/env bash

clear
echo "      _       _    __ _ _             "
echo "     | |     | |  / _(_) |            "
echo "   __| | ___ | |_| |_ _| | ___  ___   "
echo "  / _\` |/ _ \| __|  _| | |/ _ \/ __|  "
echo " | (_| | (_) | |_| | | | |  __/\__ \  "
echo "(_)__,_|\___/ \__|_| |_|_|\___||___/  "
echo "______________________________________________"
echo
echo "Installing dotfiles into your home directory"
echo

backup_dir=".backup_old_dot_files"

for name in *; do

  target="$HOME/.$name"

  # ignore *.md and *.sh files
  if [[ ${name: -3} != ".sh" && ${name: -3} != ".md" ]]; then
    # check if file already exists
    if [ -e "$target" ]; then
      # check if file is a symlink.
      # if it is symlink we just delete it
      # if it's a real file we back it up
      if [ ! -L "$target" ]; then
        # create backup dir if it's not there
        if [ ! -d "$HOME/$backup_dir" ]; then
          mkdir -p "$HOME/$backup_dir"
        fi
        echo "Backing up .$name in $HOME/$backup_dir/ directory"
        cp "$target" "$HOME/$backup_dir/.$name$(date +"%d-%m-%Y-%H:%M:%S")"
      fi
      rm -rf "$target"
    fi

    echo "Creating $target"
    ln -s "$PWD/$name" "$target"
  fi

done

# Activate this repo's git hooks (the gitleaks secret-scan pre-commit hook).
if [ -d "$PWD/.githooks" ] && git -C "$PWD" rev-parse --git-dir > /dev/null 2>&1; then
  echo "Enabling git hooks (core.hooksPath = .githooks)"
  chmod +x "$PWD/.githooks/"* 2>/dev/null
  git -C "$PWD" config core.hooksPath .githooks
fi

echo "Run chsh -s /bin/zsh to use zsh (or chsh -s /bin/bash for bash) — both are configured"

