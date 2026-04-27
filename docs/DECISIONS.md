# Architecture Decision Records

Records of non-obvious decisions made while building this starter. Each one explains *why*, so future contributors can decide when the reasoning still holds vs. when it's stale.

> Format: Lightweight ADR. Status / Context / Decision / Consequences. Use `docs/ADR-template.md` for new entries.

---

## ADR-001 — Packwerk modular monolith on the backend

**Status:** Accepted (2026-04-28)

### Context
Rails apps tend to slide into one giant `app/` over time, making it hard to know which code "owns" a domain. We considered three alternatives: vanilla Rails, Rails engines, separate microservices.

### Decision
Use Packwerk (Shopify) to enforce layered packs at compile-time. Four layers: `orchestrator`, `business_domain`, `platform`, `utility`. Domain code MUST live in a pack.

### Consequences
- **Pro:** Cross-pack imports are checked. Adding a new domain = new pack with explicit `dependencies:`. Refactoring is grep-friendly because each domain is self-contained.
- **Pro:** Can later extract any pack into a service if scale demands it — boundaries are already explicit.
- **Pro:** No microservice tax (latency, deployment complexity) until proven necessary.
- **Con:** Initial learning curve — junior devs trip over "where do I put this?". Mitigated by `/new-pack` scaffolding + `architect` subagent.
- **Con:** `bin/packwerk check` adds a CI step (~5–10 sec).

### When to revisit
- If a single pack grows beyond ~50k LOC and ownership stops being clear — split it.
- If any pack hits true async boundary (different release cadence, different team) — extract to service.

---

## ADR-002 — Feature-Sliced Design on the frontend

**Status:** Accepted (2026-04-28)

### Context
React app structure is famously bikeshed-prone. Common alternatives: feature-folders by domain, atomic design (atoms/molecules/organisms), pages-first, "ducks" Redux modules.

### Decision
Use FSD with 6 layers: `app → pages → widgets → features → entities → shared`. Strict downward dependencies. Sibling-on-same-layer imports forbidden. Public API of each slice via `index.ts` only.

### Consequences
- **Pro:** Clear answer to "where does this go?" for every kind of code (UI primitive vs. business UI vs. user-facing flow vs. composite block).
- **Pro:** ESLint enforces it — `boundaries/element-types` rule + `no-restricted-imports` for deep paths.
- **Pro:** Slicing aligns with how features are reasoned about ("the auth feature", "the post-feed widget"), not how they happen to be implemented.
- **Con:** More indirection than feature-folders. The `index.ts` re-exports add boilerplate.
- **Con:** Some teams find the strict no-sibling rule annoying when two features genuinely share logic — requires refactoring shared bits down to `entities/` or `shared/`.

### When to revisit
- If `entities/` grows past ~30 slices, FSD might be the wrong fit (rare; usually means modeling problem).

---

## ADR-003 — JWT in httpOnly signed cookie, never localStorage

**Status:** Accepted (2026-04-28)

### Context
React apps commonly stash JWTs in `localStorage` for ergonomics. This is a well-known XSS vulnerability: any injected script can exfiltrate the token. The OWASP cheat sheet has been recommending against it for years.

### Decision
JWT is set by the backend in an httpOnly, Secure, SameSite=Lax cookie. Frontend never touches the token directly; auth state is derived from a `/me` endpoint.

### Consequences
- **Pro:** XSS can't steal the token (no JS access to httpOnly cookies).
- **Pro:** CSRF mitigation is provided by SameSite=Lax + the API design (we use Bearer-style header for cross-origin if ever needed, with explicit allow-list).
- **Pro:** Logout is server-side (clear cookie + revoke), simpler than dual-storage rotation.
- **Con:** Auth flow requires more backend coordination (`/sign_in` sets cookie; frontend can't "see" the token).
- **Con:** Cross-origin setups (different API domain) require explicit CORS + cookies = hot mode.

### Enforcement
- `frontend/src/entities/session/` doesn't import `localStorage`.
- `.claude/scripts/guard-write.sh` blocks `localStorage.*Item` calls in `frontend/src/`.

---

## ADR-004 — Disable Rails inflections for API/JWT/JSON acronyms

**Status:** Accepted (2026-04-27)

### Context
Rails' `Inflector` lets you declare acronyms (e.g. `API`) so it camelizes correctly (`api` → `API` instead of `Api`). The starter initially had this. Result: Zeitwerk camelized `packs/api/app/controllers/api/base_controller.rb` to `API::BaseController`, while every controller in the codebase uses `Api::*`. Boot failed with `uninitialized constant Api::BaseController`.

### Decision
Keep all three acronyms (`API`, `JWT`, `JSON`) **disabled**. Folder structure under `packs/*/app/controllers/api/` stays as `Api::*`.

### Consequences
- **Pro:** Boots clean. No mass-rename of dozens of files.
- **Con:** `Api` looks slightly less idiomatic than `API` to a Rails purist.
- **Mitigation:** A loud warning comment in `backend/config/initializers/inflections.rb` explains why never to re-enable them without renaming all `Api::*` modules to `API::*` in lockstep.

### When to revisit
- Only if the team decides to do a coordinated rename. Don't toggle either side independently.

---

## ADR-005 — camelCase JSON keys per resource (Alba 3 constraint)

**Status:** Accepted (2026-04-27)

### Context
Alba 2.x supported a global `Alba.transform_keys :lower_camel`. Alba 3 removed it — transform is now per-resource. Frontend was written expecting camelCase (`createdAt`, `publishedAt`). Without per-resource transforms, all dates rendered as `Invalid Date`.

### Decision
Every Alba serializer adds `transform_keys :lower_camel`. Documented in `backend/config/initializers/alba.rb`. We chose NOT to subclass into a base `ApplicationSerializer` because that would force the rule on every future serializer (sometimes you legitimately want snake_case — internal admin APIs, third-party webhooks).

### Consequences
- **Pro:** Explicit per-resource — easy to opt out for an admin endpoint if needed.
- **Con:** Boilerplate. Every new serializer needs the line.
- **Mitigation:** Mentioned in the initializer comment + `/new-pack` scaffolding leaves a TODO note.

---

## ADR-006 — Docker registry mirrors in `~/.docker/daemon.json`

**Status:** Accepted (2026-04-27)

### Context
On the user's network, Docker Hub's Cloudflare CDN was timing out — pulls of `postgres:16-alpine` and `axllent/mailpit:latest` failed reliably. Common workaround is to "skip the image" locally, but that defers the problem.

### Decision
Add registry mirrors to the docker daemon config (`mirror.gcr.io`, `huecker.io`, `dockerhub.timeweb.cloud`) plus `1.1.1.1` / `8.8.8.8` DNS. Documented in `bootstrap.sh` and `docs/TROUBLESHOOTING.md`.

### Consequences
- **Pro:** All future Docker pulls just work, no per-image workarounds.
- **Pro:** Resilient to a single registry going down (mirrors are redundant).
- **Con:** Registry trust slightly more spread out — pulls can come from different mirrors. Mitigated by Docker checking image digests, so a malicious mirror can't inject content.

### When to revisit
- If switching to a different registry (e.g. internal registry) — drop mirrors and pin that one.
