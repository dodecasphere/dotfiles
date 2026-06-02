#!/usr/bin/env bash
#
# bootstrap.sh — clone this (public) dotfiles repo and link it on a fresh machine.
#
# Deliberately minimal: it only needs git to clone the repo. Everything else —
# Homebrew, gh, languages, apps, and the private secrets (via `gh auth login`) —
# is installed by `provision.sh` afterward.
#
# Run it straight from the raw URL on a fresh machine:
#
#   curl -fsSL https://raw.githubusercontent.com/dodecasphere/dotfiles/master/bootstrap.sh | bash
#
# Every step is idempotent — safe to re-run.
#

set -euo pipefail

REPO_URL="https://github.com/dodecasphere/dotfiles.git"
DOTFILES_DIR="$HOME/Dotfiles"

info() { printf '\n\033[1;32m==> %s\033[0m\n' "$1"; }

# Ensure git is available. On macOS git ships with the Xcode Command Line Tools
# (there's no standalone git — a bare `git` on a fresh Mac just triggers their
# installer), so install those if git isn't found yet.
if ! command -v git &>/dev/null; then
  case "$(uname -s)" in
    Darwin)
      info "Installing Xcode Command Line Tools (provides git) — accept the prompt, then wait…"
      xcode-select --install || true
      until command -v git &>/dev/null; do sleep 5; done
      ;;
    Linux)
      info "Installing git…"
      if   command -v apt-get &>/dev/null; then sudo apt-get update && sudo apt-get install -y git
      elif command -v dnf     &>/dev/null; then sudo dnf install -y git
      elif command -v yum     &>/dev/null; then sudo yum install -y git
      elif command -v pacman  &>/dev/null; then sudo pacman -Sy --noconfirm git
      elif command -v zypper  &>/dev/null; then sudo zypper install -y git
      elif command -v apk     &>/dev/null; then sudo apk add git
      else
        echo "git is missing and no supported package manager was found — install git manually and re-run." >&2
        exit 1
      fi
      ;;
    *)
      echo "Unsupported OS '$(uname -s)' — install git manually and re-run." >&2
      exit 1
      ;;
  esac
fi

# Clone (or update) the public repo — no auth needed.
if [ -d "$DOTFILES_DIR/.git" ]; then
  info "Dotfiles already present at ${DOTFILES_DIR} — pulling latest…"
  git -C "$DOTFILES_DIR" pull --ff-only || true
else
  info "Cloning dotfiles → ${DOTFILES_DIR}…"
  git clone "$REPO_URL" "$DOTFILES_DIR"
fi

# Link the dotfiles into $HOME.
cd "$DOTFILES_DIR"
info "Linking dotfiles (install.sh)…"
./install.sh

# Print the right provision command for this OS.
provision_flag=""   # stays defined for any OS, so the printf below is safe under `set -u`
case "$(uname -s)" in
  Darwin) provision_flag="--mac" ;;
  Linux)  provision_flag="--linux" ;;
esac

info "Bootstrap complete."
printf '\nNext, provision the machine when you are ready:\n  cd %s && ./provision.sh %s\n\n' "$DOTFILES_DIR" "$provision_flag"
