#!/usr/bin/env bash
#
# Pre-commit check: block commit if staged files contain debug leftovers
# (dd(), dump(), var_dump(), ray(), console.log/debug, debugger;, [DEBUG- tags).
# Called from .githooks/pre-commit. No-op outside a git repo.
# Pairs with the diagnosing-bugs skill, which tags temp logs [DEBUG-...].
#
git rev-parse --git-dir >/dev/null 2>&1 || exit 0
files=$(git diff --cached --name-only 2>/dev/null \
        | grep -Ei '\.(php|vue|ts|tsx|js|jsx|mjs)$')
[ -z "$files" ] && exit 0

# \b word boundaries prevent false positives: \bdd\( won't match add(,
# \bray\( won't match Array(.
pattern='\bdd\(|\bdump\(|var_dump\(|\bray\(|console\.(log|debug)|debugger;|\[DEBUG-'
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
  echo "Debug leftovers in staged files — remove before committing:" >&2
  printf '%s\n' "$hits" >&2
  exit 1
fi
exit 0
