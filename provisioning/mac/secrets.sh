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

# Clone or update the private repo. --autostash so a dirtied working tree (ssh
# appends to the symlinked known_hosts on new connections) doesn't block pulling
# key/config updates; the local known_hosts changes are stashed and reapplied.
if [ -d "$SECRETS_DIR/.git" ]; then
  git -C "$SECRETS_DIR" pull --autostash || true
else
  gh repo clone "$SECRETS_REPO" "$SECRETS_DIR"
fi

# Install SSH keys/config by symlinking them from the secrets repo into ~/.ssh,
# so the repo stays the single source of truth (edit once, both reflect it).
# The link logic lives in the secrets repo itself (link-ssh-keys.sh) since
# that's where the keys live — this just invokes it. Also what to (re-)run
# there after adding or regenerating a key.
if [ -x "$SECRETS_DIR/link-ssh-keys.sh" ]; then
  doing "Linking SSH keys into ~/.ssh…"
  "$SECRETS_DIR/link-ssh-keys.sh"
fi

# secrets.env (FONTAWESOME_NPM_TOKEN, EXPOSE_TOKEN, …) is sourced by the shells
# directly from ~/.dotfiles-secrets/secrets.env — nothing to install here.
if [ -r "$SECRETS_DIR/secrets.env" ]; then
  echo "secrets.env present — the shells source it on startup"
fi
