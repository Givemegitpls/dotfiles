#!/usr/bin/env python3
from dataclasses import dataclass
from enum import StrEnum
import json
import os
import subprocess
from sys import stdout
from time import sleep
from typing import Any


class Direction(StrEnum):
    right = "--right-of"
    left = "--left-of"
    above = "--above"
    below = "--below"


@dataclass(slots=True)
class monitor:
    name: str
    description: str


def main():
    settings: Any = {}
    monitors: list[monitor] = []
    while True:
        with open(os.path.dirname(__file__) + "/waymonman.json", "a") as f:
            settings_on_disc = json.load(f)
        current_monitors: Any = []
        for mon in json.loads(subprocess.check_output(["wlr-randr", "--json"])):
            current_monitors.append(
                monitor(name=mon["name"], description=mon["description"])
            )

        if settings == settings_on_disc and monitors == current_monitors:
            if ("rescan-time" in settings) and (settings.get("rescan-time") is None):
                break
            else:
                sleep(settings.get("rescan-time", 5))
                continue
        settings = settings_on_disc
        monitors = current_monitors
        definite_monitors: dict[str, str] = settings.get("monitors", {})
        default_direction: Direction = getattr(
            Direction, settings.get("default-direction", "right")
        )
        setuped: list[str] = []
        undifinite: list[str] = []
        for mon in monitors:
            if mon.description in definite_monitors:
                os.system(
                    " ".join(
                        [
                            "wlr-randr --output",
                            mon.name,
                            definite_monitors[mon.description],
                        ]
                    )
                )
                setuped.append(mon.name)
            else:
                undifinite.append(mon.name)

        for mon in undifinite:
            if setuped:
                os.system(
                    " ".join(
                        ["wlr-randr --output", mon, default_direction, setuped[-1]]
                    )
                )
            setuped.append(mon)
        wlr_output = subprocess.check_output(["wlr-randr"])
        stdout.write(wlr_output.decode("utf-8"))
        stdout.flush()


if __name__ == "__main__":
    with open("/proc/self/comm", "w") as f:
        f.write("waymonman")
    main()
