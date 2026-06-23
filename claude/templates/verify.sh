#!/usr/bin/env bash
#
# Project test gate. Copy to <project>/.claude/verify.sh and `chmod +x` it.
# The global verify-done Stop hook runs it before Claude can finish; a non-zero
# exit blocks finishing until tests pass and coverage clears the bar.
#
# COST: this runs on every finish in a project that has it. If the suite is
# slow, scope it (pest --dirty, vitest --changed) or move the coverage check to
# commit time. Tune the commands and threshold below for this project.
#
# Requirements: Pest coverage needs Xdebug or PCOV. Vitest coverage needs
# @vitest/coverage-v8 (or istanbul); set thresholds in vitest.config
# (test.coverage.thresholds) so Vitest exits non-zero when they are unmet.
#
set -uo pipefail

MIN_PHP_COVERAGE=85
fail=0

# --- PHP: Pest (preferred) or PHPUnit ---
if [ -x vendor/bin/pest ]; then
  echo "==> Pest (min ${MIN_PHP_COVERAGE}% coverage)"
  vendor/bin/pest --coverage --min="$MIN_PHP_COVERAGE" || fail=1
elif [ -x vendor/bin/phpunit ]; then
  echo "==> PHPUnit"
  vendor/bin/phpunit || fail=1
fi

# --- JS: Vitest (coverage thresholds come from vitest.config) ---
if [ -x node_modules/.bin/vitest ]; then
  echo "==> Vitest (+ coverage thresholds from vitest.config)"
  node_modules/.bin/vitest run --coverage || fail=1
fi

if [ "$fail" -ne 0 ]; then
  echo "verify.sh: tests or coverage failed - not done yet." >&2
fi
exit "$fail"
