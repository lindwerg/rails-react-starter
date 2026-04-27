---
description: Run every quality gate sequentially. Use before claiming "done".
allowed-tools: ['Bash']
---

Run all quality checks in order. **Do not skip any.** If anything fails, stop and report — do not auto-fix unless asked.

```bash
make test
```

```bash
make lint
```

```bash
make typecheck
```

```bash
make security
```

```bash
make pack-check
```

After all pass, report a one-line summary: `✅ All checks green — N specs, M frontend tests, 0 lint issues, 0 type errors, 0 security findings, packwerk clean.`

If any failed: report which one + first 30 lines of relevant output. Do not proceed to other steps until the failure is acknowledged.
