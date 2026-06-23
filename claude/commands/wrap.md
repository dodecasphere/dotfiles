---
description: Wrap up the session - update the Project Brain and route any other durable learnings
allowed-tools: Bash(readlink:*), Bash(mkdir:*), Bash(cp:*), Bash(cat:*), Bash(ls:*), Bash(date:*), Bash(test:*), Read, Write, Edit
---
Close out this session so the next one starts ready. Work only from what actually happened; never invent facts (use `(fill in)` when unknown).

## 1. Update the Project Brain
Locate the brain (`./`, `brain/`, `.brain/`, or a `*-brain/` dir with canonical `0N-XX-*.md` files). If none exists and this is a real project, offer to create one: resolve templates with `tpl="$(dirname "$(readlink "$HOME/.claude/settings.json")")/templates/brain"`, copy them into `brain/`, pre-fill OV/AR from what you can verify, and leave `(fill in)` elsewhere.

Then bring it current:
- **Decisions (DC):** prepend a dated entry (`## YYYY-MM-DD: <title>` with Context / Choice / Why / Alternatives) for each meaningful choice. Never edit old entries.
- **Open Questions (OQ):** move resolved ones into DC; add any new ones.
- **Architecture (AR):** update if the stack or structure changed, with a DC note on why.
- **Glossary (GL):** add any new project-specific terms.
- **Current State (ST):** archive `05-ST-*.md` to `.history/ST-$(date +%Y-%m-%d-%H%M).md`, then rewrite works / in progress / broken / next 3.

Apply these directly (ST is archived first); only pause when a fact is genuinely ambiguous.

## 2. Route anything that does not belong in the brain
For durable learnings that are not project-specific state:
- **Global ~/.claude/CLAUDE.md** - cross-project behavioral rules only.
- **the `remember` plugin** - runtime/session continuity.
- If the project has no brain, project-specific conventions go in its own CLAUDE.md instead.

Propose the exact text for these and wait for my approval before writing them.

## 3. Summary
Give a short summary of what changed, and confirm the brain is current and ready for the next session.
