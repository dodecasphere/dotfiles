#!/usr/bin/env bash
#
# Render the Herdr agent skills from the installed binaries, so they always
# match the installed version. Sourced by formulae.sh (provisioning) and run
# nightly by autoupdate.sh (cron/LaunchAgent PATH is minimal, hence the PATH
# line). Machine-local on purpose: not in the plugin store, because each skill
# must match the binary installed on that machine. Codex only if ~/.codex exists.
#
#   herdr --skill   the herdr TUI's delegation skill (split panes, drive agents)
#   hc --skill      herdr-core's manual (run, read, message terminals in the
#                   desktop app's core). Upstream prints no skill frontmatter,
#                   so we prepend name/description; the body is upstream's.
#   herdr-app --skill  the desktop app's window manual (inspect, show, change
#                   layouts/keys/mods). Same frontmatter treatment. mac only.
#

PATH="$HOME/.local/bin:/opt/homebrew/bin:/home/linuxbrew/.linuxbrew/bin:/usr/local/bin:$PATH"

for skills_dir in "$HOME/.claude/skills" "$HOME/.codex/skills"; do
  [ -d "$(dirname "$skills_dir")" ] || [ "$skills_dir" = "$HOME/.claude/skills" ] || continue

  if command -v herdr >/dev/null; then
    mkdir -p "$skills_dir/herdr"
    herdr --skill > "$skills_dir/herdr/SKILL.md"
  fi

  if command -v hc >/dev/null; then
    mkdir -p "$skills_dir/herdr-core"
    {
      printf -- '---\nname: herdr-core\n'
      printf -- 'description: "Run, read, message and wait on terminals and agents in the Herdr desktop app'"'"'s core with hc. Use when HC_TERMINAL_ID is set and the user asks about other terminals, tabs or agents, or to start or drive one."\n---\n\n'
      hc --skill
    } > "$skills_dir/herdr-core/SKILL.md"
  fi

  if command -v herdr-app >/dev/null; then
    mkdir -p "$skills_dir/herdr-app"
    {
      printf -- '---\nname: herdr-app\n'
      printf -- 'description: "Drive the Herdr desktop app window with herdr-app: inspect spaces, tabs and panes, show or focus things, run app commands, and change its layouts, keys, settings or mods. Use when HC_TERMINAL_ID is set and the user asks to change what the Herdr window shows or how it looks or behaves."\n---\n\n'
      herdr-app --skill
    } > "$skills_dir/herdr-app/SKILL.md"
  fi
done
