#!/usr/bin/env bash
#
# PreToolUse(Bash) hook: block a small, conservative set of irreversible
# commands. The policy is "suggest, don't execute" — Claude should propose
# these and let the human run them.
#
# Exit 2 = block the command (stderr is shown to Claude). Exit 0 = allow.
# Kept deliberately narrow to avoid false positives that break flow.
#
input=$(cat)

# Extract the command string. Prefer jq; fall back to the raw JSON (the
# dangerous substrings we match appear literally either way).
if command -v jq >/dev/null 2>&1; then
  cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty')
else
  cmd=$input
fi

block() {
  echo "BLOCKED by block-dangerous-commands hook: $1" >&2
  echo "This is irreversible — suggest the exact command and let the user run it." >&2
  exit 2
}

# Only match a dangerous command when it appears in command position: at the
# start of the string or right after a separator (; & | ( && ||). This avoids
# false positives when the words appear as arguments or inside quotes (e.g. a
# commit message or echo that mentions "terraform apply").
CMDPOS='(^|[;&|(]|&&|\|\|)[[:space:]]*'

# Force pushes (rewrite remote history)
if printf '%s' "$cmd" | grep -Eq "$CMDPOS"'git[[:space:]]+push' \
   && printf '%s' "$cmd" | grep -Eq '(--force|[[:space:]]-f([[:space:]]|$))'; then
  block "git force-push"
fi

# Catastrophic recursive deletes of root / home (allows deleting normal paths)
if printf '%s' "$cmd" | grep -Eq "$CMDPOS"'rm[[:space:]]+-[a-zA-Z]*r[a-zA-Z]*[[:space:]]+(/|~|\$HOME)([[:space:]/;|*]|$)'; then
  block "rm -r of a root/home path"
fi

# Terraform state changes (Marco Lancini's rule: apply/destroy are yours, not the agent's)
if printf '%s' "$cmd" | grep -Eq "$CMDPOS"'terraform[[:space:]]+(apply|destroy)'; then
  block "terraform apply/destroy"
fi

exit 0
