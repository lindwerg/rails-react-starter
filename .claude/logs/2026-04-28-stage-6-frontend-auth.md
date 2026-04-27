---
date: 2026-04-28
plan: wild-crunching-jellyfish.md
status: completed
commits:
  - (pending)
---

# Stage 6: Frontend — Auth-by-email

## Что сделано
**entities/user**
- `model/types.ts` — реэкспорт `User` из `shared/api`
- `api/userApi.ts` — `fetchCurrentUser()` (GET /me, возвращает null на 401 без выкидывания)
- `index.ts` — public API

**entities/session**
- `model/sessionStore.ts` — Zustand-store (user, isLoading, setUser/reset)
- `model/useSession.ts` — обёртка с TanStack Query: подтягивает /me один раз, синхронизирует со стором, exposes `signOut()` и `refresh()`
- `index.ts` — public API: `useSession`, `useSessionStore`, `SESSION_QUERY_KEY`

**features/auth-by-email**
- `model/schemas.ts` — Zod схемы (signIn, signUp) + типы
- `api/authApi.ts` — `signIn(values)`, `signUp(values)` через `http`
- `model/useSignInMutation.ts`, `useSignUpMutation.ts` — TanStack Query mutations, кладут пользователя в `SESSION_QUERY_KEY` через `setQueryData`
- `ui/SignInForm.tsx`, `ui/SignUpForm.tsx` — RHF + zodResolver, `aria-label` на форму, `role="alert"` на server-error, mutation pending-state в кнопке
- `index.ts` — public API: формы, схемы, типы

**pages**
- `pages/sign-in/SignInPage.tsx`, `pages/sign-up/SignUpPage.tsx` — Card + форма + ссылка-переключатель, navigate('/') on success

**Тесты**
- `SignInForm.test.tsx` — 3 кейса (валидация, успех, серверная ошибка через MSW мок)
- `e2e/auth.spec.ts` — 2 Playwright-кейса:
  - sign-up с уникальным email → header показывает email → sign-out возвращает в анонимный режим
  - sign-in с битыми кредами → отображает alert

## Решения и почему
- **Zustand + TanStack Query вместе**: TanStack Query — единственный источник состояния `/me`, Zustand зеркалит для немедленного доступа без хука (например, в неhook-местах). Альтернатива — только TanStack — была бы "правильнее", но чуть менее удобна для глобального флага `isAuthenticated`.
- **Forms через RHF, не controlled inputs**: производительность + integration with Zod через `@hookform/resolvers`. Стандарт de-facto.
- **`aria-label="sign-in-form"`**: Playwright и a11y-тесты могут таргетить форму без бороться с маркапом.
- **`onSuccess` callback вместо useEffect+navigate**: явный контроль из page-компонента, форма не знает про роутер.
- **MSW в Vitest** обрабатывает запросы — `SignInForm.test.tsx` гоняет реальный mutation цикл без mock-сервера, всё end-to-end в JSDOM.
- **httpOnly cookie + JSON-token в ответе**: cookie ставится автоматически (credentials: 'include'), token нам по сути не нужен на фронте — забираем только user.

## Открытые вопросы / TODO
- `entities/user/ui/UserCard` пока не реализован (не используется ни в Header, ни в pages). Добавим когда понадобится.
- Magic-link / OAuth — out-of-scope, добавлять отдельным feature: `features/auth-by-magic-link`, `features/auth-by-oauth`.
- Reset-password — отсутствует.
- E2E полагаются на реально работающий backend (с миграциями) — на CI это требует поднятия backend в workflow.

## Куда дальше
**Этап 7** — Frontend Posts CRUD:
- `entities/post` — types, `PostCard` UI
- `features/create-post` — форма (RHF + Zod) + мутация
- `features/edit-post` — форма + мутация
- `features/delete-post` — кнопка + мутация
- `widgets/post-feed` — список с pagy meta
- `pages/posts`, `pages/post-detail`, `pages/post-new`
- Тесты: PostCard, форма create-post, useCreatePostMutation
- Playwright E2E: «логин → создал пост → отредактировал → удалил»
