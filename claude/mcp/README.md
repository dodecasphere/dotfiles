# MCP servers

MCP servers are stored in `~/.claude.json` (machine-local, never committed), not
in this repo's `settings.json`. Portability is handled by scope:

- **User scope** (`-s user`): secret-free, project-agnostic servers, available
  everywhere. These are re-registered on each machine by
  `provisioning/mac/claude.sh`. Currently: **playwright** (browser automation
  for the Vue/Capacitor UI, via `npx @playwright/mcp@latest`).
- **Project scope** (`-s project`): servers specific to one app, written to that
  app's `.mcp.json`. This is where a database MCP would belong, since the
  connection (and its credentials) are per-project. No project currently uses
  one; design it per-project when first needed (removed convention doc:
  EOS IDEA-013 stage 1, restorable via git history).
