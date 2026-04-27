#!/usr/bin/env bash
# Scaffold a new FSD slice.
# Usage: .claude/scripts/new-slice.sh <layer> <name>
#   layer ∈ {entities, features, widgets, pages}

set -euo pipefail

LAYER="${1:?Usage: new-slice.sh <layer> <name>}"
NAME="${2:?Usage: new-slice.sh <layer> <name>}"

case "${LAYER}" in
  entities|features|widgets|pages) ;;
  *) echo "Invalid layer '${LAYER}'. Use one of: entities|features|widgets|pages" >&2; exit 1 ;;
esac

ROOT="frontend/src/${LAYER}/${NAME}"
if [[ -d "${ROOT}" ]]; then
  echo "Slice already exists: ${ROOT}" >&2
  exit 1
fi

mkdir -p "${ROOT}/ui" "${ROOT}/model" "${ROOT}/api" "${ROOT}/lib"
touch "${ROOT}/ui/.keep" "${ROOT}/model/.keep" "${ROOT}/api/.keep" "${ROOT}/lib/.keep"

# Pages get a default Page component skeleton.
if [[ "${LAYER}" == "pages" ]]; then
  PASCAL="$(echo "${NAME}" | awk -F'-' '{for(i=1;i<=NF;i++)$i=toupper(substr($i,1,1)) tolower(substr($i,2))}1' OFS='')"
  cat > "${ROOT}/${PASCAL}Page.tsx" <<EOF
export function ${PASCAL}Page() {
  return (
    <div className="py-6">
      <h1 className="text-2xl font-semibold">${PASCAL}</h1>
      <p className="text-neutral-500">TODO: implement ${NAME} page.</p>
    </div>
  );
}
EOF
  cat > "${ROOT}/index.ts" <<EOF
export { ${PASCAL}Page } from './${PASCAL}Page';
EOF
else
  cat > "${ROOT}/index.ts" <<EOF
// Public API of slice "${NAME}" (FSD layer: ${LAYER}).
// Re-export only what other slices/layers should consume.
export {};
EOF
fi

echo "✅ Created FSD slice: ${ROOT}"
echo "   Layer: ${LAYER}"
echo ""
echo "Next steps:"
if [[ "${LAYER}" == "features" || "${LAYER}" == "widgets" || "${LAYER}" == "entities" ]]; then
  echo "  - For UI components inside ui/, USE magic-mcp first (see CLAUDE.md §2.1)."
fi
echo "  - Write a failing test before any implementation (see CLAUDE.md §2.2)."
echo "  - Re-export public API additions through ${ROOT}/index.ts only — no deep imports allowed."
