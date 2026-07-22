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

# The portable statusline (claude/statusline/) is now fully self-contained: it
# reads everything, including subscription usage, from the JSON Claude Code pipes
# to it on stdin. No extra dependencies, no cookie, nothing to provision here.
