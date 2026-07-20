#!/usr/bin/env bash

#
# Keep Ubuntu itself patched.
#
# Package updates: unattended-upgrades applies security updates daily —
# it handles dpkg locks and conffile prompts properly, unlike a cron'd
# `apt-get -y upgrade`. Logs land in /var/log/unattended-upgrades/.
#
# Reboots stay manual (deliberate): when a kernel update needs one, MOTD
# shows "System restart required" (and /var/run/reboot-required exists).
#
# Release upgrades (e.g. 24.04 -> 26.04) stay manual too — never automate
# do-release-upgrade; it is interactive and can break SSH/boot unsupervised.
# Prompt=lts below means it only offers LTS-to-LTS jumps.
#

doing "Configuring unattended-upgrades..."
sudo apt-get install -y unattended-upgrades

# Daily package-list refresh + unattended upgrade run, weekly autoclean
# (replaces the old root apt crons).
sudo tee /etc/apt/apt.conf.d/20auto-upgrades >/dev/null <<'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::AutocleanInterval "7";
EOF

# Local overrides layered on the stock 50unattended-upgrades — never edit that
# file in place, or the package's own upgrades hit conffile prompts.
sudo tee /etc/apt/apt.conf.d/52unattended-upgrades-local >/dev/null <<'EOF'
Unattended-Upgrade::Remove-Unused-Dependencies "true";
// Manual reboots: check MOTD or /var/run/reboot-required after kernel updates.
Unattended-Upgrade::Automatic-Reboot "false";
EOF

# Only offer LTS-to-LTS release upgrades; run `do-release-upgrade` by hand.
sudo sed -i 's/^Prompt=.*/Prompt=lts/' /etc/update-manager/release-upgrades
