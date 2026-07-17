---
name: tech-stack
description: "The user's typical web app stack and the latest stable versions to target"
metadata: 
  node_type: memory
  type: user
  originSessionId: a828f7c1-d77a-45fd-8b99-3f2823003504
---

Typical web app stack: **Laravel + Inertia + Vue 3** (Composition API, `<script setup>`) **+ Tailwind + Alpine**, on **Postgres**, deployed via **Laravel Forge to DigitalOcean**. NOT Filament, NOT Capacitor — the original project handoff wrongly assumed those; corrected 2026-06-23.

**Plain JavaScript, not TypeScript.** The user finds TS too verbose/messy and has chosen to skip it (web apps are solo/small, so the main TS win — catching PHP↔Vue prop drift — is a nice-to-have, not essential). Use runtime `defineProps` declarations; JSDoc + `// @ts-check` is the available middle path if editor hints are ever wanted, but do not introduce `.ts` files or type syntax in their app code. (Config files like `vite.config.ts` may still be TS; that is fine.)

Latest stable versions to target (confirmed on the web 2026-06-23):
- **Laravel 13** (13.16.x)
- **Vue 3.5** — 3.6/Vapor still beta, do not target
- **Inertia v3** (stable since Mar 2026): built-in XHR client (Axios removed), `useHttp`, `useLayoutProps`, `Inertia::optional()` replaces `Inertia::lazy()`, SSR in dev via `@inertiajs/vite`, optimistic updates; deferred props/prefetch/polling/useForm/Form carried over from v2
- **Tailwind v4.3** — CSS-first `@theme`, no JS config, `@import "tailwindcss"`
- **Alpine 3**
- **Postgres 18** (19 in beta)

Stack best practice guidance lives in Engineering OS packs (`engineering-os/plugins/core/references/packs/`), loaded per project via the `profile:` line in `.engineering-os/STATE.md`; only the `inertia-vue` skill remains in `claude/skills/` pending the vue pack's first real load (shadowed copies of the rest: `claude/_shadow/2026-07-17/`). See [[claude-config-layer]]. Always re-confirm "latest" on the web before relying on a version; the user expects current releases.
