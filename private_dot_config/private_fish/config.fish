if status is-interactive
    # Commands to run in interactive sessions can go here
end

pyenv init - fish | source

set -g fish_key_bindings fish_vi_key_bindings

if uwsm check may-start; then
    exec uwsm start hyprland.desktop
fi
end
