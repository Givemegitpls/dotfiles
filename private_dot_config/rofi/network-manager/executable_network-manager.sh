#!/bin/bash
# Thanks for idea and source, DIMFLIX
# Github: https://github.com/DIMFLIX-OFFICIAL

SIGNAL_ICONS=("󰤟 " "󰤢 " "󰤥 " "󰤨 ")
SECURED_SIGNAL_ICONS=("󰤡 " "󰤤 " "󰤧 " "󰤪 ")

list_wifi() {
  local counter=0
  local active="\0active\x1f"

  while IFS=: read -r in_use signal security ssid; do
    if [ -z "$ssid" ]; then continue; fi # Пропускаем сети без SSID

    local signal_icon
    local signal_level=$((signal / 25))
    if [[ $signal_level > 3 ]]; then
      signal_level=3
    fi
    if [[ "$signal_level" -lt "${#SIGNAL_ICONS[@]}" ]]; then
      signal_icon="${SIGNAL_ICONS[$signal_level]}"
    fi

    if [[ "$security" =~ WPA || "$security" =~ WEP ]]; then
      signal_icon="${SECURED_SIGNAL_ICONS[$signal_level]}"
    fi

    # Добавляем иконку подключения, если сеть активна
    local formatted="$signal_icon $ssid"
    if [[ "$in_use" =~ \* ]]; then
      active+="$counter,"
    fi
    echo "$formatted"
  done <<<"$(nmcli -t -f IN-USE,SIGNAL,SECURITY,SSID dev wifi)"
  echo -en "$active\n"
}

manage_wifi() {
  local wifi_device=$(nmcli d | grep "wifi " | sed "s/ .*//")
  local chosen_option="$1"

  if [ -z "$chosen_option" ]; then
    return
  else

    # Удаляем значки уровня сигнала, если есть
    local chosen_id=$chosen_option
    for icon in "${SIGNAL_ICONS[@]}"; do
      chosen_id=$(echo "$chosen_id" | sed "s/$icon //")
    done

    for icon in "${SECURED_SIGNAL_ICONS[@]}"; do
      chosen_id=$(echo "$chosen_id" | sed "s/$icon //")
    done
    # Проверяем состояние выбранной сети
    local device_status=$(nmcli -t -f GENERAL device show $wifi_device | grep STATE | cut -d: -f2)
    local active_ssid=$(nmcli -t -f GENERAL device show $wifi_device | grep CONNECTION | cut -d: -f2)

    # Определяем действие в зависимости от состояния сети
    local action
    if [[ "$chosen_id" == "$active_ssid" ]]; then
      action="  Disconnect"
    else
      action="󰸋  Connect"
    fi

    action=$(echo -e "$action\n  Forget" | rofi -dmenu -p "Action: " -mesg "$chosen_option" -theme-str 'inputbar {enabled: false;} window {height: 200px;}')
    case $action in
    "󰸋  Connect")
      local saved_connections=$(nmcli -g NAME connection show)
      if [[ $(echo "$saved_connections" | grep -Fx "$chosen_id") ]]; then
        nmcli connection up id "$chosen_id" | grep "successfully" && notify-send "Connected" "$chosen_id"
      else
        local wifi_password=$(rofi -dmenu -p "Password: " -password -theme-str 'window {height: 110px;} entry {placeholder: "Password:";} textbox-prompt-colon {enabled: false;}')
        nmcli device wifi connect "$chosen_id" password "$wifi_password" | grep "successfully" && notify-send "Connected" "$chosen_id"
      fi
      ;;
    "  Disconnect")
      nmcli device disconnect $wifi_device && notify-send "Disconnected" "$chosen_id"
      ;;
    "  Forget")
      nmcli connection delete id "$chosen_id" && notify-send "Forgotten" "$chosen_id"
      ;;
    esac
  fi
}

if [ ! -z "$@" ]; then
  dir=$(dirname "$0")
  coproc (manage_wifi "$@")
else
  notify-send "Scaning Networks" "Please wait"
  list_wifi
fi
