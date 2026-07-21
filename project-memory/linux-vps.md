---
name: linux-vps
description: The Hostinger VPS (dulle.cloud) provisioned from these dotfiles for remote agent development
metadata: 
  node_type: memory
  type: project
  originSessionId: e51ddbcb-f71f-4763-b791-a4a33947bc73
---

Hostinger VPS at dulle.cloud (Ubuntu LTS, headless), provisioned 2026-07-20 via `./provision.sh --linux` as user `michael` (never root — the script refuses uid 0). Purpose: remote agent development (Claude Code + Codex CLI in tmux).

Gotchas that bit during setup (all fixed in the repo, but relevant when debugging the box):
- sshd config drop-ins: cloud-init's `50-cloud-init.conf` sets `PasswordAuthentication yes` and sshd takes the FIRST match — hardening drop-in must sort before it (`00-hardening.conf`).
- fail2ban bans the laptop after a few failed key attempts (e.g. an `ssh-copy-id` loop); unban via `sudo fail2ban-client set sshd unbanip <ip>` from the Hostinger browser console.
- Root SSH is disabled post-hardening; emergency access = Hostinger panel browser console.
- Cron needs the inline `PATH=` prefix (linuxbrew + ~/.local/bin) on every entry.

Related: [[claude-config-layer]]
