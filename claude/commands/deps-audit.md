---
description: Audit PHP and JS dependencies for known vulnerabilities and propose safe updates
allowed-tools: Bash(composer audit:*), Bash(composer outdated:*), Bash(npm audit:*), Bash(npm outdated:*), Bash(yarn:*), Bash(pnpm:*), Read
---
Check this project's dependencies for security issues and stale versions.

1. PHP: `composer audit`, plus `composer outdated --direct` for context.
2. JS: `npm audit` (or the project's package manager: `yarn npm audit` / `pnpm audit`), plus outdated direct deps.
3. Summarize actionable findings by severity. For each, propose the specific safe bump (patch or minor) and flag any that require a major upgrade or have no fix yet.
4. Do not run any updates. Present the exact commands for me to run, and call out anything risky (major versions, likely breaking changes).
