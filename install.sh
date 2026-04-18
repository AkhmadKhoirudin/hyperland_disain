#!/bin/bash

# --- Colors ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🚀 Live Dotfiles Installer${NC}"
echo "-------------------------------------"

# 1. Check for AUR Helper
AUR_HELPER=""
if command -v yay &> /dev/null; then AUR_HELPER="yay"; elif command -v paru &> /dev/null; then AUR_HELPER="paru"; else
    echo -e "${YELLOW}AUR helper tidak ditemukan. Menginstal yay...${NC}"
    git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin && cd /tmp/yay-bin && makepkg -si --noconfirm && cd -
    AUR_HELPER="yay"
fi

# 2. Install Packages
echo -e "\n${YELLOW}📦 Menginstal paket dari pkglist.txt...${NC}"
$AUR_HELPER -S --needed --noconfirm - < pkglist.txt

# 3. Backup Current Config
BACKUP_DIR="$HOME/.config/backup_live_$(date +%Y%m%d_%H%M%S)"
echo -e "\n${YELLOW}💾 Mencadangkan config lama ke $BACKUP_DIR...${NC}"
mkdir -p "$BACKUP_DIR"

# List of folders to symlink/copy
CONFIG_DIRS=("hypr" "waybar" "wofi" "kitty" "dunst" "swaync" "wlogout" "fastfetch" "nwg-look" "nwg-displays" "btop" "micro" "Thunar" "xfce4")

for DIR in "${CONFIG_DIRS[@]}"; do
    if [ -d "$HOME/.config/$DIR" ]; then
        mv "$HOME/.config/$DIR" "$BACKUP_DIR/"
    fi
    cp -r "$(pwd)/$DIR" "$HOME/.config/"
    echo -e "Berhasil memasang: ${GREEN}$DIR${NC}"
done

# Copy individual files
cp -v "$(pwd)/mimeapps.list" "$HOME/.config/" 2>/dev/null
cp -v "$(pwd)/pavucontrol.ini" "$HOME/.config/" 2>/dev/null
cp -v "$(pwd)/.bashrc" "$HOME/" 2>/dev/null

echo -e "\n${GREEN}✅ Semua pengaturan live berhasil dipasang!${NC}"
