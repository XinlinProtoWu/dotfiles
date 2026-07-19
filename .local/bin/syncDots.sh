#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# --- Configuration ---
DOT_DIR="$HOME/.dotfiles"
CONFIG_DIR="$HOME/.config"
LOCAL_BIN_DIR="$HOME/.local/bin"

# -------------------------------------------------------------
# System-level files to track from /etc/
# Add or remove paths here depending on your exact setup
# -------------------------------------------------------------
ETC_FILES=(
  "/etc/default/grub"
  "/etc/mkinitcpio.conf"
  "/etc/modprobe.d/"
  "/etc/pacman.conf"
  "/etc/systemd/logind.conf"
  "/etc/tlp.conf"
)

# Blacklist for ~/.config to catch heavy caches, electron apps, and tokens
EXCLUDES_CONFIG=(
  --exclude='.git/'
  --exclude='*.bak/'
  --exclude='chromium/'
  --exclude='google-chrome/'
  --exclude='BraveSoftware/'
  --exclude='discord/'
  --exclude='vesktop/'
  --exclude='endcord/'
  --exclude='slack/'
  --exclude='spotify/'
  --exclude='Electron/'
  --exclude='Code/'
  --exclude='*Cache*'
  --exclude='*cache*'
  --exclude='*.log'
)
# ---------------------

echo "📦 Starting complete dotfile synchronization..."

# Check for rsync dependency
if ! command -v rsync &>/dev/null; then
  echo "❌ Error: rsync is required. Install it using: sudo pacman -S rsync"
  exit 1
fi

# Ensure backup directories exist inside your target folder
mkdir -p "$DOT_DIR/.config"
mkdir -p "$DOT_DIR/.local/bin"
mkdir -p "$DOT_DIR/pkglist"
mkdir -p "$DOT_DIR/etc"

# 1. Sync ALL of ~/.config (minus blacklisted items)
echo "🔄 Syncing ~/.config..."
rsync -av --delete "${EXCLUDES_CONFIG[@]}" "$CONFIG_DIR/" "$DOT_DIR/.config/"

# 2. Sync ONLY ~/.local/bin
if [ -d "$LOCAL_BIN_DIR" ]; then
  echo "🔄 Syncing ~/.local/bin..."
  rsync -av --delete "$LOCAL_BIN_DIR/" "$DOT_DIR/.local/bin/"
else
  echo "⚠️ Warning: ~/.local/bin does not exist yet. Skipping."
fi

# 3. Sync specific dotfiles from the root of $HOME
echo "🔄 Syncing home directory dotfiles..."
HOME_FILES=(
  ".bashrc"
  ".bash_profile"
  ".profile"
  ".gitconfig"
)

for file in "${HOME_FILES[@]}"; do
  if [ -f "$HOME/$file" ]; then
    cp "$HOME/$file" "$DOT_DIR/"
  fi
done

# 4. Sync System-Level Configs from /etc/
echo "🔄 Syncing system-level files from /etc/..."
for target in "${ETC_FILES[@]}"; do
  if [ -e "$target" ]; then
    # --relative keeps the structure intact, so /etc/default/grub goes to $DOT_DIR/etc/default/grub
    sudo rsync -avR "$target" "$DOT_DIR/"
  else
    echo "⚠️ Warning: System file $target not found. Skipping."
  fi
done

# Fix permissions so your user owns the backup files inside your repository
sudo chown -R "$(id -u):$(id -g)" "$DOT_DIR/etc"

# 5. Generate explicit pacman and yay package lists
echo "📋 Generating package lists..."
if command -v pacman &>/dev/null; then
  # Added 'q' to get names ONLY, dropping the version numbers
  pacman -Qenq >"$DOT_DIR/pkglist/pacman-explicit.txt"
fi

if command -v yay &>/dev/null; then
  # Added 'q' here as well
  yay -Qemq >"$DOT_DIR/pkglist/yay-explicit.txt"
else
  pacman -Qemq >"$DOT_DIR/pkglist/aur-explicit.txt"
fi

# 4. Git Operations
cd "$DOT_DIR"

# Initialize git if it wasn't done already
if [ ! -d ".git" ]; then
  echo "⚠️ Git repository not found in $DOT_DIR. Initializing..."
  git init
  git branch -M main
  git remote add origin git@github.com:XinlinProtoWu/dotfiles.git
fi

# Check for changes, commit, and push
if [[ -n $(git status --porcelain) ]]; then
  echo "🚀 Changes detected. Committing and pushing to GitHub..."
  git add .
  git commit -m "Auto-sync dotfiles: $(date '+%Y-%m-%d %H:%M:%S')"

  CURRENT_BRANCH=$(git branch --show-current)
  git push origin "$CURRENT_BRANCH"
  echo "✅ Successfully synced to GitHub!"
else
  echo "✨ No changes detected. Your GitHub repository is up to date."
fi
