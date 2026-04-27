---
date: 2026-04-28
plan: wild-crunching-jellyfish.md
status: completed
commits:
  - (pending)
---

# Stage 3: Backend — Auth + Users

## Что сделано
**pack: users**
- Миграция `20260428000001_create_users.rb` (email unique, password_digest, name)
- Модель `User` с `has_secure_password`, валидациями, нормализацией email
- `UserSerializer` (Alba) — публичный, в `app/public/`
- `UserPolicy` — own-resource доступ
- Фабрика `users` (FactoryBot)
- Спеки: модель (валидации/нормализация/ассоциации), политика

**pack: auth**
- `Auth::InvalidToken` (исключение)
- `Auth::JwtIssuer.call(user_id:, expires_in_hours:)` — HS256 + iat/exp
- `Auth::JwtVerifier.call(token)` — выбрасывает `InvalidToken` на любую проблему
- `Auth::SignUp.call(email:, password:, name:)` — Result-pattern, коды `:validation_failed` / `:email_taken`
- `Auth::SignIn.call(email:, password:)` — Result-pattern, код `:invalid_credentials`
- Спеки на каждый сервис (success path + 2-3 failure paths)

**pack: api**
- `Api::BaseController` — обёртка `render_result` со statuс-mapping (`:invalid_credentials → 401`, `:validation_failed → 422`, итд)
- `Api::V1::AuthController` — sign_up / sign_in / sign_out, выставляет JWT в **httpOnly signed cookie** + возвращает в теле
- `Api::V1::MeController` — `GET /api/v1/me` показывает `current_user`
- Request-спеки: позитивный путь, 401, 422, dup-email

**spec/support**
- `request_helpers.rb` — `json_body`, `auth_headers_for(user)`
- `pundit_matchers.rb` — `permit_actions / forbid_actions`
- `result_matchers.rb` — `be_success_result / be_failure_result(:code)`

## Решения и почему
- **JWT в httpOnly signed cookie**: безопаснее `localStorage`, не доступно JS, защищено от XSS-кражи. Также возвращаем токен в JSON-body для тех клиентов, кому нужен Authorization header.
- **Result-pattern, не raise/rescue**: бизнес-сервисы возвращают значения, контроллер маппит код в HTTP-статус. Тестировать проще, дёрнуть сервис из не-HTTP-контекста (job, rake task) тривиально.
- **`module Auth ... module SignUp; module_function; ...`**: статeless-сервисы как модули, не классы. Меньше церемонии, нет нужды в `.new.call`.
- **`User` живёт в `packs/users`, не в `packs/auth`**: User — самодостаточная сущность, у неё могут быть посты/комменты/etc. Auth — отдельный bounded context, **зависит от** users, не наоборот. Соответствует Packwerk-направлению зависимостей.
- **Pundit вместо CanCan**: проще, явный, без мета-DSL, лучше дружит с тестами.
- **Email регистронезависим** (`LOWER(email) = ?` в SignIn + `before_save downcase`): стандартная UX-практика.

## Открытые вопросы / TODO
- Email-подтверждение, password reset — НЕ реализованы (вне scope шаблона). Добавлять при появлении реальной потребности.
- 2FA — не реализовано.
- `JWT_SECRET` падает на `Rails.application.secret_key_base` если ENV пустой — для прода нужно явно задать через `RAILS_MASTER_KEY` / Kamal secrets.
- rswag-схема для auth/me пока не сгенерирована (требует `bundle install` + `rake rswag:specs:swaggerize`).

## Куда дальше
**Этап 4** — Backend Posts CRUD:
- Pack `posts`: миграция, модель `Post` с `belongs_to :author`
- `Posts::Create / Update / Destroy` (Result-pattern)
- `Posts::Published` query
- `PostPolicy` (author-only edit/delete)
- `PostSerializer`
- `Api::V1::PostsController` — `index / show / create / update / destroy`
- Тесты: model, services, query, policy, request
- `bin/packwerk check` — должно быть чисто
