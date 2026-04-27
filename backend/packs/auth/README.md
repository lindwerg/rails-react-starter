# pack: auth

**Layer:** `business_domain`

Authentication services:
- `Auth::SignUp` — register new user
- `Auth::SignIn` — verify credentials, return user
- `Auth::JwtIssuer` — sign JWT for a user_id
- `Auth::JwtVerifier` — verify and parse JWT
- `Auth::InvalidToken` — raised on verification failure

This pack does NOT own the User model — it depends on `packs/users`.
