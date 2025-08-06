#!/bin/bash

msgId="3378455"

brightpercent=$(brightnessctl -m --class='backlight' | awk -F, '{print substr($4, 0, length($4)-1)}')

notify-send -i $HOME/.config/hypr/scripts/dunst/icons/brightness.svg -a "changeBrightness" -u low -r "$msgId" \
  -h int:value:"$brightpercent" "Яркость экрана: $brightpercent%"
