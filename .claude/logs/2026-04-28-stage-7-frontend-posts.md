---
date: 2026-04-28
plan: wild-crunching-jellyfish.md
status: completed
commits:
  - (pending)
---

# Stage 7: Frontend — Posts CRUD

## Что сделано
**entities/post**
- `model/types.ts` — реэкспорт `Post`, `Paginated`
- `api/postApi.ts` — `fetchPosts(page)`, `fetchPost(id)`
- `model/queries.ts` — `POSTS_KEYS` (factory), `usePostsQuery(page)`, `usePostQuery(id)` (with `enabled` guard)
- `ui/PostCard.tsx` — публичная карточка (title link, дата, draft/published, slot для action-кнопок)
- Тест на `PostCard` (2 кейса)

**features/create-post**
- Zod-схема `postSchema` (title, body, publish)
- `createPost(values)` API
- `useCreatePostMutation` — invalidate POSTS_KEYS.all on success
- `CreatePostForm` — RHF + zodResolver, чекбокс publish, server-error через role="alert"

**features/edit-post**
- `updatePost(id, values)`
- `EditPostForm` — переиспользует `postSchema` из `create-post`, defaultValues из существующего поста

**features/delete-post**
- `deletePost(id)`
- `DeletePostButton` — confirm() + variant="destructive"

**widgets/post-feed**
- `PostFeed` — список с пагинацией (Prev/Next), показывает action-кнопки (Edit/Delete) только автору
- Loading/error состояния

**pages**
- `pages/posts` — список + кнопка "New post" (видна только залогиненным)
- `pages/post-new` — Card + CreatePostForm, navigate в детали после создания
- `pages/post-detail` — режим просмотра / inline-edit, owner видит Edit/Delete

**E2E**
- `e2e/posts.spec.ts` — полный сценарий: signup → create → edit → delete

## Решения и почему
- **`POSTS_KEYS` как фабрика**: контролируемая иерархия ключей. `invalidateQueries({ queryKey: POSTS_KEYS.all })` сметает list+one, `POSTS_KEYS.list(page)` точечно. Шаблон, который масштабируется.
- **`postSchema` живёт в `create-post`, edit-post его импортирует**: один источник правды для валидации формы. EditPostForm = другой "виджет" над тем же данными — не феча, заслуживающая собственной схемы.
- **Inline-edit на post-detail вместо отдельного pages/post-edit**: меньше навигации, меньше кода, лучше UX. Если бы было сложнее (превью, версии), вынес бы в страницу.
- **`window.confirm` на delete**: примитивный, но честный для шаблона. На реальном проекте заменить на shadcn/ui `AlertDialog`.
- **`MemoryRouter` в тесте PostCard** — изоляция от роутер-провайдера.
- **`usePostQuery({ enabled: id > 0 })`**: защита от `Number.isNaN` если `:id` параметр битый.

## Открытые вопросы / TODO
- Optimistic updates на mutations пока не реализованы (полагаемся на refetch). Включать когда станет заметна задержка.
- Infinite scroll вместо пагинации — отдельный feature.
- Картинки в постах (Active Storage) — отдельный feature `features/upload-image`.
- Featured Markdown rendering body — пока plain text + `whitespace-pre-line`. Можно добавить `react-markdown`.

## Куда дальше
**Этап 8** — DevOps:
- GitHub Actions: 3 workflow (backend, frontend, security)
- Dependabot config
- Kamal 2 deploy template
- Заполнить Makefile, проверить связки
