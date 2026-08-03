#!/usr/bin/env bash
# Shared state helpers for phoenix phased-plan workflow.
STATE_FILE="$HOME/.claude/phoenix-phased/state"

state_get() { # state_get key default
  local val
  val=$(grep -m1 "^$1=" "$STATE_FILE" 2>/dev/null | cut -d= -f2-)
  echo "${val:-$2}"
}

state_set() { # state_set key value
  mkdir -p "$(dirname "$STATE_FILE")"
  touch "$STATE_FILE"
  if grep -q "^$1=" "$STATE_FILE"; then
    sed -i '' "s|^$1=.*|$1=$2|" "$STATE_FILE"
  else
    echo "$1=$2" >> "$STATE_FILE"
  fi
}
