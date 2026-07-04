#!/usr/bin/env bash
# Consolidated global Bash PreToolUse dispatcher (efficiency audit 2026-07-01,
# R5). Runs on EVERY Bash call in EVERY project, so this is the highest-
# leverage of the two dispatcher merges (the CrestLite project-level one only
# runs on git commands). One bash spawn + one jq parse instead of two of each,
# for the two checks that used to be separate hook scripts:
#   1. block-dangerous-commands.sh — refuse force-push / rm -r root-or-home /
#      terraform apply|destroy (exit 2 + stderr, the "suggest, don't execute"
#      contract for irreversible ops).
#   2. git-workflow-guard.sh (global, opt-in) — only does anything in a repo
#      that has its own .claude/git-guard.conf; every other repo (including
#      these dotfiles) is unaffected, matching the original's no-op default.
# Behavior is unchanged from the two original scripts, just merged.
input=$(cat)

# Cheap raw-substring pre-check before paying for a jq spawn. Every rule in
# either check requires one of these words to appear in the command, and the
# command appears literally inside the raw JSON either way, so total absence
# proves nothing below can match.
case "$input" in
  *push*|*rm*|*terraform*|*git*) ;;
  *) exit 0 ;;
esac

if command -v jq >/dev/null 2>&1; then
  cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty')
else
  cmd=$input
fi
[ -n "$cmd" ] || exit 0

block() {
  echo "BLOCKED by bash-pretooluse-dispatcher: $1" >&2
  echo "This is irreversible — suggest the exact command and let the user run it." >&2
  exit 2
}

# Command-position match: start of string, or right after a separator. Avoids
# false positives when the words appear as arguments or inside quotes.
CMDPOS='(^|[;&|(]|&&|\|\|)[[:space:]]*'

# ============================================================================
# Check 1: dangerous commands (force-push, rm -r root/home, terraform)
# ============================================================================
block_dangerous_commands() {
  if printf '%s' "$cmd" | grep -Eq "$CMDPOS"'git[[:space:]]+push' \
     && printf '%s' "$cmd" | grep -Eq '(--force|[[:space:]]-f([[:space:]]|$))'; then
    block "git force-push"
  fi

  if printf '%s' "$cmd" | grep -Eq "$CMDPOS"'rm[[:space:]]+-[a-zA-Z]*r[a-zA-Z]*[[:space:]]+(/|~|\$HOME)([[:space:]/;|*]|$)'; then
    block "rm -r of a root/home path"
  fi

  if printf '%s' "$cmd" | grep -Eq "$CMDPOS"'terraform[[:space:]]+(apply|destroy)'; then
    block "terraform apply/destroy"
  fi
}

# ============================================================================
# Check 2: git-workflow-guard (opt-in via .claude/git-guard.conf; no-op
# everywhere that file doesn't exist, same as the original)
# ============================================================================
git_workflow_guard_global() {
  local conf=".claude/git-guard.conf"
  [ -f "$conf" ] || return 0

  printf '%s' "$cmd" | grep -Eq "$CMDPOS"'git[[:space:]]+commit' || return 0

  local PROTECTED_BRANCHES="main master production release"
  local ENFORCE_CONVENTIONAL=0
  # shellcheck disable=SC1090
  . "$conf" 2>/dev/null

  local branch
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  local b
  for b in $PROTECTED_BRANCHES; do
    if [ "$branch" = "$b" ]; then
      echo "BLOCKED: do not commit directly to protected branch '$branch'." >&2
      echo "Create a feature branch first (git switch -c feature/...), then open a PR." >&2
      exit 2
    fi
  done

  if [ "$ENFORCE_CONVENTIONAL" = "1" ]; then
    local msg
    msg=$(printf '%s' "$cmd" | sed -nE "s/.*-m[[:space:]]+['\"]([^'\"]+).*/\1/p" | head -1)
    if [ -n "$msg" ] && ! printf '%s' "$msg" | grep -Eq '^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\(.+\))?!?: .+'; then
      echo "BLOCKED: commit message is not Conventional Commits format (type: subject)." >&2
      echo "Got: $msg" >&2
      exit 2
    fi
  fi
}

block_dangerous_commands
git_workflow_guard_global
exit 0
