#!/usr/bin/env bash
# Compatibility wrapper — the real implementation lives in `dots`.
#   ./syncDots.sh [--dry-run] [--no-push] [-m message] [--system] [--with-secrets]
exec "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/dots" push "$@"
