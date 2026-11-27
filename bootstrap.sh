#!/usr/bin/env bash
# Bootstrap a brand-new machine from the dotfiles repository.
#
#   curl -fsSL https://raw.githubusercontent.com/XinlinProtoWu/dotfiles/main/bootstrap.sh | bash
#   # or, from a clone:
#   ~/.dotfiles/bootstrap.sh [options]
#
# Options are passed through to `dots pull` (--no-packages, --system,
# --with-secrets, --yes, --dry-run ...).
set -Eeuo pipefail

REPO=${DOTS_REPO:-$HOME/.dotfiles}
REMOTE=${DOTS_REMOTE:-git@github.com:XinlinProtoWu/dotfiles.git}

if [[ ! -d $REPO/.git ]]; then
  echo "==> cloning $REMOTE -> $REPO"
  if ! command -v git >/dev/null; then
    echo "==> installing git + rsync"
    sudo pacman -Sy --needed --noconfirm git rsync
  fi
  mkdir -p "$(dirname "$REPO")"
  git clone "$REMOTE" "$REPO"
fi

echo "==> handing over to dots pull"
exec "$REPO/.local/bin/dots" pull --yes "$@"
