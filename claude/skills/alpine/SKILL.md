---
name: alpine
description: Conventions for Alpine.js, used for light interactivity outside full Vue/Inertia pages. Use when adding small interactive behavior (toggles, dropdowns, tabs) to Blade or server-rendered markup.
---

# Alpine.js

Alpine is for small islands of interactivity (dropdowns, toggles, tabs, simple form niceties) where a full Vue/Inertia component is overkill. On this stack, app pages are Vue/Inertia; Alpine is progressive enhancement on the edges.

## When to use Alpine vs Vue
- Alpine: sprinkle-on behavior in Blade or otherwise server-rendered HTML, no build step, minimal state.
- Vue/Inertia: anything that is a real application view, has meaningful state, or talks to the backend.
- Do not mount Alpine and Vue on the same DOM nodes; they fight over the DOM. Keep them in separate regions.

## Patterns
- Keep `x-data` small. When logic grows, extract a component with `Alpine.data('dropdown', () => ({ ... }))` and reference it by name.
- Use `x-show` for toggling visible elements, `x-if` (in `<template>`) for adding/removing from the DOM.
- Add `x-cloak` (plus the matching CSS rule) to avoid a flash of unstyled/expanded content before Alpine initializes.
- Share cross-component state with `Alpine.store(...)`, not globals.
- Use `x-model`, `x-on`/`@`, `x-bind`/`:`, and `$refs` / `$dispatch` for component communication.

## Things to avoid
- Business logic in `x-data`. Keep it presentational; the server owns real logic.
- Large inline expressions in attributes. Move them into an `Alpine.data()` component.
- Re-implementing something the page already does in Vue. Pick one tool per region.
- Inline handlers if the project enforces a strict CSP (Alpine's default eval-style expressions need `unsafe-eval` or the CSP build).
