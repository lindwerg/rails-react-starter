#!/usr/bin/env bash
# PreToolUse guard for Write|Edit. Blocks §5 anti-patterns from CLAUDE.md.
# Exit 2 = block (Claude sees stderr and corrects). Exit 0 = pass-through.

set -uo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=guard-lib.sh
source "${DIR}/guard-lib.sh"

# jq missing → don't block, just pass.
command -v jq >/dev/null 2>&1 || exit 0

guard_read_input

file="$(guard_field '.tool_input.file_path')"
content="$(guard_field '.tool_input.content')"
new_string="$(guard_field '.tool_input.new_string')"
text="${content}${new_string}"

[[ -z "${file}" ]] && exit 0

# ── Rule 1: localStorage / sessionStorage for tokens in frontend ────────
if [[ "${file}" =~ ^frontend/src/ ]]; then
  if echo "${text}" | grep -qE '(localStorage|sessionStorage)\.(set|get|remove)Item'; then
    if echo "${text}" | grep -qiE '(token|jwt|auth|session|password|secret)'; then
      guard_block \
        "localStorage/sessionStorage with auth-related keys is forbidden" \
        "JWT/session tokens go in httpOnly signed cookies. Storing in localStorage exposes them to XSS." \
        "Use the cookie-based session already wired in packs/auth/ + frontend/src/entities/session/."
    fi
  fi
fi

# ── Rule 2: backend/app/services/ at root (force into pack) ─────────────
if [[ "${file}" =~ ^backend/app/services/ ]]; then
  guard_block \
    "Service objects must live in a pack, not in backend/app/services/" \
    "Domain logic outside packs breaks Packwerk's modularity contract." \
    "Put it in packs/<domain>/app/services/ or packs/<domain>/app/public/<domain>/<verb>.rb."
fi

# ── Rule 3: any new code under backend/app/ outside the allowed dirs ────
# Allowed: backend/app/javascript (importmap), backend/app/views (mailers),
# backend/app/jobs (root-level Rails-runtime). Domain code → packs.
if [[ "${file}" =~ ^backend/app/(controllers|models|policies|forms|queries|serializers)/ ]]; then
  guard_block \
    "Domain code under backend/app/ at root is forbidden" \
    "Controllers/models/policies/forms/queries/serializers belong in a pack." \
    "Move it to packs/<domain>/app/<kind>/."
fi

# ── Rule 4: TypeScript `any` in new files ───────────────────────────────
if [[ "${file}" =~ \.(ts|tsx)$ && ! "${file}" =~ \.d\.ts$ ]]; then
  if echo "${text}" | grep -qE ':\s*any\b|\bas\s+any\b'; then
    guard_block \
      "TypeScript 'any' is forbidden in this repo" \
      "tsconfig has strict + noUncheckedIndexedAccess + exactOptionalPropertyTypes. 'any' silently breaks them." \
      "Use 'unknown' + narrowing, or a proper type. If from a third-party lib, add a typed wrapper."
  fi
fi

# ── Rule 5: useState in widgets/features/pages for likely cross-component data ──
# Soft-warn (heuristic noisy): tells Claude it might violate, doesn't block.
if [[ "${file}" =~ ^frontend/src/(widgets|features|pages)/.*\.tsx$ ]]; then
  if echo "${text}" | grep -qE 'useState\s*[<(]'; then
    if echo "${text}" | grep -qiE 'auth|user|session|token|profile|cart|filters'; then
      guard_warn "useState in ${file} for auth/user/session-shaped data — consider Zustand (client) or TanStack Query (server). CLAUDE.md §5."
    fi
  fi
fi

exit 0
