#!/usr/bin/env zsh

# Login-shell environment for zsh.
# Runs after macOS /etc/zprofile (path_helper), so anything set here — and the
# PATH re-ordering done later in ~/.zshrc — survives path_helper's reshuffling.

# Homebrew environment (PATH, MANPATH, INFOPATH, HOMEBREW_* vars).
eval "$(/opt/homebrew/bin/brew shellenv)"
