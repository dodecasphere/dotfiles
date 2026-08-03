---
name: phased-execute
description: Execute an approved Phoenix phased plan (Sonnet session) — stacked phase branches, per-phase Fable fidelity review, realtime Jacquard progress artifact, hard PR/artifact gates. Args = path to the approved plan doc.
---

# Phased Execute (Sonnet execution session)

**Phoenix only.** Args: path to plan doc (e.g. `.workflow/plans/<slug>.md`).

## Step 0 — verify approval, load plan
- `bash ~/.claude/hooks/phoenix-phased/set-state.sh` with no args prints state. `phase` must be `approved` or `executing`. If `planning`/`idle`: STOP — tell Mike the plan isn't approved; do not code.
- **Read the plan doc IN FULL before any edit.** It is the source of truth. Then: `bash ~/.claude/hooks/phoenix-phased/set-state.sh phase=executing`.
- Locate the artifact URL in the plan doc. Redeploy it (via `url` param) with banner "Executing" and phase 1 chip "In Progress" BEFORE the first edit, then `bash ~/.claude/hooks/phoenix-phased/mark-artifact.sh`. This is the #1 historically missed step.

## Per phase N
1. **Branch first.** Cut `feat/<slug>-phase-N` from the previous phase branch (phase 1 from develop) BEFORE the first edit. Never commit on develop. Hook blocks the cut if the artifact is stale — redeploy + `mark-artifact.sh` fixes it.
2. **Implement exactly to plan.** Locked Decisions are locked: no re-litigating, no re-deriving, no improvised icons/copy/scope/approach. If something genuinely cannot be built as specified, STOP and ask Mike — do not improvise. When fixing a pattern (border color, chip size, spacing…), sweep the ENTIRE app for other instances, not just the cited one. Never delete or drop scope silently — flag it.
3. **Verify before claiming done.** UI changes: verify visually with headed Playwright before saying a phase is ready for review. Run the CI-equivalent checks the diff touches (frozen install + lint + tests). Never claim done unverified.
4. **Commit per slice.** Conventional commits, no AI attribution lines, no Co-Authored-By. Let Mike read commit messages on request before push.
5. **Fable review.** Spawn ONE review agent (`model: fable` if unavailable then opus) with: plan doc path, phase N spec, diff. It delivers a single full-fidelity + faithfulness review against the plan. Apply EVERY item of feedback, then have Fable quick re-verify just the fixes. Phase closes only after re-verify passes.
6. **Artifact update — both edges.** At phase start: chip → "In Progress". At phase close: chip → "Done", progress bar advanced, "done / noticed / review findings" notes filled. Redeploy (same URL), then `bash ~/.claude/hooks/phoenix-phased/mark-artifact.sh`. Scope changes mid-phase also get redeployed immediately.
7. **Keep rolling.** After a phase closes, proceed straight to the next phase. Do not stop between phases for check-ins; stop only when blocked, when the plan can't be followed as written, or when Mike interrupts.

## Session conduct
- Work in the foreground of this thread — Mike watches live. The ONLY background agent is the Fable review. No orphan shells: before ending the session, kill/stop every background shell and say so.
- `pnpm` only, never `npm install`. Never pipe `pnpm dev` through `head`/`tail` (SIGPIPE kills it) — background it bare and poll with curl.
- `gh` list/state queries: use `--json`/`--state all`, never trust a bare list.
- Report findings in the thread, not in files, unless Mike asks for a file.
- Branch out-of-date or merge conflicts with base: detect and resolve proactively, don't leave for Mike to notice.

## PR (end only)
NEVER create a PR until Mike explicitly says he's ready (hook blocks `gh pr create` regardless). When he says so:
1. Show proposed PR title + body in the chat first. No "Test plan" section, no attribution.
2. On his confirmation: `bash ~/.claude/hooks/phoenix-phased/set-state.sh pr_approved=1`, then create ONE PR from the final phase branch into develop. The gate re-arms automatically after creation.

## Handoff
When context runs long or Mike ends the session mid-plan: update the plan doc with exact progress, redeploy the artifact, and print (in chat) the kickoff prompt for the next session (`/phased-execute <plan path>` + one line on where it left off) — unprompted.
