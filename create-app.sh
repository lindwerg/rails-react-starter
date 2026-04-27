#!/usr/bin/env bash
# create-app.sh — clone this template into a new directory and run bin/init.
#
# Designed to be invoked via `curl | bash`:
#
#   curl -fsSL https://raw.githubusercontent.com/lindwerg/rails-react-starter/main/create-app.sh \
#     | bash -s my-shop
#
# Or directly after cloning:  ./create-app.sh my-shop
#
# Env overrides:
#   TEMPLATE_REPO   default: github.com/lindwerg/rails-react-starter
#   TEMPLATE_REF    default: main
#   NO_BOOTSTRAP    if set, skip bootstrap (rename only)

set -euo pipefail

NAME="${1:-}"
if [ -z "${NAME}" ]; then
  echo "Usage: create-app.sh <project-name>" >&2
  echo "       curl -fsSL <url>/create-app.sh | bash -s <project-name>" >&2
  exit 2
fi

TEMPLATE_REPO="${TEMPLATE_REPO:-https://github.com/lindwerg/rails-react-starter.git}"
TEMPLATE_REF="${TEMPLATE_REF:-main}"

GREEN=$'\033[0;32m'
BOLD=$'\033[1m'
NC=$'\033[0m'

if [ -e "${NAME}" ]; then
  echo "Refusing to clone: '${NAME}' already exists in this directory." >&2
  exit 1
fi

if ! command -v git >/dev/null 2>&1; then
  echo "git is required. Install it first." >&2
  exit 1
fi

printf "${GREEN}▶${NC} Cloning %s into %s/\n" "${TEMPLATE_REPO}" "${NAME}"
git clone --depth=1 --branch "${TEMPLATE_REF}" "${TEMPLATE_REPO}" "${NAME}"
cd "${NAME}"

if [ "${NO_BOOTSTRAP:-}" = "1" ]; then
  ./bin/init --no-bootstrap
else
  ./bin/init
fi

cat <<EOF

${GREEN}🎉 ${NAME} is ready.${NC}

  cd ${NAME}
  ${BOLD}make dev${NC}    — start docker + Rails + Vite
  open http://localhost:\$(grep ^FRONTEND_PORT .ports.env | cut -d= -f2)
EOF
