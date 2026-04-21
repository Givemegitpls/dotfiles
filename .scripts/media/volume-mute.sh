#!/bin/bash

wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle

msgId="3378455"

icons_path=$HOME/.local/share/icons

station=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | sed 's/Volume://' | tr -d [:digit:] | tr -d ' .[]')

volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | sed 's/Volume://' | sed 's/ 0.//' | tr -d ' .')

if [ "$station" = "MUTED" ] || [ $volume -eq 0 ]; then
  icon=$icons_path/volume-mute.svg
  msg="Звук выключен"
else
  msg="Звук включен"
  if (($volume > 75)); then
    icon=$icons_path/volume-high.svg
  elif (($volume > 35)); then
    icon=$icons_path/volume-medium.svg
  else
    icon=$icons_path/volume-low.svg
  fi
fi

notify-send -i $icon -u low -r "$msgId" "$msg"
