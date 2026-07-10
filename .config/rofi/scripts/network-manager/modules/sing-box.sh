#!/bin/bash
case "$1" in
  status)
    systemctl --user is-active --quiet sing-box
    ;;
  toggle)
    if systemctl --user is-active --quiet sing-box; then
      systemctl --user stop sing-box
    else
      systemctl --user start sing-box
    fi
    ;;
esac
