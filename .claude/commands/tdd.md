---
description: Start a TDD cycle (Red → Green → Refactor) for $ARGUMENTS.
allowed-tools: ['Read', 'Write', 'Edit', 'Bash', 'Glob', 'Grep']
---

You will implement: **$ARGUMENTS**

Strictly follow the TDD cycle from CLAUDE.md §2.2:

## Step 1 — Red

1. Identify the right test file location per the architecture rules in CLAUDE.md §4.
2. Write the failing test FIRST. Be specific about the behavior being verified.
3. Run only that one test:
   - Backend: `cd backend && bin/rspec <path/to/spec> -e "<example name>"`
   - Frontend: `cd frontend && pnpm vitest run <path/to/test>`
4. Confirm it fails for the **right** reason (assertion, not "module not found"). If it fails for the wrong reason, fix the test setup before proceeding.
5. Stop here, show the failing test output, and **ask the user to confirm Red** before continuing.

## Step 2 — Green

After user confirms Red:

6. Write the **minimum** code to make the test pass. No more.
7. Re-run the test. Confirm green.
8. Run linter on changed files only:
   - Backend: `cd backend && bundle exec rubocop <changed-files>`
   - Frontend: `cd frontend && pnpm exec eslint <changed-files>`

## Step 3 — Refactor

9. Improve naming, extract helpers, deduplicate. Tests stay green.
10. Run full check: `/check-all`.

## Step 4 — Log + commit

11. Run `make log`, fill the four sections.
12. Stage test + impl + log together. Commit with conventional message.
