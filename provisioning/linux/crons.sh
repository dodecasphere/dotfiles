#!/usr/bin/env bash

#
# Create cron jobs
#
# `add_cron` comes from provisioning/mac/helpers.sh (sourced earlier on the
# Linux path too) and only appends an entry when that exact line isn't already
# in the crontab, so re-running provisioning doesn't pile up duplicate jobs.
#
# Cron runs with a minimal PATH (/usr/bin:/bin), so every entry carries an
# inline PATH prefix covering brew's bin (php, composer, npm, node) and
# ~/.local/bin (dep). Absolute tool paths alone wouldn't be enough:
# composer/dep are phars with a `#!/usr/bin/env php` shebang, so php must be
# on the PATH too.
#

CRON_ENV="PATH=/home/linuxbrew/.linuxbrew/bin:$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin"

# Run daily during the midnight hour — tool self-updates (mirrors the mac crons)
add_cron "0 0 * * * $CRON_ENV composer self-update >> /dev/null 2>&1"
add_cron "5 0 * * * $CRON_ENV composer global update >> /dev/null 2>&1"
add_cron "10 0 * * * $CRON_ENV npm install npm -g >> /dev/null 2>&1"
add_cron "15 0 * * * $CRON_ENV npm update -g >> /dev/null 2>&1"
add_cron "20 0 * * * $CRON_ENV dep self-update >> /dev/null 2>&1"

# Run daily during the 1am hour — keep brew itself fresh
add_cron "0 1 * * * $CRON_ENV brew update >> /dev/null 2>&1"
add_cron "5 1 * * * $CRON_ENV brew upgrade >> /dev/null 2>&1"
add_cron "30 1 * * * $CRON_ENV brew cleanup >> /dev/null 2>&1"

# No apt crons here: system package updates, autoremove, and autoclean are
# handled by unattended-upgrades (see provisioning/linux/updates.sh).
