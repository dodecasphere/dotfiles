#!/usr/bin/env bash

#
# Install Brew
# Maybe move all of this to brew bundle? https://github.com/driesvints/dotfiles/blob/master/Brewfile
#
# The `formula` / `cask` install guards (and other helpers) now live in
# provisioning/mac/helpers.sh, sourced at the top of provision.sh.
#

doing "Installing Brew..."
brew -v > /dev/null 2>&1
if [[ $? -ne 0 ]]; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "Brew already installed"
  brew update
  brew upgrade
fi

# Load brew into this shell. Persistent shellenv lives in the repo's `zprofile`
# dotfile (symlinked to ~/.zprofile by install.sh), so we don't append it here.
eval "$(/opt/homebrew/bin/brew shellenv)"

# Note: homebrew/cask is auto-tapped, and homebrew/cask-versions and
# homebrew/cask-fonts were archived into homebrew/cask (Homebrew 4.3.0), so no
# taps are needed anymore.

doing "Checking in with the brew doctor..."
brew doctor

press_key_to_continue "Mind the Doctor's recommendations and make any adjustments in a different tab before continuing. Press any key to continue."
