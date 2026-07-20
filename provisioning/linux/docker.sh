#!/usr/bin/env bash

#
# Docker engine via Docker's official apt repo (the mac gets Docker Desktop as
# a cask; the brew-installed helpers — lazydocker, dive, ctop — need a real
# engine here).
#

doing "Docker engine..."
if command -v docker &>/dev/null; then
  echo "docker already installed — skipping"
else
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc

  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
    | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
fi

# Run docker without sudo.
if ! id -nG "$USER" | grep -qw docker; then
  sudo usermod -aG docker "$USER"
  echo "Added $USER to the docker group — log out/in (or \`newgrp docker\`) for it to take effect."
fi
