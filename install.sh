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

  # ignore *.md and *.sh files, and the claude/ subtree (handled separately
  # below — it links individual files into ~/.claude, not the whole dir)
  if [[ ${name: -3} != ".sh" && ${name: -3} != ".md" && "$name" != "claude" ]]; then
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

# --- Claude Code config (~/.claude) ---------------------------------------
# The canonical config lives in this repo's claude/ subtree. We symlink it into
# ~/.claude, which is otherwise full of machine-local state (plugins/, projects/,
# caches, credentials, session/daemon files) that must stay out of git.
# Top-level files are linked individually so that local junk is never touched;
# the config subdirectories are ours alone and linked wholesale.
claude_src="$PWD/claude"
claude_dst="$HOME/.claude"
if [ -d "$claude_src" ]; then
  mkdir -p "$claude_dst"

  link_claude() {
    # $1 = name under claude/  (file or directory)
    local src="$claude_src/$1"
    local dst="$claude_dst/$1"
    [ -e "$src" ] || return 0
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
      mkdir -p "$HOME/$backup_dir"
      echo "Backing up .claude/$1 in $HOME/$backup_dir/"
      mv "$dst" "$HOME/$backup_dir/claude-$(basename "$1")$(date +"%d-%m-%Y-%H:%M:%S")"
    fi
    rm -rf "$dst"
    echo "Creating $dst"
    ln -s "$src" "$dst"
  }

  # Individual top-level files (never link the ~/.claude dir itself).
  for f in CLAUDE.md settings.json statusline-command.sh statusline-config.txt; do
    link_claude "$f"
  done
  # Config subdirectories (ours alone; safe to link wholesale).
  for d in agents commands hooks rules skills memory; do
    link_claude "$d"
  done
fi

# --- Dotfiles project memory (~/.claude/projects/…/memory) ----------------
# project-memory/ holds project-specific Claude memories for this repo
# (moved out of the retired brain/ dir, 2026-07-17). We symlink it into the
# path Claude Code uses for this project so memories survive a machine wipe
# and stay version-controlled.
dotfiles_project_memory_dst="$HOME/.claude/projects/-Users-$(whoami)-Dotfiles/memory"
dotfiles_project_memory_src="$PWD/project-memory"
if [ -d "$dotfiles_project_memory_src" ]; then
  mkdir -p "$(dirname "$dotfiles_project_memory_dst")"
  if [ -e "$dotfiles_project_memory_dst" ] && [ ! -L "$dotfiles_project_memory_dst" ]; then
    mkdir -p "$HOME/$backup_dir"
    echo "Backing up $dotfiles_project_memory_dst in $HOME/$backup_dir/"
    mv "$dotfiles_project_memory_dst" "$HOME/$backup_dir/claude-project-memory-$(date +"%d-%m-%Y-%H:%M:%S")"
  fi
  rm -rf "$dotfiles_project_memory_dst"
  echo "Creating $dotfiles_project_memory_dst"
  ln -s "$dotfiles_project_memory_src" "$dotfiles_project_memory_dst"
fi

# Activate this repo's git hooks (the gitleaks secret-scan pre-commit hook).
if [ -d "$PWD/.githooks" ] && git -C "$PWD" rev-parse --git-dir > /dev/null 2>&1; then
  echo "Enabling git hooks (core.hooksPath = .githooks)"
  chmod +x "$PWD/.githooks/"* 2>/dev/null
  git -C "$PWD" config core.hooksPath .githooks
fi

echo "Run chsh -s /bin/zsh to use zsh (or chsh -s /bin/bash for bash) — both are configured"

