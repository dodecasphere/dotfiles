#!/usr/bin/env bash

#
# Pull private secrets (SSH keys + token env) from the private companion repo
# and install them. Requires GitHub auth — `gh auth login` (run by bootstrap.sh
# or here) provides it. Safe to re-run.
#

SECRETS_REPO="dodecasphere/dotfiles-secrets"
SECRETS_DIR="$HOME/.dotfiles-secrets"

doing "Fetching private secrets…"

# Make sure we can reach private repos.
if ! gh auth status &>/dev/null; then
  gh auth login --hostname github.com --git-protocol https --web
fi

# Clone or update the private repo.
if [ -d "$SECRETS_DIR/.git" ]; then
  git -C "$SECRETS_DIR" pull --ff-only || true
else
  gh repo clone "$SECRETS_REPO" "$SECRETS_DIR"
fi

# Install SSH keys with correct permissions (ssh refuses world-readable keys).
if [ -d "$SECRETS_DIR/ssh" ]; then
  doing "Installing SSH keys into ~/.ssh…"
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
  cp -R "$SECRETS_DIR/ssh/." "$HOME/.ssh/"
  chmod 600 "$HOME"/.ssh/id_* 2>/dev/null
  chmod 644 "$HOME"/.ssh/*.pub 2>/dev/null
fi

# secrets.env (FONTAWESOME_NPM_TOKEN, EXPOSE_TOKEN, …) is sourced by the shells
# directly from ~/.dotfiles-secrets/secrets.env — nothing to install here.
if [ -r "$SECRETS_DIR/secrets.env" ]; then
  echo "secrets.env present — the shells source it on startup"
fi
