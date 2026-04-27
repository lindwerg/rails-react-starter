#!/usr/bin/env bash
# Status line for Claude Code. Reads project state from disk + stdin JSON.
# Output goes into the bottom bar of the Claude Code UI.
# Format: 🌿 <branch> · 🤖 <model> · ✅/❌ tests · 🟢/🔴 packwerk · ⚙ <cwd-name>

set -uo pipefail

# Read JSON from stdin (Claude Code passes session metadata) — best-effort.
input="$(cat 2>/dev/null || true)"

model="?"
if command -v jq >/dev/null 2>&1 && [[ -n "${input}" ]]; then
  model="$(echo "${input}" | jq -r '.model.display_name // .model.id // "?"' 2>/dev/null || echo "?")"
fi

# Resolve repo root.
root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "${root}" || exit 0

# Branch.
branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "no-git")"

# Last test status from .claude/.last-test-status (written by check-tdd.sh side-effect).
test_glyph="·"
if [[ -f .claude/.last-test-status ]]; then
  case "$(cat .claude/.last-test-status 2>/dev/null)" in
    pass) test_glyph="✅" ;;
    fail) test_glyph="❌" ;;
    *)    test_glyph="·" ;;
  esac
fi

# Last packwerk status from .claude/.last-packwerk-status (best-effort, optional).
pack_glyph="·"
if [[ -f .claude/.last-packwerk-status ]]; then
  case "$(cat .claude/.last-packwerk-status 2>/dev/null)" in
    clean) pack_glyph="🟢" ;;
    dirty) pack_glyph="🔴" ;;
    *)     pack_glyph="·" ;;
  esac
fi

# Uncommitted change indicator.
dirty=""
if [[ -n "$(git status --porcelain 2>/dev/null)" ]]; then
  dirty=" ✏"
fi

printf '🌿 %s%s · 🤖 %s · %s tests · %s packwerk' \
  "${branch}" "${dirty}" "${model}" "${test_glyph}" "${pack_glyph}"
