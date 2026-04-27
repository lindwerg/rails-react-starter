---
date: 2026-04-28
plan: idempotent-sniffing-blanket.md
status: completed
commits:
  - d750077 feat(bootstrap): allocate free TCP ports and wire them through every config
  - e3ca469 feat(bootstrap): wire allocated ports into Procfile, bin/dev, docker-compose, vite
  - 06ddea1 feat(bootstrap): self-healing bootstrap.sh + make heal/ports targets
  - fb236bc feat(template): bin/init + bin/rename-project for one-command project init
  - 708f752 feat(template): create-app.sh curl-installer + README quick-start + /init slash command
  - 943f6e7 chore(template): point installer URLs at lindwerg/rails-react-starter
  - <next>  fix(template): unblock all pre-push gates so a fresh clone can `git push`
---

# Stage 13: GitHub-template publish + one-command bootstrap with self-heal

## Что сделано

Стартер опубликован как **GitHub template**: <https://github.com/lindwerg/rails-react-starter>
(`isTemplate: true`, public, branch `main`).

Одной командой можно поднять новый проект:

```bash
curl -fsSL https://raw.githubusercontent.com/lindwerg/rails-react-starter/main/create-app.sh \
  | bash -s my-shop
cd my-shop && make dev
```

Что эта команда теперь делает (всё идемпотентно, всё с ретраями):

1. **Клонирует** template в `./my-shop/`.
2. **Переименовывает** `App` / `app_*` placeholder'ы в новое имя (Rails-модуль,
   DB-имена, container_name, session-key, Kamal service, package.json) —
   `bin/rename-project` с sentinel-файлом для no-op'а на повторных запусках.
3. **Авто-устанавливает**: `mise` (через curl https://mise.run), `Docker Desktop`
   (brew --cask на macOS), `gh`, `lefthook`. На каждом шаге retry x3.
4. **Авто-запускает Docker Desktop** и ждёт до 120 с готовности демона.
5. **Подбирает свободные TCP-порты** — `bin/allocate-ports` по очереди ищет
   `BACKEND_PORT/FRONTEND_PORT/POSTGRES_PORT/MAILPIT_*_PORT`, сдвигая на +1
   если занят. Сохраняет в `.ports.env` (gitignored).
6. **Пробрасывает порты** в:
   - `.env` (DATABASE_URL/CORS_ORIGINS/VITE_API_BASE_URL пересобирается)
   - `Procfile.dev` (`-p ${BACKEND_PORT}`, `--port ${FRONTEND_PORT}`)
   - `docker-compose.yml` (через `${POSTGRES_PORT:-5433}` etc.)
   - `frontend/vite.config.ts` (server.port + proxy target из env)
7. **Создаёт `master.key`** (через `EDITOR=true bin/rails credentials:edit`).
8. **Запускает Postgres + Mailpit** в Docker.
9. **`bundle install`, `db:prepare`, `db:seed`, `pnpm install`, `playwright install`** —
   все с retry x3.
10. **Делает initial commit** с сообщением `chore: initialise project as <name>`.

При **любом** failure — auto-trap запускает `make doctor` + `make heal`
(идемпотентное восстановление: re-allocate ports, mise install, bundle, pnpm,
db:prepare, lefthook install, docker compose up, open -a Docker если надо).

## Решения и почему

- **Почему `lindwerg/rails-react-starter`, не `mishanikhinkirill/odezhda`?**
  GitHub-юзера `mishanikhinkirill` не существует (404), а `gh` на машине
  залогинен как `lindwerg`. Пользователь подтвердил публикацию под этим
  аккаунтом + новое имя `rails-react-starter` (точнее описывает стек).

- **Почему `.env` — источник истины, а не `.ports.env`?**
  `.env` уже читается всеми участниками (Rails, vite, docker-compose).
  `.ports.env` нужен только как кэш аллокатора между запусками, чтобы
  при повторном `bootstrap.sh` сохранить уже выбранные порты. Lefthook
  pre-push-хук делает `source ../.env`, а не `.ports.env`.

- **Почему `bash 3.2`-совместимость в `bin/allocate-ports`?**
  macOS до сих пор поставляется с bash 3.2 в `/bin/bash`. Если кто-то
  запустит скрипт через `/bin/bash bin/allocate-ports`, ассоциативные
  массивы (bash 4+) выдадут unbound-variable ошибку. Перевёл на параллельные
  индексные массивы.

- **Почему commit с переименованием отдельно от bootstrap?**
  `bin/init` оркестратор делает `rename-project` → `bootstrap.sh` →
  initial commit. Так пользователь получает один аккуратный «нулевой» коммит
  «chore: initialise project as X», а не 5 разных. Bootstrap идёт без коммитов.

- **Зачем `package_todo.yml`?**
  При исправлении typo `folder_visibility` → `folder_privacy` в `packwerk.yml`
  поднялись 42 ранее скрытых privacy-нарушения. Зафиксировал их через
  `bin/packwerk update-todo` — Packwerk-стандарт «технический долг видим,
  но не блокирует». Постепенно расплачивать в следующих стейджах.

## Открытые вопросы / TODO

- **`gh auth login` интерактивен** — `bin/init`/`bootstrap.sh` его не
  запускает. Если у пользователя нет авторизации, `gh repo create` упадёт.
  Можно добавить хинт в bootstrap, но не блокировать.
- **42 privacy-нарушения в `package_todo.yml`** — большая часть это
  `app/controllers/application_controller.rb` и `db/seeds.rb` использующие
  `User`/`Post` напрямую. Нужно завести public entry points в `packs/users/app/public/`
  и `packs/posts/app/public/` и переключиться на них.
- **`make heal` пока не использует MAILPIT_SMTP_PORT/UI_PORT в проверках** —
  doctor.sh показывает их, но heal только переаллоцирует. ОК для MVP.
- **`create-app.sh` не проверяет `git` и `bash` версии** — если у пользователя
  старый bash, может упасть на `bin/rename-project`. Документировать в README.
- **На Linux без brew bootstrap не дойдёт до автоматической установки Docker** —
  печатает ссылку и выходит. Линукс-сценарий ждёт apt/dnf-логику.

## Куда дальше

1. **Проверить шаблон через "Use this template"** — кто-то реально клонирует,
   пробует `./bin/init demo` на свежей машине, фиксируем что обламывается.
2. **Добавить README badges** для GitHub Actions, codeql, Ruby/Node версий.
3. **GitHub Actions «Test the template»** — workflow что раз в неделю клонирует
   сам себя через `gh repo create --template`, гоняет `bin/init` + `make check-all`,
   падает если что-то сломалось. Самопроверка template'а от регрессий.
4. **Пакпейент privacy-нарушений** (`package_todo.yml`) — отдельный stage:
   завести `packs/users/app/public/users/find_by_email.rb` etc.
5. **Линукс-ветки в `bootstrap.sh`** — apt/dnf для docker и lefthook.
