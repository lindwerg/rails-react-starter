# Changelog

All notable changes to this project will be documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added — Stage 12: "ребёнок справится" upgrade
- **Hard-block guards** in PreToolUse hooks (`.claude/scripts/guard-{write,bash,lib}.sh`).
  Block §5 anti-patterns: `localStorage` for tokens, domain code outside packs,
  TypeScript `any`, `--no-verify`, force-push to `main`, `chmod 777`, `curl|sh`.
- **Five custom subagents** in `.claude/agents/`: `architect`, `tester`, `reviewer`,
  `migrator`, `debugger`. Each with its own context window and tool allowlist.
- **`/go` slash command** — single entry point. Reads PROGRESS + git state and routes.
- **`make doctor`** + `/doctor` — diagnostic: mise, Docker, ports, env, hooks, MCP.
- **Auto-terse** output style (`outputStyle: terse` in settings.json — no `/output-style` needed).
- **Status line** at the bottom of Claude Code: branch + model + test/packwerk indicators.
- **Smarter Stop hook** (`stop-check.sh`): nudges about untested changes, lingering
  staged files, missing log entries.
- **Two more MCP servers**: `shadcn-ui`, `sequential-thinking`. Total now 5.
- **`bin/dev`** — Rails-8-standard launcher. Boots docker → overmind/foreman fallback.
- **`make seed-rich`** + `dev:seed_rich` rake task — 5 users + ~50 posts via Faker.
- **`make api-docs`** — opens `/api-docs` (rswag UI) in default browser.
- **`make reset` confirmation** — interactive `yes` prompt before dropping DB.
- **CodeQL workflow** for Ruby + JavaScript/TypeScript on push, PR, and weekly schedule.
- **Mutation testing workflow** — `workflow_dispatch`-only opt-in (mutant-rspec, commented in Gemfile).
- **`pnpm typecheck` in lefthook pre-push** — TypeScript errors caught before remote.
- **Documentation**:
  - `docs/DECISIONS.md` (6 ADRs: Packwerk, FSD, JWT-cookie, inflections, Alba transforms, Docker mirrors)
  - `docs/TROUBLESHOOTING.md` (every stage-11 pain + fix)
  - `docs/ARCHITECTURE.md` (ASCII diagrams + request-flow examples)
  - `docs/ADR-template.md`
- **README** Tour section guides new contributors through docs in the right order.

### Added — Initial release
- Backend: Packwerk modular monolith (4 layers, 6 packs), JWT auth, Posts CRUD, full RSpec coverage.
- Frontend: FSD (6 layers), TanStack Query + Zustand + RHF + Zod + Tailwind v4 + shadcn-style UI kit, Vitest + Playwright + MSW + Storybook.
- DevOps: 3 GitHub Actions workflows, Dependabot, Kamal 2 deploy template, backend Dockerfile.
- Claude Code workflow: `.mcp.json`, slash commands, automated hooks, scaffolding scripts.

[Unreleased]: https://github.com/your-org/your-repo/commits/main
