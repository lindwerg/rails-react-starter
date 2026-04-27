---
date: 2026-04-28
plan: wild-crunching-jellyfish.md
status: completed
commits:
  - (pending)
---

# Stage 2: Backend skeleton

## Что сделано
- `backend/Gemfile` — все ключевые гемы (Rails 8, pg, puma, solid_*, JWT, Pundit, Alba, Pagy, dry-validation, rswag, packwerk, RSpec stack, RuboCop, Brakeman, SimpleCov)
- `config/application.rb` с автозагрузкой `packs/*/app/*` (FSD-style)
- Все стандартные Rails-конфиги: `boot.rb`, `environment.rb`, `database.yml` (с тремя соединениями для Solid Queue/Cache/Cable), `routes.rb` (с заготовленными `/api/v1` роутами), `puma.rb`, `queue.yml`, `cache.yml`, `cable.yml`, `storage.yml`
- 3 environments: `development`, `test`, `production`
- Инициализаторы: cors, filter_parameter_logging, inflections, lograge, rack_attack (с throttle на login), sentry, oj, alba (camelCase keys на проводе), rswag_api/ui
- `bin/rails`, `bin/rake`, `bin/setup`, `bin/packwerk`, `bin/rspec`, `bin/bundle` — все исполняемые
- `app/controllers/application_controller.rb` — JWT-auth через `Auth::JwtVerifier`, `Pundit::Authorization`, error handlers
- `app/models/application_record.rb`, `app/jobs/application_job.rb`, `app/mailers/application_mailer.rb`, `app/policies/application_policy.rb`
- `db/seeds.rb` — demo-юзер + 3 поста для dev
- `.rubocop.yml` — на базе `rubocop-rails-omakase` + RSpec/Performance/FactoryBot плагины
- `.rspec`, `spec/spec_helper.rb` (SimpleCov с 90% threshold), `spec/rails_helper.rb` (FactoryBot, DatabaseCleaner, Shoulda, VCR/WebMock)
- `spec/support/request_helpers.rb` (json_body, auth_headers_for) и `result_matchers.rb`
- **Packwerk**: `packwerk.yml` с 4 слоями (orchestrator/business_domain/platform/utility) + checkers (privacy, visibility, folder_visibility, layer)
- 6 packs созданы с `package.yml` и `README.md`: `api`, `auth`, `users`, `posts`, `platform`, `shared`
- В pack `shared` уже реализованы: `Shared::Result` (success/failure pattern) и `Shared::Errors::*`
- Папки `log/`, `tmp/`, `storage/`, `swagger/v1/`, `db/migrate`, `db/cache_migrate`, `db/queue_migrate`, `db/cable_migrate`, plus `.keep` файлы

## Решения и почему
- **Packwerk-extensions слои вместо чистого Packwerk**: даёт layer-checker — гарантирует архитектурные границы, а не только зависимости.
- **`packs/<name>/app/public/`** для публичного API пака (видно другим пакам). Privacy enforcement автоматически прячет `app/services/*` если они не в public.
- **Solid Queue/Cache/Cable** через 3 отдельных соединения БД — стандартная схема Rails 8, не требует Redis.
- **`Alba.transform_keys :camel_lower`** — все JSON-ключи на проводе автоматически camelCase, не нужно вручную перекладывать.
- **Sentry initializer wrapped in `if defined?(Sentry)`** — можно выкинуть DSN из `.env` и backend не упадёт.
- **`SimpleCov.minimum_coverage 90`** — TDD-disциплина: упало покрытие → CI красный.
- **`bin/setup` отдельно** — даже если `make setup` сложный, есть запасной вход.

## Открытые вопросы / TODO
- Миграции пока не созданы — будут в Stage 3 (для User) и Stage 4 (для Post).
- `config/credentials.yml.enc` и `master.key` — генерятся при первом `bundle exec rails credentials:edit`, не комитим.
- `Gemfile.lock` создастся при `bundle install`.

## Куда дальше
**Этап 3** — Backend Auth + Users (TDD!):
- Pack `users`: миграция, модель `User`, сериализатор, политика, фабрика
- Pack `auth`: `Auth::JwtIssuer`, `Auth::JwtVerifier`, `Auth::SignUp`, `Auth::SignIn` + `InvalidToken`
- Pack `api`: `Api::V1::AuthController`, `Api::V1::MeController`
- Тесты: model, services, request specs (по TDD)
- rswag-схема для auth и /me
