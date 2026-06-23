# [DC] Decisions

A log of choices made and why. Newest at the top. Never edit old entries.

## 2026-06-23: Refreshed CLAUDE.md to document the `claude/` config layer
**Context:** The project CLAUDE.md predated this repo becoming a Claude Code config repo; an audit scored it B (76) with currency as the weak point.
**Choice:** Added a "Claude Code config layer (`claude/`)" section (the 83-file subtree, how `install.sh` symlinks it individually into `~/.claude`, and the auto-loaded `brain/`), added `test.sh` to the scripts table (retitled from "Three-script workflow"), and stripped all em-dashes per the global no-dash-in-docs rule. Committed in 2438a0d.
**Why:** The largest, most active part of the repo was entirely undocumented, so a session editing agents/hooks/skills got no grounding from CLAUDE.md.
**Alternatives considered:** Also tightening the `~/.provisioning` sentence (skipped as accurate enough).

## 2026-06-23: "Claude Usage app exports ANTHROPIC_API_KEY" was overstated; no active connector problem
**Context:** Earlier this session (and the prior OQ entry) claimed the "Claude Usage" menubar app actively re-exports `ANTHROPIC_API_KEY` into launchd whenever it runs, disabling the claude.ai connectors. We tried to reproduce and classify the injected key.
**What we actually verified:** Sampled `launchctl getenv ANTHROPIC_API_KEY` across a 60s window (3s interval), a 90s window (1s) plus a Re-sync, and a 40s window (0.2s) spanning a clean quit -> relaunch. It stayed EMPTY the entire time. The ONLY SET reading all session was the very first `launchctl getenv`, taken seconds after a manual app restart, with an unconfirmed prefix. Login shells never see the var; this Claude Code session has no key in its env and connectors (Gmail/Notion/Calendar/etc.) work right now. The app's actual integration is Keychain OAuth sync of the CLI login (an `sk-ant-oat01` token, scopes incl. `user:mcp_servers`/`user:sessions:claude_code`) - the credential that *enables* connectors. `~/.claude/.credentials.json` is absent (login lives in Keychain). The app's Settings has no key-injection toggle.
**Choice:** Treat the earlier diagnosis as overstated. The single SET reading was most likely a stale value lingering in the launchd session from an earlier point (old app build / a prior manual `launchctl setenv`), cleared by the relaunch. No active problem -> made NO config change. Considered adding `"ANTHROPIC_API_KEY": ""` to settings.json `env` as a guardrail; owner chose to leave settings alone.
**Why:** Not going to defend against a ghost. Nothing in the setup uses `ANTHROPIC_API_KEY`; the connector path is healthy.
**Follow-up:** The Round-4 rationale ("connectors currently disabled by ANTHROPIC_API_KEY") no longer holds - the Notion/Gmail/Calendar-writing commands deferred then could be reconsidered. If connectors break again, first check `launchctl getenv ANTHROPIC_API_KEY` and run `launchctl unsetenv ANTHROPIC_API_KEY`.

## 2026-06-23: Round 4 - added a product-management suite
**Context:** The owner is a 20+ year career product manager; prior rounds were all engineer-focused. They asked for PM-grade features.
**Choice:** Added 9 framework skills (working-backwards, prd-writer, discovery-synthesis, prioritization, metrics-tree, positioning, experiment-design, strategy-narrative, okr-coach), 3 agents (product-critic, prd-reviewer, prd-to-stories), 3 commands (/prd-new, /competitor-watch, /launch-readiness), and the product-doc-lint hook. /prd-new and /competitor-watch output Markdown files (openable in Google Docs) instead of writing to Notion, to sidestep the connector dependency.
**Why:** The owner does both PM and eng; this rounds out the PM half and bridges to the dev setup (prd-to-stories -> task-planner/test-writer).
**Alternatives considered:** Notion-writing commands and Gmail/Calendar commands (/meeting-prep, /feedback-triage, etc.) - deferred because claude.ai connectors are currently disabled by ANTHROPIC_API_KEY.

## 2026-06-23: Round 3 - added 15 power-user features
**Context:** Second feature brainstorm; owner approved every proposed idea except a Sentry MCP.
**Choice:** Added 3 enforcement hooks (git-workflow-guard opt-in via .claude/git-guard.conf, focused-test-guard, env-drift), 5 agents (performance-reviewer, accessibility-reviewer, test-writer, pr-feedback-responder, docs-sync), 5 commands (/quality, /api-sync, /deps-audit, /factory, /changelog), and 2 skills (pest-patterns, postgres-performance).
**Why:** Each compounds with existing pieces (the TDD gates, the reviewers, the connected Postman MCP).
**Alternatives considered:** Sentry MCP (declined: owner does not use Sentry).

## 2026-06-23: Add tier-2 test enforcement (require-tests Stop hook)
**Context:** Wanted to guarantee the downside is caught; tier-1 (verify.sh) only gates pass + coverage where opted in.
**Choice:** A global require-tests Stop hook blocks finishing when app code changed but no test was touched. Auto-activates only where a test setup exists (tests/ dir, Pest/PHPUnit, or Vitest).
**Why:** Catches "changed code, wrote zero tests" robustly, without a brittle per-file mapping.
**Alternatives considered:** Per-file test mapping (too brittle); opt-in only (less automatic).

## 2026-06-23: Keep .ts/.tsx in the format/scrub hooks
**Context:** Owner uses plain JS; questioned whether the hooks should reference TS extensions.
**Choice:** Keep them.
**Why:** Config files like `vite.config.ts` are commonly TS even in JS projects; the hooks are language-agnostic and harmless when no .ts exists.
**Alternatives considered:** Stripping .ts/.tsx (rejected: risks skipping a real config file).

## 2026-06-23: /wrap runs the /brain-sync workflow (both kept)
**Context:** /wrap routes durable learnings; /brain-sync updates the brain. Wanted the brain update to always run at wrap time without losing /brain-sync as a standalone.
**Choice:** /wrap invokes the full /brain-sync workflow as its first step; /brain-sync stays a standalone command (referenced, not duplicated).
**Why:** One wrap does everything, and the brain update is still available on its own.
**Alternatives considered:** Merging and deleting /brain-sync (rejected: the standalone is useful).

## 2026-06-23: Automate Project Brain instead of installing the skill
**Context:** Wanted persistent project memory without manual effort.
**Choice:** SessionStart loader hook + a CLAUDE.md nudge rule + `/brain-sync`; vendored only the templates.
**Why:** The upstream skill needs manual "compile"/"log" commands; owner wanted it automatic.
**Alternatives considered:** Installing the harims95/project-brain skill (rejected as too manual).

## 2026-06-23: Plain JavaScript, not TypeScript
**Context:** Stack guidance had defaulted to TS.
**Choice:** Plain JS in app code; JSDoc as the optional middle path.
**Why:** Owner finds TS too verbose; for solo/small apps the main TS win (PHP/Vue prop drift) is minor.
**Alternatives considered:** Full TS (rejected, not worth the ceremony).

## 2026-06-23: Broad permission allowlist + acceptEdits
**Context:** Wanted less prompt friction.
**Choice:** Wildcard dev-command allowlist and `defaultMode: acceptEdits`.
**Why:** Personal machine; the PreToolUse hook backstops irreversible commands.
**Alternatives considered:** Conservative read-only allowlist (too little benefit).

## 2026-06-22: Symlink individual files into ~/.claude, not the whole dir
**Why:** `~/.claude` is full of machine-local junk; whitelisting good files keeps it out of git.
