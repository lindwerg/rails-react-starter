---
date: 2026-04-28
plan: wild-crunching-jellyfish.md
status: completed
commits:
  - (pending)
---

# Stage 5: Frontend skeleton

## Что сделано
- `package.json` — Node 22+, все зависимости (React 19, Vite 6, TS 5.6, TanStack Query 5, React Router 7, RHF 7, Zod 3, Tailwind v4, ky, zustand, lucide), все dev (Vitest, Testing Library, Playwright, MSW 2, Storybook 8, ESLint 9 flat, Prettier, knip, openapi-typescript)
- `tsconfig.{json,app.json,node.json}` — strict mode, `noUncheckedIndexedAccess`, `exactOptionalPropertyTypes`, alias `@/*`
- `vite.config.ts` — React+Tailwind v4 plugin, alias, dev-proxy `/api → :3000`
- `vitest.config.ts` + `vitest.setup.ts` — jsdom, MSW server boot, coverage thresholds 80/75/80
- `playwright.config.ts` — Chromium, dev-сервер автоматически в локале
- `eslint.config.js` (flat) — typescript-eslint + react/hooks/jsx-a11y, **`eslint-plugin-boundaries`** с FSD-правилами (app→pages→widgets→features→entities→shared, импорты только вниз) + блокировка глубоких импортов через `no-restricted-imports`
- `.prettierrc` (с tailwindcss plugin) и `.prettierignore`
- `commitlint.config.cjs` — conventional commits
- `index.html`, `src/main.tsx`, `src/app/App.tsx`
- `src/app/providers/AppProviders.tsx` — `QueryClientProvider` + Devtools (dev only)
- `src/app/router/AppRouter.tsx` — все роуты + `Header` + `RequireAuth`
- `src/app/styles/index.css` — Tailwind v4 imports + brand цвета
- **shared/lib/cn.ts** — `clsx` + `tailwind-merge`
- **shared/config/env.ts** — типизированный `import.meta.env`
- **shared/api/http.ts** — ky-инстанс, `credentials: 'include'`, `toApiError(e)` хелпер
- **shared/api/types.gen.ts** — placeholder типы (User, Post, AuthResponse, Paginated), регенерируется через `make typegen`
- **shared/api/__mocks__/** — MSW handlers, server (Node), browser (Service Worker)
- **shared/ui/** kit — Button (CVA-варианты), Input, Textarea, Label, Card+CardHeader+CardTitle+CardContent, FormField (label+error)
- Тесты: `Button.test.tsx` (3 кейса), Storybook story
- **widgets/header** — навигация с условным sign-in/sign-out (зависит от entities/session, его реализуем в Stage 6)
- **pages/home, pages/not-found** — заполнены
- `.storybook/{main,preview}.ts` — конфиг
- `.npmrc`, `.gitignore` для frontend

## Решения и почему
- **eslint-plugin-boundaries вместо @feature-sliced/eslint-config**: даёт более явный контроль над allow-rules между слоями. `@feature-sliced/eslint-config` сейчас сыроват и привязан к старым ESLint-конфигам.
- **no-restricted-imports блокирует deep imports** (`@/features/foo/internal-thing`): public API через `index.ts` — единственный вход.
- **MSW в Node для тестов + browser для dev (опц.)**: Vitest гоняет тесты через MSW, не нужен живой backend для frontend-тестов.
- **`exactOptionalPropertyTypes: true`**: ловит баги типа `{ x?: undefined }` vs `{ x: undefined }` — TS 5.x с этим жесткий, но это правильно.
- **Tailwind v4 (beta)**: `@tailwindcss/vite` plugin — нет необходимости в `tailwind.config.js`, темизация через `@theme` блок в CSS.
- **Vite proxy `/api → :3000`**: фронтенд бьёт по `/api/...`, прокси перебрасывает на Rails — никаких CORS-головняков в dev.
- **Tests: thresholds 80/75/80**: чуть ниже backend (90%) потому что UI имеет много визуальных кусков, которые лучше тестировать в Storybook + Playwright чем в Vitest.

## Открытые вопросы / TODO
- entities (user, session, post) и features (auth-by-email, create-post, edit-post, delete-post) — **Stage 6 и 7**. Сейчас Header импортирует из `@/entities/session`, но самого слайса ещё нет — TS будет ругаться при `pnpm typecheck` до Stage 6.
- Pages-заглушки (sign-in, sign-up, posts*) — заполнятся в Stage 6/7.
- `pnpm install` ещё не запускался, lockfile появится позже.

## Куда дальше
**Этап 6** — Frontend Auth-by-email:
- `entities/user` — типы, `UserCard` UI
- `entities/session` — Zustand-store + `useSession` hook (получение/инвалидация `/me`)
- `features/auth-by-email` — `SignInForm`, `SignUpForm`, мутации через TanStack Query
- `pages/sign-in`, `pages/sign-up` — собирают форму через слайс
- TDD: тесты на форму, мутацию, `useSession`
- Playwright E2E: «зарегистрироваться → выйти → войти → /me»
