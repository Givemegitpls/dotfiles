#!/usr/bin/env python3
from psutil import sensors_battery, process_iter
import os
import time
from setproctitle import setproctitle


class config:
    low = 15
    critical = 5
    sleep = 2
    debug = False


def debug(level):
    if config.debug:
        print(level)
        print("Charging: ", sensors_battery().power_plugged)
        print("Battery: ", sensors_battery().percent)


def main():
    while True:
        if (
            config.low < int(sensors_battery().percent)
            or sensors_battery().power_plugged
        ):
            os.system('notify-send -u normal -r "6896" "Battery" "Charging"')
            print("Charging")
            while sensors_battery().power_plugged:
                time.sleep(config.sleep)
                debug("charging loop")
            os.system('notify-send -u normal -r "6896" "Battery" "Discharging"')
        elif config.critical < int(sensors_battery().percent) <= config.low:
            os.system('notify-send -u critical -r "6896" "Battery" "Low battery alarm"')
            print("Low battery")
            while (not sensors_battery().power_plugged) and (
                int(sensors_battery().percent) > config.critical
            ):
                debug("low loop")
                time.sleep(config.sleep)
        elif int(sensors_battery().percent) <= config.critical:
            os.system('notify-send -u critical -r "6896" "Battery" "Going to sleep"')
            print("Critical low")
            os.system("systemctl suspend")
            time.sleep(30)
        time.sleep(config.sleep)


app_name = "BSC"

for proc in process_iter(["pid", "name"]):
    if proc.name() == app_name and proc.pid != os.getpid():
        print(proc)
        os.kill(proc.pid, 9)


if __name__ == "__main__":
    setproctitle(app_name)
    list_of_procs = []
    main()
