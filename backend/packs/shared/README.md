# pack: shared

**Layer:** `utility`

Pure helpers, no domain knowledge:
- `Shared::Result` — Result-pattern wrapper for service objects
- `Shared::Errors::*` — generic error classes (NotAuthorized, ValidationFailed)
- `Shared::ValueObjects::*` — pure value objects (Email, Money, etc.)

If a class needs to know about a domain, it does NOT belong here.
