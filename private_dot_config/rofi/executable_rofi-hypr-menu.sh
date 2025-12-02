#!/usr/bin/env bash

menu_content() {
  echo -en "\0message\x1fQuit hypr?\n"
  echo "No"
  echo "Yes"
}

handle_selection() {
  case x"$@" in
  x"No")
    exit 0
    ;;
  x"Yes")
    hyprctl dispatch exit
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
  rofi -show quit -modi "quit:$0" -theme-str 'inputbar {enabled: false;} window {height: 200px;}'
fi
