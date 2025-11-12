#!/usr/bin/env bash

menu_content() {
  echo -en "\0message\x1f Power menu\n"
  echo "󰌾 Lock session"
  echo "󰒲 Suspend"
  echo " Shutdown"
  echo " Reboot"
  echo "󰜺 Cancel"
}

handle_selection() {
  case x"$@" in
  x"󰌾 Lock session")
    coproc (uwsm app -- hyprlock >/dev/null 2>&1)
    ;;
  x"󰒲 Suspend")
    systemctl suspend
    ;;
  x" Shutdown")
    shutdown now
    ;;
  x" Reboot")
    reboot
    ;;
  x"󰜺 Cancel")
    exit 0
    ;;
  esac
}

if [ -n "$ROFI_RETV" ]; then
  # ROFI_RETV=0 - show menu, ROFI_RETV=1 - selection made
  if [ "$ROFI_RETV" -eq 0 ]; then
    menu_content
  elif [ "$ROFI_RETV" -eq 1 ]; then
    handle_selection "$1"
  fi
else
  rofi -show quit -modi "quit:$0" -theme-str 'inputbar {enabled: false;} window {height: 310px;}'
fi
