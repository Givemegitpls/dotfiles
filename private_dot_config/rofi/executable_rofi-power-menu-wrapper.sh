#!/usr/bin/bash

target="rofi-power-menu.sh"
RUNNING_PIDS=$(pgrep -f $target | grep -v $$)
if [ -n "${RUNNING_PIDS}" ]; then
  pkill -f $target
  systemctl suspend
else
  coproc ($(dirname "$0")/$target)
fi
