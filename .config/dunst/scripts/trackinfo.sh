#!/bin/bash

sleep 0.7

msgId="3378455"

artist=$(playerctl metadata artist)
title=$(playerctl metadata title)
image=$(playerctl metadata mpris:artUrl)

notify-send -u low -r "$msgId" "$artist" "$title" -i "$image"
