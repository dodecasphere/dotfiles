#!/usr/bin/env bash

# 
# Create cron jobs
# 

# Run daily during the midnight hour
(crontab -l 2>/dev/null; echo "0 0 * * * /usr/local/bin/composer self-update --1") | crontab
(crontab -l 2>/dev/null; echo "5 0 * * * apt-get -y autoremove && apt-get autoclean") | crontab
(crontab -l 2>/dev/null; echo "0 12 1 * * root apt-get update && apt-get -y upgrade") | crontab
