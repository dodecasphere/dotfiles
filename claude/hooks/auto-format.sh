#!/usr/bin/env bash
#
# PostToolUse(Edit|Write|MultiEdit): format the file just written using the
# project's own formatter, if present. No-op when the formatter is not
# installed, so it is safe across every project. PostToolUse cannot block;
# this only tidies. Pint for PHP, Prettier for JS/TS/Vue/CSS/JSON/MD.
#
input=$(cat)
command -v jq >/dev/null 2>&1 || exit 0
file=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')
[ -n "$file" ] && [ -f "$file" ] || exit 0

# Walk up to the project root (first dir with composer.json/package.json/.git).
root=$(cd "$(dirname "$file")" && pwd)
while [ "$root" != "/" ]; do
  if [ -e "$root/composer.json" ] || [ -e "$root/package.json" ] || [ -d "$root/.git" ]; then
    break
  fi
  root=$(dirname "$root")
done

case "$file" in
  *.php)
    [ -x "$root/vendor/bin/pint" ] && "$root/vendor/bin/pint" "$file" >/dev/null 2>&1
    ;;
  *.vue|*.ts|*.tsx|*.js|*.jsx|*.mjs|*.css|*.scss|*.json|*.md)
    [ -x "$root/node_modules/.bin/prettier" ] && "$root/node_modules/.bin/prettier" --write "$file" >/dev/null 2>&1
    ;;
esac
exit 0
