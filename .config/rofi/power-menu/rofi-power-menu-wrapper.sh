#!/usr/bin/bash
target="rofi-power-menu.sh"
if pkill -f $target >/dev/null; then
  systemctl sleep
else
  exec $(dirname "$0")/$target
fi
