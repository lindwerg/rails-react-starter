# pack: posts

**Layer:** `business_domain`

Example CRUD domain. Owns:
- `Post` AR model
- `Posts::Create`, `Posts::Update`, `Posts::Destroy` services (Result-pattern)
- `Posts::Published` query
- `PostPolicy`
- `PostSerializer`
- `Posts::PostForm` (dry-validation)
