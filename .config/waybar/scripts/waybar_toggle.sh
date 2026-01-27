#!/bin/bash
pkill -x waybar || exec waybar $@
