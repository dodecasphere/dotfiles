# [ST] Current State

Snapshot of right now. Rewrite freely as things change.

**What works:**
- Portable `claude/` config layer (settings, statusline, global CLAUDE.md, hooks, commands, agents, skills, templates), all symlinked; restore-tested via `./test.sh` (now 14/14 green after the stale force-push assertion was repointed at `bash-pretooluse-dispatcher.sh`).
- `install.sh` wires two memory symlinks on restore: `~/.claude/memory/` → `claude/memory/` (global memories: `career-product-manager`, `tech-stack`) and `~/.claude/projects/-Users-$(whoami)-Dotfiles/memory/` → `brain/memory/` (Dotfiles project memory: `claude-config-layer`).
- `~/.claude/skills` is a single directory symlink to `claude/skills/`, so a new skill is drop-in (create the dir, no `install.sh` edit) and rides the restore test automatically.
- Hooks: consolidated into `bash-pretooluse-dispatcher.sh` (dangerous-command block incl. force-push, git-workflow guard, conventional-commit + brain-sync enforcement) plus auto-format, debug-scrubber, require-tests, focused-test-guard, env-drift, product-doc-lint, code-guidelines-gate, verify-done, context-recovery, brain-loader, protect-sensitive-files.
- Engineering disciplines (Matt Pocock, vendored + house-styled; provenance in `claude/skills/UPSTREAM.md`, pinned to mattpocock/skills@d574778): grill-me, tdd, codebase-design, diagnosing-bugs, resolving-merge-conflicts, prototype, writing-great-skills, improve-codebase-architecture. Stack skills: laravel-best-practices, pest-patterns, inertia-vue, tailwind, alpine, postgres-performance.
- Core PM suite: skills working-backwards, prd-writer, discovery-synthesis, prioritization, metrics-tree, positioning, experiment-design, strategy-narrative, okr-coach; agents product-critic, prd-reviewer, prd-to-stories; commands /prd-new, /competitor-watch, /launch-readiness.
- Extended PM skills (cherry-picked, house-styled): stakeholder-mapping, stakeholder-engagement-advisor, director-readiness-advisor, altitude-horizon-framework, feature-investment-advisor, recommendation-canvas, pol-probe, epic-breakdown-advisor.
- Utility skills: caveman, write, prompt-improver, product-sense-interview-answer.
- Commands: /commit, /commit-push-pr, /clean_gone, /brain-sync, /wrap, /add-test-gate, /quality, /api-sync, /deps-audit, /factory, /changelog, /caveman(+commit/review), /backlog-this, /new-project-setup.
- Agents: task-planner, security-reviewer, db-migration-reviewer, performance-reviewer, accessibility-reviewer, test-writer, pr-feedback-responder, docs-sync.
- Default model set to `opus[1m]` in `settings.json`.
- claude.ai connectors work; consumer connectors disabled via the Claude app to reduce deferred-tools context overhead. Playwright MCP + claude-in-chrome MCP active. Claude Usage Tracker installed and reproducible via `provisioning/mac/apps.sh`.

**In progress:**
- None active.

**Broken / known issues:**
- Statusline usage gauge depends on the Claude Usage app (cache + a live `sk-ant-sid02` sessionKey in the untracked `fetch-claude-usage.swift`); cookie expires with nothing to refresh it if the app is removed. Tracked in OQ.

**Next 3 things to do:**
1. Owner to validate `improve-codebase-architecture` in a real repo (e.g. phoenix): confirm it reads `PROJECT_CONTEXT.md` and never spawns a rogue `CONTEXT.md`/`docs/adr/` write. Looked good on first pass this session.
2. Optionally add Laravel Boost MCP (deferred from prior sessions).
3. Apply the per-project memory pattern (`.claude/memory/` + symlink) to Crestlite, Watchdog, smart-mirror repos.
