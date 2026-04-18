#!/bin/bash

# Ganti URL ini dengan URL repository GitHub Anda nanti
REPO_URL="https://github.com/AkhmadKhoirudin/hyperland_disain.git"
TEMP_DIR="/tmp/my-dotfiles-setup"

echo "Mendownload konfigurasi..."
git clone $REPO_URL $TEMP_DIR

cd $TEMP_DIR
chmod +x install.sh
./install.sh

echo "Pembersihan..."
rm -rf $TEMP_DIR
