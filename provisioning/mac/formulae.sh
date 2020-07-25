#!/usr/bin/env bash

# 
# Install Brew Formulae
# 

doing "Installing brew applications..."

formula "bash"
formula "bash-completion@2"
formula "bluetoothconnector"
formula "ffmpeg"
formula "fzf"
formula "git"
formula "httpie"
formula "hub"
formula "mas"
formula "node"
formula "php-cs-fixer"
formula "python"
formula "speedtest-cli"
formula "svn"
formula "terminal-notifier"
formula "tree"
formula "wget"
formula "yarn"
formula "z"

$(brew --prefix)/opt/fzf/install
