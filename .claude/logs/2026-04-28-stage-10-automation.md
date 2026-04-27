---
date: 2026-04-28
plan: wild-crunching-jellyfish.md
status: completed
commits:
  - (pending)
---

# Stage 10: Automate the Claude workflow

## Что сделано

### CLAUDE.md — переписан как контракт, а не описание
- Заголовок изменён на "operating rules", прямо в первой строке: «Treat every rule below as MUST».
- §0 SESSION START — обязательная последовательность чтений (CLAUDE.md → PROGRESS.md → 2 последних лога → активный план)
- §1 Stack — таблица с immutable выборами + правило «нельзя менять без plan-mode»
- §2 NON-NEGOTIABLES — TDD, MCP-серверы (context7 + magic-mcp), архитектура, plan-mode, pre-PR чек, логи, коммиты
- §2.1 явно описан **обязательный** workflow для context7 и magic-mcp с триггерами
- §3 описан полный набор slash-команд
- §4 quick-references — где какие файлы лежат
- §5 anti-patterns — таблица «❌ ↔ ✅»
- §6 escalation chain — что делать когда застрял
- §7 — три полных example walkthroughs (новый домен / редизайн / баг в либе)
- §8 — описание автоматических хуков
- §9 — что от Claude ожидает пользователь

### `.mcp.json` — project-scoped MCP-серверы
3 сервера автоподключаются при открытии Claude Code в репо:
- `context7` (`@upstash/context7-mcp`) — for any library question
- `magic-mcp` (`@21st-dev/magic`) — for any new UI component
- `playwright` (`@playwright/mcp`) — for browser-driven E2E debugging
+ `.mcp.example.env` шаблон для API-ключей (опциональны).

### `.claude/commands/` — 8 slash-команд
- `/check-all` — последовательный прогон всех gate'ов
- `/tdd <description>` — Red→Green→Refactor цикл с pause-на-Red
- `/new-pack <name> [layer]` — скаффолдинг backend pack через скрипт
- `/new-slice <layer> <name>` — скаффолдинг FSD slice через скрипт
- `/new-log [slug]` — лог + запись в PROGRESS.md
- `/architecture-check` — Packwerk + FSD audit с конкретными violations
- `/first-run` — bootstrap.sh
- `/sync-types` — OpenAPI → frontend types

### `.claude/scripts/` — bash-скрипты вместо болтологии
- `new-pack.sh` — создаёт `packs/<name>/{app,spec}/...`, `package.yml` с правильным layer и default deps, README с TODO
- `new-slice.sh` — создаёт `frontend/src/<layer>/<name>/{ui,model,api,lib}/`, `index.ts`. Для `pages/` ещё генерит `<Pascal>Page.tsx`
- `new-log.sh` — копирует `_TEMPLATE.md` с подстановкой даты
- `check-tdd.sh` — нудит когда меняют файл без парного теста (хук-друг)
- `check-mcp-needed.sh` — сканит prompt на ключевые слова → подсказывает использовать context7 / magic-mcp
- `session-start.sh` — печатает 5 последних строк PROGRESS + раздел "Куда дальше" из последнего лога

### `.claude/settings.json` — усиленные хуки
- `SessionStart` → `session-start.sh` (контекст в первый же вывод)
- `UserPromptSubmit` → `check-mcp-needed.sh` (нудит про MCP когда видит trigger-слова)
- `PostToolUse(Edit|Write)` → `check-tdd.sh` через `jq` (нудит про test-файл)
- `PostToolUse(ExitPlanMode)` → ставит маркер
- `Stop` → если был ExitPlanMode, напоминает про лог
- Расширенные `permissions.allow` для типичных команд (make, bundle, pnpm, bin/*, .claude/scripts/*, git read-only)
- `enableAllProjectMcpServers: true` — `.mcp.json` авто-подключается

### Onboarding-файлы
- `CONTRIBUTING.md` — правила в 30 секунд + ссылка на CLAUDE.md
- `SECURITY.md` — список встроенных митигаций (auth, CSRF, rate limiting, Pundit, mass-assignment, bundler-audit, Brakeman, Trivy, strong_migrations) + что вне scope
- `CHANGELOG.md` (Keep-a-Changelog шаблон, Unreleased заполнен)
- `LICENSE` (MIT)
- `bootstrap.sh` — one-shot скрипт: mise install → docker compose → bundle → pnpm → playwright → lefthook → копирование .env. Показывает next-steps banner.

### Output style
- `.claude/output-styles/terse.md` — задаёт concise tone: лидируй с действием, никаких "Sure!", тащи диффы а не пересказывай.

### Makefile
- Добавлены `bootstrap`, `first-run` (alias), `check-all` targets

## Решения и почему

- **`enableAllProjectMcpServers: true`** в `.claude/settings.json` — критично, иначе `.mcp.json` не активируется автоматически. Это главный «магический» момент: пользователь клонит репо → открывает Claude Code → MCP уже доступен.
- **Хуки нудят, не блокируют**: pre-tool-use мог бы блокировать Edit без теста, но это раздражает и Claude быстро научится обходить. Soft-warning через stderr + жёсткий gate в CI = правильный баланс.
- **`/tdd` останавливается на Red и спрашивает подтверждения**: главная польза TDD — увидеть failing test для нужной причины. Это место где люди халтурят. Команда forces pause.
- **Скаффолдинг через bash, а не Claude-инстанс генерит файлы**: bash детерминированный, делает одинаковую структуру каждый раз. Claude может переключиться в режим «начну с нуля» и нарушить convention. Скрипт защищает.
- **`session-start.sh` сразу выводит "Куда дальше" из последнего лога**: первое, что видит Claude — точку, на которой остановились. Никакой "что мне делать?" в первой реплике пользователя.
- **`magic-mcp` обязателен только для **новых** компонентов**: рефакторинг существующего — выбор Claude. Это снижает трение для мелких правок.
- **Output-style `terse`**: на этом репо болтливый ответ = wasted context = плохой UX. Стиль явный.
- **`.mcp.example.env` отдельно от `.env.example`**: разные жизненные циклы — `.env` для приложения, `.mcp.env` только для Claude.

## Открытые вопросы / TODO

- `.claude/output-styles/terse.md` — нужно вручную активировать через `/config` → output style. Не успел придумать как авто.
- Хук `PostToolUse(Edit|Write)` зависит от `jq` — на чистой macOS jq отсутствует. Скрипт падает молча (`|| true`), но было бы чище использовать `python3 -c` или прямой парсинг. Решение: оставил `jq` и добавил его в `bootstrap.sh` через `brew install jq` — TODO в следующей итерации.
- `magic-mcp` без API-ключа работает в trial-режиме с лимитами. Документировал в `.mcp.example.env`.
- Custom subagents в `.claude/agents/` — пока не делал. Есть смысл добавить `architect` (проверяет планы на Packwerk/FSD совместимость) — но slash-команды + хуки уже покрывают 80% кейсов.
- Не запустил `bootstrap.sh` против чистой машины (Ruby 2.6 в окружении не подходит) — пользователь должен проверить вживую при первом запуске.

## Куда дальше

Шаблон закрыт. **Никаких этапов больше нет.** Что делать пользователю:

1. `git clone` → `./bootstrap.sh` (или `make bootstrap`).
2. Открыть Claude Code в корне репо. MCP-серверы и хуки активируются автоматически.
3. Сказать Claude *"начнём проект X"* или *"добавь фичу Y"*. Claude:
   - Прочитает CLAUDE.md, PROGRESS.md, последние логи (хук `SessionStart` подскажет).
   - Войдёт в plan-mode для нетривиальных задач.
   - Обратится к context7 / magic-mcp когда нужно (хук `UserPromptSubmit` напомнит).
   - Напишет тесты до кода.
   - Прогонит `/check-all`.
   - Напишет лог через `/new-log`.
   - Сделает atomic-коммит.

Если пользователь хочет настроить под себя:
- Сменить domain `Posts` на свой: `make pack-check`, удалить `packs/posts/` и `frontend/src/{entities/post,features/{create,edit,delete}-post,widgets/post-feed,pages/{posts,post-*}}/`, удалить миграцию posts, обновить `routes.rb` и `db/seeds.rb`.
- Заменить placeholders в `config/deploy.yml` и `.github/workflows/*` на реальные домены/IP/registry.
- Сменить `name`/`title` в `package.json`, `index.html`, `Application` модуле.
