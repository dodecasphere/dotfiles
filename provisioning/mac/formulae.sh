#!/usr/bin/env bash

# 
# Install Brew Formulae
# 

doing "Installing brew applications..."

formula "bash"                    # up-to-date bash (macOS ships an ancient 3.2)
formula "bash-completion@2"       # tab completion for bash
formula "zsh-completions"         # extra tab completions for zsh
formula "zsh-autosuggestions"     # inline command suggestions from history
formula "zsh-syntax-highlighting" # colorizes commands as you type
formula "bluetoothconnector"      # connect/disconnect Bluetooth devices from the CLI
formula "ffmpeg"                  # audio/video converter
formula "fzf"                     # fuzzy finder (Ctrl-R history search, etc.)
formula "gifsicle"                # GIF optimizer/editor
formula "git"                     # up-to-date git (newer than Apple's)
formula "gh"                      # GitHub CLI (PRs, issues, API)
formula "httpie"                  # friendlier curl for HTTP requests
formula "jpegoptim"               # JPEG optimizer
formula "libavif"                 # AVIF image encoding/decoding
formula "mas"                     # Mac App Store CLI (used by apps.sh)
formula "node"                    # Node.js runtime
formula "optipng"                 # PNG optimizer (lossless)
formula "php-cs-fixer"            # PHP code style fixer
formula "pngquant"                # PNG compressor (lossy)
formula "python"                  # Python 3
formula "speedtest-cli"           # internet speed test
formula "svgo"                    # SVG optimizer
formula "svn"                     # Subversion (needed by some font casks)
formula "terminal-notifier"       # send macOS notifications from scripts
formula "tree"                    # directory listing as a tree
formula "wget"                    # file downloader
formula "yarn"                    # JS package manager

# Modern CLI tools
formula "eza"        # modern ls
formula "bat"        # modern cat (syntax highlighting)
formula "fd"         # modern find
formula "ripgrep"    # modern grep (rg)
formula "zoxide"     # smarter cd (replaces z)
formula "btop"       # system/process monitor
formula "tealdeer"   # tldr cheatsheets
formula "gitleaks"   # secret scanner (used by the pre-commit hook)

# Docker helpers (Docker Desktop itself is a cask in apps.sh and bundles the
# docker CLI, compose, and buildx — these are just ergonomics on top).
formula "lazydocker"
formula "dive"
formula "ctop"
formula "act"
formula "mkcert"

# Install fzf key bindings + completion non-interactively, without editing rc
# files (our zshrc/bashrc already source ~/.fzf.zsh / ~/.fzf.bash).
"$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc
