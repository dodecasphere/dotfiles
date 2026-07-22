#!/bin/bash
# fetch-usage.sh — refresh the Claude subscription-usage cache the statusline reads.
#
# Why this exists: claude.ai's usage endpoint sits behind Cloudflare, which
# fingerprints the TLS handshake (JA3). A plain curl is challenged with a 403
# "Just a moment…" page no matter what headers you send. macOS's Swift/URLSession
# happens to look browser-like enough to pass; nothing on a headless Linux box
# does. So we fetch with curl-impersonate, which forges a real Chrome TLS
# fingerprint. This is the ONE piece that is not zero-dependency.
#
# Auth is a claude.ai WEB SESSION cookie (sk-ant-sid0*), which can only be minted
# by an interactive browser login — there is no headless way to regenerate it.
# It lives OUTSIDE this (public) repo. See README.md for provisioning + expiry.
#
# Output: writes the cache the renderer reads, atomically. On any failure it
# writes nothing and exits non-zero, so the renderer just shows the last good
# value (or "~"). Never prints secrets.

set -u

CACHE_FILE="${CLAUDE_USAGE_CACHE:-$HOME/.claude/.statusline-usage-cache}"
CRED_FILE="${CLAUDE_STATUSLINE_CREDENTIALS:-$HOME/.config/claude-statusline/credentials}"
LOCK_DIR="${TMPDIR:-/tmp}/claude-statusline-fetch.lock"

# --- Single-flight lock ----------------------------------------------------
# Many statusline renders can fire in quick succession; only one should fetch.
# A stale lock (>60s, e.g. a killed fetch) is reclaimed.
if ! mkdir "$LOCK_DIR" 2>/dev/null; then
  if [ -d "$LOCK_DIR" ]; then
    lock_age=$(( $(date +%s) - $(stat -f %m "$LOCK_DIR" 2>/dev/null || stat -c %Y "$LOCK_DIR" 2>/dev/null || echo 0) ))
    [ "$lock_age" -lt 60 ] && exit 0
    rmdir "$LOCK_DIR" 2>/dev/null; mkdir "$LOCK_DIR" 2>/dev/null || exit 0
  else
    exit 0
  fi
fi
trap 'rmdir "$LOCK_DIR" 2>/dev/null' EXIT

# --- Credentials -----------------------------------------------------------
# SESSION_KEY + ORG_ID come from the credentials file, or the environment
# (env wins — handy for the systemd/launchd path). Never hardcoded here.
[ -f "$CRED_FILE" ] && . "$CRED_FILE"
SESSION_KEY="${CLAUDE_SESSION_KEY:-${SESSION_KEY:-}}"
ORG_ID="${CLAUDE_ORG_ID:-${ORG_ID:-}}"
if [ -z "$SESSION_KEY" ] || [ -z "$ORG_ID" ]; then
  exit 1
fi

# --- Locate a curl-impersonate command -------------------------------------
# Priority: explicit env override, then known wrapper names on PATH, then a
# conventional local install dir. The chromeNNN wrappers preset every
# impersonation flag, so we just append our request args.
#
# NOTE: the override var is STATUSLINE_CURL, deliberately NOT "CURL_IMPERSONATE"
# — that name is reserved: the curl-impersonate binary reads $CURL_IMPERSONATE
# as its impersonation TARGET, so pointing it at a file path silently disables
# impersonation and you get Cloudflare 403s.
ci_cmd=""
if [ -n "${STATUSLINE_CURL:-}" ]; then
  ci_cmd="$STATUSLINE_CURL"
else
  for c in curl_chrome116 curl_chrome110 curl_chrome104 curl-impersonate-chrome; do
    if command -v "$c" >/dev/null 2>&1; then ci_cmd="$c"; break; fi
    if [ -x "$HOME/.local/bin/curl-impersonate/$c" ]; then ci_cmd="$HOME/.local/bin/curl-impersonate/$c"; break; fi
  done
fi
[ -z "$ci_cmd" ] && exit 3   # no impersonating client available
command -v jq >/dev/null 2>&1 || exit 4

URL="https://claude.ai/api/organizations/${ORG_ID}/usage"

# --- Fetch -----------------------------------------------------------------
resp=$($ci_cmd -s -w '\n%{http_code}' \
  -H "Cookie: sessionKey=${SESSION_KEY}" \
  -H "Accept: application/json" \
  "$URL" 2>/dev/null)
http_code=$(printf '%s' "$resp" | tail -n1)
body=$(printf '%s' "$resp" | sed '$d')
[ "$http_code" = "200" ] || exit 5   # 403 => Cloudflare challenge or expired cookie

# --- Parse -----------------------------------------------------------------
# utilization is a float (e.g. 5.0); round to an int for the renderer's integer
# comparisons. resets_at is ISO with microseconds + "+00:00" offset; normalize
# to "...Z" so both GNU and BSD date parse it. seven_day is the weekly bucket.
read -r util resets w_util w_resets < <(printf '%s' "$body" | jq -r '
  [ (.five_hour.utilization // empty | round),
    (.five_hour.resets_at   // "null"),
    (.seven_day.utilization // empty | round),
    (.seven_day.resets_at   // "null")
  ] | @tsv' 2>/dev/null)

[ -z "${util:-}" ] && exit 6
norm() { printf '%s' "$1" | sed -E 's/\.[0-9]+//; s/\+00:00$/Z/'; }
resets=$(norm "$resets"); w_resets=$(norm "$w_resets")

# --- Write cache atomically ------------------------------------------------
mkdir -p "$(dirname "$CACHE_FILE")"
tmp="${CACHE_FILE}.tmp.$$"
{
  echo "UTILIZATION=${util}"
  echo "RESETS_AT=${resets}"
  echo "TIMESTAMP=$(date +%s)"
  echo "WEEKLY_UTILIZATION=${w_util}"
  echo "WEEKLY_RESETS_AT=${w_resets}"
} > "$tmp" && mv "$tmp" "$CACHE_FILE"
