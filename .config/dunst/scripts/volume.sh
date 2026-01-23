#!/bin/bash

case "$1" in
"up")
  wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ -l 1.0
  ;;
"down")
  wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- -l 0.0
  ;;
esac

msgId="3378455"

volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | sed 's/Volume://' |
  sed 's/ 0.//' | tr -d ' .')

notify-send -i $HOME/.config/dunst/scripts/icons/volume.svg -a "changevolume" -u low -r "$msgId" \
  -h int:value:"$volume" "Громкость: $volume%"
