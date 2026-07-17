#!/usr/bin/env bash
#
# Stop hook: block finishing if a changed test file contains a focus directive
# (Pest `->only()`, JS `.only(` / `fit(` / `fdescribe(`). A committed focused
# test silently disables the rest of the suite, so the green checkmark lies.
# Inspects only changed test files in a git repo; no-op elsewhere.
#
input=$(cat)
printf '%s' "$input" | grep -q '"stop_hook_active"[[:space:]]*:[[:space:]]*true' && exit 0
git rev-parse --git-dir >/dev/null 2>&1 || exit 0

tests=$( { git diff --name-only HEAD; git ls-files --others --exclude-standard; } 2>/dev/null \
  | sort -u | grep -E '(^tests/|/__tests__/|\.(test|spec)\.(js|vue|jsx)$|Test\.php$)')
[ -z "$tests" ] && exit 0

pattern='->only\(|\.only\(|\bfit\(|\bfdescribe\(|\bfcontext\('
hits=""
while IFS= read -r f; do
  [ -f "$f" ] || continue
  m=$(grep -nE -- "$pattern" "$f" 2>/dev/null)
  [ -n "$m" ] && hits="${hits}
${f}:
${m}"
done <<EOF
$tests
EOF

if [ -n "$hits" ]; then
  echo "Focused tests left in changed files - they disable the rest of the suite. Remove the focus before finishing:" >&2
  printf '%s\n' "$hits" >&2
  exit 2
fi
exit 0
