#!/bin/bash
dir=$(dirname "$0")
rofi -combi-mody " "," " -modi " ":$dir/network-manager.sh," ":$dir/vpn-manager.sh -show " "
