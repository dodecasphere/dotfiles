#!/usr/bin/env bash
# Shared state helpers for the phased-workflow system (phased-plan /
# phased-execute skills). State is scoped per repo: each repo's git root gets
# its own state file, so two projects running the workflow concurrently (or
# a repo that's never touched it) don't collide or get gated by accident.

repo_root() { # repo_root [start_dir]
  git -C "${1:-.}" rev-parse --show-toplevel 2>/dev/null || true
}

state_file() { # state_file [repo_root]
  local root="${1:-$(repo_root)}"
  if [ -z "$root" ]; then
    echo "$HOME/.claude/phased-workflow/state/_no-repo"
    return
  fi
  local slug
  slug=$(printf '%s' "$root" | sed 's#^/##; s#/#_#g')
  echo "$HOME/.claude/phased-workflow/state/$slug"
}

state_get() { # state_get key default [repo_root]
  local val
  val=$(grep -m1 "^$1=" "$(state_file "${3:-}")" 2>/dev/null | cut -d= -f2-)
  echo "${val:-$2}"
}

state_set() { # state_set key value [repo_root]
  local f
  f=$(state_file "${3:-}")
  mkdir -p "$(dirname "$f")"
  touch "$f"
  if grep -q "^$1=" "$f"; then
    sed -i '' "s|^$1=.*|$1=$2|" "$f"
  else
    echo "$1=$2" >> "$f"
  fi
}
