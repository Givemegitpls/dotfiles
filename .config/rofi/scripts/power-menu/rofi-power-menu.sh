#!/usr/bin/bash

menu_content() {
  echo -en "\0message\x1f Power menu\n"
  echo "󰌾 Lock session"
  echo "󰓓 Gamescope"
  echo "󰒲 Sleep"
  echo "󰍃 Logout"
  echo " Reboot"
  echo " Shutdown"
  echo "󰜺 Close menu"
}

handle_selection() {
  case x"$@" in
  x"󰌾 Lock session")
    loginctl lock-session
    ;;
  x"󰓓 Gamescope")
    gamescope-session-switcher gamescope
    ;;
  x"󰒲 Sleep")
    systemctl suspend-then-hibernate
    ;;
  x"󰍃 Logout")
    uwsm stop
    ;;
  x" Reboot")
    reboot
    ;;
  x" Shutdown")
    shutdown now
    ;;
  x"󰜺 Close menu")
    exit 0
    ;;
  esac
}

if [ -n "$ROFI_RETV" ]; then
  if [ "$ROFI_RETV" -eq 0 ]; then
    menu_content
  elif [ "$ROFI_RETV" -eq 1 ]; then
    handle_selection "$1"
  fi
else
  rofi -show quit -modi "quit:$0" -theme-str 'inputbar {enabled: false;} window {height: 380px;}'
fi
