---
name: tech-stack
description: "The user's typical web app stack and the latest stable versions to target"
metadata: 
  node_type: memory
  type: user
  originSessionId: a828f7c1-d77a-45fd-8b99-3f2823003504
---

Typical web app stack: **Laravel + Inertia + Vue 3** (Composition API, `<script setup>`) **+ Tailwind + Alpine**, on **Postgres**, deployed via **Laravel Forge to DigitalOcean**. Plain JavaScript, not TypeScript, in app code. Capacitor is not used. Filament is in use on at least one project (see the Filament theme entry in `packs/laravel`), correcting an earlier note here that claimed otherwise.

This file is the identity fact only: which stack the user defaults to, so a session can pick the right technology packs when a project has no `profile:` line yet. Everything else (target versions, idioms, gotchas) lives in Engineering OS packs at `engineering-os/plugins/core/references/packs/`, loaded per project via that `profile:` line in `.engineering-os/STATE.md`. Map: `laravel`, `laravel-inertia`, `laravel-pest`, `vue`, `vue-testing`, `vue-reka`, `tailwind`, `css`, `alpine`, `postgres`, `browser-testing`. Each pack carries its own version baseline; re-confirm "latest" on the web before relying on one, since the user expects current releases.
