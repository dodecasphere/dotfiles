---
name: crestlite-forge
description: "Crestlite (forge@178.156.194.174) is the owner's solo Hetzner box managed by Laravel Forge; provisioned with provision.sh --forge, zsh-vs-Forge-deploy check pending"
metadata:
  node_type: memory
  type: project
  originSessionId: f323ae0e-dc2d-42fc-81a9-c24b22644abd
  modified: 2026-11-11T02:05:59.852Z
---

Crestlite (not Crestlite Legacy) is a Hetzner Ubuntu 24.04 server managed by Laravel Forge, used only by the owner. It gets `provision.sh --forge` (added 2026-11-10): user space only, Forge keeps apt, PHP, Node, composer, firewall, sshd, swap and `~/.ssh`. The owner said leave its SSH keys alone and skip the secrets repo.

**Why:** brew's bin precedes /usr/bin, so brew php/node/python/git would shadow Forge's copies.

**How to apply:** never add a formula to `provisioning/forge/formulae.sh` that is or depends on php, node, python or git (check `brew deps --os=linux --arch=intel`). Provisioned 2026-11-10 (login shell now zsh). Open item: confirm a staging deploy still works (revert with `chsh -s /bin/bash`). The staging remote URL embeds a Forge token; owner said not to worry about it. Related: [[linux-vps]].
