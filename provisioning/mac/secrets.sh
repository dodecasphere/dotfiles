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
# ssh follows the symlinks and enforces perms on the *target* file, so we set
# the modes on the repo copies — git only tracks the +x bit, so this won't dirty
# the repo. ~/.ssh itself must be 700, and keys must not be world-readable.
if [ -d "$SECRETS_DIR/ssh" ]; then
  doing "Linking SSH keys into ~/.ssh…"
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
  chmod 600 "$SECRETS_DIR"/ssh/id_* 2>/dev/null   # private + (briefly) public keys
  chmod 644 "$SECRETS_DIR"/ssh/*.pub 2>/dev/null  # restore public keys to 644

  for src in "$SECRETS_DIR"/ssh/*; do
    [ -e "$src" ] || continue
    target="$HOME/.ssh/$(basename "$src")"
    # Replace any prior copy or stale link so re-runs converge on the symlink.
    # known_hosts is symlinked too: ssh appends new host keys straight into the
    # tracked repo file (the pull above uses --autostash to tolerate that).
    if [ -L "$target" ] || [ -e "$target" ]; then rm -f "$target"; fi
    ln -s "$src" "$target"
  done
fi

# secrets.env (FONTAWESOME_NPM_TOKEN, EXPOSE_TOKEN, …) is sourced by the shells
# directly from ~/.dotfiles-secrets/secrets.env — nothing to install here.
if [ -r "$SECRETS_DIR/secrets.env" ]; then
  echo "secrets.env present — the shells source it on startup"
fi
