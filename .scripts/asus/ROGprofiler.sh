#!/bin/bash

asusctl profile next

notify-send -i $HOME/.local/share/icons/performance.svg -u low -r "3378455" "$(asusctl profile get | grep Active | sed 's/^.*: //')"
