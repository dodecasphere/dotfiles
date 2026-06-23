# [DC] Decisions

A log of choices made and why. Newest at the top. Never edit old entries.

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
