#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

DOT_DIR="$HOME/.dotfiles"

echo "🚀 Starting System Reconstruction (Copy Method)..."

# 1. Install Official Pacman Packages
if [ -f "$DOT_DIR/pkglist/pacman-explicit.txt" ]; then
  echo "📦 Installing official system packages..."
  sudo pacman -S --needed - <"$DOT_DIR/pkglist/pacman-explicit.txt"
else
  echo "⚠️ Warning: pacman-explicit.txt not found. Skipping official packages."
fi

# 2. Set up Yay & Install AUR Packages
if [ -f "$DOT_DIR/pkglist/yay-explicit.txt" ] || [ -f "$DOT_DIR/pkglist/aur-explicit.txt" ]; then
  if ! command -v yay &>/dev/null; then
    echo "📦 yay not found. Installing yay (AUR helper)..."
    sudo pacman -S --needed base-devel git
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay && makepkg -si --noconfirm && cd -
  fi

  echo "📦 Installing AUR packages..."
  if [ -f "$DOT_DIR/pkglist/yay-explicit.txt" ]; then
    yay -S --needed - <"$DOT_DIR/pkglist/yay-explicit.txt"
  else
    yay -S --needed - <"$DOT_DIR/pkglist/aur-explicit.txt"
  fi
fi

# 3. Create Required Destination Directories
echo "📂 Preparing home directory structures..."
mkdir -p "$HOME/.config"
mkdir -p "$HOME/.local/bin"

# 4. Copy Configurations to ~/.config
if [ -d "$DOT_DIR/.config" ]; then
  echo "📥 Copying application configurations to ~/.config/..."
  # Using 'cp -r' to copy all subfolders recursively
  cp -r "$DOT_DIR/.config/"* "$HOME/.config/"
fi

# 5. Copy Custom Scripts to ~/.local/bin
if [ -d "$DOT_DIR/.local/bin" ]; then
  echo "📥 Copying custom scripts to ~/.local/bin/..."
  cp -r "$DOT_DIR/.local/bin/"* "$HOME/.local/bin/"
  # Ensure everything in bin is executable
  chmod +x "$HOME/.local/bin/"*
fi

# 6. Copy Root Home Dotfiles (.bashrc, .gitconfig, etc.)
echo "📥 Copying root home files..."
HOME_FILES=(
  ".bashrc"
  ".bash_profile"
  ".profile"
  ".gitconfig"
)

for file in "${HOME_FILES[@]}"; do
  if [ -f "$DOT_DIR/$file" ]; then
    cp "$DOT_DIR/$file" "$HOME/"
    echo "✅ Copied $file to $HOME/"
  fi
done

echo "✨ System deployment complete! Your configurations are physically copied over."
