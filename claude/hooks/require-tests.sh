#!/usr/bin/env bash
#
# Stop hook (tier-2 test enforcement): if app-code files changed in the working
# tree but no test file was added or updated, block finishing so tests get
# written. It checks "were any tests touched at all," not a brittle per-file
# mapping. Active ONLY where a test setup exists (a tests/ dir, Pest/PHPUnit, or
# Vitest), so non-test repos and config/docs-only changes are unaffected.
#
input=$(cat)
printf '%s' "$input" | grep -q '"stop_hook_active"[[:space:]]*:[[:space:]]*true' && exit 0

git rev-parse --git-dir >/dev/null 2>&1 || exit 0
# Only enforce in projects that actually have a test setup.
[ -d tests ] || [ -x vendor/bin/pest ] || [ -x vendor/bin/phpunit ] || [ -x node_modules/.bin/vitest ] || exit 0

changed=$( { git diff --name-only HEAD; git ls-files --others --exclude-standard; } 2>/dev/null | sort -u )
[ -z "$changed" ] && exit 0

# App-code changes that ordinarily warrant a test (exclude entrypoints and tests).
appcode=$(printf '%s\n' "$changed" \
  | grep -E '^(app/.*\.php|resources/js/.*\.(js|vue|jsx))$' \
  | grep -vE '(\.(test|spec)\.|/__tests__/|resources/js/(app|bootstrap|ssr)\.js$)')
[ -z "$appcode" ] && exit 0

# Was any test file added or changed?
tests_touched=$(printf '%s\n' "$changed" \
  | grep -E '(^tests/|/__tests__/|\.(test|spec)\.(js|vue|jsx|ts|php)$|Test\.php$)')
[ -n "$tests_touched" ] && exit 0

echo "Tier-2 gate: app code changed but no test was added or updated. Write a unit or feature test before finishing:" >&2
printf '%s\n' "$appcode" | sed 's/^/  - /' >&2
exit 2
