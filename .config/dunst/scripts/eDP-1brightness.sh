#!/bin/bash

case "$1" in
"up")
  brightnessctl --class='backlight' set 5%+
  ;;
"down")
  brightnessctl --class='backlight' set 5%-
  ;;
esac

msgId="3378455"

brightpercent=$(brightnessctl -m --class='backlight' | awk -F, '{print substr($4, 0, length($4)-1)}')

notify-send -i $HOME/.config/dunst/scripts/icons/brightness.svg -a "changeBrightness" -u low -r "$msgId" \
  -h int:value:"$brightpercent" "Яркость экрана: $brightpercent%"
