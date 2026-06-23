# [ST] Current State

Snapshot of right now. Rewrite freely as things change.

**What works:**
- Portable `claude/` config layer (settings, statusline, global CLAUDE.md, hooks, commands, agents, skills, templates), all symlinked; restore-tested via `./test.sh` (14/14).
- Hooks: block-dangerous-commands, protect-sensitive-files, auto-format, debug-scrubber, require-tests, verify-done, context-recovery, brain-loader.
- Commands: /commit, /commit-push-pr, /clean_gone, /brain-sync, /wrap (runs the brain update too), /add-test-gate.
- Agents: task-planner, security-reviewer, db-migration-reviewer. Skills: grill-me, handoff, diagnosing-bugs, tdd, codebase-design, resolving-merge-conflicts, maintaining-context, stack skills (laravel/inertia-vue/tailwind/alpine), plus _TEMPLATE.
- Playwright MCP at user scope (provisioned).

**In progress:**
- None active.

**Broken / known issues:**
- None known.

**Next 3 things to do:**
1. Optionally add Laravel Boost MCP (skipped so far).
2. Build remaining menu items: /ship, /standup, /prime.
3. Author the owner's own skills (ai-to-human, tooth-fairy, job-tailor) when source is available.
