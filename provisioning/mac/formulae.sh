#!/usr/bin/env bash

# 
# Install Brew Formulae
# 

doing "Installing brew applications..."

formula "bash"
formula "bash-completion@2"
formula "zsh-completions"
formula "zsh-autosuggestions"
formula "zsh-syntax-highlighting"
formula "bluetoothconnector"
formula "ffmpeg"
formula "fzf"
formula "gifsicle"
formula "git"
formula "gh"
formula "httpie"
formula "jpegoptim"
formula "libavif"
formula "mas"
formula "node"
formula "optipng"
formula "php-cs-fixer"
formula "pngquant"
formula "python"
formula "speedtest-cli"
formula "svgo"
formula "svn"
formula "terminal-notifier"
formula "tree"
formula "wget"
formula "yarn"

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
