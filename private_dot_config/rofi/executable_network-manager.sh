#!/bin/bash
# Thanks for idea and source, DIMFLIX
# Github: https://github.com/DIMFLIX-OFFICIAL

SIGNAL_ICONS=("󰤟 " "󰤢 " "󰤥 " "󰤨 ")
SECURED_SIGNAL_ICONS=("󰤡 " "󰤤 " "󰤧 " "󰤪 ")

manage_wifi() {
  local ssids=()
  local formatted_list=()
  local active_ssid=""
  local wifi_device=$(nmcli d | grep "wifi " | sed "s/ .*//")
  local counter=0
  local active_options=""

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
      active_ssid="$ssid"
      active_options+="-a $counter"
    fi
    ssids+=("$ssid")
    formatted_ssids+="$formatted\n"
    let counter++
  done <<<"$(nmcli -t -f IN-USE,SIGNAL,SECURITY,SSID dev wifi)"

  # Добавляем sing-box
  let counter++
  formatted_ssids+="\n"
  if sudo systemctl status sing-box >/dev/null 2>&1; then
    if [ -z "$active_options" ]; then
      active_options+="-a $counter"
    else
      active_options+=",$counter"
    fi
    formatted_ssids+=" Stop sing-box"
  else
    formatted_ssids+=" Start sing-box"
  fi

  # Добавляем netbird
  let counter++
  formatted_ssids+="\n"
  local netbird_status=$(netbird status | grep "Networks" | cut -d: -f2 | sed "s/ -//")
  if [ -z "$netbird_status" ]; then
    formatted_ssids+=" Start netbird"
  else
    if [ -z "$active_options" ]; then
      active_options+="-a $counter"
    else
      active_options+=",$counter"
    fi
    formatted_ssids+=" Stop netbird"
  fi

  local chosen_option=$(echo -e "$formatted_ssids" | rofi -dmenu -i $active_options -selected-row 1 -p "Wi-Fi SSID: ")
  if [ -z "$chosen_option" ]; then
    return
  else
    # Проверяем sing-box и netbird
    case x"$chosen_option" in
    x" Stop sing-box")
      sudo systemctl stop sing-box
      return
      ;;
    x" Start sing-box")
      sudo systemctl start sing-box
      return
      ;;
    x" Stop netbird")
      netbird down
      return
      ;;
    x" Start netbird")
      netbird up
      return
      ;;
    esac

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

    # Определяем действие в зависимости от состояния сети
    local action
    if [[ "$chosen_id" == "$active_ssid" ]]; then
      action="  Disconnect"
    else
      action="󰸋  Connect"
    fi

    action=$(echo -e "$action\n  Forget" | rofi -dmenu -p "Action: ")
    case $action in
    "󰸋  Connect")
      local success_message="You are now connected to the Wi-Fi network \"$chosen_id\"."
      local saved_connections=$(nmcli -g NAME connection show)
      if [[ $(echo "$saved_connections" | grep -Fx "$chosen_id") ]]; then
        nmcli connection up id "$chosen_id" | grep "successfully" && notify-send "Connection Established" "$success_message"
      else
        local wifi_password=$(rofi -dmenu -p "Password: " -password)
        nmcli device wifi connect "$chosen_id" password "$wifi_password" | grep "successfully" && notify-send "Connection Established" "$success_message"
      fi
      ;;
    "  Disconnect")
      nmcli device disconnect $wifi_device && notify-send "Disconnected" "You have been disconnected from $chosen_id."
      ;;
    "  Forget")
      nmcli connection delete id "$chosen_id" && notify-send "Forgotten" "The network $chosen_id has been forgotten."
      ;;
    esac
  fi

}

manage_wifi
