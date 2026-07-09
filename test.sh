#!/usr/bin/env bash
#
# Dry-run restore test for the Claude Code config layer.
#
# Simulates a fresh machine: clone this repo's committed HEAD into a temp dir,
# run install.sh against a throwaway HOME, and verify ~/.claude is restored
# correctly via symlinks. Never touches the real ~/.claude (HOME is sandboxed).
# Validates committed state only, so commit before running. Exits non-zero on
# any failure.
#
set -uo pipefail

REPO="$(cd "$(dirname "$0")" && pwd)"
TMP="$(mktemp -d)"
CLONE="$TMP/clone"
FAKEHOME="$TMP/home"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$FAKEHOME"

pass=0; fail=0
ok()   { echo "   OK   $1"; pass=$((pass+1)); }
bad()  { echo "   FAIL $1"; fail=$((fail+1)); }

echo "## 1. Clone committed HEAD (simulating a fresh machine)"
git clone --quiet "file://$REPO/.git" "$CLONE" || { echo "CLONE FAILED"; exit 1; }
echo "   cloned to $CLONE"

echo
echo "## 2. Secret-bearing artifact must not be in the repo"
if [ -e "$CLONE/claude/fetch-claude-usage.swift" ]; then
  bad "fetch-claude-usage.swift is committed"
else
  ok "fetch-claude-usage.swift absent (gitignored)"
fi

echo
echo "## 3. Run install.sh with a sandboxed HOME"
( cd "$CLONE" && HOME="$FAKEHOME" bash install.sh ) >/dev/null 2>&1
rc=$?
[ "$rc" -eq 0 ] && ok "install.sh exited 0" || bad "install.sh exited $rc"

echo
echo "## 4. ~/.claude symlinks point into the clone"
chk_link() {
  local p="$FAKEHOME/.claude/$1"
  if [ -L "$p" ] && readlink "$p" | grep -qF "$CLONE/claude/$1"; then
    ok "link $1"
  else
    bad "link $1 (got: $(readlink "$p" 2>/dev/null || echo missing))"
  fi
}
for f in CLAUDE.md settings.json statusline-command.sh statusline-config.txt; do chk_link "$f"; done
for d in agents commands hooks rules skills; do chk_link "$d"; done

echo
echo "## 5. settings.json valid with hooks + permissions"
if jq -e '.hooks and .permissions' "$FAKEHOME/.claude/settings.json" >/dev/null 2>&1; then
  ok "settings.json valid"
else
  bad "settings.json missing hooks/permissions or invalid"
fi

echo
echo "## 6. Multi-file skill resolves through the directory symlink"
[ -f "$FAKEHOME/.claude/skills/diagnosing-bugs/SKILL.md" ] \
  && ok "skills/diagnosing-bugs/SKILL.md reachable" \
  || bad "multi-file skill not reachable"

echo
echo "## 7. A restored hook actually runs (blocks a force-push)"
printf '{"tool_name":"Bash","tool_input":{"command":"git push --force"}}' \
  | bash "$FAKEHOME/.claude/hooks/bash-pretooluse-dispatcher.sh" >/dev/null 2>&1
[ "$?" -eq 2 ] && ok "bash-pretooluse-dispatcher blocked force-push (exit 2)" \
  || bad "hook did not block force-push"

echo
echo "## RESULT: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
