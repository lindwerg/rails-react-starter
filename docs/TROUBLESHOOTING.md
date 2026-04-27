# Troubleshooting

Known pain points and how to fix them. If you hit one of these, don't suffer — apply the fix and move on.

> First step always: run `make doctor`. It checks most of the items below and tells you the exact fix.

---

## First-run

### "command not found: ruby" / "ruby: 2.6 not 3.3"
Cause: `mise` is installed but not activated in your shell.

```bash
# Add to ~/.zshrc (or ~/.bashrc) and restart the terminal:
eval "$(mise activate zsh)"
```

Verify with `make doctor` — both `ruby active via mise` and `node active via mise` should be ✓.

### `bundle install` fails with "psych" / "libyaml" errors
Cause: mise tried to *compile* Ruby from source and your system libyaml/openssl is missing or wrong version.

```bash
mise settings ruby.compile=false
mise install ruby
```

This forces precompiled binaries. `bootstrap.sh` does this automatically.

### `docker pull` times out / "context deadline exceeded"
Cause: Docker Hub's Cloudflare CDN is unreachable on this network (rate limit or routing).

```jsonc
// ~/.docker/daemon.json
{
  "registry-mirrors": [
    "https://mirror.gcr.io",
    "https://huecker.io",
    "https://dockerhub.timeweb.cloud"
  ],
  "dns": ["1.1.1.1", "8.8.8.8"]
}
```

Then **Restart Docker Desktop**. Verify with `docker pull hello-world`.

### Port 5432 collision (host Postgres clashing with the docker one)
Default `docker-compose.yml` exposes Postgres on `${POSTGRES_HOST_PORT:-5433}:5432`.

If a Homebrew-installed Postgres is running on 5432, the host port mapping skips to 5433 by default. If you see "address already in use" anyway, set explicitly:

```bash
echo "POSTGRES_HOST_PORT=5444" >> .env
docker compose up -d
```

---

## Boot

### `uninitialized constant Api::BaseController`
Cause: `backend/config/initializers/inflections.rb` accidentally re-enabled the `API` acronym.

Open it and ensure the `inflect.acronym` lines for `API`, `JWT`, `JSON` are **commented out**. See `docs/DECISIONS.md` ADR-004 for the long version.

### Frontend dates show as "Invalid Date"
Cause: backend serializer didn't camelCase the keys. Frontend expects `publishedAt` / `createdAt`, backend sent `published_at` / `created_at`.

Fix in the offending Alba serializer:

```ruby
class PostSerializer
  include Alba::Resource
  transform_keys :lower_camel   # ← add this line
  attributes :id, :title, :body, :published_at, :created_at
end
```

See ADR-005 for why it's per-resource and not global.

### Pagination metadata broken / `pagy.vars[:items]` returns nil
Cause: Pagy 9 renamed `:items` → `:limit` and `:max_items` → `:max_limit`.

Fix in `pagy_metadata`:

```ruby
{ count: pagy.count, page: pagy.page, limit: pagy.vars[:limit] }
```

---

## Tests

### `bin/rspec` exit "factory not found"
Cause: a new factory wasn't loaded. Check `backend/packs/<pack>/spec/factories/<name>.rb` exists and matches the model name.

### `pnpm test` "Cannot find module './types.gen'"
Cause: OpenAPI types are stale. Regenerate:

```bash
make typegen
```

(Equivalent to `cd backend && bundle exec rake rswag:specs:swaggerize` then `cd frontend && pnpm openapi-typescript ...`.)

### Playwright says "browsers not installed"

```bash
cd frontend && pnpm exec playwright install --with-deps chromium
```

`bootstrap.sh` runs this automatically; this fix is only for manual setups.

---

## Lefthook / git hooks

### Commits get blocked by guard hooks (Claude scripts)
Cause: you triggered a `.claude/scripts/guard-*.sh` rule. The error tells you exactly which rule + how to fix. Common ones:

- "localStorage with auth-related keys" → use the cookie-based session, not localStorage
- "Service objects must live in a pack" → put the file in `packs/<domain>/app/services/`
- "TypeScript any is forbidden" → use `unknown` + narrow, or a real type
- "Bypassing git hooks" → don't use `--no-verify`. Fix the hook failure instead.

### `lefthook` not on PATH after install
On macOS:
```bash
brew install lefthook
lefthook install
```

Or via npm prefix (if not using Homebrew):
```bash
npm install --prefix "$HOME/.npm-global" lefthook
export PATH="$HOME/.npm-global/bin:$PATH"   # add to .zshrc too
lefthook install
```

---

## Claude Code

### `.mcp.json` servers don't appear in `/mcp`
- Make sure `enableAllProjectMcpServers: true` is set in `.claude/settings.json` (it is, by default).
- Restart Claude Code after editing `.mcp.json`.
- For `magic-mcp` premium features: copy `.mcp.example.env` to `.mcp.env` and set `MAGIC_MCP_API_KEY=...`.

### Status line is empty / wrong
The status line at the bottom of Claude Code reads from `.claude/.last-test-status` and `.claude/.last-packwerk-status`. Run `make test` and `make pack-check` once to populate them. They auto-update on every subsequent run.

### Custom subagent (architect/tester/etc.) doesn't trigger automatically
You can invoke explicitly: `Agent(subagent_type="architect", prompt="...")`. Auto-delegation depends on phrasing in the user request matching the agent's `description`. If it never picks up, check the description in `.claude/agents/<name>.md` is specific about WHEN it applies.

---

## When all else fails

1. `make doctor` — check the basics.
2. `git stash && git checkout main && git pull && ./bootstrap.sh` — start from a clean state.
3. `docs/DECISIONS.md` — the answer might already be there as an explicit "we decided X".
4. Ask Claude with `/go` — it'll route you to a debug flow.
