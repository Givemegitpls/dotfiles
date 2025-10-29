#!/bin/bash

proc=$(pgrep waybar)
if [[ "$proc" -eq "" ]]; then
  waybar $@
else
  kill -s KILL $proc
fi
