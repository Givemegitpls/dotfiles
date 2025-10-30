#!/usr/bin/env python3
from enum import StrEnum
import hashlib
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


def main():
    settings: Any = {}
    wlr_hash: str = ""
    while True:
        with open(os.path.dirname(__file__) + "/waymonman.json") as f:
            settings_on_disc = json.load(f)
            current_wlr_hash = hashlib.md5(
                subprocess.check_output(["wlr-randr"])
            ).hexdigest()
        if settings == settings_on_disc and wlr_hash == current_wlr_hash:
            if ("rescan-time" in settings) and (settings.get("rescan-time") is None):
                break
            else:
                sleep(settings.get("rescan-time", 5))
                continue
        settings = settings_on_disc
        wlr_hash = current_wlr_hash
        definite_monitors: dict[str, str] = settings.get("monitors", {})
        default_direction: Direction = getattr(
            Direction, settings.get("default-direction", "right")
        )
        monitors = json.loads(subprocess.check_output(["wlr-randr", "--json"]))
        setuped: list[str] = []
        undifinite: list[str] = []
        for mon in monitors:
            if mon["description"] in definite_monitors:
                os.system(
                    " ".join(
                        [
                            "wlr-randr --output",
                            mon["name"],
                            definite_monitors[mon["description"]],
                        ]
                    )
                )
                setuped.append(mon["name"])
            else:
                undifinite.append(mon["name"])

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
