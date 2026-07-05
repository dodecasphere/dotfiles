#!/usr/bin/env bash
# Consolidated global Bash PreToolUse dispatcher (efficiency audit 2026-07-01,
# R5; git-workflow guard upgraded to parity with CrestLite's project-local
# version 2026-07-05). Runs on EVERY Bash call in EVERY project. One bash
# spawn + one jq parse for:
#   1. block-dangerous-commands.sh — refuse force-push / rm -r root-or-home /
#      terraform apply|destroy (exit 2 + stderr, the "suggest, don't execute"
#      contract for irreversible ops).
#   2. git-workflow-guard (opt-in, activated by a project's own
#      .claude/git-guard.conf): branch protection, fast-lane docs/tooling
#      commits, branch-naming convention, staged-script syntax check,
#      optional Conventional Commits enforcement.
#   3. brain-sync gate (opt-in, same conf): blocks a commit that stages app
#      code with no corresponding Project Brain update and no [no-brain]
#      opt-out. Only meaningful in a project using the Project Brain
#      convention (see templates/brain/).
input=$(cat)

# Cheap raw-substring pre-check before paying for a jq spawn. Every rule in
# either check requires one of these words to appear in the command, and the
# command appears literally inside the raw JSON either way, so total absence
# proves nothing below can match.
case "$input" in
  *push*|*rm*|*terraform*|*git*) ;;
  *) exit 0 ;;
esac

if command -v jq >/dev/null 2>&1; then
  IFS=$'\t' read -r cmd cwd_field < <(
    printf '%s' "$input" | jq -r '[(.tool_input.command // ""), (.cwd // "")] | @tsv'
  )
else
  cmd=$input
  cwd_field=""
fi
[ -n "$cmd" ] || exit 0

block() {
  echo "BLOCKED by bash-pretooluse-dispatcher: $1" >&2
  echo "This is irreversible — suggest the exact command and let the user run it." >&2
  exit 2
}

deny() {
  jq -n --arg reason "$1" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $reason
    }
  }'
  exit 0
}

# Command-position match: start of string, or right after a separator. Avoids
# false positives when the words appear as arguments or inside quotes.
CMDPOS='(^|[;&|(]|&&|\|\|)[[:space:]]*'

# ============================================================================
# Check 1: dangerous commands (force-push, rm -r root/home, terraform)
# ============================================================================
block_dangerous_commands() {
  if printf '%s' "$cmd" | grep -Eq "$CMDPOS"'git[[:space:]]+push' \
     && printf '%s' "$cmd" | grep -Eq '(--force|[[:space:]]-f([[:space:]]|$))'; then
    block "git force-push"
  fi

  if printf '%s' "$cmd" | grep -Eq "$CMDPOS"'rm[[:space:]]+-[a-zA-Z]*r[a-zA-Z]*[[:space:]]+(/|~|\$HOME)([[:space:]/;|*]|$)'; then
    block "rm -r of a root/home path"
  fi

  if printf '%s' "$cmd" | grep -Eq "$CMDPOS"'terraform[[:space:]]+(apply|destroy)'; then
    block "terraform apply/destroy"
  fi
}

# ============================================================================
# Check 2: git-workflow guard (opt-in via .claude/git-guard.conf; no-op
# everywhere that file doesn't exist)
# ============================================================================
git_workflow_guard_global() {
  local conf=".claude/git-guard.conf"
  [ -f "$conf" ] || return 0

  printf '%s' "$cmd" | grep -Eq "$CMDPOS"'git[[:space:]]+' || return 0

  # Defaults (overridable by the conf below).
  local PROTECTED_BRANCHES="main master"
  local BRANCH_TYPES="feature bugfix hotfix chore refactor docs spike release"
  local FAST_LANE_PATHS='docs/|brain/|scripts/|\.remember/|\.claude/|\.githooks/'
  local FAST_LANE_SCRIPT_CHECK=1
  local ENFORCE_CONVENTIONAL=0
  local BRAIN_SYNC_ENFORCE=0
  local BRAIN_CODE_PATHS=""
  # shellcheck disable=SC1090
  . "$conf" 2>/dev/null

  local PROTECTED_BRANCHES_RE
  PROTECTED_BRANCHES_RE="^($(printf '%s' "$PROTECTED_BRANCHES" | tr ' ' '|'))\$"
  local BRANCH_TYPES_RE
  BRANCH_TYPES_RE="^($(printf '%s' "$BRANCH_TYPES" | tr ' ' '|'))/[a-z0-9]+(-[a-z0-9]+)*\$"
  local RELEASE_VERSION_RE='^release/v?[0-9]+\.[0-9]+\.[0-9]+$'
  local FAST_LANE_RE="^(${FAST_LANE_PATHS})|\\.md\$"

  # The repo this command actually operates on. CLAUDE_PROJECT_DIR alone is
  # NOT enough: a background agent working in its own git worktree needs the
  # harness's own cwd, not the main checkout's path.
  local proj repo_dir cd_target resolved current_branch
  proj="$(cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null && pwd || echo '')"
  repo_dir="${cwd_field:-${CLAUDE_PROJECT_DIR:-.}}"

  cd_target="$(printf '%s' "$cmd" | sed -nE 's/^[[:space:]]*cd[[:space:]]+([^;&|[:space:]]+)[[:space:]]*(&&|;).*/\1/p')"
  if [ -n "$cd_target" ]; then
    case "$cd_target" in '~'*) cd_target="${HOME}${cd_target#\~}" ;; esac
    case "$cd_target" in
      /*) : ;;
      *) cd_target="$repo_dir/$cd_target" ;;
    esac
    repo_dir="$cd_target"
  fi

  resolved="$(cd "$repo_dir" 2>/dev/null && pwd || echo '')"
  case "$resolved" in
    "$proj"|"$proj"/*) repo_dir="$resolved" ;;
    *) return 0 ;;
  esac

  current_branch="$(git -C "$repo_dir" rev-parse --abbrev-ref HEAD 2>/dev/null || echo '')"

  # --- Fast lane: collect every path this command could commit -------------
  fast_lane_paths() {
    local repo="$repo_dir" paths="" tok segs
    paths="$(git -C "$repo" diff --cached --name-only 2>/dev/null || true)"

    segs="$(printf '%s' "$cmd" | grep -oE 'git[[:space:]]+add[[:space:]]+[^;&|]*' | sed -E 's/^git[[:space:]]+add[[:space:]]+//' || true)"
    for tok in $segs; do
      case "$tok" in
        -*|.|..*|*'*'*) return 1 ;;
        *) paths="$paths"$'\n'"$tok" ;;
      esac
    done

    if printf '%s' "$cmd" | grep -Eq 'git[[:space:]]+commit[[:space:]]+[^;&|]*(-a|--all|-am)([[:space:]]|$)'; then
      paths="$paths"$'\n'"$(git -C "$repo" diff --name-only 2>/dev/null || true)"
    fi

    paths="$(printf '%s\n' "$paths" | sed '/^$/d' | sort -u)"
    [ -z "$paths" ] && return 1
    printf '%s\n' "$paths" | grep -Evq "$FAST_LANE_RE" && return 1
    printf '%s\n' "$paths"
    return 0
  }

  # --- Rule 1: block commits on a protected branch --------------------------
  if printf '%s' "$cmd" | grep -Eq '(^|[;&|[:space:]])git[[:space:]]+([^;&|]*[[:space:]])?commit([[:space:]]|$)'; then
    if printf '%s' "$current_branch" | grep -Eq "$PROTECTED_BRANCHES_RE"; then
      local lane_paths
      if lane_paths="$(fast_lane_paths)"; then
        if [ "$FAST_LANE_SCRIPT_CHECK" = "1" ]; then
          while IFS= read -r f; do
            case "$f" in
              .claude/*.sh|scripts/*.sh|.githooks/*)
                if [ -f "$repo_dir/$f" ] && ! bash -n "$repo_dir/$f" 2>/dev/null; then
                  deny "Fast lane refused: '$f' fails bash -n (syntax error). Fix it, or take the full branch flow."
                fi
                ;;
            esac
          done <<< "$lane_paths"
        fi
        : # all paths are docs/tooling — commit on '$current_branch' allowed
      else
        deny "Commits on '$current_branch' are blocked (long-lived branch). Create a branch first: $(printf '%s' "$BRANCH_TYPES" | sed -E 's/ +/\/<slug>, /g')/<slug>. Then commit there and merge in. (Docs/tooling-only commits take the fast lane and may commit here directly.)"
      fi
    fi

    if [ "$ENFORCE_CONVENTIONAL" = "1" ]; then
      local msg
      msg=$(printf '%s' "$cmd" | sed -nE "s/.*-m[[:space:]]+['\"]([^'\"]+).*/\1/p" | head -1)
      if [ -n "$msg" ] && ! printf '%s' "$msg" | grep -Eq '^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\(.+\))?!?: .+'; then
        deny "Commit message is not Conventional Commits format (type: subject). Got: $msg"
      fi
    fi
  fi

  # --- Rule 2: validate names of newly created branches ---------------------
  local new_branch=""
  if printf '%s' "$cmd" | grep -Eq '(^|[[:space:]])git[[:space:]]+switch[[:space:]]+(-c|-C)([[:space:]]|$)'; then
    new_branch="$(printf '%s' "$cmd" | sed -nE 's/.*git[[:space:]]+switch[[:space:]]+-[cC][[:space:]]+([^[:space:];&|]+).*/\1/p')"
  elif printf '%s' "$cmd" | grep -Eq '(^|[[:space:]])git[[:space:]]+checkout[[:space:]]+(-b|-B)([[:space:]]|$)'; then
    new_branch="$(printf '%s' "$cmd" | sed -nE 's/.*git[[:space:]]+checkout[[:space:]]+-[bB][[:space:]]+([^[:space:];&|]+).*/\1/p')"
  elif printf '%s' "$cmd" | grep -Eq '(^|[[:space:]])git[[:space:]]+branch[[:space:]]'; then
    new_branch="$(printf '%s' "$cmd" | sed -nE 's/.*git[[:space:]]+branch[[:space:]]+([^-][^[:space:];&|]*).*/\1/p')"
  fi

  if [ -n "$new_branch" ]; then
    if ! printf '%s' "$new_branch" | grep -Eq "$PROTECTED_BRANCHES_RE" \
       && ! printf '%s' "$new_branch" | grep -Eq "$RELEASE_VERSION_RE" \
       && ! printf '%s' "$new_branch" | grep -Eq "$BRANCH_TYPES_RE"; then
      deny "Branch '$new_branch' violates the naming convention. Use <type>/<kebab-slug> where type is one of: $(printf '%s' "$BRANCH_TYPES" | tr ' ' ', ') (e.g. feature/kit-bulk-add). No tickets, lowercase kebab-case slug."
    fi
  fi

  # --- Rule 3: brain-sync gate (opt-in, needs BRAIN_CODE_PATHS configured) --
  if [ "$BRAIN_SYNC_ENFORCE" = "1" ] && [ -n "$BRAIN_CODE_PATHS" ]; then
    case "$cmd" in
      *"git commit"*)
        local staged app_code brain
        staged=$(git -C "$repo_dir" diff --cached --name-only 2>/dev/null) || staged=""
        if [ -n "$staged" ]; then
          app_code=$(printf '%s\n' "$staged" | grep -E "$BRAIN_CODE_PATHS" || true)
          brain=$(printf '%s\n' "$staged" | grep -E '^brain/' || true)
          if [ -n "$app_code" ] && [ -z "$brain" ]; then
            case "$cmd" in
              *"[no-brain]"*) ;;
              *) deny $'Blocked: app/feature code is staged but no brain/ change is in this commit, and the message has no [no-brain] opt-out. Before committing, either sync the Project Brain (brain/04-DC-decisions.md, brain/05-ST-state.md) and stage it with the commit, or add the literal token [no-brain] to the commit message to opt out consciously.' ;;
            esac
          fi
        fi
        ;;
    esac
  fi

  return 0
}

block_dangerous_commands
git_workflow_guard_global
exit 0
