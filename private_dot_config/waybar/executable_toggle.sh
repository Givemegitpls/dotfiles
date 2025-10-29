#!/bin/bash
pkill waybar || exec waybar $@
