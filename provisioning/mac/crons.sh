#!/usr/bin/env bash

# 
# Create cron jobs
# 

# Run daily during the midnight hour
(crontab -l 2>/dev/null; echo "0 0 * * * composer self-update >> /dev/null 2>&1") | crontab
(crontab -l 2>/dev/null; echo "5 0 * * * composer global update >> /dev/null 2>&1") | crontab
(crontab -l 2>/dev/null; echo "10 0 * * * npm install npm -g >> /dev/null 2>&1") | crontab
(crontab -l 2>/dev/null; echo "15 0 * * * npm update -g >> /dev/null 2>&1") | crontab
(crontab -l 2>/dev/null; echo "20 0 * * * dep self-update --upgrade >> /dev/null 2>&1") | crontab

# Run daily during the 1am hour
(crontab -l 2>/dev/null; echo "0 1 * * * brew update >> /dev/null 2>&1") | crontab
(crontab -l 2>/dev/null; echo "5 1 * * * brew upgrade >> /dev/null 2>&1") | crontab
(crontab -l 2>/dev/null; echo "30 1 * * * brew cleanup >> /dev/null 2>&1") | crontab

(crontab -l 2>/dev/null; echo "* * * * * cd ~/Dropbox/Sites/smart-mirror && php artisan schedule:run >> /dev/null 2>&1") | crontab
(crontab -l 2>/dev/null; echo "* * * * * cd ~/Dropbox/Sites/family && php artisan schedule:run >> /dev/null 2>&1") | crontab
