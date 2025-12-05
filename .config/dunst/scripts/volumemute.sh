#!/bin/bash

msgId="3378455"

station=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | sed 's/Volume://' | tr -d [:digit:] | tr -d ' .[]')

if [ $station = 'MUTED' ]; then
  notify-send -i "$HOME/.config/dunst/scripts/icons/volume mute.svg" -u low -r "$msgId" "Звук выключен"
else
  notify-send -i "$HOME/.config/dunst/scripts/icons/volume.svg" -u low -r "$msgId" "Звук включен"
fi
