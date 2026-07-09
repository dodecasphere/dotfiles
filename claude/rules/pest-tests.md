---
paths:
  - "tests/**/*.php"
---

# Pest Test Rules

- Follow the pest-patterns skill for idioms: datasets over copy-paste,
  higher-order expectations, architecture tests, query-count assertions.
- Test behavior, not implementation. One behavior per `it()`.
- Laravel's bare `throttle:N,1` shares one bucket per user across every
  route using it; never assert two throttled endpoints in one test.
- A gate meant to allow guests needs a nullable-typed first parameter
  (`?User $user`) or it silently denies every guest. Write the failing
  guest test whenever a gate guards a public route.
- After rewriting or deleting a file with external references, run the
  full suite once, not just the touched spec.
