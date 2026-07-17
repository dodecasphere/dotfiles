---
description: Update this project's Project Brain and get it ready for the next session
allowed-tools: Bash(readlink:*), Bash(mkdir:*), Bash(cp:*), Bash(cat:*), Bash(ls:*), Bash(date:*), Bash(test:*), Read, Write, Edit
---
Bring this project's Project Brain current so the next session starts fully grounded. Work only from what actually happened this session; never invent facts (use `(fill in)` when something is unknown).

1. **Locate the brain**: look in `./`, `brain/`, `.brain/`, or a `*-brain/` dir for the canonical `0N-XX-*.md` files.
   - If none exists and this is a real project, offer to create one: resolve the templates with `tpl="$(dirname "$(readlink "$HOME/.claude/settings.json")")/templates/brain"`, copy them into a `brain/` folder, pre-fill OV/AR from what you can verify about the repo, and leave `(fill in)` everywhere else.
2. **Decisions (DC)**: for each meaningful choice made this session, prepend a dated entry (`## YYYY-MM-DD: <title>` with Context / Choice / Why / Alternatives). Never edit existing entries.
3. **Open Questions (OQ)**: move any resolved question into DC as a decision; add any new ones that surfaced. **Prune, don't just append**: also drop any existing entry that's stale — no longer relevant, overtaken by a later decision, or answered informally without ever being moved to DC. OQ should stay a short, live list of things actually still unresolved, not an ever-growing archive.
4. **Architecture (AR)**: if the stack or structure changed, update AR and add a DC note on why. Also correct anything AR still asserts that's now wrong (a removed dependency re-adopted, a component that moved) rather than leaving the old claim to rot alongside the new one.
5. **Glossary (GL)**: add any new project-specific terms (one line each).
6. **Current State (ST)**: archive the existing `05-ST-*.md` to `.history/ST-$(date +%Y-%m-%d-%H%M).md` (create `.history/` if needed), then rewrite the four sections (works / in progress / broken / next 3) to reflect reality now. **This is a rewrite, not an append**: drop anything no longer true or no longer relevant to what's next, rather than accumulating every session's entries on top of each other. If ST keeps growing session over session instead of staying roughly the same size, that's the sign this step is being skipped.
7. End with a short summary of what changed and confirm the brain is ready for the next session.

Apply the updates directly (ST is safely archived first); only pause to ask when a fact is genuinely ambiguous.
