#!/usr/bin/env bash
# Lightweight TDD-compliance check used by hooks.
# Given a changed file path on stdin, prints a warning if no matching test exists.
# Always exits 0 (hooks shouldn't block — they nudge).

set -uo pipefail

file="${1:-}"
[[ -z "${file}" ]] && exit 0

# Backend: packs/<pack>/app/<kind>/<file>.rb → packs/<pack>/spec/<kind>/<file>_spec.rb
if [[ "${file}" =~ ^backend/packs/([^/]+)/app/([^/]+)/(.+)\.rb$ ]]; then
  pack="${BASH_REMATCH[1]}"
  kind="${BASH_REMATCH[2]}"
  rest="${BASH_REMATCH[3]}"
  spec="backend/packs/${pack}/spec/${kind}/${rest}_spec.rb"
  if [[ ! -f "${spec}" ]]; then
    echo "📋 TDD reminder: no spec found at ${spec}. Add a failing test before implementing (CLAUDE.md §2.2)." >&2
  fi
  exit 0
fi

# Frontend: src/<layer>/<slice>/.../<file>.tsx → colocated <file>.test.tsx
if [[ "${file}" =~ ^frontend/src/.+\.tsx$ && ! "${file}" =~ \.test\.tsx$ && ! "${file}" =~ \.stories\.tsx$ ]]; then
  test_file="${file%.tsx}.test.tsx"
  if [[ ! -f "${test_file}" ]]; then
    echo "📋 TDD reminder: no test found at ${test_file}. Add a failing test before implementing (CLAUDE.md §2.2)." >&2
  fi
fi

exit 0
