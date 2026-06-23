#!/usr/bin/env bash
#
# SessionStart hook (matched on compact|resume): print a short orientation
# block that Claude keeps in context. Most valuable right after a compaction,
# when prior context was summarized away. Reads cheap, local signals only
# (no network) so it never slows session start.
#
input=$(cat)
cwd=$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null)
[ -n "$cwd" ] || cwd=$(pwd)
cd "$cwd" 2>/dev/null || exit 0
git rev-parse --git-dir >/dev/null 2>&1 || exit 0

echo "## Project orientation (auto-injected after compaction/resume)"
echo "- Repo: $(basename "$cwd")"
branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
echo "- Branch: ${branch:-unknown}"
echo "- Uncommitted changes: $(git status --porcelain 2>/dev/null | wc -l | tr -d ' ') file(s)"
if [ -f CONTEXT.md ]; then
  echo "- CONTEXT.md (project domain model / conventions) — first lines:"
  sed -n '1,40p' CONTEXT.md | sed 's/^/  /'
else
  echo "- No CONTEXT.md yet (consider the maintaining-context skill to create one)."
fi
exit 0
