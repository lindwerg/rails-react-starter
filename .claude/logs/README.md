# .claude/logs

Progress logs that Claude reads at session start to understand what's been done.

## Naming

```
YYYY-MM-DD-<short-kebab-slug>.md
```

Examples:
- `2026-04-28-stage-1-scaffolding.md`
- `2026-05-02-fix-jwt-expiry.md`
- `2026-05-10-feat-comments-crud.md`

## Workflow

1. Plan-mode → execute → done.
2. Run `make log` (or copy `_TEMPLATE.md`) → fill in.
3. Append a one-line index entry to `/PROGRESS.md`.
4. Commit log + PROGRESS.md update along with the work.

## What goes in a log

- **Что сделано** — concrete changes (files added/changed, features delivered)
- **Решения и почему** — non-obvious tradeoffs, library choices, architectural calls
- **Открытые вопросы / TODO** — known limitations, deferred work
- **Куда дальше** — what the next session should pick up first

Keep it under 200 lines. Long logs lose value. If a session was huge, summarize and link to artifacts.
