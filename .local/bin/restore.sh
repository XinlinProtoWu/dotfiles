#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

DOT_DIR="$HOME/.dotfiles"

echo "🚀 Starting System Reconstruction (Copy Method)..."
# 1. Handle devkitPro Keyring and Repositories Pre-requisites
echo "🔑 Setting up devkitPro package signing keys..."

# 1a. Populate default Arch keys first to ensure a healthy keyring base
sudo pacman-key --init
sudo pacman-key --populate archlinux

# 1b. Import the specific devkitPro validation key
sudo pacman-key --recv BC26F752D25B92CE272E0F44F7FD5492264BB9D0 --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign BC26F752D25B92CE272E0F44F7FD5492264BB9D0

# 1c. CRITICALFIX: Explicitly locally sign Dave Murphy's key to bypass "unknown trust" errors
echo "✍️ Locally signing devkitPro developer key..."
sudo pacman-key --lsign-key BC26F752D25B92CE272E0F44F7FD5492264BB9D0

echo "📦 Installing devkitpro-keyring..."
sudo pacman -U --noconfirm https://pkg.devkitpro.org/devkitpro-keyring.pkg.tar.zst || true

# Safe fallback to populate the newly installed keyring
sudo pacman-key --populate devkitpro

# Restore system-level configs early so /etc/pacman.conf contains the new [dkp-libs] and [dkp-linux] blocks
if [ -f "$DOT_DIR/etc/pacman.conf" ]; then
  echo "📥 Injecting custom pacman.conf with devkitPro repositories..."
  sudo cp "$DOT_DIR/etc/pacman.conf" "/etc/pacman.conf"
fi

# Full system database sync (pacman -Syyu) to register the newly added dkp repos
echo "🔄 Refreshing system package databases..."
sudo pacman -Syyu --noconfirm
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

# 7. Restore System-Level Configurations (/etc/)
if [ -d "$DOT_DIR/etc" ]; then
  echo "📥 Restoring system configurations to /etc/..."
  # Re-sync files directly back to system root with correct permissions
  sudo rsync -av "$DOT_DIR/etc/" "/etc/"

  # Regenerate kernel hooks and GRUB configurations since we overrode them
  echo "⚙️ Rebuilding initramfs kernels..."
  sudo mkinitcpio -P

  if command -v grub-mkconfig &>/dev/null; then
    echo "⚙️ Updating GRUB bootloader configuration..."
    sudo grub-mkconfig -o /boot/grub/grub.cfg
  fi
fi

# 8. Enable Essential Background Services
echo "⚙️ Enabling core system services..."
sudo systemctl enable NetworkManager || true

echo "✨ System deployment complete! Reboots are highly recommended."
