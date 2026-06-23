---
description: Update this project's Project Brain and get it ready for the next session
allowed-tools: Bash(readlink:*), Bash(mkdir:*), Bash(cp:*), Bash(cat:*), Bash(ls:*), Bash(date:*), Bash(test:*), Read, Write, Edit
---
Bring this project's Project Brain current so the next session starts fully grounded. Work only from what actually happened this session; never invent facts (use `(fill in)` when something is unknown).

1. **Locate the brain**: look in `./`, `brain/`, `.brain/`, or a `*-brain/` dir for the canonical `0N-XX-*.md` files.
   - If none exists and this is a real project, offer to create one: resolve the templates with `tpl="$(dirname "$(readlink "$HOME/.claude/settings.json")")/templates/brain"`, copy them into a `brain/` folder, pre-fill OV/AR from what you can verify about the repo, and leave `(fill in)` everywhere else.
2. **Decisions (DC)**: for each meaningful choice made this session, prepend a dated entry (`## YYYY-MM-DD: <title>` with Context / Choice / Why / Alternatives). Never edit existing entries.
3. **Open Questions (OQ)**: move any resolved question into DC as a decision; add any new ones that surfaced.
4. **Architecture (AR)**: if the stack or structure changed, update AR and add a DC note on why.
5. **Glossary (GL)**: add any new project-specific terms (one line each).
6. **Current State (ST)**: archive the existing `05-ST-*.md` to `.history/ST-$(date +%Y-%m-%d-%H%M).md` (create `.history/` if needed), then rewrite the four sections (works / in progress / broken / next 3) to reflect reality now.
7. End with a short summary of what changed and confirm the brain is ready for the next session.

Apply the updates directly (ST is safely archived first); only pause to ask when a fact is genuinely ambiguous.
