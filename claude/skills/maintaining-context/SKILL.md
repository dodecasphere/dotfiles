---
name: maintaining-context
description: Create and maintain a project's CONTEXT.md — its domain model, key terms, architecture, conventions, and gotchas. Use when starting work in a project that has no CONTEXT.md, when the domain model or a convention becomes clearer, or when the user says "update context"/"capture this". Other skills (diagnosing-bugs, tdd) read CONTEXT.md when it exists.
---

# Maintaining CONTEXT.md

## Purpose
Keep a short, high-signal `CONTEXT.md` at the project root that gives any agent (or human) a fast, accurate mental model of the project: its domain language, architecture, conventions, and the gotchas that bite. Several skills read it automatically when present, and the context-recovery hook surfaces it after compaction.

## When to use
- The project has no `CONTEXT.md` and the work is more than a one-off.
- A domain term, architectural decision, or convention just became clear.
- The user says "update context", "capture this", or corrects a wrong assumption worth remembering.

## When not to use
- Throwaway scripts or trivial one-file changes.
- Information that already lives in the README, ADRs, or code comments — link to it instead of duplicating.

## Workflow
1. Check for an existing `CONTEXT.md`. If present, read it and update only what changed.
2. If absent and the work warrants it, offer to bootstrap one. Explore the codebase (entry points, modules, models, routes, tests) before writing, so the model is real, not guessed.
3. Write or update these sections, keeping the whole file short (aim for one screen):
   - **Domain** — what the project does and the key terms, defined precisely.
   - **Architecture** — the main modules/layers and how they fit; where the seams are.
   - **Conventions** — patterns this codebase follows (naming, structure, testing).
   - **Gotchas** — non-obvious traps, footguns, and "do not do X" lessons.
4. Confirm material changes with the user before committing them.

## Things to avoid
- Bloat. CONTEXT.md is a map, not the territory. Cut anything derivable from the code.
- Stale claims. If something named here no longer exists, fix or remove it.
- Duplicating the README or ADRs. Reference them.

## Quality checklist
- [ ] Fits on roughly one screen.
- [ ] Every term/file/module named still exists in the code.
- [ ] A new contributor could orient from it in two minutes.

## Gotchas
- (none yet)
