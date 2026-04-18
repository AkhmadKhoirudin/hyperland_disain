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

# Jalankan wofi di background agar kita bisa memantau kursor
printf "$options" | wofi --dmenu --width 150 --height 260 --lines 4 --location top_right --xoffset -15 --yoffset 10 --style "$STYLE" --hide-scroll --no-actions --hide-search --cache-file /dev/null --prompt "Power Menu" > "$TMP_FILE" &
WOFI_PID=$!

# Beri jeda sebentar agar kursor tidak dianggap "di luar" saat baru mengklik tombol
sleep 0.5

# Monitor kursor secara dinamis
while kill -0 $WOFI_PID 2>/dev/null; do
    # Ambil posisi kursor saat ini
    CPOS=$(hyprctl cursorpos)
    CX=$(echo $CPOS | cut -d',' -f1 | tr -d ' ')
    CY=$(echo $CPOS | cut -d',' -f2 | tr -d ' ')
    
    # Ambil info monitor yang sedang aktif
    MONITOR_INFO=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true)')
    M_WIDTH=$(echo $MONITOR_INFO | jq -r '.width')
    M_X=$(echo $MONITOR_INFO | jq -r '.x')
    M_Y=$(echo $MONITOR_INFO | jq -r '.y')

    # Hitung Zona Aman (Popup ada di top_right, lebar 150, offset -15)
    # Kita beri toleransi 50px ekstra agar tidak terlalu sensitif
    SAFE_X_MIN=$((M_X + M_WIDTH - 250)) 
    SAFE_Y_MAX=$((M_Y + 350))           

    # Jika kursor keluar dari zona aman, matikan menu
    if [[ $CX -lt $SAFE_X_MIN || $CY -gt $SAFE_Y_MAX || $CY -lt $M_Y ]]; then
        kill $WOFI_PID 2>/dev/null
        break
    fi
    sleep 0.1
done

# Pastikan LOCK_FILE dihapus
rm -f "$LOCK_FILE"

# Tunggu sebentar untuk memastikan file hasil wofi tertulis
sleep 0.1

# Ambil pilihan user jika file ada dan tidak kosong
if [ -s "$TMP_FILE" ]; then
    chosen=$(cat "$TMP_FILE")
    rm -f "$TMP_FILE"
    
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
else
    rm -f "$TMP_FILE"
fi
