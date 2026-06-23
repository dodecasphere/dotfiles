# [OQ] Open Questions

Things I'm unsure about. When a question is resolved, move it to DC as a decision.

- Adopt Laravel Boost MCP for the owner's Laravel projects?
- Connector fix (in progress): the third-party "Claude Usage" menubar app re-exports `ANTHROPIC_API_KEY` (set in launchd while it runs), which disables the claude.ai connectors (Notion/Gmail/Calendar/Drive). Verified: quitting the app clears the key, so a fresh Claude Code launch gets connectors back. The app is a login item, so it returns each login. PENDING decision: remove it from login items + rebuild the statusline app-free (lose the 5h/weekly subscription quota gauge), vs keep the gauge and forgo connectors. Statusline usage currently comes from the app injecting the claude.ai sessionKey into `fetch-claude-usage.swift`, not from the API key.
