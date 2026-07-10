# Network Manager (rofi)

Rofi menu for managing VPN services. Consists of the main script `vpn-manager.sh` and modules in `modules/`, enabled via symlinks in `enabled/`.

## Structure

```
network-manager/
├── vpn-manager.sh   # main script: menu + toggle dispatcher
├── modules/         # service driver modules
└── enabled/         # symlinks to active modules
```

## Module contract

A module is an executable bash script that takes a single argument:

| Argument | Behavior                                                          |
| -------- | ----------------------------------------------------------------- |
| `status` | Exit 0 — service is active. Exit 1 (non-zero) — service is inactive. |
| `toggle` | Switches state: starts if stopped, stops if running.              |

The module filename (without `.sh`) is used as the display name in the menu.

Minimal module example:

```bash
#!/bin/bash
case "$1" in
  status)
    systemctl --user is-active --quiet my-service
    ;;
  toggle)
    if systemctl --user is-active --quiet my-service; then
      systemctl --user stop my-service
    else
      systemctl --user start my-service
    fi
    ;;
esac
```

## Enabling a module

1. Place the script in `modules/<name>.sh`
2. Make it executable: `chmod +x modules/<name>.sh`
3. Create a symlink: `ln -s ../modules/<name>.sh enabled/<name>.sh`

The module will appear in the menu automatically on the next run.

## Disabling a module

Remove the symlink from `enabled/`:

```bash
rm enabled/<name>.sh
```

The module stays in `modules/` and can be re-enabled later.

## Current modules

| Module    | status                                     | toggle             |
| --------- | ------------------------------------------ | ------------------ |
| mihomo    | `systemctl --user is-active mihomo.target` | start/stop target  |
| sing-box  | `systemctl --user is-active sing-box`      | start/stop unit    |
| netbird   | `netbird status --check startup`            | `netbird up`/`down`|
