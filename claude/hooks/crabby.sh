#!/usr/bin/env bash
# Mirror Claude Code state onto "crabby", the ESP32 desk display
# (firmware in ~/Projects/desk-gadgets/devices/crabby). Fire and forget: returns immediately and
# never blocks or fails Claude, even when the board is off or out of range.
# It goes to every board on this network: each one announces itself as a _crabby._tcp service, whatever it
# is named, so nothing needs setting when a board is renamed or the Mac moves to another network.
# CRABBY_HOST (one or more names, space separated) skips the search and names the boards outright.
#
#   crabby.sh          hook mode: stdin is a hook payload  -> POST /event
#   crabby.sh status   statusline mode: stdin is the statusline payload -> POST /status
#                            (only when it changed, or every 10s, since the statusline runs every second)

# The boards found last time. Searching takes a couple of seconds, so it happens in the background, at most
# once a minute, and this run uses the list as it stands (crabby.local until the first search has landed).
found="${TMPDIR:-/tmp}/crabby-hosts"
hosts="${CRABBY_HOST:-$(cat "$found" 2>/dev/null)}"
discover() {
  [[ -z "${CRABBY_HOST:-}" ]] && command -v dns-sd >/dev/null || return 0
  [[ -f "$found.at" ]] && (( $(date +%s) - $(date -r "$found.at" +%s) < 60 )) && return 0
  touch "$found.at"  # before the search, so the runs of the next seconds do not start their own
  (
    dns-sd -B _crabby._tcp local. > "$found.raw" 2>/dev/null &
    pid=$!
    sleep 2
    kill "$pid" 2>/dev/null
    awk '$2 == "Add" { print $NF ".local" }' "$found.raw" | sort -u | tr '\n' ' ' > "$found.new"
    mv "$found.new" "$found"
    rm -f "$found.raw"
  ) >/dev/null 2>&1 &
}
send() {
  discover
  local h
  for h in ${hosts:-crabby.local}; do
    # -4: macOS stalls ~5s on the AAAA lookup for .local names the board doesn't answer.
    curl -4 -s --max-time 2 -d "$2" "http://$h/$1" >/dev/null 2>&1 &
  done
}

if [[ "${1:-}" == status ]]; then
  form=$(jq -r '
    def n: if . == null then "" else tostring end;
    "session=\(.session_id | @uri)&title=\((.session_name // ((.cwd // "") | split("/") | last)) | @uri)" +
    "&u5=\(.rate_limits.five_hour.used_percentage | n)&r5=\(.rate_limits.five_hour.resets_at | n)" +
    "&u7=\(.rate_limits.seven_day.used_percentage | n)&r7=\(.rate_limits.seven_day.resets_at | n)"
  ' 2>/dev/null) || exit 0
  [[ -n "$form" ]] || exit 0
  now=$(date +%s)
  cache="${TMPDIR:-/tmp}/crabby-$(printf '%s' "$form" | sed 's/&.*//; s/[^A-Za-z0-9-]//g')"
  if [[ -f "$cache" && "$(cat "$cache")" == "$form" ]] && (( now - $(date -r "$cache" +%s) < 10 )); then
    exit 0
  fi
  printf '%s' "$form" > "$cache"
  # Org name of the logged-in account, so the board can say whose usage it shows. Read only when
  # sending: .claude.json is large and the statusline runs every second.
  acct=$(jq -r '.oauthAccount.organizationName // "" | @uri' "${CLAUDE_CONFIG_DIR:-$HOME}/.claude.json" 2>/dev/null)
  send status "$form&now=$now&acct=$acct"
  exit 0
fi

form=$(jq -r '
  (.hook_event_name // "") as $e | (.tool_name // "") as $t |
  (if   $e == "Stop"       then "done"
   elif $e == "SessionEnd" then "end"
   elif $e == "Notification" then
     (if (.notification_type // "") == "permission_prompt" or ((.message // "") | test("permission"; "i"))
      then "needs_you" else empty end)
   elif $e == "PreToolUse" and ($t | test("^(AskUserQuestion|ExitPlanMode)$")) then "needs_you"
   else "working" end) as $s |
  "session=\(.session_id | @uri)&state=\($s)&tool=\($t | @uri)&name=\((.cwd // "") | split("/") | last | @uri)"
' 2>/dev/null) || exit 0
[[ -n "$form" ]] || exit 0

send event "$form&ts=$(perl -MTime::HiRes=time -e 'printf "%d", time * 1000')"
exit 0
