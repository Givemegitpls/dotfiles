#!/bin/bash

check=$(hyprctl monitors | awk '/HDMI-A-1/{print $1}' | tr -d '\n')

if [ $check != '' ]; then
  hyprctl keyword monitor "eDP-1, disable"
  swww kill
  uwsm app -- swww-daemon
fi
