# [DC] Decisions

A log of choices made and why. Newest at the top. Never edit old entries.

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
