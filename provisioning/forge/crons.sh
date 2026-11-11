#!/usr/bin/env bash

#
# Cron jobs for a Forge server: user-space updates only. The composer and dep
# crons from linux/crons.sh are left out (Forge owns the root-owned composer).
# NPM_CONFIG_PREFIX matches ~/.shell.local, so npm updates ~/.local, not /usr.
#

CRON_ENV="PATH=/home/linuxbrew/.linuxbrew/bin:$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin NPM_CONFIG_PREFIX=$HOME/.local"

add_cron "15 0 * * * $CRON_ENV npm update -g >> /dev/null 2>&1"
add_cron "0 1 * * * $CRON_ENV brew update >> /dev/null 2>&1"
add_cron "5 1 * * * $CRON_ENV brew upgrade >> /dev/null 2>&1"
add_cron "30 1 * * * $CRON_ENV brew cleanup >> /dev/null 2>&1"
add_cron "45 23 * * * $HOME/Dotfiles/autoupdate.sh"
