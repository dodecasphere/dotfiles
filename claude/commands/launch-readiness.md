---
description: Generate a cross-functional launch readiness checklist for a feature
allowed-tools: Read, Write, Glob, Grep
argument-hint: [feature/launch name]
---
Generate a tailored go-to-market / launch readiness checklist for "$ARGUMENTS".

Ask one or two quick scope questions if needed (audience, phased vs full rollout). Then produce concrete, checkable items per function, tailored to what this launch actually involves (not generic boilerplate):
- **Product**: success metrics instrumented, guardrails set, rollout/rollback plan, feature flags.
- **Engineering**: tested, load/perf checked, error monitoring, migration safety.
- **Design**: final assets, empty and error states, accessibility.
- **Marketing / Comms**: positioning, release notes, announcement, help docs.
- **Support**: enablement, FAQ, escalation path.
- **Legal / Privacy**: data handling, terms, compliance (where relevant).
- **Analytics**: events live, dashboard ready, success criteria defined.

Mark items that look not-applicable rather than padding the list. Offer to save as a Markdown file openable in Google Docs.
