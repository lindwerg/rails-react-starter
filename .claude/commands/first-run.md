---
description: Set up the project from a fresh clone. Run once after cloning.
allowed-tools: ['Bash', 'Read']
---

Bootstrap a fresh clone of this repo.

```bash
./bootstrap.sh
```

The script:
1. Verifies `mise` is installed (or asks to install it)
2. `mise install` — pins Ruby 3.3.6, Node 22, pnpm 9
3. Installs `lefthook`, `overmind` if missing
4. `cd backend && bundle install`
5. `cd frontend && pnpm install`
6. `docker compose up -d` — Postgres + Mailhog
7. `cd backend && bin/rails db:prepare db:seed`
8. `cd frontend && pnpm exec playwright install --with-deps chromium`
9. `lefthook install`
10. Initializes MCP credentials prompt (creates `.env` from `.mcp.example.env` if missing)
11. Prints the next-steps banner

When done, suggest: `make dev` and open http://localhost:5173. Demo creds: `demo@example.com` / `password123`.
