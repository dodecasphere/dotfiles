# [OQ] Open Questions

Things I'm unsure about. When a question is resolved, move it to DC as a decision.

- Adopt Laravel Boost MCP for the owner's Laravel projects?
- Make the statusline usage gauge app-independent? It still depends on the Claude Usage app (cache file + the live `sk-ant-sid02` sessionKey baked into the untracked `fetch-claude-usage.swift`). That cookie expires with nothing to refresh it if the app is ever removed. Not urgent (app is in use); open if/when the app is dropped.
- (resolved 2026-06-23 -> DC) The "Claude Usage app disables connectors via ANTHROPIC_API_KEY" question: investigation could not reproduce the key inject; earlier diagnosis was overstated, no active problem, no config change. See DC.
