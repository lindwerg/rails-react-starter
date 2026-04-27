#!/usr/bin/env bash
# Stop hook: nudges Claude (and the user) about housekeeping tasks before
# ending a session. Always exits 0 — non-blocking.

set -uo pipefail

cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)" || exit 0

# 1. ExitPlanMode marker — reminds about logging.
if [[ -f /tmp/claude-just-exited-plan-mode ]]; then
  echo "📝 Reminder: run /new-log to record what you did, and update PROGRESS.md before ending. (CLAUDE.md §2.6)"
  rm -f /tmp/claude-just-exited-plan-mode
fi

# 2. Modified .rb / .tsx files in the working tree but no recent test run.
if git diff --quiet -- '*.rb' '*.tsx' 2>/dev/null; then
  : # no source changes
else
  if [[ ! -f .claude/.last-test-status ]] || [[ "$(find .claude/.last-test-status -mmin -10 2>/dev/null)" == "" ]]; then
    echo "🧪 Source files changed but tests haven't run in the last 10 min — run 'make test' or '/check-all' before claiming done."
  fi
fi

# 3. Staged changes lingering — encourage atomic commits.
if [[ -n "$(git diff --cached --name-only 2>/dev/null)" ]]; then
  staged_count="$(git diff --cached --name-only | wc -l | tr -d ' ')"
  echo "📦 ${staged_count} staged file(s) waiting — finalize with a commit or unstage if not done."
fi

exit 0
