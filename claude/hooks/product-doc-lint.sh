#!/usr/bin/env bash
#
# Stop hook (advisory): lint changed product docs (PRDs, strategy memos,
# PR-FAQs, positioning, OKRs) for writing smells - hype/weasel words and likely
# vanity metrics. Surfaces findings (exit 2) so they get tightened before
# sharing; this is about product docs only. Code, README, the claude config,
# and the brain are excluded, so it stays silent during normal dev work.
#
# Chosen as a Stop hook rather than PostToolUse so it lints the finished doc
# once, instead of nagging on every keystroke-save mid-draft.
#
input=$(cat)
printf '%s' "$input" | grep -q '"stop_hook_active"[[:space:]]*:[[:space:]]*true' && exit 0
git rev-parse --git-dir >/dev/null 2>&1 || exit 0

docs=$( { git diff --name-only HEAD; git ls-files --others --exclude-standard; } 2>/dev/null \
  | sort -u \
  | grep -iE '\.md$' \
  | grep -iE '(prd|spec|strategy|pr-?faq|brief|positioning|okr|roadmap|memo)' \
  | grep -vE '^(claude/|brain/|vendor/|node_modules/)')
[ -z "$docs" ] && exit 0

weasel='\b(very|really|just|simply|easy|easily|obviously|seamless|seamlessly|robust|leverage|synergy|world-class|best-in-class|cutting-edge|game-?changing|revolutionary|delightful|intuitive|user-friendly|basically|actually|literally)\b'
vanity='\b(page ?views|impressions|registered users|total users|total downloads|raw signups)\b'

findings=""
while IFS= read -r f; do
  [ -f "$f" ] || continue
  w=$(grep -inE -- "$weasel" "$f" 2>/dev/null)
  v=$(grep -inE -- "$vanity" "$f" 2>/dev/null)
  [ -n "$w" ] && findings="${findings}
${f} - hype / weasel words:
${w}"
  [ -n "$v" ] && findings="${findings}
${f} - possible vanity metrics:
${v}"
done <<EOF
$docs
EOF

if [ -n "$findings" ]; then
  echo "Advisory (product-doc-lint): tighten these before sharing - fix, or proceed if intentional:" >&2
  printf '%s\n' "$findings" >&2
  exit 2
fi
exit 0
