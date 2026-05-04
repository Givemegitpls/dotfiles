#!/bin/bash
# Проверяем sing-box и netbird
case x"$@" in
x"  Stop mihomo")
  coproc (systemctl --user stop mihomo >/dev/null 2>&1) &
  exit 0
  ;;
x"  Start mihomo")
  coproc (systemctl --user start mihomo >/dev/null 2>&1) &
  exit 0
  ;;
x"  Stop sing-box")
  coproc (systemctl --user stop sing-box >/dev/null 2>&1) &
  exit 0
  ;;
x"  Start sing-box")
  coproc (systemctl --user start sing-box >/dev/null 2>&1) &
  exit 0
  ;;
x"  Stop netbird")
  coproc (netbird down >/dev/null 2>&1) &
  exit 0
  ;;
x"  Start netbird")
  coproc (netbird up >/dev/null 2>&1) &
  exit 0
  ;;
esac

active="\0active\x1f"

# Добавляем mihomo
if systemctl --user is-active --quiet mihomo; then
  active+="0,"
  echo "  Stop mihomo"
else
  echo "  Start mihomo"
fi

# Добавляем sing-box
if systemctl --user is-active --quiet sing-box; then
  active+="1,"
  echo "  Stop sing-box"
else
  echo "  Start sing-box"
fi

# Добавляем netbird
if systemctl --user is-active --quiet netbird; then
  netbird_status=$(netbird status | grep "Networks" | cut -d: -f2 | sed "s/ -//")
else
  $netbird_status=""
fi
if [ -z "$netbird_status" ]; then
  echo "  Start netbird"
else
  active+="2"
  echo "  Stop netbird"
fi
echo -en "$active\n"
