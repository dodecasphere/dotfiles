#!/usr/bin/env bash

#
# Set up Composer and Laravel tooling.
# PHP is managed by Laravel Herd (versions, Xdebug, extensions, php-fpm).
# USE DBNGIN INSTEAD OF INSTALLING DATABASES
#

# Set up Composer
doing "Installing Composer..."
if command -v composer &>/dev/null; then
  echo "composer already installed — skipping"
else
  curl -sS https://getcomposer.org/installer | php
  sudo mv composer.phar /usr/local/bin/composer
fi

# Then install Laravel things
# Make sure to place the $HOME/.composer/vendor/bin directory (or the equivalent directory for your OS)
# in your $PATH so the laravel executables can be located by your system.
doing "Installing Laravel things..."
composer_global "laravel/installer"
composer_global "laravel/envoy"
composer_global "ergebnis/composer-normalize"
composer_global "squizlabs/php_codesniffer"
composer_global "beyondcode/expose"

doing "Installing Deployer..."
if command -v dep &>/dev/null || [ -f /usr/local/bin/dep ]; then
  echo "deployer (dep) already installed — skipping"
else
  curl -LO https://deployer.org/deployer.phar
  sudo mv deployer.phar /usr/local/bin/dep
  chmod +x /usr/local/bin/dep
fi
