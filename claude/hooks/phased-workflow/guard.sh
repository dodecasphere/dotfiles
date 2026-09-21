#!/usr/bin/env bash
# PreToolUse guard for the phased-workflow system (phased-plan / phased-execute
# skills), any project. Gates apply only to a repo that has actually armed the
# workflow (phased-plan's Step 0 ran `set-state.sh` in it at least once) — a
# repo that's never touched phased-plan is untouched by this hook.
# Gates: 1) gh pr create needs pr_approved=1
#        2) code edits blocked while phase=planning
#        3) new phase branch blocked if progress artifact stale vs HEAD
# Exit 0 = allow, exit 2 = deny (stderr shown to model).
set -euo pipefail
source "$HOME/.claude/hooks/phased-workflow/state-lib.sh"

INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty')

REPO_ROOT=$(repo_root "$CWD")
[ -n "$REPO_ROOT" ] || exit 0   # not inside a git repo: nothing to gate

SF=$(state_file "$REPO_ROOT")
[ -f "$SF" ] || exit 0          # this repo has never armed the workflow: nothing to gate

PHASE=$(state_get phase idle "$REPO_ROOT")

if [ "$TOOL" = "Bash" ]; then
  CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

  # Gate 1: PR creation gated once this repo's workflow is armed.
  if echo "$CMD" | grep -Eq 'gh[[:space:]]+pr[[:space:]]+create'; then
    if [ "$(state_get pr_approved 0 "$REPO_ROOT")" != "1" ]; then
      echo "PHASED GATE: PR creation is blocked. Mike has not said he is ready for a PR. Show him the proposed PR title/body in the chat; when he explicitly approves, run: bash ~/.claude/hooks/phased-workflow/set-state.sh pr_approved=1 — then retry." >&2
      exit 2
    fi
    exit 0
  fi

  # Gate 3: phase-branch creation requires a fresh artifact redeploy.
  if [ "$PHASE" = "executing" ] && echo "$CMD" | grep -Eq '(git[[:space:]]+checkout[[:space:]]+-b|git[[:space:]]+switch[[:space:]]+-c)[[:space:]].*-phase-[0-9]'; then
    HEAD_TS=$(git -C "$REPO_ROOT" log -1 --format=%ct 2>/dev/null || echo 0)
    ART_TS=$(state_get artifact_epoch 0 "$REPO_ROOT")
    if [ "$ART_TS" -lt "$HEAD_TS" ]; then
      echo "PHASED GATE: progress artifact not updated since the last commit. Redeploy the artifact (status chips + progress bar + notes for the finished phase, next phase set to In Progress), run: bash ~/.claude/hooks/phased-workflow/mark-artifact.sh — then cut the branch." >&2
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
    "$REPO_ROOT"/.workflow/*) exit 0 ;;   # plan docs, session files
    "$REPO_ROOT"/*)
      echo "PHASED GATE: plan is not approved yet (state=planning). No code edits until Mike explicitly approves the plan via the approval question. Plan docs under .workflow/ are allowed." >&2
      exit 2 ;;
    *) exit 0 ;;                                               # scratchpad, memory, home
  esac
fi

exit 0
