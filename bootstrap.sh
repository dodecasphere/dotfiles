#!/usr/bin/env bash
#
# bootstrap.sh — set up a brand-new Mac from this (private) dotfiles repo.
#
# Uses the GitHub CLI's browser device-flow to authenticate — no token to create
# or store. That login also unlocks the private dotfiles-secrets repo that the
# provisioner pulls SSH keys/tokens from.
#
# This repo is public, so run it straight from its raw URL on a fresh machine:
#
#   curl -fsSL https://raw.githubusercontent.com/dodecasphere/dotfiles/master/bootstrap.sh | bash
#
# Every step is idempotent — safe to re-run.
#

set -euo pipefail

REPO="dodecasphere/dotfiles"
DOTFILES_DIR="$HOME/Dotfiles"

info() { printf '\n\033[1;32m==> %s\033[0m\n' "$1"; }

# 1. Xcode Command Line Tools (gives us git, compilers, etc.)
if xcode-select -p &>/dev/null; then
  info "Xcode Command Line Tools already installed"
else
  info "Installing Xcode Command Line Tools — accept the GUI prompt, then wait…"
  xcode-select --install || true
  until xcode-select -p &>/dev/null; do sleep 5; done
fi

# 2. Homebrew (public install script — no repo needed)
if ! command -v brew &>/dev/null; then
  info "Installing Homebrew…"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
# Load brew into this shell.
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# 3. GitHub CLI (public formula)
if ! command -v gh &>/dev/null; then
  info "Installing GitHub CLI…"
  brew install gh
fi

# 4. Authenticate via browser device-flow (skip if already logged in).
if gh auth status &>/dev/null; then
  info "Already authenticated with GitHub"
else
  info "Authenticating with GitHub — a browser window will open to authorize…"
  gh auth login --hostname github.com --git-protocol https --web
fi
# Make sure git uses gh's credentials for HTTPS operations.
gh auth setup-git

# 5. Clone (or update) the dotfiles repo.
if [ -d "$DOTFILES_DIR/.git" ]; then
  info "Dotfiles already present at $DOTFILES_DIR — pulling latest…"
  git -C "$DOTFILES_DIR" pull --ff-only || true
else
  info "Cloning $REPO → $DOTFILES_DIR…"
  gh repo clone "$REPO" "$DOTFILES_DIR"
fi

# 6. Link the dotfiles into $HOME.
cd "$DOTFILES_DIR"
info "Linking dotfiles (install.sh)…"
./install.sh

info "Bootstrap complete."
printf '\nNext, provision the machine when you are ready:\n  cd %s && ./provision.sh --mac\n\n' "$DOTFILES_DIR"
