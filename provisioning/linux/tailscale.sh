#!/usr/bin/env bash

#
# Tailscale — private WireGuard mesh. SSH and dev servers become reachable
# from other tailnet devices (laptop, phone) without opening public ports.
# `tailscale up --ssh` also enables Tailscale SSH (tailnet identity replaces
# key management for intra-tailnet connections).
#

doing "Tailscale..."
if command -v tailscale &>/dev/null; then
  echo "tailscale already installed — skipping"
else
  curl -fsSL https://tailscale.com/install.sh | sh
fi

if sudo tailscale status &>/dev/null; then
  echo "tailscale already logged in"
elif [ "yes" = "$(ask_yes_or_no "Log this machine into your tailnet now (prints an auth URL)?")" ]; then
  sudo tailscale up --ssh
else
  echo "Run \`sudo tailscale up --ssh\` later to join the tailnet."
fi
