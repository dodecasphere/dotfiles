#!/usr/bin/env bash

#
# Install Claude Code via its native installer (https://claude.ai/install.sh).
# The binary lands in ~/.local/bin, which the `path` file adds to $PATH.
#

doing "Claude Code..."
if [ -x "$HOME/.local/bin/claude" ]; then
  echo "Claude Code already installed ($("$HOME/.local/bin/claude" --version 2>/dev/null)) — skipping"
else
  curl -fsSL https://claude.ai/install.sh | bash
fi

#
# Register user-scope MCP servers (idempotent). These are stored in
# ~/.claude.json, which is machine-local and not committed, so re-add them on
# each machine here. Only secret-free, project-agnostic servers belong at user
# scope; per-project servers (e.g. a database MCP) live in that project's
# own .mcp.json — see claude/mcp/README.md.
#
claude_bin="$HOME/.local/bin/claude"
if [ -x "$claude_bin" ]; then
  doing "Claude MCP servers..."
  if "$claude_bin" mcp get playwright >/dev/null 2>&1; then
    echo "playwright MCP already registered — skipping"
  else
    "$claude_bin" mcp add playwright -s user -- npx -y @playwright/mcp@latest
  fi
fi

#
# Portable statusline dependencies (claude/statusline/). The usage segment fetches
# from claude.ai, which sits behind Cloudflare TLS fingerprinting. A plain curl is
# blocked with a 403; curl-impersonate forges a real Chrome fingerprint and passes.
# It is NOT in Homebrew, so install the pinned release binary into
# ~/.local/bin/curl-impersonate/ (where fetch-usage.sh looks by default). jq parses
# the JSON response. See claude/statusline/README.md.
#
doing "Claude statusline deps (jq + curl-impersonate)..."
command -v jq >/dev/null 2>&1 || brew install jq

ci_dir="$HOME/.local/bin/curl-impersonate"
ci_version="v1.5.6"
if [ -x "$ci_dir/curl_chrome116" ]; then
  echo "curl-impersonate already installed — skipping"
else
  ci_os="$(uname -s)"; ci_arch="$(uname -m)"
  ci_asset=""
  case "$ci_os:$ci_arch" in
    Darwin:arm64)              ci_asset="arm64-macos" ;;
    Darwin:x86_64)             ci_asset="x86_64-macos" ;;
    Linux:x86_64)              ci_asset="x86_64-linux-gnu" ;;
    Linux:aarch64|Linux:arm64) ci_asset="aarch64-linux-gnu" ;;
  esac
  if [ -z "$ci_asset" ]; then
    echo "curl-impersonate: no prebuilt asset for $ci_os/$ci_arch — install manually (see statusline README)"
  else
    ci_url="https://github.com/lexiforest/curl-impersonate/releases/download/${ci_version}/curl-impersonate-${ci_version}.${ci_asset}.tar.gz"
    mkdir -p "$ci_dir"
    if curl -fsSL "$ci_url" | tar xz -C "$ci_dir"; then
      chmod +x "$ci_dir"/* 2>/dev/null
      echo "curl-impersonate ${ci_version} (${ci_asset}) installed to $ci_dir"
    else
      echo "curl-impersonate download failed ($ci_url) — install manually (see statusline README)"
    fi
  fi
fi

#
# Reminder: the statusline usage segment also needs a claude.ai session cookie at
# ~/.config/claude-statusline/credentials (SESSION_KEY + ORG_ID, mode 600). That is
# a per-machine secret and is never committed — provision it by hand once. See
# claude/statusline/README.md.
#
if [ ! -f "$HOME/.config/claude-statusline/credentials" ]; then
  echo "NOTE: statusline usage will show '~' until you create ~/.config/claude-statusline/credentials (see claude/statusline/README.md)"
fi
