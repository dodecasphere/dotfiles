# Dotfiles: Project Brain

The canonical memory of this dotfiles repo. It is auto-loaded at the start of
every session by the `brain-loader` hook, so it never needs pasting. As a
session runs, Claude offers to update it; at the end, `/brain-sync` brings it
current for next time.

## Files
- `01-OV-overview.md`: what this project is
- `02-GO-goals.md`: goals and non-goals
- `03-AR-architecture.md`: stack and structure
- `04-DC-decisions.md`: log of choices and why (append, do not edit old entries)
- `05-ST-state.md`: current snapshot (rewritten freely)
- `06-GL-glossary.md`: project-specific terms
- `07-OQ-questions.md`: open questions
- `.history/`: timestamped snapshots of past ST files (used for diffs)

## Rules
- One job per file. Do not blur Decisions, State, and Architecture.
- Append to DC, never rewrite old entries. It is a log.
- ST is the one file rewritten freely. It is a snapshot, not history.
- Short over complete. No invented facts; use `(fill in)` where unknown.
