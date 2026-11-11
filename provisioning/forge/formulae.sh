#!/usr/bin/env bash

#
# Curated brew formulae for a Laravel Forge server. A subset of
# provisioning/shared/formulae.sh: shell and CLI ergonomics only. Nothing here
# may install or depend on php, node, python or git, because brew's bin sits
# ahead of /usr/bin on PATH and would shadow the copies Forge manages.
# herdr and hc are already installed in ~/.local/bin by the mac's herdr.sh.
#

doing "Installing brew applications (forge subset)..."

# zsh plugins: zshrc only loads them from the brew prefix.
formula "zsh-completions"
formula "zsh-autosuggestions"
formula "zsh-syntax-highlighting"
brew tap olets/tap
brew trust --tap olets/tap
formula "zsh-abbr"

# CLI tools the aliases and exports expect (apt names some differently).
formula "fzf"
formula "eza"
formula "bat"
formula "fd"
formula "ripgrep"
formula "zoxide"
formula "tree"

# Git tooling (apt's gh is old, lazygit isn't packaged for 24.04).
formula "gh"
formula "git-delta"
formula "lazygit"
formula "gitleaks"   # the dotfiles pre-commit hook

formula "neovim"     # apt's 0.9 is too old for LazyVim
formula "btop"
formula "tealdeer"

"$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc

source provisioning/shared/agent-skills.sh
