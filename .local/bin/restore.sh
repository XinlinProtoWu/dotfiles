#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

DOT_DIR="$HOME/.dotfiles"

echo "🚀 Starting System Reconstruction (Strict Move Method)..."

# =====================================================================
# PHASE 1: Deploy Core Environment Identity Files (CRITICAL PRE-REQUISITES)
# =====================================================================
echo "🆔 Moving core environment identity files first..."

# 1a. Move shell profiles so paths and environments take immediate effect
HOME_FILES=(".bashrc" ".bash_profile" ".profile" ".gitconfig")
for file in "${HOME_FILES[@]}"; do
  if [ -f "$DOT_DIR/$file" ]; then
    # Clear out any existing target file to prevent moving inside a directory by mistake
    rm -f "$HOME/$file"
    mv "$DOT_DIR/$file" "$HOME/"
    echo "✅ Moved $file to $HOME/"
  fi
done

# 1b. Inject custom pacman.conf early so repository flags work for the keyrings
if [ -f "$DOT_DIR/etc/pacman.conf" ]; then
  echo "📥 Moving custom pacman.conf with devkitPro repositories..."
  sudo mkdir -p /etc
  sudo rm -f "/etc/pacman.conf"
  sudo mv "$DOT_DIR/etc/pacman.conf" "/etc/pacman.conf"
fi

# =====================================================================
# PHASE 2: Handle devkitPro Keyring and Repositories
# =====================================================================
echo "🔑 Setting up devkitPro package signing keys..."

sudo pacman-key --init
sudo pacman-key --populate archlinux

sudo pacman-key --recv BC26F752D25B92CE272E0F44F7FD5492264BB9D0 --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign BC26F752D25B92CE272E0F44F7FD5492264BB9D0

echo "✍️ Locally signing devkitPro developer key..."
sudo pacman-key --lsign-key BC26F752D25B92CE272E0F44F7FD5492264BB9D0

echo "📦 Installing devkitpro-keyring..."
sudo pacman -U --noconfirm https://pkg.devkitpro.org/devkitpro-keyring.pkg.tar.zst || true
sudo pacman-key --populate devkitpro

# Full system database sync to register the newly added dkp repos
echo "🔄 Refreshing system package databases..."
sudo pacman -Syyu --noconfirm

# =====================================================================
# PHASE 3: Install Package Lists
# =====================================================================
# 1. Install Official Pacman Packages
if [ -f "$DOT_DIR/pkglist/pacman-explicit.txt" ]; then
  echo "📦 Installing official system packages..."
  sudo pacman -S --needed --noconfirm - <"$DOT_DIR/pkglist/pacman-explicit.txt"
else
  echo "⚠️ Warning: pacman-explicit.txt not found. Skipping official packages."
fi

# 2. Set up Yay & Install AUR Packages
if [ -f "$DOT_DIR/pkglist/yay-explicit.txt" ] || [ -f "$DOT_DIR/pkglist/aur-explicit.txt" ]; then
  if ! command -v yay &>/dev/null; then
    echo "📦 yay not found. Installing yay (AUR helper)..."
    sudo pacman -S --needed --noconfirm base-devel git
    rm -rf /tmp/yay
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay && makepkg -si --noconfirm && cd -
  fi

  echo "📦 Installing AUR packages..."
  if [ -f "$DOT_DIR/pkglist/yay-explicit.txt" ]; then
    yay -S --needed --noconfirm - <"$DOT_DIR/pkglist/yay-explicit.txt"
  else
    yay -S --needed --noconfirm - <"$DOT_DIR/pkglist/aur-explicit.txt"
  fi
fi

# =====================================================================
# PHASE 4: Deploy Directory Configurations via Move
# =====================================================================
echo "📂 Preparing home directory structures..."
mkdir -p "$HOME/.config"
mkdir -p "$HOME/.local/bin"

# Explicitly loop and move every single standalone config folder (i3, hyprland, etc.)
if [ -d "$DOT_DIR/.config" ]; then
  echo "📥 Moving application configurations into ~/.config/..."
  for target_config in "$DOT_DIR/.config"/*; do
    [ -e "$target_config" ] || continue
    config_name=$(basename "$target_config")

    # Destructive clean of the destination to prevent nesting folder bugs
    rm -rf "$HOME/.config/$config_name"

    # Structural move execution
    mv "$target_config" "$HOME/.config/"
    echo "⚙️  Moved profile config: $config_name"
  done
fi

# Move Custom Scripts to ~/.local/bin safely
if [ -d "$DOT_DIR/.local/bin" ]; then
  echo "📥 Moving custom scripts to ~/.local/bin/..."
  for script in "$DOT_DIR/.local/bin"/*; do
    [ -e "$script" ] || continue
    script_name=$(basename "$script")
    rm -f "$HOME/.local/bin/$script_name"
    mv "$script" "$HOME/.local/bin/"
  done
  chmod +x "$HOME/.local/bin/"*
fi

# =====================================================================
# PHASE 5: Restore System-Level Configurations (/etc/)
# =====================================================================
if [ -d "$DOT_DIR/etc" ]; then
  echo "📥 Moving remaining system configurations to /etc/..."

  # Note: rsync acts exactly like an atomic mv/overwrite for nested tree structures
  # without destroying the host folder architecture.
  sudo rsync -av --remove-source-files "$DOT_DIR/etc/" "/etc/"

  # Clean up empty directories left behind inside the dotfiles etc folder
  find "$DOT_DIR/etc" -type d -empty -delete 2>/dev/null || true

  echo "⚙️ Rebuilding initramfs kernels..."
  sudo mkinitcpio -P

  if command -v grub-mkconfig &>/dev/null; then
    echo "⚙️ Updating GRUB bootloader configuration..."
    sudo grub-mkconfig -o /boot/grub/grub.cfg
  fi
fi

# =====================================================================
# PHASE 6: Services Activation
# =====================================================================
echo "⚙️ Enabling core system services..."
sudo systemctl enable NetworkManager || true

echo "✨ System deployment complete! Your dotfile folder has been migrated."
