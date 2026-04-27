---
date: 2026-04-28
plan: wild-crunching-jellyfish.md
status: completed
commits:
  - (pending)
---

# Stage 4: Backend — Posts CRUD

## Что сделано
- Миграция `create_posts` (author_id, title, body, published_at, индексы)
- Модель `Post` с `belongs_to :author`, валидациями, scopes (`published`, `recent`)
- `PostSerializer` (Alba) — публичный, c вычисляемым полем `published`
- `PostPolicy` — author-only edit/delete; published виден всем; black-box scope для index (свои черновики + чужие опубликованные)
- `Posts::PostForm` (dry-validation contract) — title/body/publish
- Сервисы (Result-pattern): `Posts::Create`, `Posts::Update`, `Posts::Destroy`
- Query: `Posts::Published` (scope: published.recent)
- Фабрики `posts` (+ traits :draft, :scheduled)
- Спеки: модель, политика, сервисы (Create/Update), reqest для всех действий
- Pagy initializer (default 20, max 100)
- `Api::V1::PostsController` — index/show/create/update/destroy с Pundit и pagy
- Optional auth для index/show — анон видит published, автор видит свои драфты

## Решения и почему
- **Form через dry-validation, валидации модели — на инвариантах БД** (presence/length): два слоя валидации работают вместе. Form ловит юзер-инпут, model ловит rogue писателей.
- **Опциональный auth в index/show**: один эндпоинт работает для всех (анон, авторизованный), Pundit-scope сам срежет невидимые записи. Меньше дубликатов API.
- **Result-pattern даже в Destroy**: однообразие — контроллер всегда `render_result`. Никакого if-else по разным типам.
- **`policy_scope` + `authorize`** — как Pundit рекомендует, ловит ошибки забытых проверок (`after_action :verify_authorized` можно добавить позже, если будем писать новые контроллеры).
- **Pagy default 20, max 100** — защита от `?per_page=999999`.

## Открытые вопросы / TODO
- Mass-update / bulk delete не реализованы — добавлять при необходимости.
- Сериализация коллекции в `index` — пагинация через мету; `Link`-header не генерится (можно добавить `pagy/extras/headers` если понадобится).
- `bin/packwerk check` запустится только после `bundle install`. По структуре всё уложено правильно: posts → users + shared, api → all business_domain, никто не лезет в orchestrator снизу.

## Куда дальше
**Этап 5** — Frontend skeleton:
- Vite + React 19 + TS strict
- FSD-структура с заготовками всех слоёв
- Tailwind v4, shadcn/ui (Button, Input, Card, Form)
- TanStack Query, React Router 7, Zustand
- Vitest, Testing Library, Playwright, MSW, Storybook 8
- ESLint flat config (с FSD plugin), Prettier, lefthook, commitlint
- HTTP-клиент в `shared/api/http.ts` с куки credentials
