#!/usr/bin/env bash
#
# SessionStart (startup): warn when ~/.claude/settings.json is no longer a
# symlink into Dotfiles. iTerm2's Claude Code integration rewrites the file in
# place when it (re)installs its cc-status hook, which silently replaces the
# symlink with a regular file; after that, repo edits never go live. One stat,
# no output when healthy.
settings="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/settings.json"
[ -L "$settings" ] && exit 0
[ -e "$settings" ] || exit 0

msg="settings.json drift: $settings is a regular file, not a symlink to ~/Dotfiles/claude/settings.json. Repo edits are not live. Diff it against the repo, fold any real extras into the repo, then relink (see Dotfiles project-memory/claude-config-layer.md)."
jq -n --arg msg "$msg" \
  '{systemMessage: $msg, hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: $msg}}'
