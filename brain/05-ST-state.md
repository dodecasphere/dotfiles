# [ST] Current State

Snapshot of right now. Rewrite freely as things change.

**What works:**
- Portable `claude/` config layer (settings, statusline, global CLAUDE.md, hooks, commands, agents, skills, templates), all symlinked; restore-tested via `./test.sh`.
- `install.sh` now wires two memory symlinks on restore: `~/.claude/memory/` → `claude/memory/` (global cross-project memories) and `~/.claude/projects/-Users-$(whoami)-Dotfiles/memory/` → `brain/memory/` (Dotfiles project memory).
- Global memories (`career-product-manager`, `tech-stack`) live in `claude/memory/` and load in every project. Dotfiles project memory (`claude-config-layer`) lives in `brain/memory/`.
- Hooks: block-dangerous-commands, protect-sensitive-files, auto-format, debug-scrubber, require-tests, focused-test-guard, env-drift, git-workflow-guard (opt-in), product-doc-lint, verify-done, context-recovery, brain-loader.
- Core PM suite: skills working-backwards, prd-writer, discovery-synthesis, prioritization, metrics-tree, positioning, experiment-design, strategy-narrative, okr-coach; agents product-critic, prd-reviewer, prd-to-stories; commands /prd-new, /competitor-watch, /launch-readiness.
- Extended PM skills (cherry-picked, house-styled): stakeholder-mapping, stakeholder-engagement-advisor, director-readiness-advisor, altitude-horizon-framework, feature-investment-advisor, recommendation-canvas, pol-probe, epic-breakdown-advisor. (10 others pruned this session — see DC 2026-06-29.)
- Dev skills: grill-me, diagnosing-bugs, tdd, codebase-design, resolving-merge-conflicts, pest-patterns, postgres-performance, laravel-best-practices, inertia-vue, tailwind, alpine.
- Utility skills: caveman, write, product-sense-interview-answer (kept for occasional use).
- Commands: /commit, /commit-push-pr, /clean_gone, /brain-sync, /wrap, /add-test-gate, /quality, /api-sync, /deps-audit, /factory, /changelog, /caveman, /caveman-commit, /caveman-review.
- Agents: task-planner, security-reviewer, db-migration-reviewer, performance-reviewer, accessibility-reviewer, test-writer, pr-feedback-responder, docs-sync.
- claude.ai connectors work; consumer connectors (AllTrails, Audible, Resy, Spotify, StubHub, Play Sheet Music, others) disabled via Claude app settings to reduce deferred-tools context overhead.
- Playwright MCP at user scope (provisioned). claude-in-chrome MCP active.
- Claude Usage Tracker installed and reproducible via `provisioning/mac/apps.sh`.

**In progress:**
- None active.

**Broken / known issues:**
- Statusline usage gauge depends on the Claude Usage app (cache + a live `sk-ant-sid02` sessionKey in the untracked `fetch-claude-usage.swift`); cookie expires with nothing to refresh it if the app is removed. Tracked in OQ.

**Next 3 things to do:**
1. Optionally add Laravel Boost MCP (deferred from prior sessions).
2. Apply the per-project memory pattern (`.claude/memory/` + symlink) to Crestlite, Watchdog, smart-mirror repos.
3. Build remaining commands: /ship, /standup, /prime.
