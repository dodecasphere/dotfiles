#!/usr/bin/env bash

#
# Install Claude Code via its native installer (https://claude.ai/install.sh).
# The binary lands in ~/.local/bin, which the `path` file adds to $PATH.
#

doing "Claude Code..."
if command -v claude &>/dev/null; then
  echo "Claude Code already installed ($(claude --version 2>/dev/null)) — skipping"
else
  curl -fsSL https://claude.ai/install.sh | bash
fi
