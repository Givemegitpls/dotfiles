#!/bin/bash
case "$1" in
status)
  systemctl --user is-active --quiet mihomo.target
  ;;
toggle)
  if systemctl --user is-active --quiet mihomo.target; then
    systemctl --user stop mihomo.target
  else
    systemctl --user start mihomo.target
  fi
  ;;
esac
