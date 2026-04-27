---
description: Verify the codebase still respects Packwerk + FSD architecture rules.
allowed-tools: ['Bash', 'Read', 'Grep']
---

Run a full architectural audit. Report violations clearly with line refs.

## Backend — Packwerk

```bash
cd backend && bin/packwerk check
```

If violations:
- Show each violation with file:line.
- For each, propose one of: (a) add the dependency to `package.yml`, (b) refactor the importing code, (c) move the constant to a different pack. Recommend the cleanest option.

## Frontend — FSD via ESLint

```bash
cd frontend && pnpm exec eslint . --rule 'boundaries/element-types: error' --rule 'no-restricted-imports: error'
```

If violations:
- Show each: `<file>:<line>: imports <X> from <wrong layer>`.
- Recommend: move the imported thing down a layer, or restructure the importer.

## Manual checks

Also report:

```bash
# 1. Any deep imports past the public API?
grep -RE 'from ['\''"]@/(features|entities|widgets|pages|app)/[^/]+/(?!index)' frontend/src/ || echo "none"
```

```bash
# 2. Any `useState` for cross-component data? (heuristic: useState in a file that imports from features or pages)
grep -lE 'useState' frontend/src/widgets/ frontend/src/features/ 2>/dev/null || echo "none"
```

```bash
# 3. Any service objects living outside packs?
ls -la backend/app/services/ 2>/dev/null || echo "no app/services/ directory — good"
```

End with a one-line verdict:
- `✅ Architecture clean.` — no violations
- `⚠️ N violations found.` — list above
