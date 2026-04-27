#!/usr/bin/env bash
# Hook: SessionStart. Surfaces the latest log entries so Claude lands with context.

set -uo pipefail

cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)" || exit 0

echo "──────────── PROGRESS (latest 5 entries) ────────────"
if [[ -f PROGRESS.md ]]; then
  grep -E '^- 2[0-9]{3}-' PROGRESS.md | head -5
fi

LATEST="$(ls -1t .claude/logs/2*.md 2>/dev/null | head -1 || true)"
if [[ -n "${LATEST}" ]]; then
  echo ""
  echo "──────────── Latest log: $(basename "${LATEST}") ────────────"
  awk '/^## Куда дальше/{flag=1; next} /^---|^##/{if(flag) exit} flag' "${LATEST}" | head -10
fi

echo ""
echo "──────────── Mandatory reads ────────────"
echo "  CLAUDE.md, PROGRESS.md, latest 2 logs in .claude/logs/"
echo ""
