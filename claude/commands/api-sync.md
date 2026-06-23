---
description: Generate or update a Postman collection from the app's API routes via the Postman MCP
allowed-tools: Bash(php artisan route:list:*), mcp__claude_ai_Postman__*, Read, Grep, Glob
---
Sync a Postman collection with this Laravel app's API routes, using the Postman MCP.

1. List the routes: `php artisan route:list --json`. Focus on `api/` routes; capture method, URI, name, and middleware.
2. Via the Postman MCP, find an existing collection for this project (ask which workspace/collection if ambiguous) or offer to create one.
3. Add or update one request per route: method, URL with `:params`, and auth where middleware implies it (e.g. `auth:sanctum` -> bearer token). Group requests by resource.
4. Derive example request bodies from Form Request validation rules where you can; otherwise leave them empty. Do not invent fields.
5. Summarize what you created or updated and link the collection. Confirm with me before deleting or overwriting anything in Postman.
