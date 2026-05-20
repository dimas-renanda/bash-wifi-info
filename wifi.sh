#!/usr/bin/env bash
# wifi.sh — show WiFi info (macOS + Linux)
echo "📶 WiFi Info"
echo "────────────────────────"

if [[ "$OSTYPE" == darwin* ]]; then
  SSID=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I 2>/dev/null | awk '/ SSID/{print $2}')
  RSSI=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I 2>/dev/null | awk '/agrCtlRSSI/{print $2}')
  IP=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null)
  IFACE="en0"
elif command -v nmcli &>/dev/null; then
  SSID=$(nmcli -t -f active,ssid dev wifi 2>/dev/null | grep '^yes' | cut -d: -f2)
  RSSI=$(nmcli -t -f active,signal dev wifi 2>/dev/null | grep '^yes' | cut -d: -f2)
  IFACE=$(ip route show default | awk '/default/{print $5}' | head -1)
  IP=$(ip -4 addr show "$IFACE" 2>/dev/null | awk '/inet /{print $2}' | cut -d/ -f1)
elif command -v iwconfig &>/dev/null; then
  IFACE=$(iwconfig 2>/dev/null | awk '/IEEE/{print $1}' | head -1)
  SSID=$(iwconfig "$IFACE" 2>/dev/null | awk -F'"' '/ESSID/{print $2}')
  RSSI=$(iwconfig "$IFACE" 2>/dev/null | awk '/Signal/{print $4}' | cut -d= -f2)
  IP=$(ip -4 addr show "$IFACE" 2>/dev/null | awk '/inet /{print $2}' | cut -d/ -f1)
fi

echo "  SSID   : ${SSID:-N/A}"
echo "  Signal : ${RSSI:-N/A} dBm"
echo "  IP     : ${IP:-N/A}"
echo "  Iface  : ${IFACE:-N/A}"
echo ""
echo "  Public IP : $(curl -s --max-time 3 https://api.ipify.org 2>/dev/null || echo 'N/A')"
