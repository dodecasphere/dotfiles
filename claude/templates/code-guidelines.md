# Code guidelines

House rules for this project's code, distilled from real findings (a sweep,
an incident, a recurring review comment) rather than invented up front. The
global `code-guidelines-gate` hook points here on the first code edit of
every session - keep this current, not aspirational.

## Universal

- (naming conventions, error-handling philosophy, when to abstract vs. inline)
- (what "done" means: tests, types, lint - see the project's own CLAUDE.md)

## Backend

### Layering (the write path)

- (controller -> action/service -> model, or whatever this project's actual
  layering is - name the real files/directories, not a generic pattern)

### Conventions

- (framework-specific idioms this project has settled on)

### Performance floor

- (concrete, previously-found issues: N+1 patterns, missing indexes,
  anything a performance-reviewer pass already caught once - list them so
  they don't recur)

### Security floor

- (concrete, previously-found issues: authz gaps, mass-assignment, injection
  vectors already caught once)

## Frontend

### Components

- (design-system/component conventions - what's hand-rolled vs. governed)

### Styling

- (token/CSS conventions, what's banned and why)

### Async/framework correctness

- (framework-specific gotchas already hit once - cancellation, race
  conditions, hydration mismatches, whatever actually bit this project)

### Hard invariants (lint- and test-enforced, listed for completeness)

- (things a linter or test already blocks - list them here too so a human
  or an AI without the linter still knows the rule)

## Tests

- (test-first expectations, what goes in unit vs. feature/integration,
  factory/fixture conventions)

## What enforces what

- (a short table or list: which of the above is enforced by a hook/lint/CI
  check vs. relies on this document alone - honesty about the gap matters
  more than the list itself)
