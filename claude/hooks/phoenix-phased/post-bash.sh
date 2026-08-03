#!/usr/bin/env bash
# PostToolUse(Bash): after a git commit during execution, remind about the
# artifact; after a successful gh pr create, re-arm the PR gate.
set -euo pipefail
source "$HOME/.claude/hooks/phoenix-phased/state-lib.sh"

INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')
case "$CWD" in
  /Users/michaeldulle/Sites/phoenix*) ;;
  *) exit 0 ;;
esac
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if echo "$CMD" | grep -Eq 'gh[[:space:]]+pr[[:space:]]+create'; then
  state_set pr_approved 0   # one PR per approval; re-arm the gate
  exit 0
fi

if [ "$(state_get phase idle)" = "executing" ] && echo "$CMD" | grep -q 'git commit'; then
  jq -n '{hookSpecificOutput:{hookEventName:"PostToolUse",additionalContext:"PHASED REMINDER: commit landed. If this closes or advances a phase, redeploy the progress artifact NOW (chips, bar, done/noticed notes) and run: bash ~/.claude/hooks/phoenix-phased/mark-artifact.sh. The next phase branch is hook-blocked until the artifact is fresh."}}'
fi
exit 0
