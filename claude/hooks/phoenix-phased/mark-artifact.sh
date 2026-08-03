#!/usr/bin/env bash
# Run IMMEDIATELY AFTER redeploying the progress artifact. Records freshness
# so guard.sh allows the next phase branch to be cut.
set -euo pipefail
source "$HOME/.claude/hooks/phoenix-phased/state-lib.sh"
state_set artifact_epoch "$(date +%s)"
echo "artifact marked fresh at $(date)"
