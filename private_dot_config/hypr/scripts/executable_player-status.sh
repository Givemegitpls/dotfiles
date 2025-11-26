#!/bin/bash

artist_offset=25
title_offset=40

artist=$(playerctl metadata artist 2>/dev/null)
title=$(playerctl metadata title 2>/dev/null)

if [ ! ${#title} -eq 0 ]; then
  if [ ${#artist} -gt $artist_offset ]; then
    artist=$(echo $artist | cut -c1-$artist_offset)
    artist=$(echo $artist'...')
  fi
  if [ ${#title} -gt $title_offset ]; then
    title=$(echo $title | cut -c1-$title_offset)
    title=$(echo $title'...')
  fi
  echo $artist - $title
fi
