uwsm app -- /usr/lib/xdg-desktop-portal-hyprland &
uwsm app -- /usr/lib/xdg-desktop-portal &
uwsm app -- /usr/lib/xdg-desktop-portal-gtk &
uwsm app -- swww-daemon &
uwsm app -- dunst &
uwsm app -- hypridle &
uwsm app -- systemd-inhibit --who='Niri config' --why='wlogout keybind' --what=handle-power-key --mode=block sleep infinity &
uwsm app -- wl-paste --type text --watch cliphist store &
uwsm app -- wl-paste --type image --watch cliphist store &
uwsm app -- noisetorch -i alsa_input.pci-0000_04_00.6.analog-stereo &
~.config/hypr/scripts/rog.sh
