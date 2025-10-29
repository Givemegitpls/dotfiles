uwsm finalize
uwsm app -- ~/.config/mango/waymonman.py &
uwsm app -- ~/.config/waybar/toggle.sh -c ~/.config/waybar/config-universal.jsonc &
uwsm app -- swww-daemon &
uwsm app -- hypridle &
uwsm app -- dunst &
uwsm app -- ~/.config/dunst/scripts/BSC.py &
uwsm app -- systemd-inhibit --who="Mango config" --why="wlogout keybind" --what=handle-power-key --mode=block sleep infinity
