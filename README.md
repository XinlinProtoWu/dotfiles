#  Dotfiles

A complete backup of my system configuration, only for restoration on a fresh **Arch Linux** installation. Featuring a fully customized **Hyprland** environment and a lightweight **i3wm** fallback.

---

* **Theme:** [Tokyonight](https://github.com/folke/tokyonight.nvim) (Consistent across all applications, terminals, and WMs).
* **Display Manager Choice:** Upon login, you will be prompted to choose between:
  * **Hyprland:** The main environment.
  * **i3wm:** A low-requirement X11 fallback for older hardware or resource-heavy tasks.
* **Keybindings:** Both environments share a highly unified control scheme for muscle memory consistency. See the config files for specifics

---

The setup includes an automated `restore.sh` script that handles the entire deployment process. syncDots.sh is more for myself to keep my .dotfiles up to date. 

### What the script does:
1. **Packages:** Automatically installs all required applications, drivers, and utilities from `pkglist.txt`.
2. **User Configs:** Copies all dotfiles to `~/.config/`.
3. **Shell Profiles:** Sets up `~/.bashrc` and `~/.bash_profile`.
4. **System Configs:** Deploys necessary system-wide configurations to `/etc/`.

### Usage

```bash
# Clone the repository

cd ~/.dotfiles/.local/bin/

# Make the restore script executable and run it
chmod +x ~/.dotfiles/.local/bin/restore.sh
./restore.sh
