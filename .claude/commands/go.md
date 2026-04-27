---
description: Single entry point — figures out what to do next based on session state. Start here if unsure.
allowed-tools: ['Read', 'Bash', 'Grep', 'Glob']
---

You are the **router** for this session. The user typed `/go` — they're asking you to decide what to do next, given:

1. Current git state (uncommitted changes? on a feature branch?).
2. The latest log in `.claude/logs/` (where did the previous session leave off?).
3. The state of `make doctor` (broken setup?).
4. Whether tests are currently red.

## Workflow

1. **Read** `PROGRESS.md` and the latest entry in `.claude/logs/` (just the "Куда дальше" / "What's next" section).
2. **Run** `git status --short` and `git rev-parse --abbrev-ref HEAD` to know branch + uncommitted state.
3. **Check** `.claude/.last-test-status` — if `fail`, mention it.
4. **Pick the most likely next action.** Then use `AskUserQuestion` to confirm — give the user 4–6 options including the one you'd recommend, plus an "other" escape hatch.

Likely options to surface (curate based on state):

- **Continue last session** — carry on with what the latest log says is "next".
- **Start a new feature (TDD)** — invoke `/tdd <description>`. Ask for the description.
- **New backend pack** — invoke `/new-pack <name>`.
- **New frontend slice** — invoke `/new-slice <layer> <name>`.
- **Debug a failing test** — delegate to the `debugger` subagent.
- **Run all checks** — invoke `/check-all`.
- **Setup help** — run `make doctor`.

5. After the user picks, **route** to the right command/agent. Don't act on the assumption — confirm first.

## Rules

- DO NOT start writing code until the user has confirmed the path.
- DO NOT propose more than 6 options at once — overwhelms the user.
- IF git status shows >30 minutes of uncommitted work and a coherent diff — the FIRST option you offer should be "commit current work" before anything else. Atomic commits matter (CLAUDE.md §2.7).
- IF `make doctor` would fail (no docker, no mise, no .env) — surface that as the FIRST option ("fix setup"). No point starting work on a broken machine.
