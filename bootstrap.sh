#!/usr/bin/env bash
# bootstrap.sh — one-shot setup from a fresh clone.
# Run this ONCE after `git clone`. After that, use `make dev` / `make test` / etc.

set -euo pipefail

GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
RED=$'\033[0;31m'
BOLD=$'\033[1m'
NC=$'\033[0m'

step() { printf "\n${GREEN}▶ %s${NC}\n" "$1"; }
warn() { printf "${YELLOW}⚠ %s${NC}\n" "$1"; }
fail() { printf "${RED}✗ %s${NC}\n" "$1"; exit 1; }

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${REPO_ROOT}"

# ──────────────────────────────────────────────────────────────────────
# 1. mise must exist AND be activated in this shell.
# ──────────────────────────────────────────────────────────────────────
step "Checking mise (Ruby/Node version manager)"
if ! command -v mise >/dev/null 2>&1; then
  warn "mise not found. Install with:"
  echo ""
  echo "    curl https://mise.run | sh"
  echo ""
  echo "Then add this line to ~/.zshrc (or ~/.bashrc) and restart the terminal:"
  echo ""
  echo "    eval \"\$(\$HOME/.local/bin/mise activate zsh)\""
  echo ""
  exit 1
fi

# ──────────────────────────────────────────────────────────────────────
# 2. Trust this repo's .mise.toml (otherwise mise silently ignores it).
# ──────────────────────────────────────────────────────────────────────
step "Trusting .mise.toml for this repo"
mise trust "${REPO_ROOT}/.mise.toml"

# ──────────────────────────────────────────────────────────────────────
# 3. Install pinned versions.
# ──────────────────────────────────────────────────────────────────────
step "Installing pinned Ruby + Node via mise"
mise install

# ──────────────────────────────────────────────────────────────────────
# 4. Verify mise is activated in CURRENT shell. Bail with a clear msg if not.
# ──────────────────────────────────────────────────────────────────────
step "Verifying mise is active in this shell"
RUBY_PATH="$(mise which ruby 2>/dev/null || true)"
NODE_PATH="$(mise which node 2>/dev/null || true)"
ACTIVE_RUBY="$(command -v ruby || true)"
ACTIVE_NODE="$(command -v node || true)"

if [[ -z "${RUBY_PATH}" || -z "${NODE_PATH}" ]]; then
  fail "mise didn't install runtimes. Run 'mise doctor' to diagnose."
fi

if [[ "${ACTIVE_RUBY}" != "${RUBY_PATH}" || "${ACTIVE_NODE}" != "${NODE_PATH}" ]]; then
  warn "mise is installed but NOT activated in this shell."
  echo ""
  echo "  Active ruby:   ${ACTIVE_RUBY}"
  echo "  Should be:     ${RUBY_PATH}"
  echo "  Active node:   ${ACTIVE_NODE}"
  echo "  Should be:     ${NODE_PATH}"
  echo ""
  echo "Add this line to your shell rc and restart:"
  echo "    ${BOLD}eval \"\$(mise activate zsh)\"${NC}"
  echo ""
  echo "OR run this once in the current session, then re-run ./bootstrap.sh:"
  echo "    ${BOLD}eval \"\$(mise activate zsh)\"${NC}"
  exit 1
fi

echo "  ✓ ruby = $(ruby -v)"
echo "  ✓ node = $(node -v)"

# ──────────────────────────────────────────────────────────────────────
# 5. Activate corepack and pin pnpm 9 (Node 22 ships with corepack).
# ──────────────────────────────────────────────────────────────────────
step "Activating pnpm via corepack"
corepack enable
corepack prepare pnpm@9.15.0 --activate
echo "  ✓ pnpm = $(pnpm -v)"

# ──────────────────────────────────────────────────────────────────────
# 6. Docker.
# ──────────────────────────────────────────────────────────────────────
step "Checking Docker"
if ! command -v docker >/dev/null 2>&1; then
  fail "Docker not found. Install Docker Desktop and rerun."
fi
if ! docker info >/dev/null 2>&1; then
  fail "Docker is installed but not running. Open Docker Desktop and wait for the green tray icon, then rerun."
fi
echo "  ✓ docker is running"

# ──────────────────────────────────────────────────────────────────────
# 7. Lefthook — install via brew if available, else via npm in user prefix.
# ──────────────────────────────────────────────────────────────────────
step "Installing lefthook (git hooks)"
if command -v lefthook >/dev/null 2>&1; then
  echo "  ✓ lefthook already installed: $(lefthook version)"
elif command -v brew >/dev/null 2>&1; then
  brew install lefthook
else
  # Fallback: install in user-writable prefix (no sudo needed).
  npm install --location=user --prefix "${HOME}/.npm-global" lefthook
  if ! grep -q '.npm-global/bin' "${HOME}/.zshrc" 2>/dev/null; then
    echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> "${HOME}/.zshrc"
    warn "Added \$HOME/.npm-global/bin to ~/.zshrc — restart shell to pick it up."
  fi
  export PATH="${HOME}/.npm-global/bin:${PATH}"
fi

if ! command -v lefthook >/dev/null 2>&1; then
  warn "lefthook still not on PATH. Skipping git-hooks install — you can install later via 'brew install lefthook'."
else
  lefthook install
fi

# ──────────────────────────────────────────────────────────────────────
# 8. .env files.
# ──────────────────────────────────────────────────────────────────────
step "Preparing .env files"
if [[ ! -f .env ]]; then
  cp .env.example .env
  echo "  Created .env from .env.example. Edit if you need non-default secrets."
fi

if [[ ! -f .mcp.env ]] && [[ -f .mcp.example.env ]]; then
  cp .mcp.example.env .mcp.env
  echo "  Created .mcp.env (add MAGIC_MCP_API_KEY for premium features)."
fi

# ──────────────────────────────────────────────────────────────────────
# 9. Docker services.
# ──────────────────────────────────────────────────────────────────────
step "Starting Postgres + Mailhog (docker compose)"
docker compose up -d
sleep 3

# ──────────────────────────────────────────────────────────────────────
# 10. Backend.
# ──────────────────────────────────────────────────────────────────────
step "Backend: bundle install"
( cd backend && bundle install )

step "Backend: db:prepare + db:seed"
( cd backend && bin/rails db:prepare db:seed )

# ──────────────────────────────────────────────────────────────────────
# 11. Frontend.
# ──────────────────────────────────────────────────────────────────────
step "Frontend: pnpm install"
( cd frontend && pnpm install )

step "Frontend: install Playwright Chromium"
( cd frontend && pnpm exec playwright install chromium )

# ──────────────────────────────────────────────────────────────────────
# 12. Verify.
# ──────────────────────────────────────────────────────────────────────
step "Verifying setup"
( cd backend && bin/rspec --dry-run >/dev/null ) && echo "  ✓ RSpec specs discoverable" || warn "RSpec dry-run failed"
( cd backend && bin/packwerk check ) && echo "  ✓ Packwerk clean" || warn "Packwerk check reported violations"

# ──────────────────────────────────────────────────────────────────────
# 13. Done.
# ──────────────────────────────────────────────────────────────────────
cat <<EOF

${GREEN}✅ Bootstrap complete.${NC}

Next:
  ${BOLD}make dev${NC}                 — start docker + Rails + Vite together
  open http://localhost:5173 — sign in as demo@example.com / password123

Then in Claude Code:
  - .mcp.json wires up context7 + magic-mcp + playwright MCP servers
  - First user prompt: Claude reads CLAUDE.md → PROGRESS.md → latest 2 logs automatically
  - Use plan-mode (Shift+Tab) for any non-trivial change
  - Slash commands: /check-all, /tdd, /new-pack, /new-slice, /new-log, /architecture-check

Read CLAUDE.md to understand the rules. Then ship.
EOF
