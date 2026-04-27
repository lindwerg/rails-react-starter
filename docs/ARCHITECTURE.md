# Architecture

Two pictures: backend (Packwerk modular monolith) and frontend (Feature-Sliced Design). Both layered. Higher MAY import lower; lower MUST NEVER import higher.

---

## Backend

```
                   ┌─────────────────────────┐
                   │ orchestrator            │  packs/api
                   │ (HTTP, serialization)   │
                   └────────────┬────────────┘
                                │
                                ▼
   ┌──────────────────────────────────────────────────┐
   │ business_domain                                  │
   │ packs/auth · packs/users · packs/posts · …       │
   └──────────────────┬───────────────────────────────┘
                      │
                      ▼
        ┌──────────────────────────────┐
        │ platform                     │  packs/platform
        │ (jobs, mail, storage)        │
        └──────────────┬───────────────┘
                       │
                       ▼
            ┌─────────────────────┐
            │ utility             │  packs/shared
            │ (Result, Errors,    │
            │  ValueObjects)      │
            └─────────────────────┘
```

**Rules** (enforced by `bin/packwerk check`):
- A higher layer MAY import from a lower one.
- A lower layer MUST NOT import from a higher one.
- Cross-pack code uses `app/public/` of the source pack.
- Domain code outside `packs/` is forbidden (also enforced by `.claude/scripts/guard-write.sh`).

### Example flow: `POST /api/v1/posts`

```
HTTP request
  ↓
Api::V1::PostsController#create               (orchestrator: packs/api)
  ↓
Posts::Create.call(author:, attrs:)           (business_domain: packs/posts)
  ↓                       └─ wraps with Shared::Result.success/.failure   (utility: packs/shared)
Post.create!                                  (business_domain: packs/posts → AR)
  ↓
PostSerializer.new(post).serialize            (business_domain → public)
  ↓
JSON response
```

If any step tries to call upward (e.g. `packs/posts` → `packs/api`), Packwerk fails CI.

---

## Frontend

```
            ┌──────────────────────────────────────┐
            │ app                                  │  src/app
            │ (providers, router, store, styles)   │
            └─────────────────┬────────────────────┘
                              ▼
            ┌──────────────────────────────────────┐
            │ pages                                │  src/pages
            │ (route entries: HomePage, etc.)      │
            └─────────────────┬────────────────────┘
                              ▼
            ┌──────────────────────────────────────┐
            │ widgets                              │  src/widgets
            │ (PostFeed, Header, …)                │
            └─────────────────┬────────────────────┘
                              ▼
            ┌──────────────────────────────────────┐
            │ features                             │  src/features
            │ (auth-by-email, create-post, …)      │
            └─────────────────┬────────────────────┘
                              ▼
            ┌──────────────────────────────────────┐
            │ entities                             │  src/entities
            │ (User, Post, Session)                │
            └─────────────────┬────────────────────┘
                              ▼
            ┌──────────────────────────────────────┐
            │ shared                               │  src/shared
            │ (UI kit, api client, libs)           │
            └──────────────────────────────────────┘
```

**Rules** (enforced by `eslint-plugin-boundaries` + `no-restricted-imports`):
- A slice exposes ONLY what's in its `index.ts`. Deep paths are blocked.
- Sibling-on-same-layer is forbidden (e.g. `features/foo` → `features/bar` ✗). Refactor common bits down.
- Cross-component data → Zustand (client) or TanStack Query (server). `useState` for shared state is forbidden.

### Example flow: viewing the post feed

```
URL /posts
  ↓
pages/posts/PostsPage                           (uses PostFeed widget)
  ↓
widgets/post-feed/PostFeed                      (composes entities + features)
  ├─ uses entities/post (PostCard, usePosts query)
  └─ uses features/create-post (mutation, form)
       ↓
       entities/post (types, query keys)
         ↓
         shared/api (http client, types.gen.ts)
```

The page never reaches into `features/create-post/ui/` directly — that's a deep import. It imports `CreatePostForm` from the feature's `index.ts` only.

---

## Where things go (cheat-sheet)

### Backend

| Code | Path |
|---|---|
| AR model | `packs/<domain>/app/models/` |
| Service object (Result) | `packs/<domain>/app/public/<domain>/<verb>.rb` (cross-pack) or `app/services/` (intra) |
| Form / contract | `packs/<domain>/app/forms/<domain>/<form>.rb` |
| Controller | `packs/api/app/controllers/api/v1/<resource>_controller.rb` |
| Serializer | `packs/<domain>/app/public/<resource>_serializer.rb` |
| Policy | `packs/<domain>/app/policies/<resource>_policy.rb` |
| Spec | `packs/<domain>/spec/<type>/<name>_spec.rb` |
| Migration | `backend/db/migrate/` (always at root, not in packs) |

### Frontend

| Code | Path |
|---|---|
| UI primitive | `src/shared/ui/<name>/` |
| Lib helper | `src/shared/lib/` |
| HTTP / API utility | `src/shared/api/` |
| Business entity | `src/entities/<name>/` |
| User-facing feature | `src/features/<feature>/` |
| Composite block | `src/widgets/<name>/` |
| Page | `src/pages/<page>/` |
| Provider / router / store | `src/app/` |

Public API of every slice/segment: `index.ts`. Never deep-import past it.
