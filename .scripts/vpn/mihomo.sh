#!/bin/bash
naiveproxy $HOME/.config/naive/config.json &
sudo mihomo -f $HOME/.config/mihomo/config.yml
wait
