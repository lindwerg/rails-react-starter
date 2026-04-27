# Makefile — single entry point for all commands.
# Run `make help` to see what's available.

.DEFAULT_GOAL := help
.PHONY: help bootstrap first-run setup setup-tools setup-backend setup-frontend \
        dev dev-services test test-backend test-frontend e2e \
        lint lint-backend lint-frontend lint-fix \
        typecheck security typegen pack-check check-all doctor \
        seed-rich api-docs \
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
dev: ## Start docker services + Rails + Vite (delegates to bin/dev)
	./bin/dev

dev-services: ## Start docker-compose services (postgres, mailhog)
	docker compose up -d

# ---------- demo data ----------
seed-rich: ## Replace seeds with a richer dataset (5 users, ~50 posts) for UI dev
	cd backend && bin/rails db:seed:replant
	cd backend && bin/rails dev:seed_rich

# ---------- API docs ----------
api-docs: ## Open the rswag Swagger UI in the default browser
	@if command -v open >/dev/null 2>&1; then open http://localhost:3000/api-docs; \
	elif command -v xdg-open >/dev/null 2>&1; then xdg-open http://localhost:3000/api-docs; \
	else echo "Open http://localhost:3000/api-docs in a browser"; fi

# ---------- test ----------
test: ## Run all tests (writes .claude/.last-test-status for the Claude statusline)
	@mkdir -p .claude
	@if $(MAKE) -s test-backend && $(MAKE) -s test-frontend; then \
		echo pass > .claude/.last-test-status; \
	else \
		echo fail > .claude/.last-test-status; exit 1; \
	fi

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

pack-check: ## Packwerk architectural boundaries (writes .claude/.last-packwerk-status for the statusline)
	@mkdir -p .claude
	@if cd backend && bin/packwerk check; then \
		echo clean > ../.claude/.last-packwerk-status; \
	else \
		echo dirty > ../.claude/.last-packwerk-status; exit 1; \
	fi

# ---------- security ----------
security: ## Brakeman + bundler-audit + npm audit
	cd backend && bundle exec brakeman --no-pager
	cd backend && bundle exec bundle-audit check --update
	cd frontend && pnpm audit --prod

# ---------- everything (use before claiming "done") ----------
check-all: test lint typecheck security pack-check ## Run every quality gate sequentially
	@echo "✅ All checks green."

# ---------- doctor: diagnose broken-first-run pain ----------
doctor: ## Diagnose mise/Docker/ports/env/hooks (run when something feels off)
	@.claude/scripts/doctor.sh

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

reset: ## Drop & recreate database (DESTRUCTIVE — asks for confirmation)
	@printf "⚠️  This will DROP the database. All data will be lost.\nType 'yes' to continue: "; \
		read ans; \
		[ "$$ans" = "yes" ] || { echo "Aborted."; exit 1; }
	cd backend && bin/rails db:drop db:create db:migrate db:seed
