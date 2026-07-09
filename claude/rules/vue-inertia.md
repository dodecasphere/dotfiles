---
paths:
  - "resources/js/**/*.vue"
  - "resources/js/**/*.js"
---

# Vue / Inertia Rules

- Follow the inertia-vue skill for page, layout, form, and props
  conventions (Composition API, script setup, plain JS).
- Never fire a second Inertia visit before the first finishes: Inertia
  tracks one active visit and silently aborts the previous. In loops,
  await a promise resolved from the visit's own `onFinish` inside
  `for...of`.
- Never reference `window`/`document` directly in an inline template
  handler; define a named function in `<script setup>` and bind to that.
- Anything passed as Inertia props is fully visible in the page payload;
  keep hidden attributes, tokens, and other users' rows out.
- Per-feature data belongs in that feature's controller props, never in
  `HandleInertiaRequests::share()` (which runs on every page load).
