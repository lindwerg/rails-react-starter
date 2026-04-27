# PROGRESS.md

Index of all `.claude/logs/` entries — read top-down. Newest first.

> Format: `- YYYY-MM-DD — [title](.claude/logs/file.md) — one-line summary`

---

## 2026-04

- 2026-04-28 — [Stage 13: GitHub-template publish + one-command bootstrap](.claude/logs/2026-04-28-stage-13-template-publish.md) — Опубликован как https://github.com/lindwerg/rails-react-starter (template, public). `curl … | bash -s my-app` ставит весь стек: rename placeholders → install mise/Docker/gh/lefthook → auto-allocate free ports → fill .env/Procfile/vite/docker → master.key → docker up → bundle/pnpm/playwright → initial commit. Все pre-push gates зелёные после вытаскивания pre-existing багов: packwerk folder_privacy typo, RSpec specs pattern, FactoryBot definition_paths, exactOptionalPropertyTypes, vitest e2e exclude.
- 2026-04-28 — [Stage 12: «ребёнок справится» upgrade](.claude/logs/2026-04-28-stage-12-kid-can-develop.md) — 8 атомарных коммитов: hard-block guards, 5 субагентов, /go + make doctor, auto-terse + statusline, shadcn-ui + sequential-thinking MCP, bin/dev + seed-rich + api-docs, ADR/Troubleshooting/Architecture docs, CodeQL + mutation opt-in.
- 2026-04-27 — [Stage 11: First-run fixes & live E2E](.claude/logs/2026-04-27-stage-11-first-run-fixes.md) — Bootstrap, Zeitwerk inflector, Alba 3, Pagy 9, Docker mirrors, camelCase serializers; full UI happy path verified via Playwright MCP.
- 2026-04-28 — [Stage 10: Automation](.claude/logs/2026-04-28-stage-10-automation.md) — CLAUDE.md как контракт, .mcp.json (context7+magic-mcp+playwright), 8 slash-команд, скаффолдинг-скрипты, усиленные хуки, bootstrap.sh, output style.
- 2026-04-28 — [Stage 9: Final summary](.claude/logs/2026-04-28-stage-9-final-summary.md) — Starter ready: 239 files, all 9 stages done in one session.
- 2026-04-28 — [Stage 8: DevOps](.claude/logs/2026-04-28-stage-8-devops.md) — 3 GitHub Actions workflows, Dependabot, Kamal 2 template, backend Dockerfile.
- 2026-04-28 — [Stage 7: Frontend Posts CRUD](.claude/logs/2026-04-28-stage-7-frontend-posts.md) — entities/post, create/edit/delete-post features, post-feed widget, pages, Playwright E2E.
- 2026-04-28 — [Stage 6: Frontend Auth](.claude/logs/2026-04-28-stage-6-frontend-auth.md) — entities/user+session, auth-by-email feature, sign-in/sign-up pages, E2E.
- 2026-04-28 — [Stage 5: Frontend skeleton](.claude/logs/2026-04-28-stage-5-frontend-skeleton.md) — Vite+React 19 strict TS, FSD scaffolding, shared/ui kit, Vitest+Playwright+MSW+Storybook.
- 2026-04-28 — [Stage 4: Posts CRUD](.claude/logs/2026-04-28-stage-4-posts-crud.md) — Post model, dry-validation form, Create/Update/Destroy services, PostsController, full request specs.
- 2026-04-28 — [Stage 3: Auth + Users](.claude/logs/2026-04-28-stage-3-auth-users.md) — User model, JWT issuer/verifier, SignUp/SignIn services, Auth/Me controllers, request specs.
- 2026-04-28 — [Stage 2: Backend skeleton](.claude/logs/2026-04-28-stage-2-backend-skeleton.md) — Rails 8 API config, Packwerk 4 слоя, 6 packs, RSpec/RuboCop/SimpleCov.
- 2026-04-28 — [Stage 1: Repository scaffolding](.claude/logs/2026-04-28-stage-1-scaffolding.md) — Created repo skeleton, CLAUDE.md, .claude/logs/, Makefile, docker-compose, .mise.toml.

---

## How to read this file

1. Top entry = most recent state of the project.
2. Each log entry has: what was done, why, open TODOs, and what's next.
3. Claude reads the **two latest entries** at session start to understand context.
