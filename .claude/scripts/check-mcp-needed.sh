#!/usr/bin/env bash
# Hook script: scan a user prompt for keywords that should trigger an MCP nudge.
# Reads the prompt from stdin (Claude Code passes UserPromptSubmit data via stdin).
# Always exits 0 — non-blocking nudge.

set -uo pipefail

prompt="$(cat)"

# UI work → magic-mcp
if echo "${prompt}" | grep -qiE '(button|modal|component|page|widget|form|layout|design|style|ui|компонент|кнопк|модал|форм|стил)'; then
  echo "💡 Hint: this looks like UI work — consider mcp__magic-mcp__21st_magic_component_inspiration for inspiration before writing JSX (CLAUDE.md §2.1)." >&2
fi

# Library question → context7
if echo "${prompt}" | grep -qiE '(rails|react|tanstack|prisma|tailwind|zustand|playwright|vitest|kamal|packwerk|solid_(queue|cache|cable)|ruby on rails|how to use|how does .* work|migrate from)'; then
  echo "💡 Hint: this references a library — fetch fresh docs via mcp__context7__query-docs before answering (CLAUDE.md §2.1)." >&2
fi

exit 0
