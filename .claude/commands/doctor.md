---
description: Diagnose broken-first-run problems (mise, Docker, ports, env, hooks).
allowed-tools: ['Bash']
---

Run the diagnostic script and surface any failures clearly to the user.

```bash
make doctor
```

If any check fails:
- Show the specific failures.
- For each, propose the exact fix command (already shown in the doctor output).
- DO NOT auto-fix without user confirmation — some fixes require shell-rc edits or restarts.

If all green: confirm "✅ Setup healthy" and ask if they want to start `make dev`.
