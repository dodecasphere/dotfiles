#!/usr/bin/env bash

#
# Create cron jobs
#
# add_cron only appends an entry when that exact line isn't already in the
# crontab, so re-running provisioning doesn't pile up duplicate jobs.
#
# Cron runs with a minimal PATH (/usr/bin:/bin), so every entry carries an
# inline PATH prefix. An absolute path to composer/dep alone wouldn't be
# enough: they are phars with a `#!/usr/bin/env php` shebang, so php (Herd's,
# resolved at provisioning time) must be on the PATH too. The value is quoted
# because Herd's bin dir contains a space ("Application Support").
#

PHP_DIR=""
command -v php &>/dev/null && PHP_DIR="$(dirname "$(command -v php)")"
CRON_ENV="PATH=\"$(brew --prefix)/bin:/usr/local/bin:/usr/bin:/bin${PHP_DIR:+:$PHP_DIR}\""

# Run daily during the midnight hour
add_cron "0 0 * * * $CRON_ENV composer self-update >> /dev/null 2>&1"
add_cron "5 0 * * * $CRON_ENV composer global update >> /dev/null 2>&1"
add_cron "10 0 * * * $CRON_ENV npm install npm -g >> /dev/null 2>&1"
add_cron "15 0 * * * $CRON_ENV npm update -g >> /dev/null 2>&1"
add_cron "20 0 * * * $CRON_ENV dep self-update --upgrade >> /dev/null 2>&1"

# Run daily during the 1am hour
add_cron "0 1 * * * $CRON_ENV brew update >> /dev/null 2>&1"
add_cron "5 1 * * * $CRON_ENV brew upgrade >> /dev/null 2>&1"
add_cron "30 1 * * * $CRON_ENV brew cleanup >> /dev/null 2>&1"

# The PATH prefix sits on the php command, not the cd — a VAR=val prefix only
# applies to the single command it precedes, so before `cd` it would be lost
# after the `&&`.
add_cron "* * * * * cd ~/Dropbox/Sites/smart-mirror && $CRON_ENV php artisan schedule:run >> /dev/null 2>&1"
add_cron "* * * * * cd ~/Dropbox/Sites/family && $CRON_ENV php artisan schedule:run >> /dev/null 2>&1"
