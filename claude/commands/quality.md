---
description: Run the Laravel quality pipeline (Pint, Rector, Larastan, Pest), stopping at the first failure
allowed-tools: Bash(vendor/bin/pint:*), Bash(vendor/bin/rector:*), Bash(vendor/bin/phpstan:*), Bash(php artisan:*), Bash(vendor/bin/pest:*), Bash(vendor/bin/phpunit:*), Read
---
Run this project's PHP quality pipeline in order, stopping at the first failure and reporting it. Skip any tool that is not installed (check `vendor/bin/`).

**Scoped mode**: if invoked as `/quality changed`, scope the style/static steps to what actually changed instead of the whole repo. Compute the changed PHP files with `git diff --name-only --diff-filter=d $(git merge-base HEAD origin/develop 2>/dev/null || git merge-base HEAD origin/main)...HEAD -- '*.php'` plus `git diff --name-only --staged -- '*.php'`. Pass that file list as path arguments to Pint, Rector, and PHPStan (all three accept explicit paths). Tests still run in full: Pest stays the unscoped gate either way. If the changed list is empty, say so and stop.

1. **Pint** (style): `vendor/bin/pint --test` - report style issues, do not auto-fix unless I ask. Do not add `-p`/`--parallel`: measured 3x slower than serial on a small-to-medium repo (worker-spawn overhead dominates), not worth it here.
2. **Rector** (structural, dry-run): `vendor/bin/rector --dry-run` if present. No parallel flag exists in Rector's CLI (checked 2.5) - nothing to add.
3. **Larastan / PHPStan** (static analysis): `vendor/bin/phpstan analyse` if present. Parallelism is config-driven (`phpstan.neon` `parallel:` block) and on by default - no CLI flag needed.
4. **Pest** (tests): `vendor/bin/pest --parallel`, or `vendor/bin/phpunit` (no parallel support - PHPUnit only, not Pest, so this fallback stays serial).

Report each step's result. On the first failure, stop and summarize what failed with the key output; do not run later steps. If everything passes, say so concisely.
