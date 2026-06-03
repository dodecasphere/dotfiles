#!/usr/bin/env bash

#
# Xcode Command Line Tools (git, compilers, etc.).
#
# bootstrap.sh already installs these before provisioning runs; this is just a
# safety net so `provision.sh --mac` also works when run on its own.
#

doing "Checking Xcode Command Line Tools..."
if xcode-select -p &>/dev/null; then
  echo "Xcode Command Line Tools already installed — skipping"
else
  xcode-select --install
  press_key_to_continue   # wait for the GUI installer to finish
fi
