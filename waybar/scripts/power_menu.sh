#!/bin/bash

STYLE="$HOME/.config/waybar/scripts/power_menu.css"
options=" Lock\n Logout\n Reboot\n Shutdown"
TMP_FILE="/tmp/wofi_power"
LOCK_FILE="/tmp/power_menu.lock"

# Cegah spam klik (jika skrip sudah jalan, keluar)
if [ -f "$LOCK_FILE" ]; then
    exit 0
fi

touch "$LOCK_FILE"

# Jalankan wofi - Lebar dikurangi (150) dan posisi dikembalikan (xoffset -15)
printf "$options" | wofi --dmenu --width 150 --height 260 --lines 4 --location top_right --xoffset -15 --yoffset 10 --style "$STYLE" --hide-scroll --no-actions --hide-search --cache-file /dev/null --prompt "Power Menu" > "$TMP_FILE" &
WOFI_PID=$!

sleep 0.2

# Monitor kursor secara dinamis
while kill -0 $WOFI_PID 2>/dev/null; do
    CPOS=$(hyprctl cursorpos)
    CX=$(echo $CPOS | cut -d',' -f1 | tr -d ' ')
    CY=$(echo $CPOS | cut -d',' -f2 | tr -d ' ')
    
    MONITOR_LINE=$(hyprctl monitors | grep -B 10 "focused: yes" | grep "Monitor" | head -n 1)
    M_WIDTH=$(echo $MONITOR_LINE | cut -d' ' -f3 | cut -d'x' -f1)
    M_OFFSET=$(echo $MONITOR_LINE | cut -d' ' -f5)
    M_X=$(echo $M_OFFSET | cut -d'x' -f1)
    M_Y=$(echo $M_OFFSET | cut -d'x' -f2)

    # Sesuaikan batas aman (Safe Zone) dengan lebar 150 dan xoffset -15
    SAFE_X_MIN=$((M_X + M_WIDTH - 180)) 
    SAFE_Y_MAX=$((M_Y + 280))           

    if [[ $CX -lt $SAFE_X_MIN || $CY -gt $SAFE_Y_MAX || $CY -lt $M_Y ]]; then
        kill $WOFI_PID 2>/dev/null
        break
    fi
    sleep 0.1
done

# Pastikan LOCK_FILE dihapus setelah selesai
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
