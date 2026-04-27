#!/usr/bin/env bash
# bootstrap.sh — one-shot setup from a fresh clone.
#
# This script is paranoid about "works on a clean machine":
#   - Installs missing tools (mise, Docker Desktop, gh, lefthook) when it can.
#   - Retries network operations (bundle, pnpm, playwright, docker pull) up to 3x.
#   - Picks free TCP ports automatically and writes them to .ports.env.
#   - Substitutes ports + DB names into .env from .env.example.
#   - Auto-generates the Rails master key on first run.
#   - On any fatal failure: runs `.claude/scripts/doctor.sh` and points at heal.
#
# Run after cloning:   ./bootstrap.sh
# Or via Makefile:     make bootstrap
# Then:                make dev

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${REPO_ROOT}"

GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
RED=$'\033[0;31m'
BOLD=$'\033[1m'
NC=$'\033[0m'

step() { printf "\n${GREEN}▶ %s${NC}\n" "$1"; }
warn() { printf "${YELLOW}⚠ %s${NC}\n" "$1"; }
fail() { printf "${RED}✗ %s${NC}\n" "$1"; exit 1; }
note() { printf "  %s\n" "$1"; }

# ──────────────────────────────────────────────────────────────────────
# retry CMD ARGS — try up to 3 times with backoff (5s, 10s).
# ──────────────────────────────────────────────────────────────────────
retry() {
  local n=0 max=3
  while [ "$n" -lt "$max" ]; do
    if "$@"; then return 0; fi
    n=$((n + 1))
    if [ "$n" -lt "$max" ]; then
      local delay=$((n * 5))
      warn "Command failed (attempt ${n}/${max}); retrying in ${delay}s..."
      sleep "$delay"
    fi
  done
  return 1
}

# ──────────────────────────────────────────────────────────────────────
# On any fatal exit: run doctor + heal hint.
# ──────────────────────────────────────────────────────────────────────
on_failure() {
  local ec=$?
  if [ "$ec" -ne 0 ]; then
    printf "\n${RED}━━━ Bootstrap failed (exit %d) ━━━${NC}\n" "$ec"
    if [ -x .claude/scripts/doctor.sh ]; then
      printf "${BOLD}Running doctor for diagnosis...${NC}\n"
      .claude/scripts/doctor.sh || true
    fi
    printf "\n${BOLD}Try one of:${NC}\n"
    echo "  • make heal             — auto-fixes most common breakage"
    echo "  • cat docs/TROUBLESHOOTING.md"
    echo "  • re-run ./bootstrap.sh after addressing the ✗ items above"
  fi
}
trap on_failure EXIT

is_macos() { [ "$(uname)" = "Darwin" ]; }

# ══════════════════════════════════════════════════════════════════════
# 1. brew (macOS prerequisite for installing everything else)
# ══════════════════════════════════════════════════════════════════════
if is_macos && ! command -v brew >/dev/null 2>&1; then
  fail "Homebrew is required on macOS. Install with:
    /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"
Then re-run ./bootstrap.sh."
fi

# ══════════════════════════════════════════════════════════════════════
# 2. mise — install + activate
# ══════════════════════════════════════════════════════════════════════
step "Checking mise (Ruby/Node version manager)"
if ! command -v mise >/dev/null 2>&1; then
  warn "mise not found — installing via curl https://mise.run | sh"
  retry curl -fsSL https://mise.run | sh
  export PATH="${HOME}/.local/bin:${PATH}"
  if ! command -v mise >/dev/null 2>&1; then
    fail "mise install failed. See https://mise.jdx.dev for manual install."
  fi
  if ! grep -q 'mise activate' "${HOME}/.zshrc" 2>/dev/null; then
    echo '' >> "${HOME}/.zshrc"
    echo '# mise — Ruby/Node version manager' >> "${HOME}/.zshrc"
    echo 'eval "$(mise activate zsh)"' >> "${HOME}/.zshrc"
    note "Added mise activation to ~/.zshrc (restart shell after this script finishes)."
  fi
  eval "$(mise activate bash 2>/dev/null || mise activate zsh 2>/dev/null || true)"
fi
note "mise = $(mise --version | head -1)"

step "Trusting .mise.toml for this repo"
mise trust "${REPO_ROOT}/.mise.toml" >/dev/null

step "Configuring mise to use precompiled Ruby (avoids libyaml/openssl build failures)"
mise settings ruby.compile=false 2>/dev/null || true

step "Installing pinned Ruby + Node via mise"
retry mise install

# ══════════════════════════════════════════════════════════════════════
# 3. Verify mise is active in *this* shell.
# ══════════════════════════════════════════════════════════════════════
step "Verifying mise is active in this shell"
RUBY_PATH="$(mise which ruby 2>/dev/null || true)"
NODE_PATH="$(mise which node 2>/dev/null || true)"
ACTIVE_RUBY="$(command -v ruby || true)"
ACTIVE_NODE="$(command -v node || true)"

if [ -z "${RUBY_PATH}" ] || [ -z "${NODE_PATH}" ]; then
  fail "mise didn't install runtimes. Run 'mise doctor' to diagnose."
fi

if [ "${ACTIVE_RUBY}" != "${RUBY_PATH}" ] || [ "${ACTIVE_NODE}" != "${NODE_PATH}" ]; then
  warn "mise is installed but NOT activated in *this* shell."
  echo ""
  echo "  Active ruby:   ${ACTIVE_RUBY}"
  echo "  Should be:     ${RUBY_PATH}"
  echo "  Active node:   ${ACTIVE_NODE}"
  echo "  Should be:     ${NODE_PATH}"
  echo ""
  echo "Restart your terminal (or 'source ~/.zshrc') and re-run ./bootstrap.sh."
  exit 1
fi

note "ruby = $(ruby -v)"
note "node = $(node -v)"

# ══════════════════════════════════════════════════════════════════════
# 4. pnpm via corepack.
# ══════════════════════════════════════════════════════════════════════
step "Activating pnpm via corepack"
corepack enable
retry corepack prepare pnpm@9.15.0 --activate
note "pnpm = $(pnpm -v)"

# ══════════════════════════════════════════════════════════════════════
# 5. Docker — install (macOS) and start if needed.
# ══════════════════════════════════════════════════════════════════════
step "Checking Docker"
if ! command -v docker >/dev/null 2>&1; then
  if is_macos; then
    warn "Docker not installed — running 'brew install --cask docker'"
    brew install --cask docker
  else
    fail "Docker not installed. Install Docker Desktop and rerun: https://docker.com/products/docker-desktop"
  fi
fi

if ! docker info >/dev/null 2>&1; then
  if is_macos; then
    warn "Docker daemon not running — opening Docker Desktop"
    open -a Docker || true
    note "Waiting for Docker daemon (up to 120s)..."
    for _ in $(seq 1 24); do
      sleep 5
      if docker info >/dev/null 2>&1; then break; fi
    done
  fi
fi

if ! docker info >/dev/null 2>&1; then
  fail "Docker is installed but daemon won't start. Open Docker Desktop manually, wait for the green tray icon, then re-run."
fi
note "docker is running"

# ══════════════════════════════════════════════════════════════════════
# 6. lefthook (git hooks).
# ══════════════════════════════════════════════════════════════════════
step "Installing lefthook (git hooks)"
if command -v lefthook >/dev/null 2>&1; then
  note "lefthook already installed: $(lefthook version)"
elif command -v brew >/dev/null 2>&1; then
  brew install lefthook
else
  npm install --location=user --prefix "${HOME}/.npm-global" lefthook
  if ! grep -q '.npm-global/bin' "${HOME}/.zshrc" 2>/dev/null; then
    echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> "${HOME}/.zshrc"
    warn "Added \$HOME/.npm-global/bin to ~/.zshrc — restart shell to pick it up."
  fi
  export PATH="${HOME}/.npm-global/bin:${PATH}"
fi

if command -v lefthook >/dev/null 2>&1; then
  lefthook install
else
  warn "lefthook still not on PATH — skipping hooks install."
fi

# ══════════════════════════════════════════════════════════════════════
# 7. gh CLI (used by 'gh repo create', PR review, etc).
# ══════════════════════════════════════════════════════════════════════
step "Installing gh (GitHub CLI)"
if command -v gh >/dev/null 2>&1; then
  note "gh already installed: $(gh --version | head -1)"
elif command -v brew >/dev/null 2>&1; then
  brew install gh
else
  warn "gh not installed and no brew available — skip (install manually: https://cli.github.com)"
fi

# ══════════════════════════════════════════════════════════════════════
# 8. Allocate free ports → .ports.env.
# ══════════════════════════════════════════════════════════════════════
step "Allocating free TCP ports"
./bin/allocate-ports
# shellcheck disable=SC1091
. ./bin/allocate-ports
load_ports
note "BACKEND_PORT=${BACKEND_PORT}  FRONTEND_PORT=${FRONTEND_PORT}  POSTGRES_PORT=${POSTGRES_PORT}"

# ══════════════════════════════════════════════════════════════════════
# 9. .env files — create from example, substitute ports.
# ══════════════════════════════════════════════════════════════════════
step "Preparing .env files"
if [ ! -f .env ]; then
  cp .env.example .env
  note "Created .env from .env.example."
fi

# Substitute the auto-allocated ports (idempotent — only touches the *PORT lines).
substitute_port() {
  local key="$1" val="$2"
  if [ -f .env ]; then
    if grep -qE "^${key}=" .env; then
      # macOS sed needs '' after -i.
      sed -i.bak -E "s|^${key}=.*$|${key}=${val}|" .env && rm -f .env.bak
    else
      printf "%s=%s\n" "$key" "$val" >> .env
    fi
  fi
}

substitute_port BACKEND_PORT       "${BACKEND_PORT}"
substitute_port FRONTEND_PORT      "${FRONTEND_PORT}"
substitute_port POSTGRES_PORT      "${POSTGRES_PORT}"
substitute_port MAILPIT_SMTP_PORT  "${MAILPIT_SMTP_PORT}"
substitute_port MAILPIT_UI_PORT    "${MAILPIT_UI_PORT}"
substitute_port SMTP_PORT          "${MAILPIT_SMTP_PORT}"

# Rebuild URLs that reference ports.
sed -i.bak -E "s|^DATABASE_URL=.*$|DATABASE_URL=postgres://postgres:postgres@localhost:${POSTGRES_PORT}/$(grep '^POSTGRES_DB=' .env | cut -d= -f2)|" .env && rm -f .env.bak
sed -i.bak -E "s|^CORS_ORIGINS=.*$|CORS_ORIGINS=http://localhost:${FRONTEND_PORT}|" .env && rm -f .env.bak
sed -i.bak -E "s|^VITE_API_BASE_URL=.*$|VITE_API_BASE_URL=http://localhost:${BACKEND_PORT}|" .env && rm -f .env.bak

if [ ! -f .mcp.env ] && [ -f .mcp.example.env ]; then
  cp .mcp.example.env .mcp.env
  note "Created .mcp.env (add MAGIC_MCP_API_KEY for premium features)."
fi

# ══════════════════════════════════════════════════════════════════════
# 10. Rails master key — auto-generate if missing.
# ══════════════════════════════════════════════════════════════════════
step "Ensuring Rails master key exists"
if [ ! -f backend/config/master.key ]; then
  ( cd backend && EDITOR=true bin/rails credentials:edit )
  note "Generated backend/config/master.key + credentials.yml.enc"
else
  note "master.key already present"
fi

# ══════════════════════════════════════════════════════════════════════
# 11. Docker services up (with allocated ports from environment).
# ══════════════════════════════════════════════════════════════════════
step "Starting Postgres + Mailpit (docker compose)"
retry docker compose up -d
sleep 3

# ══════════════════════════════════════════════════════════════════════
# 12. Backend.
# ══════════════════════════════════════════════════════════════════════
step "Backend: bundle install"
( cd backend && retry bundle install )

step "Backend: db:prepare + db:seed"
( cd backend && retry bin/rails db:prepare db:seed )

# ══════════════════════════════════════════════════════════════════════
# 13. Frontend.
# ══════════════════════════════════════════════════════════════════════
step "Frontend: pnpm install"
( cd frontend && retry pnpm install )

step "Frontend: install Playwright Chromium"
( cd frontend && retry pnpm exec playwright install chromium )

# ══════════════════════════════════════════════════════════════════════
# 14. Verify.
# ══════════════════════════════════════════════════════════════════════
step "Verifying setup"
( cd backend && bin/rspec --dry-run >/dev/null 2>&1 ) && note "✓ RSpec specs discoverable" || warn "RSpec dry-run failed"
( cd backend && bin/packwerk check ) && note "✓ Packwerk clean" || warn "Packwerk check reported violations"

# ══════════════════════════════════════════════════════════════════════
# Done — disable trap so we don't print the failure banner on success.
# ══════════════════════════════════════════════════════════════════════
trap - EXIT

cat <<EOF

${GREEN}✅ Bootstrap complete.${NC}

Allocated dev ports (saved to .ports.env):
  Rails    → http://localhost:${BACKEND_PORT}
  Vite     → http://localhost:${FRONTEND_PORT}
  Postgres → localhost:${POSTGRES_PORT}
  Mailpit  → http://localhost:${MAILPIT_UI_PORT}

Next:
  ${BOLD}make dev${NC}                 — start docker + Rails + Vite together
  open http://localhost:${FRONTEND_PORT} — sign in as demo@example.com / password123

Then in Claude Code:
  - .mcp.json wires up context7 + magic-mcp + playwright + shadcn-ui + sequential-thinking
  - First user prompt: Claude reads CLAUDE.md → PROGRESS.md → latest 2 logs automatically
  - Use plan-mode (Shift+Tab) for any non-trivial change
  - Slash commands: /go, /check-all, /tdd, /new-pack, /new-slice, /new-log, /architecture-check, /init

Read CLAUDE.md to understand the rules. Then ship.
EOF
