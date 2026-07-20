#!/usr/bin/env bash

#
# Install Brew Formulae — macOS-only ones, then the shared core list.
#

formula "bluetoothconnector"      # connect/disconnect Bluetooth devices from the CLI
formula "mas"                     # Mac App Store CLI (used by apps.sh)
formula "svn"                     # Subversion (needed by some font casks)
formula "terminal-notifier"       # send macOS notifications from scripts

# Everything OS-agnostic (modern CLI tools, git, node, docker helpers, …).
source provisioning/shared/formulae.sh
