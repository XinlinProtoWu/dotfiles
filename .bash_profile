#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

export WLR_NO_HARDWARE_CURSORS=1
export WLR_RENDERER_ALLOW_SOFTWARE=1

# Auto-start Hyprland on TTY1
if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then
  echo "=========================================="
  echo "Select Desktop Environment for session:"
  echo "=========================================="
  echo "1) Hyprland"
  echo "2) i3wm"
  echo "=========================================="
  read -p "CHOOOSE [1-2]: " choice
  case $choice in
  1)
    export WLR_NO_HARDWARE_CURSORS=1
    exec start-hyprland
    ;;
  2)
    exec startx /usr/bin/i3
    ;;
  *)
    echo "Staying in pure TTY mode."
    ;;
  esac
fi
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
