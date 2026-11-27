#!/usr/bin/env bash
# Compatibility wrapper — the real implementation lives in `dots`.
#   ./restore.sh [--dry-run] [--no-packages] [--system] [--with-secrets] [-y]
exec "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/dots" pull "$@"
