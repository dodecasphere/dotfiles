#!/usr/bin/env bash
#
# SessionStart hook: if this project has a Project Brain (the canonical
# 0N-XX-*.md files), inject it so the session starts grounded without pasting
# anything in. Brains are small by design, so the whole thing is printed.
# No-op when the project has no brain.
#
input=$(cat)
cwd=$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null)
[ -n "$cwd" ] || cwd=$(pwd)
cd "$cwd" 2>/dev/null || exit 0

# Locate a brain: the cwd itself, or a likely subdirectory.
braindir=""
for d in . brain .brain project-brain ./*-brain; do
  [ -d "$d" ] || continue
  if ls "$d"/[0-9]*-{OV,GO,AR,DC,ST,GL,OQ}-*.md >/dev/null 2>&1; then
    braindir="$d"; break
  fi
done
[ -n "$braindir" ] || exit 0

echo "## Project Brain (auto-loaded; authoritative grounding for this project, do not restate unless asked)"
for f in "$braindir"/[0-9]*-{OV,GO,ST,OQ}-*.md; do
  [ -f "$f" ] || continue
  echo
  echo "### $(basename "$f")"
  cat "$f"
done
exit 0
