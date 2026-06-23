#!/usr/bin/env bash
#
# Stop hook: block finishing if changed files still contain debug leftovers
# (dd(), dump(), var_dump(), ray(), console.log/debug, debugger;, [DEBUG- tags).
# Inspects only files changed in the working tree of a git repo; no-op
# elsewhere. Pairs with the diagnosing-bugs skill, which tags temp logs
# [DEBUG-...] precisely so this can catch leftovers.
#
input=$(cat)
printf '%s' "$input" | grep -q '"stop_hook_active"[[:space:]]*:[[:space:]]*true' && exit 0

git rev-parse --git-dir >/dev/null 2>&1 || exit 0
files=$( { git diff --name-only HEAD; git ls-files --others --exclude-standard; } 2>/dev/null \
         | sort -u | grep -Ei '\.(php|vue|ts|tsx|js|jsx|mjs)$')
[ -z "$files" ] && exit 0

pattern='dd\(|dump\(|var_dump\(|ray\(|console\.(log|debug)|debugger;|\[DEBUG-'
hits=""
while IFS= read -r f; do
  [ -f "$f" ] || continue
  m=$(grep -nE "$pattern" "$f" 2>/dev/null)
  [ -n "$m" ] && hits="${hits}
${f}:
${m}"
done <<EOF
$files
EOF

if [ -n "$hits" ]; then
  echo "Debug leftovers in changed files — remove before finishing:" >&2
  printf '%s\n' "$hits" >&2
  exit 2
fi
exit 0
