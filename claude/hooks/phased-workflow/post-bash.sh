#!/usr/bin/env bash
# PostToolUse(Bash): after a git commit during execution, remind about the
# artifact; after a successful gh pr create, re-arm the PR gate. Scoped to
# repos that have armed the phased-workflow system (see guard.sh).
set -euo pipefail
source "$HOME/.claude/hooks/phased-workflow/state-lib.sh"

INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')
REPO_ROOT=$(repo_root "$CWD")
[ -n "$REPO_ROOT" ] || exit 0
SF=$(state_file "$REPO_ROOT")
[ -f "$SF" ] || exit 0

CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if echo "$CMD" | grep -Eq 'gh[[:space:]]+pr[[:space:]]+create'; then
  state_set pr_approved 0 "$REPO_ROOT"   # one PR per approval; re-arm the gate
  exit 0
fi

if [ "$(state_get phase idle "$REPO_ROOT")" = "executing" ] && echo "$CMD" | grep -q 'git commit'; then
  jq -n '{hookSpecificOutput:{hookEventName:"PostToolUse",additionalContext:"PHASED REMINDER: commit landed. If this closes or advances a phase, redeploy the progress artifact NOW (chips, bar, done/noticed notes) and run: bash ~/.claude/hooks/phased-workflow/mark-artifact.sh. The next phase branch is hook-blocked until the artifact is fresh."}}'
fi
exit 0
