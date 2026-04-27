---
date: 2026-04-28
plan: wild-crunching-jellyfish.md
status: completed
commits:
  - (pending)
---

# Stage 8: DevOps

## Что сделано
**GitHub Actions**
- `ci-backend.yml` — поднимает Postgres-сервис, кеширует Bundler, запускает RuboCop → Brakeman → bundler-audit → packwerk check → RSpec; артефакт coverage. Триггер только на изменения `backend/**`.
- `ci-frontend.yml` — два jobs: `test` (lint, format, typecheck, vitest, build) и `e2e` (поднимает backend + frontend preview, ждёт через `wait-on`, гоняет Playwright). Артефакты coverage + playwright-report.
- `security.yml` — еженедельный cron + push-trigger на lockfiles: bundler-audit, Brakeman, pnpm audit + Trivy filesystem scan (HIGH/CRITICAL fail).

**Dependabot** (`.github/dependabot.yml`)
- 4 экосистемы: bundler (backend), npm (frontend), github-actions, docker
- Группировка PR по production / development зависимостям — меньше шума
- Лимиты open PR: 5 на экосистему

**Kamal 2** (`config/deploy.yml`)
- Шаблон с placeholders `<YOUR_REGISTRY_USER>`, `<YOUR_DOMAIN>`, `<SERVER_IP>`, `<REGISTRY>`
- 2 servers role: `web` и `worker` (Solid Queue в отдельном процессе)
- Proxy с автоматическим SSL и `/up` healthcheck
- Postgres как accessory (для маленьких прод-сетапов)
- Aliases: `console`, `shell`, `logs`, `dbc`

**Docker**
- `backend/Dockerfile` — multi-stage (build → runtime), bootsnap precompile, non-root user, libjemalloc2/libvips для image processing
- `backend/bin/docker-entrypoint` — делает `db:prepare` перед запуском server
- `backend/.dockerignore` — исключает log/tmp/storage/spec/etc.

## Решения и почему
- **Backend и frontend CI разделены, триггерятся по paths**: PR с фронт-изменениями не пересобирают Rails, и наоборот. Экономит минуты CI.
- **Trivy на FS вместо image-scan**: нет нужды push'ить промежуточный образ для скана.
- **Solid Queue в отдельном `worker` server-role**: позволяет масштабировать воркеры независимо от web. Альтернатива — `SOLID_QUEUE_IN_PUMA=true` (закомментировано в env, можно включить для маленьких сетапов).
- **Postgres как accessory, не managed-service**: для шаблона / стартапа подходит. Для продакшена с реальным трафиком — заменить на RDS/Supabase/Neon.
- **`registry.password: [KAMAL_REGISTRY_PASSWORD]`**: пароль из Kamal secrets, не в коде. `.kamal/secrets` в `.gitignore`.
- **Dockerfile non-root user 1000:1000**: не запускаем Rails от root.
- **bootsnap precompile** в build-stage: ускоряет cold-start контейнера.

## Открытые вопросы / TODO
- Frontend ещё не имеет своего Dockerfile — деплоится как build-артефакт через preview (Vite preview). Для прода: положить `dist/` в Caddy/Nginx, или собирать отдельный образ. Альтернатива — отдавать через Rails Active Storage / public/. Решим, когда будет реальный прод.
- CI для e2e гоняет Playwright против `pnpm preview`, который не идеален для тестирования (вотч-ребилд отсутствует, но это и хорошо для e2e).
- Заменить `wait-on` на нативный health-check цикл, если `npx -y wait-on` будет тормозить.
- Kamal деплой не верифицирован вживую (требует реального сервера) — всё placeholder'ы.

## Куда дальше
**Этап 9** — Финал:
- Прогон git init + первый коммит
- Возможный `make setup` dry-run чтобы проверить, что Makefile валидный
- Финальный сводный лог `2026-04-28-final-summary.md`
- Обновить README cherrypick'ами актуальных команд / quickstart
- Обновить PROGRESS.md финальным entry
