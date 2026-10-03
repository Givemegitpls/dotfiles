#!/bin/bash
# netbird systemd service active ≠ netbird connected to network.
# Only `--check startup` correctly detects management disconnect;
# `ready` and `live` return 0 even when disconnected.
is_connected() {
  [[ -z "$(netbird status | grep 'NetBird IP: N/A')" ]]
}

case "$1" in
status)
  is_connected
  ;;
toggle)
  if is_connected; then
    netbird down
  else
    netbird up
  fi
  ;;
esac
