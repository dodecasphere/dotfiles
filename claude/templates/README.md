# Project templates

Files to copy into individual projects. These are not deployed into `~/.claude`;
they are starting points you drop into a repo.

## verify.sh (test + coverage gate)

The global `verify-done` Stop hook runs `./.claude/verify.sh` (when present and
executable) before Claude can finish, and blocks on a non-zero exit. Use this to
enforce that tests pass and coverage clears a threshold for both PHP (Pest) and
JS (Vitest).

Install it in a project:

```bash
mkdir -p .claude
cp ~/Dotfiles/claude/templates/verify.sh .claude/verify.sh
chmod +x .claude/verify.sh
```

Then tune the threshold and commands at the top of the copied file. Note it runs
on every finish, so keep it fast or scope it (e.g. `pest --dirty`,
`vitest --changed`) if the full suite is slow.

This enforces tests-pass-and-covered, not test-first ordering. Ordering is a
discipline carried by the `tdd` skill and the CLAUDE.md workflow, not something
a hook can prove.
