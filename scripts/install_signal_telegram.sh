#!/bin/bash

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonctions d'installation
install_signal() {
    echo -e "${BLUE}Installation de Signal...${NC}"
    
    wget -O- https://updates.signal.org/desktop/apt/keys.asc | \
    gpg --dearmor | \
    sudo tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null

    echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' | \
    sudo tee /etc/apt/sources.list.d/signal-xenial.list

    sudo apt update && sudo apt install -y signal-desktop

    echo -e "${GREEN}✅ Signal installé avec succès !${NC}"
}

install_telegram() {
    echo -e "${BLUE}Installation de Telegram via Flatpak...${NC}"

    sudo apt install -y flatpak
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    flatpak install -y flathub org.telegram.desktop

    echo -e "${GREEN}✅ Telegram installé avec succès !${NC}"
}

# Menu
clear
echo -e "${YELLOW}================================${NC}"
echo -e "${YELLOW}   Installateur Signal/Telegram  ${NC}"
echo -e "${YELLOW}================================${NC}"
echo ""
echo -e "Que voulez-vous installer ?"
echo ""
echo -e "  ${GREEN}1)${NC} Signal"
echo -e "  ${GREEN}2)${NC} Telegram"
echo -e "  ${GREEN}3)${NC} Les deux"
echo -e "  ${RED}4)${NC} Quitter"
echo ""
read -p "Votre choix [1-4] : " choix

case $choix in
    1)
        install_signal
        ;;
    2)
        install_telegram
        ;;
    3)
        install_signal
        install_telegram
        ;;
    4)
        echo -e "${YELLOW}Au revoir !${NC}"
        exit 0
        ;;
    *)
        echo -e "${RED}❌ Choix invalide${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${YELLOW}================================${NC}"
echo -e "${GREEN}   Installation terminée ! 🎉    ${NC}"
echo -e "${YELLOW}================================${NC}"

