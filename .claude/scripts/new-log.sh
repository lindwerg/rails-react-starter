#!/usr/bin/env bash
# Scaffold a new entry in .claude/logs/.
# Usage: .claude/scripts/new-log.sh <slug>

set -euo pipefail

SLUG="${1:-untitled}"
DATE="$(date +%Y-%m-%d)"
FILE=".claude/logs/${DATE}-${SLUG}.md"
TEMPLATE=".claude/logs/_TEMPLATE.md"

if [[ -f "${FILE}" ]]; then
  echo "Log already exists: ${FILE}" >&2
  exit 1
fi

cp "${TEMPLATE}" "${FILE}"
# Replace YYYY-MM-DD placeholder with today's date (BSD/GNU sed compatible).
if sed --version >/dev/null 2>&1; then
  sed -i "s/YYYY-MM-DD/${DATE}/g" "${FILE}"
else
  sed -i '' "s/YYYY-MM-DD/${DATE}/g" "${FILE}"
fi

echo "${FILE}"
