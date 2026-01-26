#!/bin/bash

check=$(wlr-randr | sed "/^[[:space:]]/d" | sed "/eDP-1/d")

if [ '$check' != '' ]; then
  wlr-randr --output eDP-1 --off
fi
