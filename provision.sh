#!/usr/bin/env bash

#
# `./provision.sh --mac or --linux`
#

clear

# Functions
source functions

sudo -v

while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

if [[ "$1" == "--mac" ]]; then
    # Install guards (formula/cask/mas_install/... skip anything already installed)
    source provisioning/mac/helpers.sh

    source provisioning/mac/terminal.sh
    source provisioning/mac/xcode.sh

    source provisioning/mac/brew.sh
    source provisioning/mac/formulae.sh
    source provisioning/mac/apps.sh
    source provisioning/mac/fonts.sh
    source provisioning/mac/app-store-apps.sh

    # Fix zsh compinit "insecure directories" warning — Homebrew leaves share/ group-writable.
    chmod -R go-w "$(brew --prefix)/share"

    source provisioning/mac/macos.sh

    source provisioning/mac/node.sh
    source provisioning/mac/claude.sh
    source provisioning/mac/secrets.sh
    source provisioning/mac/ssh.sh
    source provisioning/mac/git.sh
    source provisioning/mac/php.sh

    source provisioning/mac/crons.sh
    source provisioning/mac/launchagents.sh

    source provisioning/mac/todo.sh

elif [[ "$1" == "--linux" ]]; then
    # Base system packages (also what Homebrew-on-Linux needs), then brew itself.
    source provisioning/linux/apt.sh
    source provisioning/linux/updates.sh
    source provisioning/linux/hardening.sh
    source provisioning/linux/tailscale.sh
    source provisioning/linux/docker.sh
    source provisioning/linux/swap.sh
    source provisioning/linux/brew.sh

    # Install guards — portable; the mac-only ones (cask/mas_install) are
    # defined but simply never called on this path.
    source provisioning/mac/helpers.sh

    source provisioning/shared/formulae.sh

    # Fix zsh compinit "insecure directories" warning — same brew quirk as macOS.
    chmod -R go-w "$(brew --prefix)/share"

    source provisioning/mac/node.sh
    source provisioning/mac/claude.sh
    source provisioning/linux/codex.sh
    source provisioning/mac/secrets.sh
    source provisioning/linux/git.sh
    source provisioning/linux/php.sh

    source provisioning/linux/crons.sh

fi



# Default to zsh (macOS ships it at /bin/zsh; on Linux apt's is /usr/bin/zsh —
# resolve whichever exists). Bash remains fully configured — switch any time
# with `chsh -s /bin/bash`.
if [ "$(basename "$SHELL")" != "zsh" ]; then
    chsh -s "$(command -v zsh)"
fi
