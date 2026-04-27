#!/bin/bash
dir=$(dirname "$0")
rofi -modi clipboard:$dir/cliphist-rofi-img.sh \
  -show clipboard -show-icon \
  -config $dir/clipboard-config.rasi
