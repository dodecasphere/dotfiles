#!/usr/bin/env bash
#
# PreToolUse(Edit|Write|MultiEdit): block direct edits to sensitive files.
# Claude should ask the user to make these changes (or explicitly override).
# Exit 2 blocks. Covers env files, lockfiles, and CI workflows.
#
input=$(cat)
command -v jq >/dev/null 2>&1 || exit 0
file=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')
[ -n "$file" ] || exit 0
base=$(basename "$file")

block() {
  echo "BLOCKED: $file is protected ($1)." >&2
  echo "Ask the user to make this change, or have them confirm an explicit override." >&2
  exit 2
}

case "$file" in
  *.env.example) ;;                       # safe to edit, fall through
  *.env|*/.env|*.env.*) block "env file with secrets" ;;
esac
case "$base" in
  composer.lock|package-lock.json|yarn.lock|pnpm-lock.yaml)
    block "lockfile — regenerate via the package manager, do not hand-edit" ;;
esac
case "$file" in
  */.github/workflows/*) block "CI workflow" ;;
esac
exit 0
