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
    source provisioning/mac/macos.sh

    source provisioning/mac/node.sh
    source provisioning/mac/secrets.sh
    source provisioning/mac/ssh.sh
    source provisioning/mac/git.sh
    source provisioning/mac/php.sh

    source provisioning/mac/crons.sh
    source provisioning/mac/launchagents.sh

    source provisioning/mac/todo.sh

elif [[ "$1" == "--linux" ]]; then
    source provisioning/linux/apt-get.sh

fi



# Default to zsh (macOS ships it and it's already in /etc/shells).
# Bash remains fully configured — switch any time with `chsh -s /bin/bash`.
chsh -s /bin/zsh
