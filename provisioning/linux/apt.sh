#!/usr/bin/env bash

#
# Base system packages via apt — the minimum Homebrew-on-Linux needs
# (build-essential, procps, curl, file, git) plus basics the system should
# own rather than brew (zsh for chsh, unzip, net-tools, ufw, mosh — mosh must
# be apt not brew: mosh-server spawns in a non-interactive shell where the
# linuxbrew PATH isn't set).
# `apt-get install -y` is naturally idempotent — safe to re-run.
#

doing "Installing base apt packages..."

sudo apt-get update
sudo apt-get install -y \
  build-essential \
  procps \
  curl \
  file \
  git \
  zsh \
  unzip \
  net-tools \
  ufw \
  mosh
