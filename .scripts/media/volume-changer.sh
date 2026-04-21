#!/bin/bash

msgId="3378455"

icons_path=$HOME/.local/share/icons

case "$1" in
"up")
  wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ -l 1.0
  ;;
"down")
  wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- -l 0.0
  ;;
esac

volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | sed 's/Volume://' |
  sed 's/ 0.//' | tr -d ' .')

if (($volume > 75)); then
  icon=$icons_path/volume-high.svg
elif (($volume > 35)); then
  icon=$icons_path/volume-medium.svg
elif (($volume > 0)); then
  icon=$icons_path/volume-low.svg
else
  icon=$icons_path/volume-mute.svg
fi

notify-send -i $icon -a "changevolume" -u low -r "$msgId" \
  -h int:value:"$volume" "Громкость: $volume%"
