import os
from random import randrange

swww_output = str(os.popen('swww query').read())
swww_output = swww_output.split(" ")
path = swww_output[len(swww_output) - 1].replace('\n', '')

print(path)