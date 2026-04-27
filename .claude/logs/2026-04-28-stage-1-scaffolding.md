---
date: 2026-04-28
plan: wild-crunching-jellyfish.md
status: completed
commits:
  - (pending)
---

# Stage 1: Repository scaffolding

## Что сделано
- Создана базовая структура каталогов: `backend/`, `frontend/`, `.claude/`, `.github/`, `config/`
- Написан `CLAUDE.md` — главный документ: стек, TDD-правило, FSD/Packwerk границы, plan-mode workflow, формат логов, pre-PR чек-лист, "что нельзя делать"
- `README.md` — Quick start + структура + команды
- `PROGRESS.md` — индекс логов (1 запись)
- `.gitignore`, `.editorconfig`, `.mise.toml` (Ruby 3.3.6, Node 22.11.0, pnpm 9.15.0)
- `.env.example` — все переменные окружения
- `Makefile` — единая точка входа (setup, dev, test, e2e, lint, typecheck, security, typegen, pack-check, log)
- `Procfile.dev` — для overmind/foreman (web, worker, frontend)
- `docker-compose.yml` — Postgres 16 + Mailhog
- `lefthook.yml` — pre-commit (rubocop, eslint, prettier), commit-msg (commitlint), pre-push (тесты + packwerk)
- `.claude/logs/README.md` + `_TEMPLATE.md` — формат логов
- `.claude/settings.json` — права + хук-напоминалка о написании лога после ExitPlanMode
- `.github/PULL_REQUEST_TEMPLATE.md` — pre-merge чек-лист

## Решения и почему
- **Монорепо, а не два отдельных репо**: общий CI, единый docker-compose, проще для шаблона. Backend и frontend всё равно слабосвязанные через OpenAPI.
- **mise вместо asdf/rbenv+nvm**: один инструмент, один файл, работает кроссплатформенно.
- **lefthook вместо husky**: быстрее, нативный, без Node-зависимости в pre-push.
- **`.claude/settings.json` хук на ExitPlanMode**: использует marker-file `/tmp/claude-just-exited-plan-mode` — Stop-хук показывает напоминалку после plan-сессии. Простая и надёжная схема.
- **`make typegen` через `rswag:specs:swaggerize` + `openapi-typescript`**: единый источник типов от Rails до фронта.
- **PR template обязывает обновлять `.claude/logs/`**: дисциплинирует обращение с логами.

## Открытые вопросы / TODO
- Папка `.claude/commands/` пока пустая — кастомные slash-команды добавим по мере появления повторяющихся задач.
- `make dev` использует `overmind || foreman` — пользователь должен иметь хотя бы один установленным (mise это не покрывает; добавим в setup-tools при первом запуске).

## Куда дальше
**Этап 2** — Backend skeleton:
- Подготовить `backend/Gemfile` и базовую структуру Rails 8 API
- Установить и сконфигурить Packwerk + packwerk-extensions
- `packwerk.yml` с 4 слоями (orchestrator → business_domain → platform → utility)
- Создать пустые packs: `api`, `auth`, `users`, `posts`, `platform`, `shared`
- RSpec + FactoryBot + RuboCop + Brakeman + SimpleCov
- Health-check `GET /up`
