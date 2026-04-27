---
description: Scaffold a new FSD slice. Usage: /new-slice <layer> <name>
allowed-tools: ['Bash', 'Read']
---

Create a new FSD slice. **$ARGUMENTS** must be `<layer> <slice-name>` where layer ∈ {entities, features, widgets, pages}.

Run:

```bash
.claude/scripts/new-slice.sh $ARGUMENTS
```

Slice receives the canonical FSD segments:
- `ui/` — visual components
- `model/` — types, schemas, hooks, stores
- `api/` — fetchers / mutations
- `lib/` — slice-local helpers
- `index.ts` — public API barrel

After creation:

1. Read the new `index.ts`. It will have a placeholder; replace with real exports as you implement.
2. **For new visual components inside the `ui/` segment, USE `magic-mcp` first** (CLAUDE.md §2.1).
3. Suggest the next step: `/tdd <first behavior of the new slice>`.
