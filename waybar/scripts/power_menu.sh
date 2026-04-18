#!/bin/bash

STYLE="$HOME/.config/waybar/scripts/power_menu.css"
options=" Lock\n Logout\n Reboot\n Shutdown"
TMP_FILE="/tmp/wofi_power"
LOCK_FILE="/tmp/power_menu.lock"

# Cegah spam klik
if [ -f "$LOCK_FILE" ]; then
    exit 0
fi

touch "$LOCK_FILE"

# Jalankan wofi - Versi Stabil
# Menu ini akan terbuka sampai Anda memilih sesuatu atau menekan Esc
printf "$options" | wofi --dmenu --width 150 --height 260 --lines 4 --location top_right --xoffset -15 --yoffset 10 --style "$STYLE" --hide-scroll --no-actions --hide-search --cache-file /dev/null --prompt "Power Menu" > "$TMP_FILE"

# Tunggu proses selesai
rm -f "$LOCK_FILE"

# Ambil pilihan user
if [ -f "$TMP_FILE" ]; then
    chosen=$(cat "$TMP_FILE")
    rm -f "$TMP_FILE"
fi

case "$chosen" in
    *"Lock"*)
        hyprlock ;;
    *"Logout"*)
        hyprctl dispatch exit ;;
    *"Reboot"*)
        systemctl reboot ;;
    *"Shutdown"*)
        systemctl poweroff ;;
esac
