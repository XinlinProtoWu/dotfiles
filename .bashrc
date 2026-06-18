#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '
export PATH="$HOME/.local/bin:$PATH"
export DEVKITPRO=/opt/devkitpro
export DEVKITARM=$DEVKITPRO/devkitARM
# For window creation with SDL2
export SDL_VIDEODRIVER=wayland
# PSP SDK Configuration
if [ -f /etc/profile.d/pspdev.sh ]; then
  source /etc/profile.d/pspdev.sh
fi

vpio() {
  if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: vpio <project_name> <board_name>"
    echo "Examples:"
    echo "  vpio my_esp esp32dev"
    echo "  vpio my_arduino uno"
    return 1
  fi

  local project_name=$1
  local board_name=$2

  echo "🚀 Creating project: $project_name for $board_name..."
  mkdir -p "$project_name" && cd "$project_name" || return 1

  echo "📦 Initializing PlatformIO..."
  pio project init --board "$board_name"

  echo "⚡ Generating LSP compilation database..."
  pio run -t compiledb

  echo "📝 Opening main.cpp in LazyVim..."
  touch src/main.cpp
  nvim src/main.cpp
}
