#!/bin/bash

msgId="3378455"

wpctl set-mute @DEFAULT_AUDIO_SINK@ 0

volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | sed 's/Volume://' |
  sed 's/ 0.//' | tr -d ' .')

notify-send -i $HOME/.config/dunst/scripts/icons/volume.svg -a "changevolume" -u low -r "$msgId" \
  -h int:value:"$volume" "Громкость: $volume%"
