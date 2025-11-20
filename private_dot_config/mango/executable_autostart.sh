uwsm finalize
uwsm app -- dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=wlroots &
uwsm app -- swww-daemon &
uwsm app -- hypridle &
uwsm app -- dunst &
uwsm app -- ~/.config/mango/scripts/waymonman.py &
uwsm app -- ~/.config/dunst/scripts/BSC.py &
uwsm app -- ~/.config/waybar/toggle.sh &
uwsm app -- wl-paste --type text --watch cliphist store &
uwsm app -- wl-paste --type image --watch cliphist store &
uwsm app -- systemd-inhibit --who="Mango config" --why="wlogout keybind" --what=handle-power-key --mode=block sleep infinity &
uwsm app -- noisetorch -i alsa_input.pci-0000_04_00.6.analog-stereo &
~/.config/mango/scripts/rog.sh
