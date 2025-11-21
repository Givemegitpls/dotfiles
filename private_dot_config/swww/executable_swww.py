#!/usr/bin/python
import os
from random import randrange

swww_output = str(os.popen("swww query").read())
swww_output = swww_output.split(" ")
path = swww_output[len(swww_output) - 1].replace("\n", "")
current = path.split("/")
current = current[len(current) - 1]

images = os.listdir(path.replace(current, ""))
for_hyprlock = "hyprlock.png"

if for_hyprlock in images:
    images.pop(images.index(for_hyprlock))

next = images.index(current) + 1

if next >= len(images):
    next = images[0]
else:
    next = images[next]

next = path.replace(current, next)

swww_command = f"swww img {next} --transition-step 90 --transition-angle 45 --transition-type outer --transition-fps 60 --transition-pos {float(randrange(1, 9, 1)) / 10},{float(randrange(0, 10, 1)) / 10}"

ln_command = f"ln -s -f {next} {path.replace(current, for_hyprlock)}"

os.system(swww_command)
os.system(ln_command)
