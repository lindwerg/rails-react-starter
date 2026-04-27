---
date: 2026-04-28
plan: greedy-knitting-quill.md
status: completed
commits:
  - 21e72e4 feat(claude): hard-block guards for §5 anti-patterns
  - 4d19ceb feat(claude): five specialized subagents for isolated tasks
  - a0544c2 feat(claude): auto-terse output style + statusline
  - 5d3c5d0 feat(claude): /go router, make doctor, smarter Stop hook
  - 435b74b feat(mcp): add shadcn-ui and sequential-thinking servers
  - 5b56ddb feat(dev): bin/dev, seed-rich, api-docs, reset confirmation
  - ca82e0d docs: DECISIONS, TROUBLESHOOTING, ARCHITECTURE, ADR template
  - 43c2f69 chore(ci): codeql + mutation opt-in + typecheck pre-push + changelog
---

# Stage 12: «ребёнок справится» upgrade

8 атомарных коммитов, 8 фаз, ~30 новых файлов и ~10 правок. Цель: после
клона + `./bootstrap.sh` пользователь говорит Claude любую фичу, и
архитектурно невозможно уронить проект; растерянному человеку всегда
есть одна команда (`/go`); первый запуск самодиагностируется.

## Что сделано

### A. Hard-block guard hooks
- `.claude/scripts/guard-{lib,write,bash}.sh` + PreToolUse в `settings.json`.
- guard-write: блок на localStorage с auth-ключами, backend/app/{controllers,models,policies,forms,queries,serializers,services}, TS `any`, soft-warn на useState с auth-shaped data.
- guard-bash: блок на --no-verify / -n / --no-gpg-sign / --skip-checks, force-push к main, rm -rf на опасных путях, curl|sh, chmod 777.
- `test-guards.sh`: 16 тестовых кейсов, все green.
- Heredoc-bodies стрипаются перед regex — иначе текст коммит-сообщения «git commit -n» (в этом самом логе) триггерил бы guard.

### B. 5 custom subagents
- `.claude/agents/{architect,tester,reviewer,migrator,debugger}.md`
- architect — pre-execution Packwerk + FSD layer validation
- tester — TDD-Red phase test generation per таблицу §2.2
- reviewer — pre-commit code review, верный read-only
- migrator — strong_migrations-aware schema changes
- debugger — scientific-method root-cause analysis (диагностирует, не фиксит)
- `CLAUDE.md` §3.1 + §6 escalation chain обновлены.

### C. Auto-terse + statusline
- `outputStyle: "terse"` в settings.json — больше не нужно `/output-style` каждый раз.
- `statusLine: command → .claude/scripts/statusline.sh`. Формат: `🌿 main · 🤖 Opus 4.7 · ✅ tests · 🟢 packwerk`.
- Last-status sentinel files (`.claude/.last-test-status`, `.last-packwerk-status`) пишутся через Makefile (надёжнее чем хук-парсинг).

### D. /go router + make doctor + smarter Stop hook
- `/go` слэш-команда — единая точка входа, AskUserQuestion с 4–6 опциями.
- `/doctor` + `make doctor` — диагностический скрипт. Проверяет 17+ пунктов: mise активирован, ruby/node/pnpm/jq/lefthook, Docker daemon, ports 3000/5173/5433/1025/8025, .env, master.key, lock files, MCP. Каждый ✗ = конкретная команда «как починить».
- Stop hook теперь нудит про несохранённое (изменены .rb/.tsx > 10 мин без `make test`, staged без коммита).

### E. MCP servers extension
- `.mcp.json`: добавлены `shadcn-ui` (@jpisnice/shadcn-ui-mcp-server) и `sequential-thinking` (@modelcontextprotocol/server-sequential-thinking). Total 5.
- CLAUDE.md §2.1: триггеры + воркфлоу для каждого. Ясный split: shadcn для примитивов, magic-mcp для composition.

### F. DevX scaffolding
- `bin/dev` — Rails-8 convention launcher: docker-up → overmind → foreman → install foreman.
- `backend/lib/tasks/dev.rake` — `dev:seed_rich`: 5 users, ~50 posts (mix published/draft) через Faker.
- `make seed-rich`, `make api-docs` (open Swagger UI), `make reset` с `read -r 'yes'` подтверждением.

### G. Documentation
- `docs/DECISIONS.md` — 6 ADR (Packwerk, FSD, JWT-cookie, inflections, Alba transforms, Docker mirrors).
- `docs/TROUBLESHOOTING.md` — все боли stage-11 + точные команды-фиксы.
- `docs/ARCHITECTURE.md` — ASCII-диаграммы layers + примеры request flow для обоих стеков.
- `docs/ADR-template.md`.
- README Tour section направляет нового контрибьютора в правильном порядке: CLAUDE → ARCHITECTURE → DECISIONS → TROUBLESHOOTING → один пак → один слайс.

### H. Quality gates
- `.github/workflows/codeql.yml` — Ruby + JS/TS, security-and-quality, weekly schedule.
- `.github/workflows/mutation.yml` — opt-in workflow_dispatch (mutant-rspec). Hint когда mutant-rspec не в Gemfile.
- `backend/Gemfile` — `# gem "mutant-rspec"` закомментирован с пояснением.
- `lefthook.yml` pre-push: добавлен `pnpm typecheck` к параллельным гейтам.
- `CHANGELOG.md` Unreleased заполнен.

## Решения и почему

- **Heredoc-aware regex в guard-bash**: первая итерация ловила собственные коммит-сообщения. Решение — стрипать всё после `<<` перед матчингом. Это закрывает 99% кейсов и не требует полноценного shell-парсера.
- **Statusline через sentinel-файлы, не через хук-парсинг**: `make test` всегда даёт явный exit code; парсинг PostToolUse(Bash) `tool_response` менее надёжен и зависит от точного формата CC. Sentinel files под `.gitignore`, регенерируются при каждом make test.
- **Subagent descriptions с anti-instructions**: каждый агент явно говорит «do NOT X». Без этого их роли пересекаются и Claude путается какого звать. Например, reviewer.md: «do NOT modify any file. Read-only».
- **Mutation testing opt-in only, не on:push**: 10+ минут на пак — нельзя на каждом PR. Workflow_dispatch + закомментированный gem = explicit opt-in. Hint workflow печатает инструкцию когда юзер впервые запустит без gem'а.
- **`outputStyle: terse`** vs ручная активация: stage-10 лог явно отметил «не успел придумать как авто». Поле существует в schema (подтверждено через claude-code-guide), просто никто не ставил.
- **Не добавлял CodeQL в существующие workflow** — отдельный файл проще откатить и не зависит от backend/frontend split.
- **`make reset` confirmation через `read`, а не флаг**: дефолт безопасный — пользователь обязан явно сказать «yes», ни один CI-флаг не bypassит.
- **`bin/dev` отдельно от `make dev`**: Rails-8 convention. `make dev` теперь делегирует. Дал пользователю обе формы.

## Открытые вопросы / TODO

- **Auto-screenshot в README** — не реализовано. Нужен running app + Playwright. Оставлено как TODO в самом README (через place-holder секцию «What does it look like?»). Можно автоматизировать через Playwright MCP, но это отдельный stage.
- **Mutant-rspec реальный тест** — закомментирован, не запускали. Workflow содержит check + hint. Юзер сам решит когда включать.
- **CodeQL первый прогон** — workflow добавлен но не запускался (требует push). При следующем push в main будет первый baseline.
- **Stop hook false positives**: «10 минут без теста» heuristic может срабатывать на быстрые правки. Если жалобы — повысить порог до 30 мин или сделать настраиваемым через env.
- **`/go` тестирование** — slash-command написан как декларация, но реальный flow с AskUserQuestion не отработали в этой сессии. Пользователь сам прогонит.
- **Update of pnpm 9.15** в lefthook hooks — `mise x -- pnpm typecheck` зависит от mise activation. На clean install будет работать после `lefthook install` после `bootstrap.sh`.

## Куда дальше

Stage 12 закрывает все 8 пунктов из плана `greedy-knitting-quill.md`. Стартер «готов отдать ребёнку» по моим критериям.

**Конкретные следующие шаги для пользователя:**

1. Перезапустить Claude Code в репо. Проверить:
   - `/mcp` → 5 серверов connected
   - Status line внизу показывает `🌿 main · 🤖 Opus 4.7 …`
   - Output по умолчанию terse (без «Sure, I'll …» прелюдий)
2. Запустить `make doctor` — все checks должны быть зелёные (или ⚠ на занятые порты — это OK, наш же Docker).
3. Опционально: `make seed-rich` → `make api-docs` чтобы убедиться что end-to-end работает.
4. Push в GitHub → 4 workflow стартуют (ci-backend, ci-frontend, security, codeql).
5. Сделать «test feature»: `/go` → "new feature" → `/tdd "Comment model with body"` → проверить что хуки блокируют попытки нарушить §5.

**Если планируется реальный starter-go-public (publish to GitHub Marketplace / share):**
- Заменить `your-org/your-repo` placeholders в CHANGELOG, deploy.yml, workflows.
- Добавить screenshot в README (запустить app, сделать скрин dashboard).
- Записать GIF demo (asciinema или terminalizer для CLI flow).
- Tweet/blog post с архитектурными решениями.

Дальнейшие upgrade-кандидаты (если хочется):
- Custom shadcn registry для собственных примитивов.
- Bundle-size budget в CI (size-limit или bundlewatch).
- Visual regression на ключевых страницах через Playwright + Percy.
- E2E full happy-path для seed-rich data (auth + create + edit + delete).
