#!/usr/bin/env bash

#
# Create cron jobs
#
# add_cron only appends an entry when that exact line isn't already in the
# crontab, so re-running provisioning doesn't pile up duplicate jobs.

# Run daily during the midnight hour
add_cron "0 0 * * * composer self-update >> /dev/null 2>&1"
add_cron "5 0 * * * composer global update >> /dev/null 2>&1"
add_cron "10 0 * * * npm install npm -g >> /dev/null 2>&1"
add_cron "15 0 * * * npm update -g >> /dev/null 2>&1"
add_cron "20 0 * * * dep self-update --upgrade >> /dev/null 2>&1"

# Run daily during the 1am hour
add_cron "0 1 * * * brew update >> /dev/null 2>&1"
add_cron "5 1 * * * brew upgrade >> /dev/null 2>&1"
add_cron "30 1 * * * brew cleanup >> /dev/null 2>&1"

add_cron "* * * * * cd ~/Dropbox/Sites/smart-mirror && php artisan schedule:run >> /dev/null 2>&1"
add_cron "* * * * * cd ~/Dropbox/Sites/family && php artisan schedule:run >> /dev/null 2>&1"
