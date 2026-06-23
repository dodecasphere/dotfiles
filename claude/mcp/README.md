# MCP servers

MCP servers are stored in `~/.claude.json` (machine-local, never committed), not
in this repo's `settings.json`. Portability is handled by scope:

- **User scope** (`-s user`): secret-free, project-agnostic servers, available
  everywhere. These are re-registered on each machine by
  `provisioning/mac/claude.sh`. Currently: **playwright** (browser automation
  for the Vue/Capacitor UI, via `npx @playwright/mcp@latest`).
- **Project scope** (`-s project`): servers specific to one app, written to that
  app's `.mcp.json`. This is where a database MCP belongs, since the connection
  (and its credentials) are per-project.

## Read-only database MCP (per Laravel project)

A read-only DB MCP lets Claude introspect the schema and run safe queries so it
stops guessing column names. Add it inside the Laravel app, read-only, with the
DSN taken from the environment. Never commit a DSN that contains a password.

Use a read-only-capable server (for example `@bytebase/dbhub`, which supports
MySQL and Postgres and a `--readonly` flag; confirm the exact flags for whatever
server you pick):

```bash
# run from the Laravel project root; writes .mcp.json there
claude mcp add db -s project -- \
  npx -y @bytebase/dbhub --transport stdio --readonly --dsn "$DB_MCP_DSN"
```

The resulting `.mcp.json` should reference the DSN by env var, not inline it:

```json
{
  "mcpServers": {
    "db": {
      "command": "npx",
      "args": ["-y", "@bytebase/dbhub", "--transport", "stdio", "--readonly",
               "--dsn", "${DB_MCP_DSN}"]
    }
  }
}
```

Supply `DB_MCP_DSN` from the environment, not the file. Laravel's `.env` is not
loaded into your shell automatically, so either export it (e.g. in the project's
local `.shell.local`, gitignored) or compose it from the app's `DB_*` values.
Keep the server `--readonly` so the agent cannot mutate data.
```
mysql://USER:PASSWORD@127.0.0.1:3306/DATABASE
```

Committing `.mcp.json` with a `${DB_MCP_DSN}` placeholder is safe; committing one
with a literal password is not (the gitleaks pre-commit hook will catch the
obvious cases, but do not rely on it).
