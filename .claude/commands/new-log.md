---
description: Scaffold a new entry in .claude/logs/ for the current work.
allowed-tools: ['Bash', 'Read', 'Write', 'Edit']
---

Create a log entry for the work just done.

Steps:

1. Determine today's date: `date +%Y-%m-%d`
2. Decide a kebab-slug for this entry (4-5 words max). If user-provided in $ARGUMENTS, use that.
3. Run `.claude/scripts/new-log.sh "<slug>"` — it creates `.claude/logs/YYYY-MM-DD-<slug>.md` from the template and fills the date.
4. Open the file. Fill in:
   - **Что сделано** — list of concrete files created/changed and behaviors delivered (NOT what the user requested — what actually shipped).
   - **Решения и почему** — every non-obvious decision (library choice, architectural tradeoff). One-liner each.
   - **Открытые вопросы / TODO** — what was deferred and why.
   - **Куда дальше** — what the next session should pick up (be specific — name the next concrete task).
5. Append a single index line to `PROGRESS.md` at the top of the dated section. Do NOT append the full log content there — only the one-line index.
6. Stage the log + PROGRESS.md update along with the work commits.

Format reminder: read `.claude/logs/_TEMPLATE.md` if you forget the structure.
