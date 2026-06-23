---
description: Wrap up the session - run the brain update, then route any other durable learnings
allowed-tools: Bash(readlink:*), Bash(mkdir:*), Bash(cp:*), Bash(cat:*), Bash(ls:*), Bash(date:*), Bash(test:*), Read, Write, Edit
---
Close out this session so the next one starts ready. Work only from what actually happened; never invent facts.

## 1. Update the Project Brain
Run the full `/brain-sync` workflow (defined in `~/.claude/commands/brain-sync.md` - read it and follow its steps): locate or scaffold the brain, log decisions to DC, resolve open questions, refresh AR/GL, and archive + rewrite ST. Apply directly (ST is archived first).

## 2. Route anything that does not belong in the brain
For durable learnings that are not project-specific state:
- **Global ~/.claude/CLAUDE.md** - cross-project behavioral rules only.
- **the `remember` plugin** - runtime/session continuity.
- If the project has no brain, project-specific conventions go in its own CLAUDE.md instead.

Propose the exact text for these and wait for my approval before writing them.

## 3. Summary
Give a short summary of what changed, and confirm the brain is current and ready for the next session.
