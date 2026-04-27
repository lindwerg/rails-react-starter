#!/usr/bin/env bash
# Diagnostic script for first-run / broken-setup pain points.
# Each check prints ✓ or ✗ + a one-line "how to fix".
# Exit non-zero if any critical check fails.

set -uo pipefail

GREEN=$'\033[0;32m'
RED=$'\033[0;31m'
YELLOW=$'\033[1;33m'
BOLD=$'\033[1m'
NC=$'\033[0m'

passes=0
fails=0
warns=0

ok()   { printf "  ${GREEN}✓${NC} %s\n" "$1"; passes=$((passes + 1)); }
bad()  { printf "  ${RED}✗${NC} %s\n     ${YELLOW}fix:${NC} %s\n" "$1" "$2"; fails=$((fails + 1)); }
warn() { printf "  ${YELLOW}⚠${NC} %s\n     %s\n" "$1" "$2"; warns=$((warns + 1)); }

section() { printf "\n${BOLD}%s${NC}\n" "$1"; }

cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)" || exit 1

# ── Tooling ─────────────────────────────────────────────────────────────
section "Tooling"

if command -v mise >/dev/null 2>&1; then
  ok "mise installed: $(mise --version | head -1)"
else
  bad "mise not installed" "curl https://mise.run | sh && add 'eval \"\$(mise activate zsh)\"' to ~/.zshrc"
fi

if command -v ruby >/dev/null 2>&1; then
  active_ruby="$(command -v ruby)"
  expected_ruby="$(mise which ruby 2>/dev/null || echo "")"
  if [[ -n "${expected_ruby}" && "${active_ruby}" == "${expected_ruby}" ]]; then
    ok "ruby active via mise: $(ruby -v | awk '{print $1, $2}')"
  elif [[ -n "${expected_ruby}" ]]; then
    bad "ruby on PATH is NOT mise's ruby" "Add 'eval \"\$(mise activate zsh)\"' to ~/.zshrc and restart shell. Active=${active_ruby}, expected=${expected_ruby}"
  else
    warn "ruby is on PATH but mise can't find its ruby" "Run 'mise install' in repo root"
  fi
else
  bad "ruby not on PATH" "Run 'mise install' after activating mise"
fi

if command -v node >/dev/null 2>&1; then
  active_node="$(command -v node)"
  expected_node="$(mise which node 2>/dev/null || echo "")"
  if [[ -n "${expected_node}" && "${active_node}" == "${expected_node}" ]]; then
    ok "node active via mise: $(node -v)"
  elif [[ -n "${expected_node}" ]]; then
    bad "node on PATH is NOT mise's node" "Active=${active_node}, expected=${expected_node}"
  fi
else
  bad "node not on PATH" "Run 'mise install'"
fi

if command -v pnpm >/dev/null 2>&1; then
  ok "pnpm: $(pnpm -v)"
else
  bad "pnpm not on PATH" "corepack enable && corepack prepare pnpm@9.15.0 --activate"
fi

if command -v jq >/dev/null 2>&1; then ok "jq installed (used by guard hooks)"; else bad "jq missing" "brew install jq (guard hooks rely on it)"; fi
if command -v lefthook >/dev/null 2>&1; then ok "lefthook installed"; else warn "lefthook not on PATH" "brew install lefthook && lefthook install"; fi
if command -v overmind >/dev/null 2>&1; then ok "overmind installed"; elif command -v foreman >/dev/null 2>&1; then ok "foreman installed (overmind not, that's OK)"; else warn "neither overmind nor foreman" "gem install foreman (or brew install overmind)"; fi

# ── Docker ──────────────────────────────────────────────────────────────
section "Docker"

if command -v docker >/dev/null 2>&1; then
  if docker info >/dev/null 2>&1; then
    ok "docker daemon running"
    if docker compose version >/dev/null 2>&1; then ok "docker compose v2 available"; else bad "docker compose missing" "Update Docker Desktop"; fi
  else
    bad "docker installed but daemon not running" "Open Docker Desktop, wait for green tray icon, retry"
  fi
else
  bad "docker not installed" "Install Docker Desktop: https://docker.com/products/docker-desktop"
fi

# ── Ports ───────────────────────────────────────────────────────────────
section "Ports"

check_port() {
  local port="$1"
  local label="$2"
  if lsof -nP -iTCP:"${port}" -sTCP:LISTEN >/dev/null 2>&1; then
    local pid
    pid="$(lsof -nP -iTCP:"${port}" -sTCP:LISTEN -t 2>/dev/null | head -1)"
    local proc
    proc="$(ps -p "${pid}" -o comm= 2>/dev/null || echo "?")"
    warn "port ${port} (${label}) is in use by pid ${pid} (${proc})" "Stop it, or set the corresponding host port in .env"
  else
    ok "port ${port} (${label}) free"
  fi
}

check_port 3000 "Rails"
check_port 5173 "Vite"
check_port 5433 "Postgres (host)"
check_port 1025 "Mailpit SMTP"
check_port 8025 "Mailpit UI"

# ── Env files ───────────────────────────────────────────────────────────
section "Env files"

if [[ -f .env ]]; then ok ".env exists"; else bad ".env missing" "cp .env.example .env"; fi
if [[ -f backend/config/master.key ]] || [[ -n "${RAILS_MASTER_KEY:-}" ]]; then
  ok "Rails master key configured"
else
  warn "backend/config/master.key missing" "Will be generated on first 'bin/rails credentials:edit', or set RAILS_MASTER_KEY env var"
fi

# ── Git hooks ───────────────────────────────────────────────────────────
section "Git hooks"

if [[ -f .git/hooks/pre-commit ]]; then ok "lefthook pre-commit installed"; else warn "lefthook hooks not installed" "Run 'lefthook install' in repo root"; fi

# ── MCP servers ─────────────────────────────────────────────────────────
section "MCP"

if [[ -f .mcp.json ]]; then
  count="$(jq -r '.mcpServers | keys | length' .mcp.json 2>/dev/null || echo "?")"
  ok ".mcp.json present with ${count} server(s)"
else
  warn ".mcp.json missing" "Should be checked in"
fi

# ── Backend boot sanity ─────────────────────────────────────────────────
section "Backend boot sanity"

if [[ -d backend/vendor/bundle ]] || bundle config --local path >/dev/null 2>&1; then
  ok "bundle path looks set"
else
  warn "bundle install hasn't run" "cd backend && bundle install"
fi

if [[ -f backend/Gemfile.lock ]]; then ok "Gemfile.lock present"; else bad "Gemfile.lock missing" "cd backend && bundle install"; fi
if [[ -f frontend/pnpm-lock.yaml ]]; then ok "pnpm-lock.yaml present"; else bad "pnpm-lock.yaml missing" "cd frontend && pnpm install"; fi
if [[ -d frontend/node_modules ]]; then ok "frontend node_modules present"; else warn "frontend node_modules missing" "cd frontend && pnpm install"; fi

# ── Result ──────────────────────────────────────────────────────────────
echo ""
printf "${BOLD}Result:${NC} ${GREEN}%d ✓${NC}  ${YELLOW}%d ⚠${NC}  ${RED}%d ✗${NC}\n" "${passes}" "${warns}" "${fails}"
[[ "${fails}" -eq 0 ]]
