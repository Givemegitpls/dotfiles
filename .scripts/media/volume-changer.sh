#!/bin/bash

msgId="3378455"

volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | sed 's/Volume://' |
  sed 's/ 0.//' | tr -d ' .')

case "$1" in
"up")
  wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ -l 1.0
  notify-send -i $HOME/.local/share/icons/volume-up.svg -a "changevolume" -u low -r "$msgId" \
    -h int:value:"$volume" "Громкость: $volume%"
  ;;
"down")
  wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- -l 0.0
  notify-send -i $HOME/.local/share/icons/volume-down.svg -a "changevolume" -u low -r "$msgId" \
    -h int:value:"$volume" "Громкость: $volume%"
  ;;
esac
