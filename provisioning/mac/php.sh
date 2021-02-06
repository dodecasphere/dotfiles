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
doing "Installing PHP..."
brew install php

doing "Installing the PHP Xdebug extension..."
pecl install xdebug

# doing "Installing the PHP Redis extension..."
# pecl install redis

doing "Installing the PHP Imagemagick extension..."
pecl install imagick

doing "Starting PHP as a service..."
brew services start php

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# run `valet install` if upgrading PHP version
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

# Then bring in phpunit (not necessary since it's brought in on every laravel project)
doing "Installing PHPUnit..."
brew install phpunit

# Then set up Composer
doing "Installing Composer..."
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# Then install Laravel things
# Make sure to place the $HOME/.composer/vendor/bin directory (or the equivalent directory for your OS)
# in your $PATH so the laravel executables can be located by your system.
doing "Installing Laravel things..."
# composer global require "laravel/installer"
# composer global require "laravel/lumen-installer"
composer global require "laravel/valet"
composer global require "laravel/envoy"
composer global require "tightenco/collect"
composer global require "tightenco/lambo"
composer global require "ergebnis/composer-normalize"
composer global require "squizlabs/php_codesniffer"
composer global require "beyondcode/expose"

doing "Running Valet installer..."
$HOME/.composer/vendor/bin/valet install
valet trust

doing "Starting nginx and dnsmasq as services (sudo)..."
sudo brew services start nginx
sudo brew services start dnsmasq

doing "Installing Mailhog (for local mail testing)..."
brew install mailhog

doing "Starting Mailhog as a service..."
brew services start mailhog

# doing "Installing Redis..."
# brew install redis

# doing "Starting Redis as a service..."
# brew services start redis

doing "Installing Deployer..."
curl -LO https://deployer.org/deployer.phar
mv deployer.phar /usr/local/bin/dep
chmod +x /usr/local/bin/dep
