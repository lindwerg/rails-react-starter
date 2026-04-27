# Rails 8 + React 19 Starter

Production-ready monorepo template for any project on **Rails 8 (API) + React 19 (FSD)**, with TDD baked in, full DevOps wiring, and a Claude-Code workflow optimized for plan-mode iterations.

> **Architecture:** Packwerk modular monolith on the backend, Feature-Sliced Design on the frontend.

---

## Quick start

**One-liner — clone, rename, install everything, in one go:**

```bash
curl -fsSL https://raw.githubusercontent.com/lindwerg/rails-react-starter/main/create-app.sh | bash -s my-shop
cd my-shop && make dev
```

That single command:
- Clones the template into `./my-shop/`.
- Renames every `App` / `app_*` placeholder (Rails module, DB names, container names, session key, Kamal service) to your project name.
- Installs **mise → Ruby 3.3.6 + Node 22 + pnpm 9** (auto-installs mise itself if missing).
- Installs **Docker Desktop** (macOS, via brew) and **starts it** if not running.
- Picks **free TCP ports** for Rails / Vite / Postgres / Mailpit and writes them to `.ports.env` and `.env`.
- Generates the Rails `master.key`, runs migrations + seeds, installs lefthook, lays down `.mcp.env`.
- Verifies RSpec + Packwerk are clean.

Or via GitHub's "Use this template" button + `gh`:

```bash
gh repo create my-shop --template lindwerg/rails-react-starter --clone --public
cd my-shop && ./bin/init
```

After install: open http://localhost:$BACKEND_PORT — sign in as `demo@example.com / password123`.

**Stuck on the first run?** `make doctor` checks mise, Docker, ports, env files, hooks — and prints the exact fix for each ✗. **`make heal`** auto-fixes the most common breakage (re-runs install, re-allocates ports, restarts Docker). See also [docs/TROUBLESHOOTING.md](./docs/TROUBLESHOOTING.md).

**Inside Claude Code:** start any session with `/go` — it reads the latest log + git state and routes you to the right next action.

---

## Tour — read in this order

1. [`CLAUDE.md`](./CLAUDE.md) — operating contract for the project. Rules for every PR.
2. [`docs/ARCHITECTURE.md`](./docs/ARCHITECTURE.md) — picture of Packwerk + FSD layers and how a request flows through them.
3. [`docs/DECISIONS.md`](./docs/DECISIONS.md) — *why* we chose what we chose (Packwerk over engines, JWT in cookies, etc.).
4. [`docs/TROUBLESHOOTING.md`](./docs/TROUBLESHOOTING.md) — known pain points and fixes.
5. One pack: [`backend/packs/posts/`](./backend/packs/posts/) — the canonical example. Read its `package.yml`, model, services, controller, specs.
6. One slice: [`frontend/src/features/create-post/`](./frontend/src/features/create-post/) — canonical FSD feature.

After that you'll know enough to ship.

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
| `make bootstrap` | Idempotent first-run: install + allocate free ports + write `.env` + `master.key` |
| `make heal` | Auto-fix common breakage (re-allocate ports, re-install gems/npm, restart Docker) |
| `make ports` | Print currently-allocated dev ports |
| `make dev` | Start Postgres + Rails + Vite using ports from `.ports.env` |
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
