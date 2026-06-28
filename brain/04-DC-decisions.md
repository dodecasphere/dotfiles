# [DC] Decisions

A log of choices made and why. Newest at the top. Never edit old entries.

## 2026-06-27: Hand-port third-party Claude skills into the `claude/` tree, never run their installers
**Context:** Brought in the `caveman` output-compression skill from JuliusBrussee/caveman. Upstream ships a `curl -fsSL ... | bash` that runs a Node installer (`bin/install.js`) writing into `~/.claude` directly, plus `.toml` command files (Codex format) and an always-on activation flag file.
**Choice:** Hand-placed `claude/skills/caveman/SKILL.md` verbatim and translated the three usable commands into Claude markdown (`claude/commands/caveman.md`, `caveman-commit.md`, `caveman-review.md`). Skipped the Node installer, the always-on flag file, and `caveman-init` (it just shells out to the installer). Left caveman opt-in (invoke via `/caveman` or "caveman mode"), not auto-on. Committed in dfa73af. Generalizes the same call made for the PM-skills import (see 2026-06-23 cherry-pick entry).
**Why:** Upstream installers target machine-local `~/.claude`, which does not ride the dotfiles symlink-restore and would drift from git. Hand-porting keeps everything portable, house-styled, and selective. Caveman stays opt-in because always-on compression fights the `ai-to-human`/`write` skills on anything exec- or human-facing.
**Alternatives considered:** Running the upstream `curl | bash` (rejected: not portable, writes outside git, all-or-nothing); porting the `.toml` commands as-is (rejected: Codex format, Claude uses markdown); enabling the always-on flag (rejected: collides with the writing-voice skills).

## 2026-06-26: Resolved git merge conflict in claude/settings.json
**Context:** `/doctor` reported settings.json as invalid JSON. The file had unresolved git merge conflict markers (`<<<<<<<`/`=======`/`>>>>>>>`) from a merge + stash conflict, making it unparseable.
**Choice:** Took the "Stashed changes" side as the winner. Wrote clean JSON directly to `claude/settings.json` (symlink target in the repo).
**Why:** The stash side was the more current/intentional version: it uses `$HOME/` references (portable) and unescaped forward slashes (standard JSON) vs. the upstream's absolute paths with `\/` escaping (macOS serializer artifact). Both sides had identical hook inventory; the stash side had a cleaner hook order (PreToolUse first) matching how the hooks are actually organized.
**Alternatives considered:** Taking the upstream side (rejected: absolute paths, escaped slashes, stale hook ordering).

## 2026-06-23: Import 15 PM skills from Product-Manager-Skills by cherry-pick + house-rewrite
**Context:** Dean Peters' Product-Manager-Skills repo (47 skills, v0.79, distributed as a Claude Code plugin/marketplace) overlaps the owner's existing PM suite but fills real gaps (finance, market sizing, stakeholder, career/leadership, AI-PM). The owner asked what to pull in and whether to install from source instead of the prior manual-copy approach.
**Choice:** Cherry-picked 15 net-new gap-fillers and rewrote each to house style (tight like `positioning.md`, em-dash-free, `[[wikilink]]` cross-links, CC-BY-NC-SA attribution footer), rather than installing the upstream plugin or bulk-copying. Imported: finance (finance-metrics-quickref, business-health-diagnostic, feature-investment-advisor, finance-based-pricing-advisor), sizing/macro (tam-sam-som-calculator, pestel-analysis), stakeholder (stakeholder-mapping, stakeholder-engagement-advisor), career (director-readiness-advisor, altitude-horizon-framework, product-sense-interview-answer), AI-PM (context-engineering-advisor, recommendation-canvas, pol-probe), delivery (epic-breakdown-advisor). Kept the `prd-to-stories` agent and cross-linked it to epic-breakdown-advisor rather than replacing it.
**Why:** Plugin/marketplace install does not ride the dotfiles symlink-restore (plugins live in machine-local state), is all-or-nothing per plugin, and would inject all 47 descriptions into context plus their em-dash-laden, workshop-heavy style. Cherry-pick + rewrite keeps the layer portable, house-styled, and selective; bulk-import would reintroduce context-tax and trigger-collision against the existing curated skills. 15 over the ~24 the clusters offered, because of internal overlap (e.g. business-health-diagnostic subsumes the two saas-* metric skills; pol-probe-advisor is just a selector for pol-probe).
**Alternatives considered:** Plugin install via `/plugin marketplace add` (rejected: not portable, all-or-nothing, style/context cost); bulk-copy all clusters (~24 skills, rejected: context tax + collisions); replacing prd-to-stories agent with the delivery skills (rejected: different modality, the agent is a batch PRD->tickets transform, the skills are interactive splitting). License: CC-BY-NC-SA 4.0, attribution recorded per skill.

## 2026-06-23: Trust the claude-usage tap before installing the cask
**Context:** Installing `claude-usage-tracker` failed with "Refusing to load cask ... from untrusted tap hamed-elfayome/claude-usage". Newer Homebrew gates casks from third-party (non-official) taps behind an explicit `brew trust`.
**Choice:** Ran `brew trust --cask hamed-elfayome/claude-usage/claude-usage-tracker` (stored in `~/.config/homebrew/trust.json`), installed the cask (Claude Usage.app 3.1.0), and added the trust line to `provisioning/mac/apps.sh` between the `brew tap` and the `cask` call so a fresh provision does not hit the wall. Committed in aa7dc71.
**Why:** The statusline usage gauge depends on this app, so keeping it installed and reproducible matters. `brew trust` is idempotent, so the new provisioning line is safe to re-run.
**Alternatives considered:** Dropping the `brew tap` line and using the fully-qualified cask name to auto-tap (rejected: the `cask` helper installs by short name and its `cask_version_installed` does `ls "$(brew --caskroom)/$1"`, which a slashed full path would break). Kept the tap -> trust -> install order.

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
