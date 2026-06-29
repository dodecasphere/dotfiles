# [ST] Current State

Snapshot of right now. Rewrite freely as things change.

**What works:**
- Portable `claude/` config layer (settings, statusline, global CLAUDE.md, hooks, commands, agents, skills, templates), all symlinked; restore-tested via `./test.sh` (14/14).
- `settings.json` is valid JSON and tracked cleanly in git (merge conflict resolved 2026-06-26).
- Hooks: block-dangerous-commands, protect-sensitive-files, auto-format, debug-scrubber, require-tests, focused-test-guard, env-drift, git-workflow-guard (opt-in), product-doc-lint, verify-done, context-recovery, brain-loader.
- PM suite (for the owner, a career product manager): skills working-backwards, prd-writer, discovery-synthesis, prioritization, metrics-tree, positioning, experiment-design, strategy-narrative, okr-coach; agents product-critic, prd-reviewer, prd-to-stories; commands /prd-new, /competitor-watch, /launch-readiness (the first two write Markdown for Google Docs).
- PM suite extended with 15 skills cherry-picked from Dean Peters' Product-Manager-Skills (v0.79) and rewritten to house style with CC-BY-NC-SA attribution (see DC 2026-06-23): finance (finance-metrics-quickref, business-health-diagnostic, feature-investment-advisor, finance-based-pricing-advisor), sizing/macro (tam-sam-som-calculator, pestel-analysis), stakeholder (stakeholder-mapping, stakeholder-engagement-advisor), career (director-readiness-advisor, altitude-horizon-framework, product-sense-interview-answer), AI-PM (context-engineering-advisor, recommendation-canvas, pol-probe), delivery (epic-breakdown-advisor, cross-linked to the prd-to-stories agent).
- Commands: /commit, /commit-push-pr, /clean_gone, /brain-sync, /wrap, /add-test-gate, /quality, /api-sync, /deps-audit, /factory, /changelog.
- Agents: task-planner, security-reviewer, db-migration-reviewer, performance-reviewer, accessibility-reviewer, test-writer, pr-feedback-responder, docs-sync.
- Skills: grill-me, handoff, diagnosing-bugs, tdd, codebase-design, resolving-merge-conflicts, maintaining-context, pest-patterns, postgres-performance, stack skills (laravel/inertia-vue/tailwind/alpine), plus PM skills and _TEMPLATE.
- Playwright MCP at user scope (provisioned).
- claude.ai connectors (Gmail/Notion/Calendar/Drive/etc.) work; the earlier ANTHROPIC_API_KEY scare was a false alarm (see DC 2026-06-23).
- CLAUDE.md documents the `claude/` config layer, `brain/`, and `test.sh`.
- Claude Usage Tracker installed and reproducible: `provisioning/mac/apps.sh` does tap -> `brew trust` -> install.

**In progress:**
- None active.

**Broken / known issues:**
- Statusline usage gauge depends on the Claude Usage app (cache + a live `sk-ant-sid02` sessionKey in the untracked `fetch-claude-usage.swift`); the cookie expires with nothing to refresh it if the app is removed. Tracked in OQ.

**Next 3 things to do:**
1. Commit the resolved settings.json (currently `UU` in git — needs `git add claude/settings.json`).
2. Optionally add Laravel Boost MCP (deferred from prior sessions).
3. Build remaining commands: /ship, /standup, /prime.
