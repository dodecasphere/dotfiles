---
description: Read-only pre-flight check before wrapping a session - reports PASS/WARN/FAIL on git state, brain freshness, and doc sync without touching anything
context: fork
agent: Explore
---

## Current state

Branch:
!`git branch --show-current`

Git status:
!`git status --short`

Unpushed commits:
!`git log --oneline @{u}..HEAD 2>/dev/null || echo "(no upstream)"`

Brain state file (if the project keeps one):
!`ls brain/05-ST-state.md 2>/dev/null && git log -1 --format="ST last touched: %cr" -- brain/05-ST-state.md || echo "no Project Brain here"`

Last 5 commits:
!`git log --oneline -5`

## Checklist

Check each item and report PASS / WARN / FAIL with one line of guidance.
This is a read-only report; do not edit anything.

### 1. Working tree clean
Dirty tree or untracked files: WARN. List them so the wrap can decide
commit vs discard. Untracked files that look like secrets or scratch
output: FAIL, call them out by name.

### 2. Commits pushed
Unpushed commits on a feature branch: WARN with the count.

### 3. Brain freshness
If a Project Brain exists: compare when `brain/05-ST-state.md` was last
touched against the recent commits. Real work committed after the last ST
update: WARN, brain-sync needed (which /wrap runs next). No brain: PASS
with a note.

### 4. Backlog capture
Scan the last 5 commit messages and the diff stat for signs of deferred
work (TODO, "follow-up", "later", skipped tests). If found and the project
has `docs/BACKLOG.md`, check whether it was touched this session; if not:
WARN, items may be unlogged.

### 5. Env drift
If `.env` was modified but `.env.example` was not (check `git status` and
recent commits): FAIL, the two must stay in sync.

## Output

A compact table: check, verdict, one-line detail. End with a single line:
"ready to wrap" or "fix the FAILs first: <list>".
