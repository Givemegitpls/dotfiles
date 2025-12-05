#!/bin/bash

asusctl profile -n

notify-send -i $HOME/.config/dunst/scripts/icons/performance.svg -u low -r "3378455" "$(asusctl profile -p | grep Active | sed 's/^.*is //')"
