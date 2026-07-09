#!/usr/bin/env bash
#
# local-ci.sh - run the full CI suite locally before pushing.
#
# TEMPLATE: mirror this project's .github/workflows/ EXACTLY (same tools,
# same flags, same order). The value of this script is byte-for-byte parity
# with CI; when CI changes, change this file in the same PR. Delete suites
# this project doesn't have.
#
# Usage:
#   ./local-ci.sh              # run everything
#   ./local-ci.sh style        # only Pint
#   ./local-ci.sh static tests # Larastan + Pest only
#
# Suites: style, rector, static, tests, js-tests, build
set -uo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"
FAILED=()

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
pass() { echo -e "${GREEN}PASS $*${NC}"; }
fail() { echo -e "${RED}FAIL $*${NC}"; FAILED+=("$*"); }
step() { echo -e "\n${YELLOW}=== $* ===${NC}"; }

SUITES=("$@")
run_suite() {
  [ ${#SUITES[@]} -eq 0 ] && return 0
  local s
  for s in "${SUITES[@]}"; do [ "$s" = "$1" ] && return 0; done
  return 1
}

run() { # run <suite-label> <command...>
  local label="$1"; shift
  step "$label"
  if "$@"; then pass "$label"; else fail "$label"; fi
}

# --- PHP -------------------------------------------------------------------
if run_suite style && [ -x vendor/bin/pint ]; then
  run "style (pint)" vendor/bin/pint --test
fi

if run_suite rector && [ -x vendor/bin/rector ]; then
  run "rector (dry-run)" vendor/bin/rector --dry-run
fi

if run_suite static && [ -x vendor/bin/phpstan ]; then
  run "static (larastan)" vendor/bin/phpstan analyse --no-progress
fi

if run_suite tests && [ -x vendor/bin/pest ]; then
  run "tests (pest)" vendor/bin/pest --parallel
fi

# --- JS --------------------------------------------------------------------
if run_suite js-tests && [ -f package.json ] && grep -q '"test"' package.json; then
  run "js-tests" npm test --silent
fi

if run_suite build && [ -f package.json ] && grep -q '"build"' package.json; then
  run "build (vite)" npm run build --silent
fi

# --- Summary ---------------------------------------------------------------
echo
if [ ${#FAILED[@]} -eq 0 ]; then
  echo -e "${GREEN}All local CI suites passed.${NC}"
else
  echo -e "${RED}Failed suites:${NC}"
  printf '  - %s\n' "${FAILED[@]}"
  exit 1
fi
