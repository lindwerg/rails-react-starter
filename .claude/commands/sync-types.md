---
description: Regenerate frontend API types from backend OpenAPI.
allowed-tools: ['Bash']
---

Regenerate `frontend/src/shared/api/types.gen.ts` from the Rails OpenAPI spec.

```bash
make typegen
```

This runs `rake rswag:specs:swaggerize` on the backend (which executes the rswag specs to produce `swagger.yaml`), then `openapi-typescript` on the frontend.

After it finishes:
1. Run `cd frontend && pnpm typecheck` to catch any new type errors caused by API shape changes.
2. If types changed in ways that break code, fix call sites — or update backend specs if the change was unintentional.
