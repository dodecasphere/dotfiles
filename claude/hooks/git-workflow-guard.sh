#!/usr/bin/env bash
#
# PreToolUse(Bash): git-workflow guard. Opt-in per project via
# .claude/git-guard.conf. When that file exists, block commits to protected
# branches (enforcing a feature-branch + PR workflow) and optionally enforce
# Conventional Commits. No config file means no-op, so repos that commit
# straight to main (like these dotfiles) are unaffected.
#
input=$(cat)
if command -v jq >/dev/null 2>&1; then
  cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty')
else
  cmd=$input
fi
[ -n "$cmd" ] || exit 0

# Only relevant to git commits, in command position.
printf '%s' "$cmd" | grep -Eq '(^|[;&|(]|&&|\|\|)[[:space:]]*git[[:space:]]+commit' || exit 0

conf=".claude/git-guard.conf"
[ -f "$conf" ] || exit 0

PROTECTED_BRANCHES="main master production release"
ENFORCE_CONVENTIONAL=0
# shellcheck disable=SC1090
. "$conf" 2>/dev/null

branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
for b in $PROTECTED_BRANCHES; do
  if [ "$branch" = "$b" ]; then
    echo "BLOCKED: do not commit directly to protected branch '$branch'." >&2
    echo "Create a feature branch first (git switch -c feature/...), then open a PR." >&2
    exit 2
  fi
done

if [ "$ENFORCE_CONVENTIONAL" = "1" ]; then
  # Best-effort: read a simple -m "message". Heredoc messages are skipped.
  msg=$(printf '%s' "$cmd" | sed -nE "s/.*-m[[:space:]]+['\"]([^'\"]+).*/\1/p" | head -1)
  if [ -n "$msg" ] && ! printf '%s' "$msg" | grep -Eq '^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\(.+\))?!?: .+'; then
    echo "BLOCKED: commit message is not Conventional Commits format (type: subject)." >&2
    echo "Got: $msg" >&2
    exit 2
  fi
fi
exit 0
