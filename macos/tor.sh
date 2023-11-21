#!/usr/bin/env bash 
 
# 'Wi-Fi' ou 'Ethernet' ou 'Display Ethernet' 
INTERFACE=Wi-Fi
 
# Demande des droits administrateur 
sudo -v
 
# Met à jour l'horodatage `sudo` existant jusqu'à la fin
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
 
# CTRL-C pour stopper
function disable_proxy() {
    sudo networksetup -setsocksfirewallproxystate $INTERFACE off
    echo "$(tput setaf 64)" #green 
    echo "SOCKS proxy disabled."
    echo "$(tput sgr0)" # color reset 
}
trap disable_proxy INT
 
# Let's go dude
sudo networksetup -setsocksfirewallproxy $INTERFACE 127.0.0.1 9050 off
sudo networksetup -setsocksfirewallproxystate $INTERFACE on
 
echo "$(tput setaf 64)" # green 
echo "SOCKS proxy 127.0.0.1:9050 enabled."
echo "$(tput setaf 136)" # orange 
echo "Starting Tor..."
echo "$(tput sgr0)" # color reset 
 
tor
