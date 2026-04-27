---
description: Scaffold a new backend pack. Usage:/new-pack <name> [layer]
allowed-tools: ['Bash', 'Read']
---

Create a new Packwerk pack named **$ARGUMENTS** in the appropriate layer (default `business_domain`).

Run the scaffolding script:

```bash
.claude/scripts/new-pack.sh $ARGUMENTS
```

This creates:
- `backend/packs/<name>/package.yml` (with correct layer + sensible default dependencies)
- `backend/packs/<name>/README.md` (with prompt to fill in responsibility)
- `backend/packs/<name>/app/{models,services,public}/.keep`
- `backend/packs/<name>/spec/{models,services,factories}/.keep`

After creation:

1. Read the new `package.yml` and `README.md`. Confirm to the user the layer and dependencies look right.
2. Update the root `backend/package.yml` to add the new pack to its `dependencies:` list (only if the api pack will need it).
3. Suggest the next step: `/tdd <first behavior of the new pack>`.

Do NOT add domain code yet — only the skeleton. Domain code goes through `/tdd`.
