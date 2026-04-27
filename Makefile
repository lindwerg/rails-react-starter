# Makefile — single entry point for all commands.
# Run `make help` to see what's available.

.DEFAULT_GOAL := help
.PHONY: help bootstrap first-run setup setup-tools setup-backend setup-frontend \
        dev dev-services test test-backend test-frontend e2e \
        lint lint-backend lint-frontend lint-fix \
        typecheck security typegen pack-check check-all \
        log clean reset

SHELL := /bin/bash

# ---------- help ----------
help: ## Show this help
	@echo "Targets:" && grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}'

# ---------- bootstrap ----------
bootstrap: ## One-shot setup from a fresh clone (alias: first-run)
	./bootstrap.sh

first-run: bootstrap ## Alias for bootstrap

# ---------- setup ----------
setup: setup-tools setup-backend setup-frontend ## Install everything (tools, gems, npm, db, hooks)
	@echo "✅ Setup complete. Run 'make dev' to start."

setup-tools: ## Install Ruby/Node/pnpm via mise
	@command -v mise >/dev/null || { echo "Install mise first: https://mise.jdx.dev"; exit 1; }
	mise install
	@command -v lefthook >/dev/null || npm i -g lefthook
	lefthook install

setup-backend: ## Bundle install + db prepare
	cd backend && bundle install
	cd backend && bin/rails db:prepare

setup-frontend: ## pnpm install + playwright browsers
	cd frontend && pnpm install
	cd frontend && pnpm exec playwright install --with-deps chromium

# ---------- dev ----------
dev: dev-services ## Start docker services + Rails + Vite
	@command -v overmind >/dev/null && overmind start -f Procfile.dev || foreman start -f Procfile.dev

dev-services: ## Start docker-compose services (postgres, mailhog)
	docker compose up -d

# ---------- test ----------
test: test-backend test-frontend ## Run all tests

test-backend: ## RSpec
	cd backend && bin/rspec

test-frontend: ## Vitest
	cd frontend && pnpm test --run

e2e: ## Playwright end-to-end
	cd frontend && pnpm exec playwright test

# ---------- lint ----------
lint: lint-backend lint-frontend ## Run all linters

lint-backend: ## RuboCop
	cd backend && bundle exec rubocop

lint-frontend: ## ESLint + Prettier check
	cd frontend && pnpm lint
	cd frontend && pnpm format:check

lint-fix: ## Auto-fix linter issues
	cd backend && bundle exec rubocop -a
	cd frontend && pnpm lint:fix
	cd frontend && pnpm format

# ---------- type & arch ----------
typecheck: ## TypeScript strict check
	cd frontend && pnpm typecheck

pack-check: ## Packwerk architectural boundaries
	cd backend && bin/packwerk check

# ---------- security ----------
security: ## Brakeman + bundler-audit + npm audit
	cd backend && bundle exec brakeman --no-pager
	cd backend && bundle exec bundle-audit check --update
	cd frontend && pnpm audit --prod

# ---------- everything (use before claiming "done") ----------
check-all: test lint typecheck security pack-check ## Run every quality gate sequentially
	@echo "✅ All checks green."

# ---------- types from OpenAPI ----------
typegen: ## Regenerate frontend types from backend OpenAPI
	cd backend && bundle exec rake rswag:specs:swaggerize
	cd frontend && pnpm openapi-typescript ../backend/swagger/v1/swagger.yaml -o src/shared/api/types.gen.ts

# ---------- claude logs ----------
log: ## Scaffold a new log entry in .claude/logs/
	@DATE=$$(date +%Y-%m-%d); \
		read -r -p "Slug (kebab-case): " SLUG; \
		FILE=".claude/logs/$$DATE-$$SLUG.md"; \
		cp .claude/logs/_TEMPLATE.md $$FILE; \
		sed -i.bak "s/YYYY-MM-DD/$$DATE/g" $$FILE && rm $$FILE.bak; \
		echo "✏️  Created $$FILE"; \
		$${EDITOR:-vi} $$FILE

# ---------- clean ----------
clean: ## Remove build artifacts
	cd backend && rm -rf tmp/cache log/*.log coverage/
	cd frontend && rm -rf dist/ coverage/ playwright-report/ test-results/

reset: ## Drop & recreate database (DESTRUCTIVE)
	cd backend && bin/rails db:drop db:create db:migrate db:seed
