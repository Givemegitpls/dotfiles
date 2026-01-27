#!/bin/bash

wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle

msgId="3378455"

station=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | sed 's/Volume://' | tr -d [:digit:] | tr -d ' .[]')

if [ $station = 'MUTED' ]; then
  notify-send -i "$HOME/.local/share/icons/mic-off.svg" -u low -r "$msgId" "Микрофон выключен"
else
  notify-send -i "$HOME/.local/share/icons/mic-on.svg" -u low -r "$msgId" "Микрофон включен"
fi
