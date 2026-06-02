#!/usr/bin/env bash

#
# Create cron jobs
#
# Self-contained add_cron (the mac helpers.sh isn't sourced on the Linux path):
# only appends an entry if that exact line isn't already in the crontab, so
# re-running doesn't pile up duplicates.

add_cron() {
  local entry="$1"
  if crontab -l 2>/dev/null | grep -Fqx "$entry"; then
    echo "Cron already present — skipping: $entry"
  else
    (crontab -l 2>/dev/null; echo "$entry") | crontab -
    echo "Cron added: $entry"
  fi
}

# Run daily during the midnight hour
add_cron "0 0 * * * /usr/local/bin/composer self-update --1"
add_cron "5 0 * * * apt-get -y autoremove && apt-get autoclean"
add_cron "0 12 1 * * apt-get update && apt-get -y upgrade"
