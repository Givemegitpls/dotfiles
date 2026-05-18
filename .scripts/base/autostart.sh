uwsm finalize
uwsm app -- awww-daemon &
uwsm app -- swayidle -C ~/.config/swayidle/config &
uwsm app -- dunst &
uwsm app -- monbrighter &
uwsm app -- ~/.config/waybar/scripts/waybar_toggle.sh &
uwsm app -- wl-paste --type text --watch cliphist store &
uwsm app -- wl-paste --type image --watch cliphist store &
uwsm app -- systemd-inhibit --who="$XDG_CURRENT_DESKTOP config" --why="wlogout keybind" --what=handle-power-key --mode=block sleep infinity &
uwsm app -- noisetorch -i &
~/.scripts/asus/ROGstartup.sh
