# pack: api

**Layer:** `orchestrator`

HTTP-facing layer. Owns:
- Controllers under `Api::V1::*`
- Request validation (delegates to dry-validation contracts in domain packs)
- Serializers (Alba)
- Routing concerns

What's not here: business rules, persistence, domain models.
