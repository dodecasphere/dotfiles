# <Project Name>: Project Brain

The canonical memory of the **<Project Name>** project. In this setup it is
auto-loaded at the start of every session by the `brain-loader` hook, so you
never paste it in. As a session runs, Claude proactively offers to update it. `/brain-sync` refreshes it
anytime, and `/wrap` runs that when closing the session.

## Files
- `01-OV-overview.md`: what this project is
- `02-GO-goals.md`: goals and non-goals
- `03-AR-architecture.md`: stack and structure
- `04-DC-decisions.md`: log of choices and why (append, do not edit old entries)
- `05-ST-state.md`: current snapshot (rewritten freely)
- `06-GL-glossary.md`: project-specific terms (optional)
- `07-OQ-questions.md`: open questions (optional)
- `.history/`: timestamped snapshots of past ST files (used for diffs)

## Rules
- One job per file. Do not blur Decisions, State, and Architecture.
- Append to DC, never rewrite old entries. It is a log.
- ST is the one file rewritten freely. It is a snapshot, not history.
- Short over complete. A small current brain beats a large stale one.
- No invented facts. Use `(fill in)` where something is unknown.
