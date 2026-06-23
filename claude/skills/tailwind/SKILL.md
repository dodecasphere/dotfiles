---
name: tailwind
description: Conventions for styling with Tailwind CSS v4 (CSS-first config). Use when adding or changing styles, theme tokens, or component markup in a project using Tailwind.
---

# Tailwind CSS v4

Tailwind v4 is CSS-first. Confirm the project is on v4 (a single `@import "tailwindcss"` and a `@theme` block, no `tailwind.config.js`); if it still uses `@tailwind base/components/utilities` and a JS config, it is v3, so follow that instead.

## Configuration (v4)
- Import with `@import "tailwindcss";` at the top of the main CSS file.
- Define design tokens in CSS with `@theme { --color-brand: ...; --font-display: ...; }`, not a JS config. Tokens become utilities automatically (`bg-brand`, `font-display`).
- Layer tokens: primitives (raw values), then semantic aliases (`--color-primary` referencing a primitive), then component tokens. This keeps theming inspectable in DevTools.
- Use `@custom-variant` / `@utility` for project-specific variants and utilities rather than plugins where possible.

## Writing styles
- Utility-first in the markup. Prefer real tokens over arbitrary values; reach for `[...]` arbitrary values only when no token fits.
- Repeated utility clusters become a Vue component (or an Alpine snippet), not an `@apply` blob. Use `@apply` sparingly, for genuinely shared primitives only.
- Mobile-first: base styles, then `sm:`/`md:`/`lg:` up. Use built-in container queries (`@container`, `@sm:`) for component-driven responsiveness.
- Dark mode via `dark:`; pick class strategy or `prefers-color-scheme` and stay consistent.

## Things to avoid
- v3 leftovers after an upgrade: `tailwind.config.js`, `@tailwind` directives, and renamed legacy classes (e.g. `flex-shrink-0` -> `shrink-0`, `bg-gradient-to-r` -> `bg-linear-to-r`). Run `npx @tailwindcss/upgrade` for migrations.
- `@apply` soup that recreates a CSS framework. If a block has many `@apply`s, make it a component.
- Arbitrary values where a theme token exists; it fragments the design system.
