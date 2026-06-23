---
description: Generate a Laravel model factory (and optional seeder) from a model or migration
allowed-tools: Bash(php artisan:*), Read, Write, Edit, Glob, Grep
argument-hint: [Model name]
---
Create a model factory for "$ARGUMENTS" (or the model I name).

1. Read the model and its migration to get the real columns, types, casts, enums, and relationships.
2. Generate the factory (`php artisan make:factory`) and fill `definition()` with faker values matching each column: respect nullable, unique, enum, and length constraints, and use realistic formatters. Add factory states for obvious variants (e.g. `unverified`, `admin`).
3. Wire relationships with factory relationship methods wherever the schema has foreign keys.
4. Offer to generate a matching seeder if it would help.
5. Use only columns the model/migration actually defines; do not invent fields. Show the result.
