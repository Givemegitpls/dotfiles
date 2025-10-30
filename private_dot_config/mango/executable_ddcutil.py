#!/usr/bin/env python3
import json
import os
import re
import socket
import subprocess
from sys import argv, stdout, exit
from threading import Timer
from typing import Any


def print(message: str):
    stdout.write(message + "\n")
    stdout.flush()


class BrightnessDaemon:
    def __init__(
        self,
        service_name: str,
        settings: Any,
    ):
        self.timer = None
        self.socket_path = f"/tmp/{service_name}.sock"
        self.pid = os.getpid()
        self.step = settings["step"]
        self.timegap = settings["timegap"]
        if image_path := settings.get("image_path"):
            self.image_params = f" -i {image_path}"
        else:
            self.image_params = ""
        if value := settings.get("default_brightness"):
            self.current_brightness = int(value)
        elif match := re.search(
            r"current value =    ([^,]+)",
            subprocess.check_output(["ddcutil", "-d", "1", "getvcp", "10"]).decode(),
        ):
            self.current_brightness = int(match.group(1))
        else:
            self.current_brightness = 50
        with open("/proc/self/comm", "w") as f:
            f.write(service_name)

    def start(self):
        try:
            os.unlink(self.socket_path)
        except FileNotFoundError:
            pass
        self.server = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        self.server.bind(self.socket_path)
        self.server.listen(1)
        os.chmod(self.socket_path, 666)  # доступ для всех

        while True:
            conn, _ = self.server.accept()
            try:
                data = conn.recv(1024).decode().strip()
                if data == "up":
                    self.current_brightness += self.step
                elif data == "down":
                    self.current_brightness -= self.step
                self.current_brightness = max(min(self.current_brightness, 100), 0)
                os.system(
                    f'notify-send{self.image_params} -a "changeBrightness" -u low -r {self.pid} -h int:value:"{self.current_brightness}" "Яркость экрана: {self.current_brightness}%"'
                )
                self.schedule_apply()
                conn.send(b"OK")
            finally:
                conn.close()

    def schedule_apply(self):
        if self.timer:
            self.timer.cancel()
        self.timer = Timer(self.timegap, self.apply_brightness)  # агрегация 300ms
        self.timer.start()

    def apply_brightness(self):
        for row in (
            subprocess.check_output(["ddcutil", "detect"]).decode("utf-8").split("\n")
        ):
            command: list[str] = []
            if "Display " in row:
                if (mon := row.replace("Display ", "")).isdigit():
                    command.append(
                        f"ddcutil -d {mon} setvcp 10 {self.current_brightness}"
                    )
            if command:
                subprocess.run(
                    " & ".join(command),
                    shell=True,
                )

                print("\n".join(command))


def send_command(command: str, service_name: str):
    sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    try:
        sock.connect(f"/tmp/{service_name}.sock")
        sock.send(command.encode())
        response = sock.recv(1024)
        print(response.decode())
    except Exception as e:
        print(f"Error: {e}")
    finally:
        sock.close()


if __name__ == "__main__":
    service_name = "ddcutild"
    if subprocess.run(["pgrep", service_name]).returncode == 1:
        with open(os.path.dirname(__file__) + "/ddcutil.json") as f:
            settings = json.load(f)
            BrightnessDaemon(service_name, settings).start()
    if len(argv) != 2 or argv[1] not in ["up", "down"]:
        stdout.write("Usage: brightness up|down")
        stdout.flush()
        exit(1)

    send_command(argv[1], service_name)
