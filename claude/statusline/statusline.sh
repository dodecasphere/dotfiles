#!/bin/bash
# Portable Claude Code statusline (macOS + headless Linux).
# Fully self-contained: every value comes from the JSON payload Claude Code pipes
# in on stdin — including subscription usage, which Claude Code exposes as
# `rate_limits` for Claude.ai Pro/Max sessions. No cache, no network, no cookie.

# Resolve this script's own directory so the config file is found regardless of
# where it's symlinked from (~/.claude/statusline -> Dotfiles/claude/statusline).
SL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Portable date helper. macOS ships BSD date; Linux ships GNU date; their flags
# for "format an epoch" are incompatible, so branch once here. All reset times
# arrive as epoch seconds on stdin, so only the epoch->string direction is needed.
if date --version >/dev/null 2>&1; then
  epoch_to_fmt() { date -d "@$1" +"$2" 2>/dev/null; }   # GNU date (Linux)
else
  epoch_to_fmt() { date -r "$1" +"$2" 2>/dev/null; }    # BSD date (macOS)
fi

config_file="${CLAUDE_STATUSLINE_CONFIG:-$SL_DIR/statusline-config.txt}"
if [ -f "$config_file" ]; then
  source "$config_file"
  show_model=$SHOW_MODEL
  show_effort=${SHOW_EFFORT:-1}   # default on for configs predating this key
  # Newer optional segments — all default on, tolerant of older config files.
  show_git_status=${SHOW_GIT_STATUS:-1}   # dirty count + ahead/behind on the branch
  show_cost=${SHOW_COST:-1}               # session $ cost
  show_lines=${SHOW_LINES:-1}             # +added/-removed
  show_duration=${SHOW_DURATION:-1}       # session wall-clock
  show_thinking=${SHOW_THINKING:-1}       # extended-thinking dot
  responsive=${RESPONSIVE:-1}             # collapse segments on narrow terminals
  show_dir=$SHOW_DIRECTORY
  show_branch=$SHOW_BRANCH
  show_context=$SHOW_CONTEXT
  context_as_tokens=$CONTEXT_AS_TOKENS
  show_usage=$SHOW_USAGE
  show_bar=$SHOW_PROGRESS_BAR
  show_pace_marker=$SHOW_PACE_MARKER
  show_reset=$SHOW_RESET_TIME
  use_24h=$USE_24_HOUR_TIME
  show_context_label=$SHOW_CONTEXT_LABEL
  show_usage_label=$SHOW_USAGE_LABEL
  show_reset_label=$SHOW_RESET_LABEL
  color_mode=$COLOR_MODE
  single_color=$SINGLE_COLOR
  show_profile=$SHOW_PROFILE
  profile_name="$PROFILE_NAME"
  pace_marker_step_colors=$PACE_MARKER_STEP_COLORS
  show_weekly=$SHOW_WEEKLY
  show_weekly_bar=$SHOW_WEEKLY_BAR
  show_weekly_pace_marker=$SHOW_WEEKLY_PACE_MARKER
  show_weekly_reset=$SHOW_WEEKLY_RESET_TIME
  show_weekly_label=$SHOW_WEEKLY_LABEL
  element_color_dir=$ELEMENT_COLOR_DIR
  element_color_branch=$ELEMENT_COLOR_BRANCH
  element_color_model=$ELEMENT_COLOR_MODEL
  element_color_profile=$ELEMENT_COLOR_PROFILE
  element_color_context=$ELEMENT_COLOR_CONTEXT
  element_color_separator=$ELEMENT_COLOR_SEPARATOR
  element_color_usage=$ELEMENT_COLOR_USAGE
  element_color_pace=$ELEMENT_COLOR_PACE
  element_color_weekly=$ELEMENT_COLOR_WEEKLY
else
  show_model=1
  show_effort=1
  show_git_status=1
  show_cost=1
  show_lines=1
  show_duration=1
  show_thinking=1
  responsive=1
  show_dir=1
  show_branch=1
  show_context=1
  context_as_tokens=0
  show_usage=1
  show_bar=1
  show_pace_marker=1
  show_reset=1
  use_24h=0
  show_context_label=1
  show_usage_label=1
  show_reset_label=1
  color_mode="colored"
  single_color="#00BFFF"
  show_profile=0
  profile_name=""
  pace_marker_step_colors=1
  show_weekly=0
  show_weekly_bar=1
  show_weekly_pace_marker=1
  show_weekly_reset=1
  show_weekly_label=1
  element_color_dir="#0000EE"
  element_color_branch="#00BB00"
  element_color_model="#BBBB00"
  element_color_profile="#BB00BB"
  element_color_context="#00BBBB"
  element_color_separator="#808080"
  element_color_usage=""
  element_color_pace=""
  element_color_weekly=""
fi

input=$(cat)
current_dir_path=$(echo "$input" | grep -o '"current_dir":"[^"]*"' | head -1 | sed 's/"current_dir":"//;s/"$//')
current_dir=$(basename "$current_dir_path")
model=$(echo "$input" | grep -o '"display_name":"[^"]*"' | head -1 | sed 's/"display_name":"//;s/"$//')
# Reasoning effort (low/medium/high/xhigh/max). Nested under "effort":{"level":...}
# and absent when the model has no effort parameter, so scope the match to the
# effort object rather than a bare "level" that could collide with a future field.
effort=$(echo "$input" | grep -o '"effort":[[:space:]]*{[^}]*}' | grep -o '"level":"[^"]*"' | head -1 | sed 's/.*:"//;s/"//')
# Session metrics from the cost object, plus two boolean flags. All optional —
# each is empty/absent early in a session, and every consumer below guards for it.
cost_usd=$(echo "$input" | grep -o '"total_cost_usd":[0-9.]*' | head -1 | sed 's/.*://')
lines_added=$(echo "$input" | grep -o '"total_lines_added":[0-9]*' | head -1 | sed 's/.*://')
lines_removed=$(echo "$input" | grep -o '"total_lines_removed":[0-9]*' | head -1 | sed 's/.*://')
duration_ms=$(echo "$input" | grep -o '"total_duration_ms":[0-9]*' | head -1 | sed 's/.*://')
# thinking.enabled — scope to the thinking object so "enabled" can't collide.
thinking_enabled=$(echo "$input" | grep -o '"thinking":[[:space:]]*{[^}]*}' | grep -o '"enabled":[a-z]*' | head -1 | sed 's/.*://')

# Subscription usage — Claude Code provides this directly on stdin under
# "rate_limits" for Claude.ai Pro/Max sessions, after the first API response.
# Each window (five_hour, seven_day) may be independently absent (empty early in
# a session, or on non-subscription auth); every consumer below guards for that.
# Scope the extraction to each window's own object so used_percentage/resets_at
# can't cross-match. used_percentage is 0-100 (may be fractional — round for the
# integer comparisons downstream); resets_at is Unix epoch seconds.
rl_five=$(echo "$input" | grep -o '"five_hour":[[:space:]]*{[^}]*}' | head -1)
rl_week=$(echo "$input" | grep -o '"seven_day":[[:space:]]*{[^}]*}' | head -1)
usage_util=$(echo "$rl_five" | grep -o '"used_percentage":[0-9.]*' | head -1 | sed 's/.*://')
usage_reset=$(echo "$rl_five" | grep -o '"resets_at":[0-9]*' | head -1 | sed 's/.*://')
weekly_util=$(echo "$rl_week" | grep -o '"used_percentage":[0-9.]*' | head -1 | sed 's/.*://')
weekly_reset=$(echo "$rl_week" | grep -o '"resets_at":[0-9]*' | head -1 | sed 's/.*://')
[ -n "$usage_util" ]  && usage_util=$(awk "BEGIN{printf \"%d\", $usage_util + 0.5}")
[ -n "$weekly_util" ] && weekly_util=$(awk "BEGIN{printf \"%d\", $weekly_util + 0.5}")

# Identity resolution (all git-derived, so it is stable across cd and worktrees):
#   project_name  — the main repo name, ALWAYS shown, unchanged by subdir/worktree
#   subdir_suffix — path within the tree when you cd below the root (purple accent)
#   worktree_name — set only inside a LINKED worktree (magenta section, own icon)
# Git commands run in the process cwd, which Claude Code sets to workspace.current_dir
# (same place the branch lookup below already relies on). Non-git dirs fall back to
# the plain current-dir basename with no suffix and no worktree.
project_name=""
subdir_suffix=""
worktree_name=""
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  common_dir=$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)
  this_git_dir=$(git rev-parse --path-format=absolute --git-dir 2>/dev/null)
  project_name=$(basename "$(dirname "$common_dir")")
  subdir_suffix=$(git rev-parse --show-prefix 2>/dev/null)
  subdir_suffix=${subdir_suffix%/}   # strip trailing slash
  # In a linked worktree, --git-dir points at .git/worktrees/<name> while
  # --git-common-dir points at the main .git; equal means we are in the main tree.
  if [ -n "$this_git_dir" ] && [ "$this_git_dir" != "$common_dir" ]; then
    worktree_name=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)")
  fi
else
  project_name="$current_dir"
fi

# Function to convert hex color to ANSI escape code
hex_to_ansi() {
  local hex=$1
  hex=${hex#\#}

  local r=$((16#${hex:0:2}))
  local g=$((16#${hex:2:2}))
  local b=$((16#${hex:4:2}))

  printf '\033[38;2;%d;%d;%dm' "$r" "$g" "$b"
}

# Set colors based on mode
RESET=$'\033[0m'

if [ "$color_mode" = "monochrome" ]; then
  # Monochrome mode - no colors
  BLUE=""
  GREEN=""
  GRAY=""
  YELLOW=""
  CYAN=""
  MAGENTA=""
  LEVEL_1=""
  LEVEL_2=""
  LEVEL_3=""
  LEVEL_4=""
  LEVEL_5=""
  LEVEL_6=""
  LEVEL_7=""
  LEVEL_8=""
  LEVEL_9=""
  LEVEL_10=""
  PACE_COMFORTABLE=""
  PACE_ON_TRACK=""
  PACE_WARMING=""
  PACE_PRESSING=""
  PACE_CRITICAL=""
  PACE_RUNAWAY=""
elif [ "$color_mode" = "singleColor" ]; then
  # Single color mode - use user's chosen color for everything
  single_ansi=$(hex_to_ansi "$single_color")
  BLUE=$single_ansi
  GREEN=$single_ansi
  GRAY=$single_ansi
  YELLOW=$single_ansi
  CYAN=$single_ansi
  MAGENTA=$single_ansi
  LEVEL_1=$single_ansi
  LEVEL_2=$single_ansi
  LEVEL_3=$single_ansi
  LEVEL_4=$single_ansi
  LEVEL_5=$single_ansi
  LEVEL_6=$single_ansi
  LEVEL_7=$single_ansi
  LEVEL_8=$single_ansi
  LEVEL_9=$single_ansi
  LEVEL_10=$single_ansi
  PACE_COMFORTABLE=$single_ansi
  PACE_ON_TRACK=$single_ansi
  PACE_WARMING=$single_ansi
  PACE_PRESSING=$single_ansi
  PACE_CRITICAL=$single_ansi
  PACE_RUNAWAY=$single_ansi
elif [ "$color_mode" = "perElement" ]; then
  # Per-element mode - each element uses its own user-defined color
  BLUE=$(hex_to_ansi "$element_color_dir")
  GREEN=$(hex_to_ansi "$element_color_branch")
  YELLOW=$(hex_to_ansi "$element_color_model")
  MAGENTA=$(hex_to_ansi "$element_color_profile")
  CYAN=$(hex_to_ansi "$element_color_context")
  GRAY=$(hex_to_ansi "$element_color_separator")

  # Usage gradient: override all levels if a base color is set, else use standard gradient
  if [ -n "$element_color_usage" ]; then
    usage_override=$(hex_to_ansi "$element_color_usage")
    LEVEL_1=$usage_override
    LEVEL_2=$usage_override
    LEVEL_3=$usage_override
    LEVEL_4=$usage_override
    LEVEL_5=$usage_override
    LEVEL_6=$usage_override
    LEVEL_7=$usage_override
    LEVEL_8=$usage_override
    LEVEL_9=$usage_override
    LEVEL_10=$usage_override
  else
    LEVEL_1=$'\033[38;5;22m'
    LEVEL_2=$'\033[38;5;28m'
    LEVEL_3=$'\033[38;5;34m'
    LEVEL_4=$'\033[38;5;100m'
    LEVEL_5=$'\033[38;5;142m'
    LEVEL_6=$'\033[38;5;178m'
    LEVEL_7=$'\033[38;5;172m'
    LEVEL_8=$'\033[38;5;166m'
    LEVEL_9=$'\033[38;5;160m'
    LEVEL_10=$'\033[38;5;124m'
  fi

  # Pace colors: override all tiers if a base color is set, else use standard 6-tier
  if [ -n "$element_color_pace" ]; then
    pace_override=$(hex_to_ansi "$element_color_pace")
    PACE_COMFORTABLE=$pace_override
    PACE_ON_TRACK=$pace_override
    PACE_WARMING=$pace_override
    PACE_PRESSING=$pace_override
    PACE_CRITICAL=$pace_override
    PACE_RUNAWAY=$pace_override
  else
    PACE_COMFORTABLE=$'\033[38;5;34m'
    PACE_ON_TRACK=$'\033[38;5;37m'
    PACE_WARMING=$'\033[38;5;178m'
    PACE_PRESSING=$'\033[38;5;208m'
    PACE_CRITICAL=$'\033[38;5;160m'
    PACE_RUNAWAY=$'\033[38;5;135m'
  fi
else
  # Colored mode (default) - use full color palette
  BLUE=$'\033[0;34m'
  GREEN=$'\033[0;32m'
  GRAY=$'\033[0;90m'
  YELLOW=$'\033[0;33m'
  CYAN=$'\033[0;36m'
  MAGENTA=$'\033[0;35m'

  # 10-level gradient: dark green → deep red
  LEVEL_1=$'\033[38;5;22m'   # dark green
  LEVEL_2=$'\033[38;5;28m'   # soft green
  LEVEL_3=$'\033[38;5;34m'   # medium green
  LEVEL_4=$'\033[38;5;100m'  # green-yellowish dark
  LEVEL_5=$'\033[38;5;142m'  # olive/yellow-green dark
  LEVEL_6=$'\033[38;5;178m'  # muted yellow
  LEVEL_7=$'\033[38;5;172m'  # muted yellow-orange
  LEVEL_8=$'\033[38;5;166m'  # darker orange
  LEVEL_9=$'\033[38;5;160m'  # dark red
  LEVEL_10=$'\033[38;5;124m' # deep red

  # 6-tier pace marker colors
  PACE_COMFORTABLE=$'\033[38;5;34m'  # green
  PACE_ON_TRACK=$'\033[38;5;37m'     # teal
  PACE_WARMING=$'\033[38;5;178m'     # yellow
  PACE_PRESSING=$'\033[38;5;208m'    # orange
  PACE_CRITICAL=$'\033[38;5;160m'    # red
  PACE_RUNAWAY=$'\033[38;5;135m'     # purple
fi

# When pace step colors enabled, use real 6-tier colors (but not in monochrome mode)
if [ "$pace_marker_step_colors" != "0" ] && [ "$color_mode" != "monochrome" ]; then
  PACE_COMFORTABLE=$'\033[38;5;34m'
  PACE_ON_TRACK=$'\033[38;5;37m'
  PACE_WARMING=$'\033[38;5;178m'
  PACE_PRESSING=$'\033[38;5;208m'
  PACE_CRITICAL=$'\033[38;5;160m'
  PACE_RUNAWAY=$'\033[38;5;135m'
fi

# Purple accent for the subdirectory suffix (distinct from the worktree MAGENTA).
# Honors the same color modes as everything else.
case "$color_mode" in
  monochrome)  PURPLE="" ;;
  singleColor) PURPLE="$MAGENTA" ;;   # single-color mode already collapsed MAGENTA to the chosen color
  *)           PURPLE=$'\033[38;5;141m' ;;
esac

# Responsive collapse. Claude Code exports COLUMNS to the width available to the
# statusline. Two tiers: below 90 cols we drop the secondary line-2 metrics
# (cost/lines/duration) and the branch's ahead-behind; below 65 we also strip the
# heavy visuals by reusing the existing toggles (bars, pace markers, reset times,
# and the whole weekly segment). sl_compact gates the new secondary segments.
sl_compact=0
cols=${COLUMNS:-999}
case "$cols" in ''|*[!0-9]*) cols=999 ;; esac
if [ "$responsive" = "1" ]; then
  if [ "$cols" -lt 65 ]; then
    show_bar=0; show_pace_marker=0; show_reset=0; show_weekly=0
    sl_compact=1
  elif [ "$cols" -lt 90 ]; then
    sl_compact=1
  fi
fi

# Format a millisecond duration as a compact human string (12s / 45m / 1h23m).
fmt_dur() {
  local s=$(( ${1:-0} / 1000 ))
  if   [ "$s" -lt 60 ];   then printf '%ds' "$s"
  elif [ "$s" -lt 3600 ]; then printf '%dm' "$((s / 60))"
  else printf '%dh%dm' "$((s / 3600))" "$(((s % 3600) / 60))"
  fi
}

# Build components (without separators)
# Directory: project name (always, blue) + optional purple "/subdir" suffix.
dir_text=""
if [ "$show_dir" = "1" ] && [ -n "$project_name" ]; then
  dir_text="${BLUE}${project_name}${RESET}"
  [ -n "$subdir_suffix" ] && dir_text="${dir_text}${PURPLE}/${subdir_suffix}${RESET}"
fi

# Worktree: only inside a linked worktree. Magenta, tree/fork icon on the left.
worktree_text=""
if [ -n "$worktree_name" ]; then
  worktree_text="${MAGENTA}⑂ ${worktree_name}${RESET}"
fi

branch_text=""
if [ "$show_branch" = "1" ]; then
  if git rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git branch --show-current 2>/dev/null)
    if [ -n "$branch" ]; then
      branch_text="${GREEN}⎇ ${branch}${RESET}"

      # Dirty/clean dot: green ● when the tree is clean, red ●N (N = changed
      # entries) when dirty. --porcelain is the cheap, script-stable form.
      if [ "$show_git_status" = "1" ]; then
        dirty_count=$(git status --porcelain 2>/dev/null | grep -c '^')
        if [ "${dirty_count:-0}" -gt 0 ]; then
          branch_text="${branch_text} ${LEVEL_9}●${dirty_count}${RESET}"
        else
          branch_text="${branch_text} ${GREEN}●${RESET}"
        fi

        # Ahead/behind upstream (↑ahead ↓behind). Skipped when narrow, or when the
        # branch has no upstream (rev-list fails and both stay empty).
        if [ "$sl_compact" = "0" ]; then
          ab=$(git rev-list --left-right --count '@{upstream}...HEAD' 2>/dev/null)
          if [ -n "$ab" ]; then
            behind=$(printf '%s' "$ab" | awk '{print $1}')
            ahead=$(printf '%s' "$ab" | awk '{print $2}')
            [ "${ahead:-0}" -gt 0 ] && branch_text="${branch_text} ${GRAY}↑${ahead}${RESET}"
            [ "${behind:-0}" -gt 0 ] && branch_text="${branch_text} ${GRAY}↓${behind}${RESET}"
          fi
        fi
      fi
    fi
  fi
fi

model_text=""
if [ "$show_model" = "1" ] && [ -n "$model" ]; then
  model_text="${YELLOW}${model}${RESET}"
  # Reasoning effort sits directly to the right of the model as a sub-label (not
  # its own bulleted section). Colored to mirror Claude Code's /effort palette:
  # low=gold, medium=green, high=blue, xhigh=purple, max=coral (ultracode reports
  # as xhigh). Honors monochrome/single-color modes like every other color.
  if [ "$show_effort" = "1" ] && [ -n "$effort" ]; then
    effort_color="$GRAY"
    if [ "$color_mode" = "singleColor" ]; then
      effort_color="$MAGENTA"
    elif [ "$color_mode" != "monochrome" ]; then
      case "$effort" in
        low)    effort_color=$'\033[38;5;220m' ;;  # gold
        medium) effort_color=$'\033[38;5;41m'  ;;  # green
        high)   effort_color=$'\033[38;5;75m'  ;;  # periwinkle blue
        xhigh)  effort_color=$'\033[38;5;99m'  ;;  # violet
        max)    effort_color=$'\033[38;5;209m' ;;  # coral
      esac
    fi
    model_text="${model_text} ${effort_color}${effort}${RESET}"
  fi
  # Extended-thinking indicator: a small dot when thinking is enabled this session.
  if [ "$show_thinking" = "1" ] && [ "$thinking_enabled" = "true" ]; then
    model_text="${model_text} ${CYAN}✳${RESET}"
  fi
fi

profile_text=""
if [ "$show_profile" = "1" ] && [ -n "$profile_name" ]; then
  profile_text="${MAGENTA}${profile_name}${RESET}"
fi

# Context percentage calculation from current_usage tokens
context_text=""
if [ "$show_context" = "1" ]; then
  input_tokens=$(echo "$input" | grep -o '"input_tokens":[0-9]*' | head -1 | sed 's/"input_tokens"://')
  cache_create=$(echo "$input" | grep -o '"cache_creation_input_tokens":[0-9]*' | sed 's/"cache_creation_input_tokens"://')
  cache_read=$(echo "$input" | grep -o '"cache_read_input_tokens":[0-9]*' | sed 's/"cache_read_input_tokens"://')
  context_size=$(echo "$input" | grep -o '"context_window_size":[0-9]*' | sed 's/"context_window_size"://')

  [ -z "$input_tokens" ] && input_tokens=0
  [ -z "$cache_create" ] && cache_create=0
  [ -z "$cache_read" ] && cache_read=0

  if [ -n "$context_size" ] && [ "$context_size" -gt 0 ]; then
    current_tokens=$((input_tokens + cache_create + cache_read))
    context_pct=$((current_tokens * 100 / context_size))

    # Determine color based on percentage
    if [ "$context_pct" -le 50 ]; then
      context_color="$CYAN"
    elif [ "$context_pct" -le 75 ]; then
      context_color="$YELLOW"
    else
      context_color="$LEVEL_9"
    fi

    # Integer percentage for display
    context_int=$context_pct

    # Display as tokens or percentage
    ctx_label=""
    [ "$show_context_label" = "1" ] && ctx_label="Ctx: "

    if [ "$context_as_tokens" = "1" ]; then
      if [ "$current_tokens" -ge 1000 ]; then
        tokens_k=$((current_tokens / 1000))
        context_text="${context_color}${ctx_label}${tokens_k}K${RESET}"
      else
        context_text="${context_color}${ctx_label}${current_tokens}${RESET}"
      fi
    else
      context_text="${context_color}${ctx_label}${context_int}%${RESET}"
    fi
  fi
fi

usage_text=""
if [ "$show_usage" = "1" ]; then
  # utilization + reset come straight from stdin's rate_limits.five_hour (parsed
  # near the top). resets_at is already epoch seconds, so no ISO conversion.
  if [ -n "$usage_util" ]; then
    utilization=$usage_util
    reset_epoch=""
    [ -n "$usage_reset" ] && [ "$usage_reset" != "null" ] && reset_epoch=$usage_reset

    if [ -n "$utilization" ]; then
      if [ "$utilization" -le 10 ]; then
        usage_color="$LEVEL_1"
      elif [ "$utilization" -le 20 ]; then
        usage_color="$LEVEL_2"
      elif [ "$utilization" -le 30 ]; then
        usage_color="$LEVEL_3"
      elif [ "$utilization" -le 40 ]; then
        usage_color="$LEVEL_4"
      elif [ "$utilization" -le 50 ]; then
        usage_color="$LEVEL_5"
      elif [ "$utilization" -le 60 ]; then
        usage_color="$LEVEL_6"
      elif [ "$utilization" -le 70 ]; then
        usage_color="$LEVEL_7"
      elif [ "$utilization" -le 80 ]; then
        usage_color="$LEVEL_8"
      elif [ "$utilization" -le 90 ]; then
        usage_color="$LEVEL_9"
      else
        usage_color="$LEVEL_10"
      fi

      if [ "$show_bar" = "1" ]; then
        if [ "$utilization" -eq 0 ]; then
          filled_blocks=0
        elif [ "$utilization" -eq 100 ]; then
          filled_blocks=10
        else
          filled_blocks=$(( (utilization * 10 + 50) / 100 ))
        fi
        [ "$filled_blocks" -lt 0 ] && filled_blocks=0
        [ "$filled_blocks" -gt 10 ] && filled_blocks=10
        empty_blocks=$((10 - filled_blocks))

        # Build progress bar safely without seq
        progress_bar=" "
        i=0
        while [ $i -lt $filled_blocks ]; do
          progress_bar="${progress_bar}▓"
          i=$((i + 1))
        done
        i=0
        while [ $i -lt $empty_blocks ]; do
          progress_bar="${progress_bar}░"
          i=$((i + 1))
        done
      else
        progress_bar=""
      fi

      # Pace marker: insert colored │ at elapsed time position
      if [ "$show_pace_marker" = "1" ] && [ "$show_bar" = "1" ] && [ -n "$reset_epoch" ]; then
        now_epoch=$(date +%s)
        remaining=$((reset_epoch - now_epoch))
        if [ $remaining -gt 0 ] && [ $remaining -lt 18000 ]; then
          elapsed_secs=$((18000 - remaining))
          marker_pos=$(( (elapsed_secs * 10 + 9000) / 18000 ))
          [ $marker_pos -gt 9 ] && marker_pos=9
          [ $marker_pos -lt 0 ] && marker_pos=0

          # Compute pace color; fall back to usage_color (empty in monochrome = no color)
          pace_color="$usage_color"
          if [ "$pace_marker_step_colors" != "0" ] && [ $elapsed_secs -ge 540 ]; then
            projected_pct=$((utilization * 18000 / elapsed_secs))
            if [ $projected_pct -lt 50 ]; then
              pace_color="$PACE_COMFORTABLE"
            elif [ $projected_pct -lt 75 ]; then
              pace_color="$PACE_ON_TRACK"
            elif [ $projected_pct -lt 90 ]; then
              pace_color="$PACE_WARMING"
            elif [ $projected_pct -lt 100 ]; then
              pace_color="$PACE_PRESSING"
            elif [ $projected_pct -lt 120 ]; then
              pace_color="$PACE_CRITICAL"
            else
              pace_color="$PACE_RUNAWAY"
            fi
          fi

          # Always insert marker (color may be empty in monochrome = terminal default)
          left="${progress_bar:0:$((marker_pos + 1))}"
          right="${progress_bar:$((marker_pos + 2))}"
          progress_bar="${left}${pace_color}┃${RESET}${usage_color}${right}"
        fi
      fi

      reset_time_display=""
      if [ "$show_reset" = "1" ] && [ -n "$reset_epoch" ]; then
        epoch=$reset_epoch

        if [ -n "$epoch" ]; then
          # Round to nearest minute to prevent pinballing (e.g., 6:59:45 -> 7:00)
          seconds_part=$((epoch % 60))
          if [ "$seconds_part" -ge 30 ]; then
            epoch=$((epoch + (60 - seconds_part)))
          else
            epoch=$((epoch - seconds_part))
          fi

          # Use user's time format preference from config
          if [ "$use_24h" = "1" ]; then
            # 24-hour format
            reset_time=$(epoch_to_fmt "$epoch" "%H:%M")
          else
            # 12-hour format (default)
            reset_time=$(epoch_to_fmt "$epoch" "%I:%M %p")
          fi
          if [ "$show_reset_label" = "1" ]; then
            [ -n "$reset_time" ] && reset_time_display=$(printf " → Reset: %s" "$reset_time")
          else
            [ -n "$reset_time" ] && reset_time_display=$(printf " → %s" "$reset_time")
          fi
        fi
      fi

      if [ "$show_usage_label" = "1" ]; then
        usage_text="${usage_color}Usage: ${utilization}%${progress_bar}${reset_time_display}${RESET}"
      else
        usage_text="${usage_color}${utilization}%${progress_bar}${reset_time_display}${RESET}"
      fi
    fi
  else
    if [ "$show_usage_label" = "1" ]; then
      usage_text="${YELLOW}Usage: ~${RESET}"
    else
      usage_text="${YELLOW}~${RESET}"
    fi
  fi
fi

weekly_text=""
if [ "$show_weekly" = "1" ] && [ "$show_usage" = "1" ]; then
  # weekly_util + weekly_reset come from stdin's rate_limits.seven_day (parsed
  # near the top). weekly_reset is epoch seconds.
  if [ -n "$weekly_util" ]; then
    if [ "$weekly_util" -le 10 ]; then
      weekly_color="$LEVEL_1"
    elif [ "$weekly_util" -le 20 ]; then
      weekly_color="$LEVEL_2"
    elif [ "$weekly_util" -le 30 ]; then
      weekly_color="$LEVEL_3"
    elif [ "$weekly_util" -le 40 ]; then
      weekly_color="$LEVEL_4"
    elif [ "$weekly_util" -le 50 ]; then
      weekly_color="$LEVEL_5"
    elif [ "$weekly_util" -le 60 ]; then
      weekly_color="$LEVEL_6"
    elif [ "$weekly_util" -le 70 ]; then
      weekly_color="$LEVEL_7"
    elif [ "$weekly_util" -le 80 ]; then
      weekly_color="$LEVEL_8"
    elif [ "$weekly_util" -le 90 ]; then
      weekly_color="$LEVEL_9"
    else
      weekly_color="$LEVEL_10"
    fi

    # Per-element override: weekly gets its own fixed color when set
    if [ "$color_mode" = "perElement" ] && [ -n "$element_color_weekly" ]; then
      weekly_color=$(hex_to_ansi "$element_color_weekly")
    fi

    if [ "$show_weekly_bar" = "1" ]; then
      if [ "$weekly_util" -eq 0 ]; then
        w_filled=0
      elif [ "$weekly_util" -eq 100 ]; then
        w_filled=10
      else
        w_filled=$(( (weekly_util * 10 + 50) / 100 ))
      fi
      [ "$w_filled" -lt 0 ] && w_filled=0
      [ "$w_filled" -gt 10 ] && w_filled=10
      w_empty=$((10 - w_filled))

      weekly_bar=" "
      i=0
      while [ $i -lt $w_filled ]; do
        weekly_bar="${weekly_bar}▓"
        i=$((i + 1))
      done
      i=0
      while [ $i -lt $w_empty ]; do
        weekly_bar="${weekly_bar}░"
        i=$((i + 1))
      done
    else
      weekly_bar=""
    fi

    if [ "$show_weekly_pace_marker" = "1" ] && [ "$show_weekly_bar" = "1" ] && [ -n "$weekly_reset" ] && [ "$weekly_reset" != "null" ]; then
      w_reset_epoch=$weekly_reset
      if [ -n "$w_reset_epoch" ]; then
        now_epoch=$(date +%s)
        w_remaining=$((w_reset_epoch - now_epoch))
        if [ $w_remaining -gt 0 ] && [ $w_remaining -lt 604800 ]; then
          w_elapsed=$((604800 - w_remaining))
          w_marker_pos=$(( (w_elapsed * 10 + 302400) / 604800 ))
          [ $w_marker_pos -gt 9 ] && w_marker_pos=9
          [ $w_marker_pos -lt 0 ] && w_marker_pos=0

          w_pace_color="$weekly_color"
          if [ "$pace_marker_step_colors" != "0" ] && [ $w_elapsed -ge 3024 ]; then
            w_projected=$((weekly_util * 604800 / w_elapsed))
            if [ $w_projected -lt 50 ]; then
              w_pace_color="$PACE_COMFORTABLE"
            elif [ $w_projected -lt 75 ]; then
              w_pace_color="$PACE_ON_TRACK"
            elif [ $w_projected -lt 90 ]; then
              w_pace_color="$PACE_WARMING"
            elif [ $w_projected -lt 100 ]; then
              w_pace_color="$PACE_PRESSING"
            elif [ $w_projected -lt 120 ]; then
              w_pace_color="$PACE_CRITICAL"
            else
              w_pace_color="$PACE_RUNAWAY"
            fi
          fi

          # Always insert marker; w_pace_color may be empty (monochrome = no color wrap)
          w_left="${weekly_bar:0:$((w_marker_pos + 1))}"
          w_right="${weekly_bar:$((w_marker_pos + 2))}"
          weekly_bar="${w_left}${w_pace_color}┃${RESET}${weekly_color}${w_right}"
        fi
      fi
    fi

    weekly_reset_display=""
    if [ "$show_weekly_reset" = "1" ] && [ -n "$weekly_reset" ] && [ "$weekly_reset" != "null" ]; then
      w_reset_epoch=$weekly_reset
      if [ -n "$w_reset_epoch" ]; then
        seconds_part=$((w_reset_epoch % 60))
        if [ "$seconds_part" -ge 30 ]; then
          w_reset_epoch=$((w_reset_epoch + (60 - seconds_part)))
        else
          w_reset_epoch=$((w_reset_epoch - seconds_part))
        fi
        if [ "$use_24h" = "1" ]; then
          w_reset_time=$(epoch_to_fmt "$w_reset_epoch" "%a %H:%M")
        else
          w_reset_time=$(epoch_to_fmt "$w_reset_epoch" "%a %I:%M %p")
        fi
        [ -n "$w_reset_time" ] && weekly_reset_display=$(printf " → %s" "$w_reset_time")
      fi
    fi

    if [ "$show_weekly_label" = "1" ]; then
      weekly_text="${weekly_color}Weekly: ${weekly_util}%${weekly_bar}${weekly_reset_display}${RESET}"
    else
      weekly_text="${weekly_color}${weekly_util}%${weekly_bar}${weekly_reset_display}${RESET}"
    fi
  fi
fi

# Secondary line-2 metrics: session cost, lines changed, wall-clock. Each is
# hidden when the terminal is narrow (sl_compact), toggled off, or the value is
# absent/zero (early in a session).
cost_text=""
if [ "$show_cost" = "1" ] && [ "$sl_compact" = "0" ] && [ -n "$cost_usd" ]; then
  case "$cost_usd" in
    0|0.0|0.00|0.000|0.0000) ;;   # skip a pure-zero cost
    *) cost_text="${GRAY}\$$(printf '%.2f' "$cost_usd")${RESET}" ;;
  esac
fi

lines_text=""
if [ "$show_lines" = "1" ] && [ "$sl_compact" = "0" ]; then
  la=${lines_added:-0}; lr=${lines_removed:-0}
  if [ "$la" -gt 0 ] || [ "$lr" -gt 0 ]; then
    lines_text="${GREEN}+${la}${RESET}${GRAY}/${RESET}${LEVEL_9}-${lr}${RESET}"
  fi
fi

duration_text=""
if [ "$show_duration" = "1" ] && [ "$sl_compact" = "0" ] && [ -n "$duration_ms" ] && [ "$duration_ms" -gt 0 ]; then
  duration_text="${GRAY}$(fmt_dur "$duration_ms")${RESET}"
fi

separator="${GRAY} • ${RESET}"

# Two lines (Claude Code renders each printed line as its own status row):
#   Line 1 — identity:  Directory(+subdir) → Worktree → Branch → Lines → Model → Duration → Profile
#   Line 2 — usage:      Context → Usage → Weekly → Cost
# add_seg appends "$2" to the line named by $1, inserting the separator only when
# the line already has content (bash 3.2 on macOS has no namerefs, so use eval).
add_seg() {
  local cur; eval "cur=\$$1"
  [ -z "$2" ] && return
  if [ -n "$cur" ]; then eval "$1=\"\$cur\${separator}\$2\""; else eval "$1=\"\$2\""; fi
}

line1=""
add_seg line1 "$dir_text"
add_seg line1 "$worktree_text"
add_seg line1 "$branch_text"
add_seg line1 "$lines_text"
add_seg line1 "$model_text"
add_seg line1 "$duration_text"
add_seg line1 "$profile_text"

line2=""
add_seg line2 "$context_text"
add_seg line2 "$usage_text"
add_seg line2 "$weekly_text"
add_seg line2 "$cost_text"

printf "%s\n" "$line1"
[ -n "$line2" ] && printf "%s\n" "$line2"