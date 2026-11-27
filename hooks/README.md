# Hooks

Executable scripts here run around `dots` operations:

| File | When |
| --- | --- |
| `pre-push.sh`  | before snapshotting (e.g. `git pull` in a vault project) |
| `post-pull.sh` | after everything is deployed |

Per-host hooks with the same names live in `profiles/<hostname>/` and run after
the shared hook. Missing hooks are ignored; `dots doctor` checks they are
executable. Example:

```bash
#!/usr/bin/env bash
set -euo pipefail
# regenerate some derived config
./scripts/gen-waybar-colors.sh
```
