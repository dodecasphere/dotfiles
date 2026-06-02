#!/usr/bin/env bash

#
# Set up PHP, MySQL, Composer and Laravel
# USE DBNGIN INSTEAD OF INSTALLING DATABASES
#

# Weird thing with macOS, might need to run `sudo chown -R $(whoami) $(brew --prefix)/*` to fix permissions, per https://stackoverflow.com/questions/16432071/how-to-fix-homebrew-permissions
# rm -rf /usr/local/var/mysql if you're trying to reinstall mysql
# Also, see this if getting weird issues with authentication: https://laracasts.com/discuss/channels/laravel/caching-sha2-password-error-when-running-php-artisan-migrate

# Start with MySQL
# doing "Installing MySQL..."
# brew install mysql@5.7

# doing "Starting MySQL as a service..."
# brew services start mysql@5.7

# doing "Setting up MySQL Password..."
# mysql_secure_installation

# doing "Creating databases..."
# mysql -u root -e "create database family;" -v
# mysql -u root -e "create database smart-mirror;" -v
# mysql -u root -e "create database crestlite55;" -v
# mysql -u root -e "create database dra;" -v
# mysql -u root -e "create database concrete;" -v

# NOTE THIS: https://flipdazed.github.io/blog/osx%20maintenance/set-up-mysql-osx

# Then set up PHP
formula "php"

doing "Installing the PHP Xdebug extension..."
pecl_install xdebug

# doing "Installing the PHP Redis extension..."
# pecl_install redis

doing "Installing the PHP Imagemagick extension..."
pecl_install imagick

doing "Starting PHP as a service..."
brew services start php

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# run `valet install` if upgrading PHP version
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

# Then bring in phpunit (not necessary since it's brought in on every laravel project)
formula "phpunit"

# Then set up Composer
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
# composer_global "laravel/lumen-installer"
# composer_global "laravel/valet"
composer_global "laravel/envoy"
# composer_global "tightenco/collect" --deprecated
composer_global "ergebnis/composer-normalize"
composer_global "squizlabs/php_codesniffer"
composer_global "beyondcode/expose"

# Laravel Herd replaces all of this
# doing "Running Valet installer..."
# $HOME/.composer/vendor/bin/valet install
# valet trust

# doing "Starting nginx and dnsmasq as services (sudo)..."
# sudo brew services start nginx
# sudo brew services start dnsmasq

doing "Installing Mailhog (for local mail testing)..."
formula "mailhog"

doing "Starting Mailhog as a service..."
brew services start mailhog

# doing "Installing Redis..."
# formula "redis"

# doing "Starting Redis as a service..."
# brew services start redis

doing "Installing Deployer..."
if command -v dep &>/dev/null || [ -f /usr/local/bin/dep ]; then
  echo "deployer (dep) already installed — skipping"
else
  curl -LO https://deployer.org/deployer.phar
  sudo mv deployer.phar /usr/local/bin/dep
  chmod +x /usr/local/bin/dep
fi
