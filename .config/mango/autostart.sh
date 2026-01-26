uwsm finalize
uwsm app -- dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=wlroots &
uwsm app -- swww-daemon &
uwsm app -- hypridle &
uwsm app -- dunst &
uwsm app -- waymonman &
uwsm app -- ~/.config/waybar/toggle.sh &
uwsm app -- wl-paste --type text --watch cliphist store &
uwsm app -- wl-paste --type image --watch cliphist store &
uwsm app -- systemd-inhibit --who="Mango config" --why="wlogout keybind" --what=handle-power-key --mode=block sleep infinity &
uwsm app -- noisetorch -i &
~/.scripts/ROGstartup.sh
