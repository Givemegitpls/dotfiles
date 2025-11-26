export WALLPAPER="$(swww query | sed 's/.*image: //' | head -n 1)"
export foreground="rgb(255, 255, 255)"
uwsm app -- hyprlock
