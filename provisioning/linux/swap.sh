#!/usr/bin/env bash

#
# Swapfile — OOM insurance on a small-RAM VPS (agent sessions + npm builds can
# spike past physical memory and get OOM-killed without it). Low swappiness
# keeps RAM preferred; swap is a safety net, not working memory.
#

doing "Swapfile..."
if [ -n "$(swapon --show --noheadings)" ]; then
  echo "swap already active — skipping"
else
  sudo fallocate -l 2G /swapfile
  sudo chmod 600 /swapfile
  sudo mkswap /swapfile
  sudo swapon /swapfile
fi

if ! grep -q '^/swapfile' /etc/fstab; then
  echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab >/dev/null
fi

sudo tee /etc/sysctl.d/99-swappiness.conf >/dev/null <<'EOF'
vm.swappiness=10
EOF
sudo sysctl -p /etc/sysctl.d/99-swappiness.conf >/dev/null
