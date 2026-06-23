---
description: Run the Laravel quality pipeline (Pint, Rector, Larastan, Pest), stopping at the first failure
allowed-tools: Bash(vendor/bin/pint:*), Bash(vendor/bin/rector:*), Bash(vendor/bin/phpstan:*), Bash(php artisan:*), Bash(vendor/bin/pest:*), Bash(vendor/bin/phpunit:*), Read
---
Run this project's PHP quality pipeline in order, stopping at the first failure and reporting it. Skip any tool that is not installed (check `vendor/bin/`).

1. **Pint** (style): `vendor/bin/pint --test` - report style issues, do not auto-fix unless I ask.
2. **Rector** (structural, dry-run): `vendor/bin/rector --dry-run` if present.
3. **Larastan / PHPStan** (static analysis): `vendor/bin/phpstan analyse` if present.
4. **Pest** (tests): `vendor/bin/pest`, or `vendor/bin/phpunit`.

Report each step's result. On the first failure, stop and summarize what failed with the key output; do not run later steps. If everything passes, say so concisely.
