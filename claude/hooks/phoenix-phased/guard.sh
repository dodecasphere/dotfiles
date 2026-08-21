#!/usr/bin/env bash
# PreToolUse guard for phoenix phased-plan workflow (personal, phoenix-only).
# Gates: 1) gh pr create needs pr_approved=1
#        2) code edits blocked while phase=planning
#        3) new phase branch blocked if progress artifact stale vs HEAD
# Exit 0 = allow, exit 2 = deny (stderr shown to model).
set -euo pipefail
source "$HOME/.claude/hooks/phoenix-phased/state-lib.sh"

INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty')

# Phoenix-only: bail (allow) if not inside the phoenix repo.
case "$CWD" in
  "$HOME"/Sites/phoenix*) ;;
  *) exit 0 ;;
esac

PHASE=$(state_get phase idle)

if [ "$TOOL" = "Bash" ]; then
  CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

  # Gate 1: PR creation always gated in phoenix.
  if echo "$CMD" | grep -Eq 'gh[[:space:]]+pr[[:space:]]+create'; then
    if [ "$(state_get pr_approved 0)" != "1" ]; then
      echo "PHASED GATE: PR creation is blocked. Mike has not said he is ready for a PR. Show him the proposed PR title/body in the chat; when he explicitly approves, run: bash ~/.claude/hooks/phoenix-phased/set-state.sh pr_approved=1 — then retry." >&2
      exit 2
    fi
    exit 0
  fi

  # Gate 3: phase-branch creation requires a fresh artifact redeploy.
  if [ "$PHASE" = "executing" ] && echo "$CMD" | grep -Eq '(git[[:space:]]+checkout[[:space:]]+-b|git[[:space:]]+switch[[:space:]]+-c)[[:space:]].*-phase-[0-9]'; then
    HEAD_TS=$(git -C "$HOME/Sites/phoenix" log -1 --format=%ct 2>/dev/null || echo 0)
    ART_TS=$(state_get artifact_epoch 0)
    if [ "$ART_TS" -lt "$HEAD_TS" ]; then
      echo "PHASED GATE: progress artifact not updated since the last commit. Redeploy the artifact (status chips + progress bar + notes for the finished phase, next phase set to In Progress), run: bash ~/.claude/hooks/phoenix-phased/mark-artifact.sh — then cut the branch." >&2
      exit 2
    fi
    exit 0
  fi
  exit 0
fi

# Gate 2: no code edits before plan approval.
if [ "$TOOL" = "Edit" ] || [ "$TOOL" = "Write" ] || [ "$TOOL" = "NotebookEdit" ]; then
  [ "$PHASE" = "planning" ] || exit 0
  FP=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.notebook_path // empty')
  case "$FP" in
    "$HOME"/Sites/phoenix/.workflow/*) exit 0 ;;   # plan docs, session files
    "$HOME"/Sites/phoenix/*)
      echo "PHASED GATE: plan is not approved yet (state=planning). No code edits until Mike explicitly approves the plan via the approval question. Plan docs under .workflow/ are allowed." >&2
      exit 2 ;;
    *) exit 0 ;;                                               # scratchpad, memory, home
  esac
fi

exit 0
