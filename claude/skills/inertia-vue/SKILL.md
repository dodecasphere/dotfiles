---
name: inertia-vue
description: Conventions for building frontend pages with Inertia.js v3 and Vue 3 (Composition API, script setup) on a Laravel backend. Use when creating or changing Inertia pages, layouts, Vue components, forms, or the data passed from controllers to the frontend.
---

# Inertia v3 + Vue 3

Frontend guidance for Laravel + Inertia v3 + Vue 3 (3.5 is current stable; do not rely on 3.6/Vapor until it ships). The server is the source of truth; Inertia pages are Vue components rendered from controller props. Confirm the project is on Inertia v3 (built-in HTTP client, the `@inertiajs/vite` plugin, `useLayoutProps`); if it still uses Axios and `Inertia::lazy()`, it is v2, so follow that instead.

## Vue 3 component style
- `<script setup>` + Composition API for all new components.
- `defineProps` / `defineEmits` with types. Never mutate a prop; emit or copy locally.
- Extract reusable logic into composables (`useX()`), not mixins.
- `computed` for derived state; `watch` for side effects only.
- Always key `v-for`. Never `v-html` on user-controlled content (XSS).
- Pinia only for genuinely client-side shared state; most state lives on the server, so prefer props plus reloads over a store.

## Inertia data flow
- Controllers return `Inertia::render('Page', [...])`. Shape props deliberately; never dump whole models (respect `$hidden`, avoid leaking columns).
- Keep shared data (`HandleInertiaRequests::share()`) small: auth summary, flash, csrf. It ships on every response.
- Use `Inertia::optional(fn () => ...)` for expensive props that should run only on demand (this replaces v2's `Inertia::lazy()`).
- Partial reloads (`only` / `except`) refetch just what changed; deferred props now support dot-notation targeting.

## Inertia v3 specifics (use them)
- **Built-in HTTP client** (Axios is gone in v3). For standalone requests that should not trigger a page visit, use the `useHttp` hook, not axios/fetch.
- **Layouts**: persistent layouts exchange data with pages via the `useLayoutProps` hook.
- **SSR in dev** works automatically through the `@inertiajs/vite` plugin; no separate Node server.
- **Optimistic updates**: apply changes instantly with automatic rollback on failure (toggles, reordering).
- **Deferred props** (`Inertia::defer()` + `<Deferred>`): render immediately, stream heavy data after. For dashboards/analytics.
- **Prefetching**: prefetch on `<Link>` for likely-next pages (hover-intent) for instant navigation.
- **Polling**: `usePoll` / `router.poll()` for live-ish data.
- Renamed APIs: visit callbacks `onHttpException` / `onNetworkError` (were `invalid` / `exception`); `router.cancelAll()` (was `router.cancel()`).

## Forms
- Use `useForm` (or the `<Form>` component) for every form: it manages `processing`, `errors`, `progress`, and dirty state.
- Submit with `form.post(route(...), { preserveScroll: true, onSuccess, onError })`.
- Show server validation via `form.errors`. Use `form.transform()` to shape payloads and `form.reset()` on success.

## Things to avoid
- Reaching for Axios (removed in v3) or hand-rolled fetch where `router` / `useForm` / `useHttp` fit.
- Bloated shared props (they cost every request).
- Client stores mirroring server state a reload would refresh.
- Anchor tags for internal navigation; use `<Link>`.
- Secrets or API keys in props or the bundle.
