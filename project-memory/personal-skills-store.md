---
name: personal-skills-store
description: "The private plugin store that replaced Dotfiles skills/commands, plus the verified Claude Code vs Codex plugin capability differences"
metadata: 
  node_type: memory
  type: project
  originSessionId: 1671f47e-99a7-4007-8039-a25a8b2cf199
  modified: 2026-08-26T20:01:48.289Z
---

`dodecasphere/personal-skills` (private, created 2026-08-26) is the canonical home
for the personal skill set, packaged as four plugins that install into **both**
Claude Code and OpenAI Codex: `product-discovery` (6 skills, 3 commands),
`engineering` (4 skills, 8 commands), `writing` (3 skills), `workflow` (3 skills,
3 commands). Working copy at `~/Projects/personal-skills`. One shared version
across all four, in eight manifests. Replaced `Dotfiles/claude/skills/` and
`claude/commands/` (see [[claude-config-layer]]).

**Verified capability differences (2026-08-26, read from the real official
marketplaces on disk, not docs):**

- Both clients use the identical `skills/<name>/SKILL.md` layout, so one tree
  serves both. Claude Code manifest is `.claude-plugin/plugin.json` (version
  optional); Codex is `.codex-plugin/plugin.json` (version required, and it needs
  an `interface` block). Catalogs are `.claude-plugin/marketplace.json` and
  `.agents/plugins/marketplace.json`.
- **Codex cannot run hooks.** Zero of 180 official Codex plugins ship a `hooks/`
  dir. Hooks and agents therefore stay in Dotfiles permanently.
- Codex rejects `policy.authentication: "NONE"`; only `ON_INSTALL` or `ON_USE`
  are valid. Omit the field for credential-free plugins.
- **Claude Code clones over SSH, Codex over HTTPS.** A machine needs both an
  authorized SSH key and gh/HTTPS creds or one client fails.
- Neither auto-upgrades an installed plugin by default. Claude Code auto-refreshes
  *marketplace catalogs* only, and only for marketplaces with auto-update enabled
  (on by default for official, **off by default for custom** ones; toggle is
  TUI-only via `/plugin` → Marketplaces). Refreshing the cache never bumps an
  installed plugin: proven with a 1.0.1 probe where the cache moved but all four
  installs stayed at 1.0.0 until `claude plugin update <plugin>` was run on each.
  `codex plugin marketplace upgrade` does move installed versions, in one command.
- `claude plugin update` syncs to the marketplace rather than strictly upgrading;
  it downgrades cleanly too.

**Open question, do not assume resolved:** `skillOverrides` in `settings.json`
appears not to suppress a plugin skill at all. Neither the bare name nor the
namespaced `plugin:skill` key had any effect, so the six skills deliberately set
to "off" came back on the moment the plugins loaded. `disable-model-invocation:
true` in the skill's own frontmatter is the documented mechanism and is now set on
all six, but its effect could not be confirmed: `claude plugin details` still
bills them as always-on and a headless probe gave contradictory answers. Re-check
after a full app restart before trusting either lever.

**Useful:** `claude plugin marketplace add` writes `extraKnownMarketplaces` and
`enabledPlugins` into `settings.json`, which Dotfiles version-controls, so a fresh
machine self-installs the Claude Code side with no manual step. Codex config lives
in unmanaged `~/.codex/config.toml` and still needs two commands by hand.
