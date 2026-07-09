# Skill provenance (upstream tracking)

Some skills in this directory are vendored from Matt Pocock's skills package,
[github.com/mattpocock/skills](https://github.com/mattpocock/skills). We do not
use his `npx skills add` installer (it writes into `~/.claude`, which fights our
symlink model where `~/.claude/skills` is one symlink to `claude/skills/` in this
repo). Instead we copy the chosen skill directories in by hand and apply local
edits.

This file records where each vendored skill came from so a future refresh is a
`git diff <recorded-sha>..main` against upstream rather than archaeology.

## Adoption scope (decided 2026-07-09)

Disciplines only. We deliberately did NOT adopt Matt's issue tracker delivery
pipeline (`triage`, `to-spec`, `to-tickets`, `implement`, `wayfinder`,
`setup-matt-pocock-skills`), nor `domain-modeling`, `handoff`, `grill-with-docs`,
`code-review`, `research`, `ask-matt`, or `teach`. Rationale: our Project Brain
plus BACKLOG plus feature-round flow already covers delivery, and the
artifact-writing skills (`domain-modeling`, `handoff`) collide with existing
project systems (for example the phoenix repo's `.workflow/handoff.md`,
`PROJECT_CONTEXT.md`, and `decisions/DECISION-NNN` ADRs).

## Upstream commit pulled

`d574778f94cf620fcc8ce741584093bc650a61d3` (fetched 2026-07-09)

## Vendored skills

| Skill | Upstream path | Local edits |
|---|---|---|
| `grill-me` | `skills/productivity/grill-me` | Kept our model-invocable frontmatter (triggers). Body upgraded to Matt's newer `grilling` engine text. We keep a single file (did not adopt his `grill-me` stub, `grilling` split). |
| `tdd` | `skills/engineering/tdd` | Genericized the context-doc pointer (see below). Repointed the "refactoring" line from the unadopted `code-review` skill to our house `refactoring.md`. Kept our house `refactoring.md` (not upstream). Took upstream's `tests.md` (adds the tautological-test example) and `SKILL.md` rewrite. NOTE: upstream's rewrite dropped the explicit RED/GREEN workflow checklists our older version had. |
| `diagnosing-bugs` | `skills/engineering/diagnosing-bugs` | Genericized the context-doc pointer. Otherwise identical to upstream. |
| `codebase-design` | `skills/engineering/codebase-design` | Genericized the context-doc pointer in `DESIGN-IT-TWICE.md`. `SKILL.md` and `DEEPENING.md` identical to upstream. |
| `resolving-merge-conflicts` | `skills/engineering/resolving-merge-conflicts` | Identical to upstream. |
| `prototype` | `skills/engineering/prototype` | None (examples left stack-agnostic). |
| `writing-great-skills` | `skills/productivity/writing-great-skills` | None. |
| `improve-codebase-architecture` | `skills/engineering/improve-codebase-architecture` | Neutered the domain-model coupling: genericized the context-doc pointer, changed "create `CONTEXT.md` lazily / write ADR" to "use the project's existing docs if it keeps them, never create top-level docs unprompted, ask first", and repointed `/grilling` to `/grill-me` and `/domain-modeling` (unadopted) to plain inline guidance. |

## The context-doc pointer edit

Several vendored skills originally read a hardcoded `CONTEXT.md` (Matt's
domain-modeling artifact). We do not use that file. Every such pointer was
genericized to read the project's own context doc if it has one (`CONTEXT.md`,
`PROJECT_CONTEXT.md`, or a Project Brain), so the discipline finds our model
wherever it lives across the project zoo, and never assumes or creates a
`CONTEXT.md`.

## Refreshing from upstream later

1. `git clone --depth 1 https://github.com/mattpocock/skills` to a scratch dir; note its HEAD.
2. For each vendored skill, `diff` scratch against this repo's copy.
3. Re-apply the local edits listed above to any changed file.
4. Update the commit SHA and the fetched date in this file.
5. Run `./test.sh`, then commit.
