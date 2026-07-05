#!/usr/bin/env bash
#
# Project test gate. Copy to <project>/.claude/verify.sh and `chmod +x` it.
# The global verify-done Stop hook runs it before Claude can finish; a non-zero
# exit blocks finishing until tests pass and coverage clears the bar.
#
# COST: this runs on every finish, so the DEFAULT is the scoped stop gate
# (pest --dirty, vitest --changed, no coverage) - cheap enough to run on every
# Stop. Set VERIFY_FULL=1 for the full suite plus the coverage bar; that's the
# pre-merge / pre-deploy gate, run explicitly, not on every Stop.
#
# Requirements: Pest coverage needs Xdebug or PCOV (this script degrades
# gracefully without one - full suite still runs, just without the coverage
# bar). Vitest coverage needs @vitest/coverage-v8 (or istanbul); set
# thresholds in vitest.config (test.coverage.thresholds) so Vitest exits
# non-zero when they are unmet.
#
# --parallel on Pest (via bundled Paratest) is on by default below - a real
# win on any suite with more than a couple dozen tests, verified ~2-2.5x
# faster on a 1400-test suite with zero flakiness (2026-07-05). For a very
# small suite the worker-spawn overhead can net LOSE time (measured on Pint's
# own -p flag, same principle) - if VERIFY_FULL feels slower after adding
# tests, time it both ways before assuming parallel is free.
#
set -uo pipefail

MIN_PHP_COVERAGE=85
VERIFY_FULL="${VERIFY_FULL:-0}"
fail=0

# --- PHP: Pest (preferred) or PHPUnit ---
if [ -x vendor/bin/pest ]; then
  if [ "$VERIFY_FULL" = "1" ]; then
    if php -m | grep -qiE '^(pcov|xdebug)$'; then
      echo "==> Pest full --parallel (min ${MIN_PHP_COVERAGE}% coverage)"
      vendor/bin/pest --parallel --coverage --min="$MIN_PHP_COVERAGE" || fail=1
    else
      echo "==> Pest full --parallel (no coverage driver)"
      vendor/bin/pest --parallel || fail=1
    fi
  else
    echo "==> Pest --dirty --parallel (scoped stop gate; VERIFY_FULL=1 for the merge gate)"
    vendor/bin/pest --dirty --parallel || fail=1
  fi
elif [ -x vendor/bin/phpunit ]; then
  echo "==> PHPUnit"
  vendor/bin/phpunit || fail=1
fi

# --- JS: Vitest (coverage thresholds, when configured, come from vitest.config) ---
if [ -x node_modules/.bin/vitest ]; then
  if [ "$VERIFY_FULL" = "1" ] && [ -d node_modules/@vitest/coverage-v8 ]; then
    echo "==> Vitest full (+ coverage thresholds from vitest.config)"
    node_modules/.bin/vitest run --coverage --passWithNoTests || fail=1
  elif [ "$VERIFY_FULL" = "1" ]; then
    echo "==> Vitest full"
    node_modules/.bin/vitest run --passWithNoTests || fail=1
  else
    echo "==> Vitest --changed (scoped stop gate; VERIFY_FULL=1 for the merge gate)"
    node_modules/.bin/vitest run --changed --passWithNoTests || fail=1
  fi
fi

if [ "$fail" -ne 0 ]; then
  echo "verify.sh: tests or coverage failed - not done yet." >&2
fi
exit "$fail"
