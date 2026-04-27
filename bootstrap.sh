#!/usr/bin/env bash
# bootstrap.sh — one-shot setup from a fresh clone.
# Run this ONCE after `git clone`. After that, use `make dev` / `make test` / etc.

set -euo pipefail

GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
RED=$'\033[0;31m'
NC=$'\033[0m'

step() { printf "\n${GREEN}▶ %s${NC}\n" "$1"; }
warn() { printf "${YELLOW}⚠ %s${NC}\n" "$1"; }
fail() { printf "${RED}✗ %s${NC}\n" "$1"; exit 1; }

# 1 ── tooling
step "Checking mise (Ruby/Node version manager)"
if ! command -v mise >/dev/null 2>&1; then
  warn "mise not found. Install with:"
  echo "    curl https://mise.run | sh"
  echo "    # then add 'eval \"\$(mise activate \$(basename \$SHELL))\"' to your shell rc"
  exit 1
fi

step "Installing pinned Ruby/Node/pnpm via mise"
mise install

step "Checking Docker"
if ! command -v docker >/dev/null 2>&1; then
  fail "Docker not found. Install Docker Desktop and rerun."
fi

step "Installing lefthook (git hooks)"
if ! command -v lefthook >/dev/null 2>&1; then
  npm install -g lefthook
fi
lefthook install

step "Installing overmind (Procfile.dev runner) — optional"
if ! command -v overmind >/dev/null 2>&1; then
  warn "overmind not found. Falling back to foreman. To get overmind:"
  echo "    brew install overmind   # macOS"
fi

# 2 ── env
step "Preparing .env"
if [[ ! -f .env ]]; then
  cp .env.example .env
  echo "  Created .env from .env.example. Edit it if you need non-default secrets."
fi

if [[ ! -f .mcp.env ]] && [[ -f .mcp.example.env ]]; then
  cp .mcp.example.env .mcp.env
  echo "  Created .mcp.env from template — add MAGIC_MCP_API_KEY for premium features."
fi

# 3 ── docker services
step "Starting Postgres + Mailhog"
docker compose up -d
sleep 3

# 4 ── backend
step "Backend: bundle install"
( cd backend && bundle install )

step "Backend: db prepare + seed"
( cd backend && bin/rails db:prepare db:seed )

# 5 ── frontend
step "Frontend: pnpm install"
( cd frontend && pnpm install )

step "Frontend: install Playwright browsers"
( cd frontend && pnpm exec playwright install --with-deps chromium )

# 6 ── verify
step "Verifying setup"
( cd backend && bin/rspec --dry-run >/dev/null ) && echo "  ✓ RSpec specs discoverable"
( cd frontend && pnpm vitest --run --reporter=basic --include='!(none)' >/dev/null 2>&1 ) || true
( cd backend && bin/packwerk check ) && echo "  ✓ Packwerk clean"

# 7 ── done
cat <<EOF

${GREEN}✅ Bootstrap complete.${NC}

Next:
  ${GREEN}make dev${NC}                 — start docker + Rails + Vite together
  open http://localhost:5173 — sign in as demo@example.com / password123

Then in Claude Code:
  - .mcp.json wires up context7 + magic-mcp + playwright MCP servers
  - First user prompt: Claude reads CLAUDE.md → PROGRESS.md → latest 2 logs automatically
  - Use plan-mode (Shift+Tab) for any non-trivial change
  - Slash commands: /check-all, /tdd, /new-pack, /new-slice, /new-log, /architecture-check

Read CLAUDE.md to understand the rules. Then ship.
EOF
