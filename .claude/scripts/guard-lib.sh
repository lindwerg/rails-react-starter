#!/usr/bin/env bash
# Shared helpers for PreToolUse guard scripts.
# Usage: source this from guard-*.sh

set -uo pipefail

# Read JSON from stdin once and cache it in a temp variable.
guard_read_input() {
  if [[ -z "${GUARD_INPUT:-}" ]]; then
    GUARD_INPUT="$(cat)"
    export GUARD_INPUT
  fi
}

guard_field() {
  guard_read_input
  echo "${GUARD_INPUT}" | jq -r "${1} // empty" 2>/dev/null || echo ""
}

guard_block() {
  printf "🚫 BLOCKED by guard: %s\n" "$1" >&2
  if [[ -n "${2:-}" ]]; then
    printf "   Why: %s\n" "$2" >&2
  fi
  if [[ -n "${3:-}" ]]; then
    printf "   Do: %s\n" "$3" >&2
  fi
  printf "   Source: CLAUDE.md §5 anti-patterns.\n" >&2
  exit 2
}

guard_warn() {
  printf "⚠️  guard: %s\n" "$1" >&2
}
