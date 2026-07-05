#!/usr/bin/env bash
#
# Code-guidelines gate (PreToolUse / Edit|Write) — once-per-session pointer.
# Global, opt-in: only activates in a project with its own
# docs/core/code-guidelines.md (see templates/code-guidelines.md).
#
# The FIRST code-file edit of a session gets denied with an instruction to
# read docs/core/code-guidelines.md, then retry. Every later edit in the same
# session passes straight through (session-keyed marker file). "Code" is
# defined as "not a fast-lane path" - the same docs/tooling-vs-app-code
# boundary the git-workflow guard uses (git-guard.conf's FAST_LANE_PATHS),
# read from the same conf if present so the two stay in sync rather than
# maintaining two separate, drifting definitions of "not code." Falls back to
# the same default fast-lane paths if a project doesn't use the git guard.
#
# Perf notes (this runs on every Edit/Write):
#   1. Cheap file-stat before any process spawn - most projects don't opt in.
#   2. Exactly one jq spawn on the slow path; zero on most calls.
#   3. Marker check short-circuits the rest of the session.
set -uo pipefail

input=$(cat)

# Nothing to point at → never block.
[ -f "${CLAUDE_PROJECT_DIR:-.}/docs/core/code-guidelines.md" ] || exit 0

# One jq spawn: session id + file path together.
IFS=$'\t' read -r session_id file_path < <(
  printf '%s' "$input" | jq -r '[.session_id // "nosession", .tool_input.file_path // ""] | @tsv'
)
[ -n "$file_path" ] || exit 0

# Already pointed there this session → pass (the common case).
marker="${TMPDIR:-/tmp}/claude-code-guidelines-ack-${session_id}"
[ -f "$marker" ] && exit 0

# "Code" = not a fast-lane (docs/tooling) path. Default matches
# git-guard.conf's own default; a project's own FAST_LANE_PATHS override
# (if it uses the git-workflow guard too) applies here as well.
FAST_LANE_PATHS='docs/|brain/|scripts/|\.remember/|\.claude/|\.githooks/'
conf="${CLAUDE_PROJECT_DIR:-.}/.claude/git-guard.conf"
if [ -f "$conf" ]; then
  # shellcheck disable=SC1090
  FAST_LANE_PATHS="$(. "$conf" 2>/dev/null; printf '%s' "$FAST_LANE_PATHS")"
fi
FAST_LANE_RE="^(${FAST_LANE_PATHS})|\\.md\$"

# file_path is absolute (Edit/Write always resolve it); FAST_LANE_RE is
# anchored for project-relative paths (matching git-guard.conf's own usage
# against `git diff --cached --name-only`), so strip the project dir prefix
# before matching. A path outside the project entirely (scratch files,
# another repo) is never this project's concern - exit rather than falling
# through to matching the raw absolute path against FAST_LANE_RE, which
# would almost always "look like code" and fire incorrectly.
proj="$(cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null && pwd || echo '')"
case "$file_path" in
  "$proj"/*) rel_path="${file_path#"$proj"/}" ;;
  *) exit 0 ;;
esac

printf '%s\n' "$rel_path" | grep -Eq "$FAST_LANE_RE" && exit 0

# First code edit of the session: point at the guidelines, once.
touch "$marker"
reason='First code edit this session: Read docs/core/code-guidelines.md (house rules for this project'"'"'s code), then retry this exact edit. This gate fires once per session and will not block again.'
jq -cn --arg r "$reason" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'
exit 0
