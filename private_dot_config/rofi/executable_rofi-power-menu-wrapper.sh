#!/usr/bin/bash
if pkill -f rofi-power-menu.sh >/dev/null; then
  systemctl suspend
else
  ~/.config/rofi/rofi-power-menu.sh
fi
