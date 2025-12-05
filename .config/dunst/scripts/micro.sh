#!/bin/bash

msgId="3378455"

station=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | sed 's/Volume://' | tr -d [:digit:] | tr -d ' .[]')

if [ $station = 'MUTED' ]; then
  notify-send -i "$HOME/.config/dunst/scripts/icons/mic off.svg" -u low -r "$msgId" "Микрофон выключен"
else
  notify-send -i "$HOME/.config/dunst/scripts/icons/mic on.svg" -u low -r "$msgId" "Микрофон включен"
fi
