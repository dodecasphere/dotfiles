#!/usr/bin/env bash
# Mirror Claude Code state onto "crabby", the ESP32 desk display
# (firmware in ~/Projects/desk-gadgets/devices/crabby). Fire and forget: returns immediately and
# never blocks or fails Claude, even when the board is off or out of range.
# Override the target with CRABBY_HOST (default crabby.local).
#
#   crabby.sh          hook mode: stdin is a hook payload  -> POST /event
#   crabby.sh status   statusline mode: stdin is the statusline payload -> POST /status
#                            (only when it changed, or every 10s, since the statusline runs every second)

host="http://${CRABBY_HOST:-crabby.local}"
send() {
  # -4: macOS stalls ~5s on the AAAA lookup for .local names the board doesn't answer.
  curl -4 -s --max-time 2 -d "$2" "$host/$1" >/dev/null 2>&1 &
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
  send status "$form&now=$now"
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
