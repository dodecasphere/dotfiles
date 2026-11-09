#!/usr/bin/env bash

#
# Saved Herdr SSH machines (the sidebar's remote machines). Herdr keeps them in
# ~/.local/state/herdr/client/endpoints.json, which is machine-local state, so
# this list is the source of truth. `herdr machine add` also prepares the remote
# Herdr server, so it needs SSH access (run after ssh.sh). Idempotent: a target
# already saved is skipped. To add one, append a "label|target" line below.
#

HERDR_MACHINES=(
  "Agent VPS|michael@dulle"
  "Crestlite|forge@178.156.194.174"
  "Crestlite Legacy|forge@159.65.236.104"
  "Hosted Tools|forge@159.65.225.238"
  "Smart Mirror|forge@159.203.182.250"
  "DulleCo|forge@67.205.154.110"
)

if ! command -v herdr &>/dev/null; then
  echo "herdr not installed — skipping saved machines"
else
  for entry in "${HERDR_MACHINES[@]}"; do
    label="${entry%%|*}"
    target="${entry#*|}"
    doing "Herdr machine [$label]..."
    # list columns (tab-separated): id, label, target, session, enabled
    if herdr machine list 2>/dev/null | awk -F'\t' -v t="$target" '$3 == t { found = 1 } END { exit !found }'; then
      echo "$label already saved — skipping"
    else
      herdr machine add --label "$label" --remote-session default "$target" \
        || echo "Could not add $label ($target), re-run provision or: herdr machine add --label \"$label\" $target"
    fi
  done
fi

# Same machines for the Herdr desktop app, whose core (hc) keeps its own list.
# hc names allow only a-z 0-9 - _ . so the label is lowercased and spaces
# become dashes ("Agent VPS" -> agent-vps). A target already added is skipped.
if ! command -v hc &>/dev/null; then
  echo "hc (herdr-core) not installed — skipping desktop app machines"
else
  for entry in "${HERDR_MACHINES[@]}"; do
    label="${entry%%|*}"
    target="${entry#*|}"
    name="$(echo "$label" | tr 'A-Z ' 'a-z-')"
    doing "Herdr app machine [$name]..."
    if hc machine ls --json 2>/dev/null | grep -q "\"target\":\"$target\""; then
      echo "$name already added — skipping"
    else
      hc machine add --install --name "$name" "$target" \
        || echo "Could not add $name ($target), re-run provision or: hc machine add --name $name $target"
    fi
  done
fi
