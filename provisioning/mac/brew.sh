#!/usr/bin/env bash

#
# Install Brew
# Maybe move all of this to brew bundle? https://github.com/driesvints/dotfiles/blob/master/Brewfile
#

# Check Cask version
function cask_version_available() {
    brew info "$1" | head -n 1 | cut -d " " -f 2
}

# Check Cask version
function cask_version_installed() {
    # ls -1 "$(cask_staging_location)/$1" | tr '\n' ' ' | sed -e 's/ $//'
    ls -1 "/usr/local/Caskroom/$1" | tr '\n' ' ' | sed -e 's/ $//'
}

# Get Cask staging location
function cask_staging_location() {
    brew doctor | grep -A1 '==> Homebrew Cask Staging Location:' | tail -n1
}

# Install brew app
function formula {
  doing "Installing Homebrew Formula [$1]..."
  brew list | grep "$1" > /dev/null 2>&1
  if [[ $? -ne 0 ]]; then
    if [ "yes" == $(ask_yes_or_no "Continue installing $1 ?") ]; then brew install $1; fi
  else
    echo "$1 already installed"
  fi
}

# Install brew cask app
function cask {
  aver=`cask_version_available $1`
  doing "Installing Homebrew Application [$1 $aver]..."
  brew list | grep "$1" > /dev/null 2>&1
  if [[ $? -ne 0 ]]; then
    if [ "yes" == $(ask_yes_or_no "Continue installing $1 $aver?") ]; then brew install --cask $1; fi
  else
    iver=`cask_version_installed $1`
    echo "$1 $iver already installed"
  fi
}

doing "Installing Brew..."
brew -v > /dev/null 2>&1
if [[ $? -ne 0 ]]; then
  # ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "Brew already installed"
  brew update
  brew upgrade
fi

echo 'eval $(/opt/homebrew/bin/brew shellenv)' >> /Users/michaeldulle/.zprofile
eval $(/opt/homebrew/bin/brew shellenv)

brew tap homebrew/cask
brew tap homebrew/cask-versions
brew tap homebrew/cask-fonts

# brew tap adoptopenjdk/openjdk
# brew cask install adoptopenjdk13

doing "Checking in with the brew doctor..."
brew doctor

read -p "Mind the Doctor's recommendations and make any adjustments in a different tab before continuing. Press any key to continue." -n 1 -r
