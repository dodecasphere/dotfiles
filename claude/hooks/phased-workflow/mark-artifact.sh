#!/usr/bin/env bash
# Run IMMEDIATELY AFTER redeploying the progress artifact. Records freshness
# so guard.sh allows the next phase branch to be cut. Run this from inside
# the project repo — state is scoped to its git root.
set -euo pipefail
source "$HOME/.claude/hooks/phased-workflow/state-lib.sh"
ROOT=$(repo_root)
[ -n "$ROOT" ] || { echo "not inside a git repo" >&2; exit 1; }
state_set artifact_epoch "$(date +%s)" "$ROOT"
echo "artifact marked fresh at $(date)"
