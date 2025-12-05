#!/bin/bash

msgId="3378455"

brightnessctl "$@" >/dev/null

brightpercent=$(ddcutil -d 1 getvcp 10 | sed 's/^.*current value =    //' | sed 's/, max.*//')

notify-send -i $HOME/.config/dunst/scripts/icons/brightness.svg -a "changeBrightness" -u low -r "$msgId" \
  -h int:value:"$brightpercent" "Яркость экрана: $brightpercent%"
