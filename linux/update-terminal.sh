#!/bin/bash
#############################################
#                                           #
#             Mise à jour                   #
#                                           #
#############################################

echo "Mise à jour et installation de Ranger"
sudo apt update && sudo apt install ranger -y
sleep 3

##############################################

echo "Installation de Neovim"
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
chmod u+x nvim.appimage
sleep 3
./nvim.appimage --appimage-extract
./squashfs-root/AppRun --version

# Optional: exposing nvim globally.
sudo mv squashfs-root /
sudo ln -s /squashfs-root/AppRun /usr/bin/nvim
sleep 3

#############################################

echo "Installation de NvChad"
git clone https://github.com/NvChad/starter ~/.config/nvim && nvim
