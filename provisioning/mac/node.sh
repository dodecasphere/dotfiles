#!/usr/bin/env bash

#
# Set up node
#

# npm_global skips any package already installed globally.
npm_global gulp
npm_global gulp-cli
npm_global trash-cli
npm_global eslint
npm_global prettier
npm_global @openai/codex   # Codex CLI (Claude Code installs via claude.sh)
