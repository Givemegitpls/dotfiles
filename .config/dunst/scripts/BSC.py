#!/usr/bin/env python3
from dataclasses import dataclass
import subprocess
import sys
import os
import time

battery_state = {"Discharging": False, "Charging": True}


@dataclass(slots=True)
class Battery:
    percent: int
    power_plugged: bool


def sensors_battery(base_path: str) -> Battery:
    with open(base_path + "capacity", "r") as c, open(base_path + "status", "r") as s:
        return Battery(
            percent=int(c.read().strip()), power_plugged=battery_state[s.read().strip()]
        )


def main(sleep_time: int, base_path: str):
    while True:
        if sensors_battery(base_path).power_plugged:
            os.system('notify-send -u normal -r "6896" "Battery" "Charging"')
            while sensors_battery(base_path).power_plugged:
                time.sleep(sleep_time)
            os.system('notify-send -u normal -r "6896" "Battery" "Discharging"')
        elif sensors_battery(base_path).percent <= 15:
            os.system('notify-send -u critical -r "6896" "Battery" "Low battery alarm"')
            while (
                not sensors_battery(base_path).power_plugged
                or sensors_battery(base_path).percent > 5
            ):
                time.sleep(sleep_time)
        if sensors_battery(base_path).percent <= 5:
            os.system("systemctl suspend")
            time.sleep(60)
        time.sleep(sleep_time)


if __name__ == "__main__":
    service_name = "BSC"
    base_path = "/sys/class/power_supply/BAT0/"
    if not os.path.exists(base_path):
        sys.stdout.write("Can't get battery info\n")
        sys.stdout.flush()
        sys.exit(1)
    if subprocess.run(["pgrep", service_name]).returncode != 1:
        sys.stdout.write("Process alredy exists\n")
        sys.stdout.flush()
        sys.exit(1)
    with open("/proc/self/comm", "w") as f:
        f.write(service_name)
    main(2, base_path)
