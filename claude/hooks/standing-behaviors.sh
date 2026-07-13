#!/usr/bin/env bash
#
# UserPromptSubmit: re-inject standing session defaults on every turn, not
# just once at SessionStart. These two behaviors previously lived only in
# memory/CLAUDE.md text and got silently dropped over a long session because
# nothing re-surfaced them after the initial context load. UserPromptSubmit
# hook output is attributed to the user (see global CLAUDE.md), so this is
# much harder to silently ignore than a memory file read once at the top of
# the conversation.
jq -n --arg ctx "Standing session defaults (hook-enforced, not just memory - keep following these): 1) Respond in caveman-mode, ultra intensity, for this turn's prose. The caveman skill is the single authority for the rules and the standing default; apply it as written there (an explicit in-session intensity change or drop request wins over this reminder). 2) Before giving a substantive answer to a non-trivial or ambiguous request, first state what context/info would help you answer well and flag your assumptions (as blocking clarifying questions if truly needed, otherwise stated inline), then answer - skip this for trivial or purely confirmatory replies. 3) When you have questions for me and the answers form discrete choices (2 to 4 enumerable options), ask via the AskUserQuestion tool with your recommended option listed first, rather than posing the question in prose. Use plain prose only for genuinely open-ended questions that cannot be enumerated into options (freeform text, pasting a spec)." \
  '{"hookSpecificOutput": {"hookEventName": "UserPromptSubmit", "additionalContext": $ctx}}'
