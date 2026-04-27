---
name: init
description: Bootstrap a new project from this template (rename placeholders → install everything → initial commit). Run once after cloning or "Use this template".
---

Run `./bin/init $ARGUMENTS`. This will:

1. Detach from the template's git history (only if origin still points at the template).
2. Run `bin/rename-project` — replaces every `App` / `app_*` placeholder with the new project's name (uses `$(basename "$PWD")` if no arg given). Idempotent via `.template-renamed` sentinel.
3. Run `./bootstrap.sh` — auto-installs mise/Docker/gh/lefthook, allocates free TCP ports, generates `.env` from `.env.example` with real ports, creates Rails `master.key`, runs migrations + seeds.
4. Make an initial commit on `main`.

After it finishes, the user should run `make dev`.

If anything fails, the trap in `bootstrap.sh` automatically runs `.claude/scripts/doctor.sh` and points at `make heal`.

Tell the user one short line about what happened and what to do next.
