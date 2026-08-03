#!/usr/bin/env bash
# Usage: set-state.sh key=value [key=value ...]
# Keys: phase=(planning|approved|executing|idle) pr_approved=(0|1) plan=<path>
set -euo pipefail
source "$HOME/.claude/hooks/phoenix-phased/state-lib.sh"
for kv in "$@"; do
  state_set "${kv%%=*}" "${kv#*=}"
done
echo "phased state now:"; cat "$STATE_FILE"
