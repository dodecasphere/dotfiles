---
description: Take one or more feedback items, flesh each out fully, file it to the project backlog (flat entry or PRD candidate), then optionally loop them through feature-round
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(git *), AskUserQuestion
argument-hint: [feedback item(s) - one per line, or leave blank and paste below]
---

Triage "$ARGUMENTS" into the project's backlog (or, if blank, ask me to paste
one or more feedback items first). The goal is not just filing a line - each
item should come out of this fully specified, ready for an unattended
execution round with no more clarification needed.

## 1. Find the backlog file, and check for a resumable run

`docs/BACKLOG.md` first. If absent, check this project's CLAUDE.md/AGENTS.md
for an explicit path, then look for `BACKLOG.md`/`TODO.md`/`IDEAS.md` at repo
root. If none exist, stop and ask where items should live - offer to scaffold
`docs/BACKLOG.md` from `~/Dotfiles/claude/templates/BACKLOG.md`. Never assume
a path or format. If a file exists, read a few of its existing entries first
and mirror its voice, checkbox style, and any dated-batch markers exactly -
new entries must look native, not bolted on.

Grep the file for an `<!-- backlog-this: in-progress ... -->` marker left by
an interrupted prior run. If found, offer to resume that batch (pick up at
the noted item) before touching `$ARGUMENTS` at all.

## 2. Split into items

One item per line/bullet. Treat a multi-sentence paragraph as one item unless
it clearly bundles unrelated asks - then split it.

## 3. Dedup pass

Before drafting anything, grep the backlog file for each item's key terms. If
a close match already exists, flag it and ask whether to update/merge that
existing line instead of filing a new one, skip it as a true duplicate, or
file it anyway as a genuinely distinct item.

## 4. Pre-triage before grilling

For each surviving item, do a quick size/ambiguity read first - don't grill
yet:

- **Flat-sized**: bounded fix/tweak/one-off with an obvious shape.
- **PRD-sized**: a real product/design tradeoff, a new feature surface, or
  more than a small/medium round can hold.

State your read and confirm with me if it's not obvious. This decides which
path the item takes next - a PRD-sized item skips step 5 entirely (it gets
interrogated later by `grill-me`/`prd-writer` as part of its own dedicated
session, not twice) and only needs a one-line problem statement captured now.

## 5. Flesh out the flat-sized items

For each flat-sized item, invoke the `grill-me` skill on it directly -
actually trigger that skill, don't just imitate its discipline in prose. Let
it interview me one question at a time (recommending an answer for each,
checking the codebase first whenever the answer is discoverable there).

Cap it at roughly 5-6 questions per item. If it's still open after that,
stop and ask me: land it with the best draft so far, keep going a bit more,
or reclassify it as PRD-sized instead of forcing resolution. If at any point
during the interview it becomes clear the item isn't worth doing at all,
say so and offer to drop it instead of filing it.

## 6. Write the batch

Write every surviving item in one edit: fully-answered flat entries, and
PRD-sized items as a `**PRD: <name>.**` tag with its one-line problem
statement, pointing at a future `grill-me` -> `prd-writer`/`prd-new` ->
`prd-to-stories` pass. Group this invocation's items under one dated bold
marker matching the file's own convention (e.g. `**Feedback pass,
<date>.**`), roughly prioritized. Never create a second "PRD queue" file -
one flat backlog only; PRD candidates are tagged in place.

If any item couldn't be fully resolved in step 5 and I chose "keep going
later," leave the `<!-- backlog-this: in-progress, resume at "<item>" -->`
marker under that batch heading instead of closing it out.

Immediately commit this write - backlog edits are docs-only fast lane (see
this repo's branching policy), no gate needed. Plain conventional-commit
message, no AI attribution.

## 7. Ask before executing

Don't assume I want to run these now. Ask whether to continue straight into
execution or leave everything filed for later.

If yes: look specifically for `.claude/commands/feature-round.md` (or this
project's equivalent). If it's not there, ask once for the equivalent command
name and remember it for the rest of this session - don't re-ask per item.

For each ready flat item, hand it to that command as raw input in turn - its
own disambiguation steps become a fast confirmation pass since the real
fleshing-out already happened here. For each PRD-tagged item, run
`grill-me` -> `prd-writer`/`prd-new` -> `prd-to-stories` instead, and only
bring the resulting story breakdown to the execution command afterward.

## 8. Check items off

After each item's round finishes, mark it done in the backlog file, matching
its existing convention for completed items (checkbox + strikethrough + a
short "Done: ..." note if that's the file's style, otherwise just check the
box). Commit each check-off too - same fast-lane reasoning as step 6.

## Rules

- One question at a time, always with a recommended answer.
- Never assume the backlog file's location, format, whether I want to
  execute now, or which command plays the feature-round role - ask.
- Big items get flagged as PRD candidates, never force-fit into a flat line,
  and never grilled twice (once here, once in the PRD session).
- Dedup before filing. Drop items that turn out not worth doing.
- One backlog file only, always. Commit every write to it - it's fast lane.
