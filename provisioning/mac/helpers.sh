#!/usr/bin/env bash

#
# Install guards — every helper here checks whether something is already
# installed and skips it if so, so provisioning is safe to re-run (idempotent).
#
# Sourced near the top of `provision.sh` (after `functions`), so every other
# provisioning script can use these. Relies on `doing` / `ask_yes_or_no` /
# `line` from the `functions` file.
#

# --- Homebrew --------------------------------------------------------------

# Cask version helpers (used by `cask` below).
function cask_version_available() {
    brew info --cask "$1" | head -n 1 | cut -d " " -f 2
}

function cask_version_installed() {
    ls -1 "$(cask_staging_location)/$1" | tr '\n' ' ' | sed -e 's/ $//'
}

function cask_staging_location() {
    brew doctor | grep -A1 '==> Homebrew Cask Staging Location:' | tail -n1
}

# Install a Homebrew formula, skipping it if already installed.
# `brew list --formula <name>` is an exact match (unlike the old `brew list |
# grep <name>`, which matched substrings — e.g. "git" matched "github").
function formula {
  doing "Homebrew Formula [$1]..."
  if brew list --formula "$1" &>/dev/null; then
    echo "$1 already installed — skipping"
  else
    if [ "yes" == $(ask_yes_or_no "Continue installing $1 ?") ]; then brew install "$1"; fi
  fi
}

# Install a Homebrew cask, skipping it if already installed.
function cask {
  doing "Homebrew Application [$1]..."
  if brew list --cask "$1" &>/dev/null; then
    echo "$1 ($(cask_version_installed "$1")) already installed — skipping"
  else
    aver=$(cask_version_available "$1")
    if [ "yes" == $(ask_yes_or_no "Continue installing $1 $aver?") ]; then brew install --cask "$1"; fi
  fi
}

# --- Mac App Store ---------------------------------------------------------

# Install a Mac App Store app by id, skipping it if already installed.
function mas_install {
  local id="$1"
  doing "App Store app [$id]..."
  if mas list 2>/dev/null | grep -q "^${id} "; then
    echo "App Store app $id already installed — skipping"
  else
    mas install "$id"
  fi
}

# --- npm globals -----------------------------------------------------------

# Install a global npm package, skipping it if already installed.
function npm_global {
  doing "Global npm package [$1]..."
  if npm ls -g --depth=0 "$1" &>/dev/null; then
    echo "npm global $1 already installed — skipping"
  else
    npm install --global "$1"
  fi
}

# --- PECL (PHP) extensions -------------------------------------------------

# Install a PECL extension, skipping it if already installed.
function pecl_install {
  doing "PECL extension [$1]..."
  if pecl list 2>/dev/null | grep -qi "^$1 "; then
    echo "PECL extension $1 already installed — skipping"
  else
    pecl install "$1"
  fi
}

# --- Composer globals ------------------------------------------------------

# Install a global Composer package, skipping it if already installed.
# Accepts an optional 2nd arg with the package name to check, for packages
# whose require name differs from the installed name (defaults to $1).
function composer_global {
  local require="$1"
  local check="${2:-$1}"
  doing "Global Composer package [$require]..."
  if composer global show "$check" &>/dev/null; then
    echo "Composer global $check already installed — skipping"
  else
    composer global require "$require"
  fi
}

# --- crontab ---------------------------------------------------------------

# Add a crontab entry only if that exact line isn't already present, so
# re-running provisioning doesn't pile up duplicate cron jobs.
function add_cron {
  local entry="$1"
  if crontab -l 2>/dev/null | grep -Fqx "$entry"; then
    echo "Cron already present — skipping: $entry"
  else
    (crontab -l 2>/dev/null; echo "$entry") | crontab -
    echo "Cron added: $entry"
  fi
}
