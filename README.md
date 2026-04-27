# Rails 8 + React 19 Starter

Production-ready monorepo template for any project on **Rails 8 (API) + React 19 (FSD)**, with TDD baked in, full DevOps wiring, and a Claude-Code workflow optimized for plan-mode iterations.

> **Architecture:** Packwerk modular monolith on the backend, Feature-Sliced Design on the frontend.

---

## Quick start

```bash
# 1. Clone and rename
git clone <this-repo> myapp && cd myapp

# 2. Install language runtimes (Ruby 3.3, Node 22) via mise
mise install

# 3. Install dependencies, prepare DB, install git hooks
make setup

# 4. Start everything (Postgres, Rails API, Vite frontend)
make dev
```

Open http://localhost:5173 — register, log in, create posts.

---

## What's inside

```
.
├── backend/                    # Rails 8 API (Packwerk modular monolith)
│   ├── packs/                  #   feature packs: api, auth, users, posts, platform, shared
│   └── ...
├── frontend/                   # React 19 + Vite + FSD
│   └── src/{app,pages,widgets,features,entities,shared}
├── .claude/
│   ├── logs/                   # Progress logs after each plan-mode session
│   ├── commands/               # Custom Claude slash-commands
│   └── settings.json           # Hooks (e.g. log reminder)
├── .github/workflows/          # CI: backend / frontend / security
├── config/deploy.yml           # Kamal 2 deployment
├── docker-compose.yml          # Postgres + Mailhog
├── Makefile                    # Unified commands
├── CLAUDE.md                   # ← READ THIS — workflow, TDD, architecture rules
└── PROGRESS.md                 # Log index
```

---

## Working with Claude

This template is optimized for **Claude Code** with a plan-mode-first workflow.

1. Open Claude Code in the repo root.
2. Tell Claude what you want — Claude reads `CLAUDE.md` + `PROGRESS.md` + recent logs to ground itself.
3. For non-trivial work, Claude enters **plan mode**, writes a plan, asks for approval.
4. After execution, Claude writes a log to `.claude/logs/` and updates `PROGRESS.md`.
5. Next session = continue where you stopped, with full history.

See [CLAUDE.md](./CLAUDE.md) for the full workflow.

---

## Commands

| Command | What it does |
|---|---|
| `make setup` | Install everything (Ruby, Node, gems, npm packages, DB, git hooks) |
| `make dev` | Start Postgres + Rails (port 3000) + Vite (port 5173) |
| `make test` | RSpec + Vitest |
| `make e2e` | Playwright end-to-end tests |
| `make lint` | RuboCop + ESLint + Prettier |
| `make typecheck` | TypeScript strict check |
| `make security` | Brakeman + bundler-audit + npm audit |
| `make typegen` | Regenerate frontend API types from backend OpenAPI |
| `make pack-check` | Verify Packwerk architectural boundaries |
| `make log` | Scaffold a new entry in `.claude/logs/` |

---

## Stack reference

**Backend** Ruby 3.3 · Rails 8 · PostgreSQL 16 · Solid Queue · Packwerk · RSpec · FactoryBot · Pundit · Alba · Pagy · Rswag · Brakeman · Lograge · Sentry

**Frontend** Node 22 · pnpm · Vite 6 · React 19 · TypeScript strict · TanStack Query · Zustand · React Router 7 · React Hook Form · Zod · Tailwind v4 · shadcn/ui · Vitest · Testing Library · Playwright · MSW · Storybook · ESLint flat config · lefthook

**DevOps** Docker Compose · Kamal 2 · GitHub Actions · Dependabot

---

## License

MIT.
