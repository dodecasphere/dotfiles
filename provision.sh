#!/usr/bin/env bash

#
# `./provision.sh --mac or --linux`
#

# Test for known flags
# for opt in $@
# do
#     case $opt in
#         --no-packages) no_packages=true ;;
#         --no-sync) no_sync=true ;;
#         -*|--*) e_warning "Warning: invalid option $opt" ;;
#     esac
# done

clear

# Functions
source functions

sudo -v

while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

if [[ "$1" == "--mac" ]]; then
    source provisioning/mac/terminal.sh
    source provisioning/mac/xcode.sh

    source provisioning/mac/brew.sh
    source provisioning/mac/formulae.sh
    source provisioning/mac/apps.sh
    source provisioning/mac/fonts.sh
    source provisioning/mac/app-store-apps.sh
    source provisioning/mac/macos.sh

    source provisioning/mac/node.sh
    source provisioning/mac/ssh.sh
    source provisioning/mac/git.sh
    source provisioning/mac/php.sh

    source provisioning/mac/crons.sh

    source provisioning/mac/todo.sh

elif [[ "$1" == "--linux" ]]; then
    source provisioning/linux/apt-get.sh

fi



echo "/usr/local/bin/bash" | sudo tee -a /etc/shells
chsh -s /usr/local/bin/bash
