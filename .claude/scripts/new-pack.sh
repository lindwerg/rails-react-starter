#!/usr/bin/env bash
# Scaffold a new Packwerk pack.
# Usage: .claude/scripts/new-pack.sh <name> [layer]
#   layer ∈ {orchestrator, business_domain, platform, utility}
#   default: business_domain

set -euo pipefail

NAME="${1:?Usage: new-pack.sh <name> [layer]}"
LAYER="${2:-business_domain}"

case "${LAYER}" in
  orchestrator|business_domain|platform|utility) ;;
  *) echo "Invalid layer '${LAYER}'. Use one of: orchestrator|business_domain|platform|utility" >&2; exit 1 ;;
esac

ROOT="backend/packs/${NAME}"
if [[ -d "${ROOT}" ]]; then
  echo "Pack already exists: ${ROOT}" >&2
  exit 1
fi

mkdir -p \
  "${ROOT}/app/models" \
  "${ROOT}/app/services/${NAME}" \
  "${ROOT}/app/public/${NAME}" \
  "${ROOT}/app/policies" \
  "${ROOT}/app/queries/${NAME}" \
  "${ROOT}/spec/models" \
  "${ROOT}/spec/services/${NAME}" \
  "${ROOT}/spec/policies" \
  "${ROOT}/spec/factories"

touch "${ROOT}/app/models/.keep" \
      "${ROOT}/app/policies/.keep" \
      "${ROOT}/spec/models/.keep" \
      "${ROOT}/spec/policies/.keep" \
      "${ROOT}/spec/factories/.keep"

# Default deps for business_domain layer; tweak for other layers.
DEPS=""
if [[ "${LAYER}" == "business_domain" ]]; then
  DEPS=$'\n  - packs/shared'
elif [[ "${LAYER}" == "platform" ]]; then
  DEPS=$'\n  - packs/shared'
elif [[ "${LAYER}" == "orchestrator" ]]; then
  DEPS=$'\n  - packs/shared\n  - packs/users'
fi

cat > "${ROOT}/package.yml" <<EOF
enforce_dependencies: true
enforce_privacy: true
enforce_layers: true
layer: ${LAYER}

dependencies:${DEPS}

metadata:
  responsibilities: |
    TODO: describe what this pack owns and why it exists as a separate boundary.
EOF

cat > "${ROOT}/README.md" <<EOF
# pack: ${NAME}

**Layer:** \`${LAYER}\`

> TODO: one paragraph describing this pack's responsibility.

## Public API

The following constants are visible to other packs (anything in \`app/public/\`):

- _empty — add files under \`app/public/${NAME}/\`_

## Tests

\`\`\`bash
cd backend && bin/rspec packs/${NAME}/spec
\`\`\`
EOF

echo "✅ Created pack: ${ROOT}"
echo "   Layer: ${LAYER}"
echo "   Edit ${ROOT}/package.yml to declare additional dependencies."
echo "   Edit ${ROOT}/README.md to document responsibility."
echo ""
echo "Next: write a failing spec under ${ROOT}/spec/ before any implementation."
