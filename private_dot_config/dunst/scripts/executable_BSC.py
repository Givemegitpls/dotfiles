#!/usr/bin/env python3
from psutil import sensors_battery, process_iter
import os
import time
from setproctitle import setproctitle


def main():
    while True:
        if sensors_battery().power_plugged:
            os.system('notify-send -u normal -r "6896" "Battery" "Charging"')
            while sensors_battery().power_plugged:
                time.sleep(2)
            os.system('notify-send -u normal -r "6896" "Battery" "Discharging"')
        elif sensors_battery().percent <= 15:
            os.system('notify-send -u critical -r "6896" "Battery" "Low battery alarm"')
            while not sensors_battery().power_plugged or sensors_battery().percent > 5:
                time.sleep(2)
        if sensors_battery().percent <= 5:
            os.system("systemctl suspend")
            time.sleep(60)
        time.sleep(2)


app_name = "BSC"

for proc in process_iter(["pid", "name"]):
    if proc.name() == app_name and proc.pid != os.getpid():
        print(proc)
        os.kill(proc.pid, 9)


if __name__ == "__main__":
    setproctitle(app_name)
    list_of_procs = []
    main()
