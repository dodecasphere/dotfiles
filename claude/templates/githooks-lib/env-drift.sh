#!/usr/bin/env bash
#
# Stop hook: if .env has keys missing from .env.example, block finishing so the
# example (what teammates, CI, and Forge rely on) stays in sync. Compares key
# names only, never values. No-op unless both files exist.
#
input=$(cat)
printf '%s' "$input" | grep -q '"stop_hook_active"[[:space:]]*:[[:space:]]*true' && exit 0
[ -f .env ] && [ -f .env.example ] || exit 0

keys_of() { grep -E '^[A-Za-z_][A-Za-z0-9_]*=' "$1" 2>/dev/null | sed -E 's/=.*//' | sort -u; }
missing=$(comm -23 <(keys_of .env) <(keys_of .env.example))

if [ -n "$missing" ]; then
  echo ".env has keys missing from .env.example - add them (value-less or with a safe placeholder) before finishing:" >&2
  printf '%s\n' "$missing" | sed 's/^/  - /' >&2
  exit 2
fi
exit 0
