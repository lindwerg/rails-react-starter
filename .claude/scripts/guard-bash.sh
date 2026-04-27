#!/usr/bin/env bash
# PreToolUse guard for Bash. Blocks dangerous patterns.
# Exit 2 = block. Exit 0 = pass.

set -uo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=guard-lib.sh
source "${DIR}/guard-lib.sh"

command -v jq >/dev/null 2>&1 || exit 0

guard_read_input

cmd="$(guard_field '.tool_input.command')"
[[ -z "${cmd}" ]] && exit 0

# Strip heredoc bodies: anything after `<<` or `<<-` belongs to a literal
# string (commonly the body of a git commit message), not the actual command.
# Without this, our own commit message body would re-trigger our own guards.
cmd_head="${cmd%%<<*}"

# ── Rule 1: bypass git hooks / signing ──────────────────────────────────
if echo "${cmd_head}" | grep -qE '(^|\s|;|&&|\|\|)git\s+(commit|merge|push|rebase|tag)\b[^"'\'']*?(--no-verify|--no-gpg-sign)\b'; then
  guard_block \
    "Bypassing git hooks/signing is forbidden" \
    "lefthook + commitlint exist for a reason — they catch the things CI catches, just earlier." \
    "Fix the hook failure (run 'make lint' or 'make test'). Don't bypass."
fi

# git commit -n (or combined like -an, -na) — the -n here is the bypass flag.
# Require -n at a word boundary, not e.g. -m where there's no n.
if echo "${cmd_head}" | grep -qE '(^|\s|;|&&|\|\|)git\s+commit\b[^"'\'']*?\s-[a-zA-Z]*n[a-zA-Z]*(\s|$)'; then
  guard_block \
    "git commit -n is short for --no-verify; both forbidden" \
    "Same reason as --no-verify: hooks exist to keep main green." \
    "Fix the issue, then 'git commit -m \"...\"' without -n."
fi

# ── Rule 2: --skip-checks flag (some tools support it for CI) ───────────
if echo "${cmd}" | grep -qE -- '(^|\s)--skip-checks\b'; then
  guard_block \
    "--skip-checks bypasses quality gates" \
    "Quality gates are not optional in this repo." \
    "Make checks pass instead of skipping."
fi

# ── Rule 3: force-push to main/master ───────────────────────────────────
if echo "${cmd}" | grep -qE '^|\s)git\s+push\b' >/dev/null 2>&1; then : ; fi
if echo "${cmd}" | grep -qE '(^|\s)git\s+push\b.*(--force\b|-f\b|--force-with-lease\b)' && \
   echo "${cmd}" | grep -qE '(\s|:|/)(main|master)(\s|$)'; then
  guard_block \
    "Force-push to main/master is forbidden" \
    "Rewriting shared history breaks everyone else's checkout." \
    "Force-push only to your own feature branches; for main, use a revert commit."
fi

# ── Rule 4: rm -rf on dangerous paths ───────────────────────────────────
if echo "${cmd}" | grep -qE 'rm\s+-[a-zA-Z]*r[a-zA-Z]*f[a-zA-Z]*\s+(/|\$HOME|~|\$\{HOME\}|/\*|\.|\.\.|/Users)\s*($|\s)'; then
  # Allow specific known-safe rm -rf usages
  if ! echo "${cmd}" | grep -qE 'rm\s+-rf\s+(tmp|node_modules|coverage|dist|\.next|\.cache|\.bundle|backend/tmp|frontend/dist|backend/coverage|frontend/coverage)'; then
    guard_block \
      "rm -rf on dangerous path" \
      "This regex caught rm -rf on /, \$HOME, ., or .. — almost certainly a mistake." \
      "If you really mean it, scope to a subdirectory under cwd."
  fi
fi

# ── Rule 5: pip/gem/npm install with arbitrary URL / curl|sh ────────────
if echo "${cmd}" | grep -qE '(curl|wget)\s+[^|]*\|\s*(sh|bash|zsh)\b'; then
  guard_block \
    "curl|sh from arbitrary URL is forbidden" \
    "Piping the network into a shell skips review and signature checks." \
    "Download to a file, inspect, then run."
fi

# ── Rule 6: chmod 777 / world-writable ──────────────────────────────────
if echo "${cmd}" | grep -qE 'chmod\s+(-R\s+)?(777|a\+w|o\+w)\b'; then
  guard_block \
    "World-writable permissions are forbidden" \
    "Almost always a sign of working around a real permission issue." \
    "Find the right user/group; chmod 644/755 is enough for most files."
fi

exit 0
