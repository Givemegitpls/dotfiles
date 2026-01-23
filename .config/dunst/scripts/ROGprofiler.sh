#!/bin/bash

asusctl profile next

notify-send -i $HOME/.config/dunst/scripts/icons/performance.svg -u low -r "3378455" "$(asusctl profile get | grep Active | sed 's/^.*: //')"
