#!/usr/bin/env bash
# Usage: set-state.sh key=value [key=value ...]
# Keys: phase=(planning|approved|executing|idle) pr_approved=(0|1) plan=<path>
# Run this from inside the project repo — state is scoped to its git root.
set -euo pipefail
source "$HOME/.claude/hooks/phased-workflow/state-lib.sh"
ROOT=$(repo_root)
[ -n "$ROOT" ] || { echo "not inside a git repo" >&2; exit 1; }
for kv in "$@"; do
  state_set "${kv%%=*}" "${kv#*=}" "$ROOT"
done
echo "phased state now ($ROOT):"; cat "$(state_file "$ROOT")"
