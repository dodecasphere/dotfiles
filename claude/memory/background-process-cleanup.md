---
name: background-process-cleanup
description: Agent-spawned CPU burners or background jobs must be killed by process group or trap, never pkill -P $$ from a subshell; a leaked probe burned six cores for three days
metadata:
  type: feedback
---

Any Bash tool call that backgrounds CPU burners or long jobs (load probes, `yes > /dev/null &`, parallel test suites) must guarantee cleanup by process group or an EXIT trap. Never `pkill -P $$` from inside `( ... )`: `$$` is the outer shell's PID there, so it matches nothing.

**Why:** On 2026-11-02 a builder:reviewer subagent (product-builder-plugin, session 8bf5dc34) ran a contention probe with six `yes` burners in a subshell and `pkill -P $$ yes` as cleanup. The pkill missed, the tool call timed out, the outer shell died, and the burners reparented to launchd. Six cores at 100% for three days until Activity Monitor blamed Ghostty (macOS bills orphans to the originating app coalition). Found 2026-11-05.

**How to apply:**
- Run burners in their own process group and kill the group: `set -m; ( ... ) & PG=$!; ...; kill -- -$PG`, or `setsid` on Linux.
- Or `trap 'kill $(jobs -p) 2>/dev/null' EXIT` in the shell that spawned them, before the `&`.
- Keep the whole probe under the Bash tool timeout (default 120 s), or pass a longer timeout; a timed-out call kills the shell, not its orphans.
- After any such probe, verify with `pgrep -x yes` (or the job's name) before reporting.
- Prefer not to spawn burners at all unless the review genuinely needs contention; a timing probe without load answers most questions.
