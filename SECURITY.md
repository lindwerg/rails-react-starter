# Security policy

## Supported versions

Only the `main` branch receives security updates.

## Reporting a vulnerability

**Do not open a public issue.** Email security@example.com (replace before going live) with:
- A description of the issue
- Steps to reproduce
- Affected versions / commits
- Your suggested fix (optional)

Expect an acknowledgement within 72 hours.

## Built-in mitigations

- **Auth**: JWT in httpOnly signed cookies (XSS-resistant). `bcrypt` password hashing. Optional Authorization header.
- **CSRF**: SameSite=Lax cookies, custom header verification (when needed).
- **Rate limiting**: `Rack::Attack` — 300 req / 5 min / IP global, 5 sign-in attempts / 20 sec / IP.
- **Authorization**: Pundit policies on every controller action.
- **Mass-assignment**: `params.require(...).permit(...)` everywhere.
- **SQL injection**: AR parameterized queries. No string interpolation in `where`.
- **Dependencies**: Dependabot (weekly), `bundler-audit` and `pnpm audit` in CI weekly.
- **Static analysis**: `Brakeman` runs on every backend PR.
- **Container scan**: `Trivy` on FS in weekly security workflow.
- **Strong migrations**: `strong_migrations` blocks dangerous DDL by default.
- **Secrets**: Rails encrypted credentials + Kamal secrets. `.env` git-ignored.

## What's out of scope (yet)

- 2FA (planned: separate `features/auth-by-totp` slice + pack)
- WebAuthn
- Session devices listing / revocation
- IP geolocation rate limiting
- Anti-bot (hcaptcha)

Open an issue to prioritize any of these.
