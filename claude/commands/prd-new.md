---
description: Draft a new PRD as a Markdown file (openable in Google Docs)
allowed-tools: Read, Write, Edit, Glob, Grep, WebSearch
argument-hint: [one-line product/feature idea]
---
Create a new PRD for "$ARGUMENTS" as a Markdown file.

1. Ask at most 2-3 sharp context questions (target user, the core problem, the outcome that defines success). Do not ask more; fill the rest with `(fill in)`.
2. If discovery notes or related docs exist in the repo, read them for grounding. Optionally do light web research for market context, clearly marked as external.
3. Using the `discovery-synthesis` and `prd-writer` skills, draft a complete PRD: problem, target user + JTBD, goals, non-goals, success metrics (each with baseline + target), solution, MVP, risks, open questions, rollout.
4. Write it to `./prd-<slug>.md` (or a `docs/` directory if one exists). Tell me the path; it opens in Google Docs via File > Open (or import the .md).
5. Never invent facts; mark assumptions. End by listing the `(fill in)` gaps I need to close.
