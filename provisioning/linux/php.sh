#!/usr/bin/env bash

#
# Set up PHP and Composer/Laravel tooling. No Herd on Linux — PHP and Composer
# come from Homebrew here. Same global Composer packages as the mac setup.
#

doing "Installing PHP + Composer..."
formula "php"
formula "composer"

doing "Installing Laravel things..."
composer_global "laravel/installer"
composer_global "laravel/envoy"
composer_global "ergebnis/composer-normalize"
composer_global "squizlabs/php_codesniffer"
composer_global "beyondcode/expose"

# Mailhog for local mail testing — the `formula` guard asks before installing,
# so skipping it on a box that doesn't need it is one "no" away.
doing "Installing Mailhog (for local mail testing)..."
formula "mailhog"
if brew list --formula mailhog &>/dev/null; then
  brew services start mailhog
fi

doing "Installing Deployer..."
if command -v dep &>/dev/null; then
  echo "deployer (dep) already installed — skipping"
else
  # ~/.local/bin is already on $PATH (see `path`) and needs no sudo.
  mkdir -p "$HOME/.local/bin"
  curl -LO https://deployer.org/deployer.phar
  mv deployer.phar "$HOME/.local/bin/dep"
  chmod +x "$HOME/.local/bin/dep"
fi
