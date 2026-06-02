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
formula "z"

# Install fzf key bindings + completion non-interactively, without editing rc
# files (our zshrc/bashrc already source ~/.fzf.zsh / ~/.fzf.bash).
"$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc
