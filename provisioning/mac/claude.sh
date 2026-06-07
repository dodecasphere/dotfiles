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
