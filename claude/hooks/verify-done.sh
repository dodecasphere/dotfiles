#!/usr/bin/env bash
#
# Stop hook: enforce a project's "definition of done" before Claude finishes.
#
# This is opt-in per project: it only acts if the project provides an
# executable .claude/verify.sh (e.g. running lint + tests + typecheck). If
# that script is absent, the hook is a no-op — so it never imposes checks on
# unrelated sessions or non-code directories.
#
# When the project script fails, exit 2 blocks Claude from stopping and feeds
# the output back so it fixes the failure first. This turns the global
# CLAUDE.md "verify before finishing" rule into actual enforcement.
#
input=$(cat)

# Prevent infinite loops: if we already blocked once this turn, let it stop.
if printf '%s' "$input" | grep -q '"stop_hook_active"[[:space:]]*:[[:space:]]*true'; then
  exit 0
fi

verify="./.claude/verify.sh"
[ -x "$verify" ] || exit 0   # project hasn't opted in — nothing to enforce

# Skip if no app code changed — no point running tests for a docs-only turn.
# NOTE: this must NOT be an && chain: `grep` exits 1 on no match, which broke
# the chain and made the skip unreachable, so verify ran on every stop
# (including skill-only turns). Fixed 2026-07-01; pattern also gained tests/
# and config/ since edits there can fail the suite too.
if git rev-parse --git-dir >/dev/null 2>&1; then
  changed=$( { git diff --name-only HEAD; git ls-files --others --exclude-standard; } 2>/dev/null \
    | grep -Ei '^(app/.*\.php|resources/js/.*\.(js|vue|jsx)|routes/.*\.php|database/.*\.php|config/.*\.php|tests/.*\.(php|js))$' || true)
  [ -z "$changed" ] && exit 0
fi

if ! out=$("$verify" 2>&1); then
  echo "Project verification failed (.claude/verify.sh) — fix before finishing:" >&2
  echo "$out" >&2
  exit 2
fi

exit 0
