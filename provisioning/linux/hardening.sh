#!/usr/bin/env bash

#
# Harden an internet-facing box: SSH key-only auth, ufw firewall, fail2ban.
# Idempotent — config files are rewritten wholesale; ufw/fail2ban re-runs no-op.
#

# --- sshd -------------------------------------------------------------------

doing "Hardening sshd..."

# Never disable password auth without a working authorized_keys — that would
# permanently lock this user out of the box.
if [ -s "$HOME/.ssh/authorized_keys" ]; then
  # Must sort BEFORE cloud-init's 50-cloud-init.conf: sshd takes the FIRST
  # occurrence of an option, and cloud-init's file sets
  # PasswordAuthentication yes — a 99-prefixed drop-in silently loses to it.
  sudo rm -f /etc/ssh/sshd_config.d/99-hardening.conf   # earlier name, superseded
  sudo tee /etc/ssh/sshd_config.d/00-hardening.conf >/dev/null <<'EOF'
PermitRootLogin no
PasswordAuthentication no
KbdInteractiveAuthentication no
EOF
  if sudo sshd -t; then
    sudo systemctl restart ssh
    echo "sshd hardened: key-only auth, no root login"
  else
    # Bad config must not be left in place — a later manual restart would
    # take sshd down with it.
    sudo rm -f /etc/ssh/sshd_config.d/00-hardening.conf
    echo "sshd config validation failed — hardening NOT applied" >&2
  fi
else
  echo "SKIPPED sshd hardening: no ~/.ssh/authorized_keys yet."
  echo "Add your laptop's public key to it first, then re-run provisioning."
fi

# --- ufw --------------------------------------------------------------------

doing "Configuring ufw firewall..."

sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw limit ssh                              # rate-limited against brute force
sudo ufw allow 60000:61000/udp comment 'mosh'
sudo ufw --force enable

# --- fail2ban ---------------------------------------------------------------

doing "Installing fail2ban..."

sudo apt-get install -y fail2ban
sudo systemctl enable --now fail2ban
