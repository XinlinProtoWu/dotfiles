# ~/.config/fish/config.fish

# 1. PATH Configuration
fish_add_path "$HOME/.local/bin"

# 2. Development & Hardware Environment Variables
set -gx DEVKITPRO /opt/devkitpro
set -gx DEVKITARM "$DEVKITPRO/devkitARM"
set -gx SDL_VIDEODRIVER wayland
set -gx LIBVA_DRIVER_NAME iHD

# 3. Proxy Settings
set -gx http_proxy "http://127.0.0.1:7897"
set -gx https_proxy "http://127.0.0.1:7897"
set -gx all_proxy "socks5://127.0.0.1:7897"

set -gx HTTP_PROXY "$http_proxy"
set -gx HTTPS_PROXY "$https_proxy"
set -gx ALL_PROXY "$all_proxy"

set -gx no_proxy "localhost,127.0.0.1,::1"
set -gx NO_PROXY "$no_proxy"

# 4. PSP SDK Configuration
# Fish cannot natively 'source' POSIX bash scripts like /etc/profile.d/pspdev.sh.
# The block below mirrors what pspdev.sh sets up directly in Fish:
set -gx PSPDEV /usr/local/pspdev
if test -d $PSPDEV/bin
    fish_add_path "$PSPDEV/bin"
end

# 5. Interactive Configuration
if status is-interactive
    # Aliases
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
end
