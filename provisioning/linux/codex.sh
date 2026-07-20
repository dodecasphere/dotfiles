#!/usr/bin/env bash

#
# Codex CLI — via npm on Linux only. The mac gets it as the `codex` cask
# (apps.sh), which owns the brew-prefix `codex` symlink; installing the npm
# package there too would collide on the same path. (Claude Code itself is
# handled by provisioning/mac/claude.sh, portable, sourced on both platforms.)
#

npm_global "@openai/codex"
