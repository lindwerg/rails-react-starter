# Contributing

This project follows a strict, automated workflow. Most of the rules are enforced by CI / hooks / linters — but the philosophy is in `CLAUDE.md`.

## Before you start

Read [CLAUDE.md](./CLAUDE.md). Then read it again. Yes, all of it.

## The rules in 30 seconds

1. **TDD first** — failing test, then code. Always.
2. **Plan-mode for non-trivial work** — Claude Code's plan mode (Shift+Tab). Approve before executing.
3. **Architecture is enforced** — Packwerk on backend (4 layers), FSD on frontend (6 layers).
4. **MCP usage is mandatory**:
   - `context7` for any library question.
   - `magic-mcp` for any new UI component.
5. **Pre-merge checklist must be all green:**
   - `make test` · `make lint` · `make typecheck` · `make security` · `make pack-check`
6. **Logs are mandatory** — every meaningful session writes a file in `.claude/logs/` and adds one line to `PROGRESS.md`.

## Commits

```
<type>(<scope>): <subject>
```

`type` ∈ `feat | fix | refactor | test | docs | chore | perf | ci | style`

Atomic commits. Tests with the feature (or as a preceding `test:` commit per TDD).

## Branches

`feat/<slug>`, `fix/<slug>`, `chore/<slug>`. Never push to `main` directly.

## PRs

Use the template in `.github/PULL_REQUEST_TEMPLATE.md`. The checklist is binding, not aspirational.

## Setup

Fresh clone:
```bash
./bootstrap.sh
```

Then:
```bash
make dev
```

Open http://localhost:5173 — log in with `demo@example.com` / `password123`.

## Something is unclear

Open an issue with the `question` label, or ask Claude — it knows the rules in this repo.
