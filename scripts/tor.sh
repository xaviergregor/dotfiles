#!/usr/bin/env bash
# Active un proxy SOCKS système vers Tor (macOS) le temps que tor tourne.
# Le proxy est désactivé à la sortie, quelle qu'en soit la cause.

# 'Wi-Fi' ou 'Ethernet' ou 'Display Ethernet'
INTERFACE="${1:-Wi-Fi}"
PORT=9050

# Demande des droits administrateur
sudo -v

# Met à jour l'horodatage `sudo` existant jusqu'à la fin
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

disable_proxy() {
    sudo networksetup -setsocksfirewallproxystate "$INTERFACE" off
    echo "$(tput setaf 64)SOCKS proxy disabled.$(tput sgr0)" # green
}

# Si le port est déjà pris (ex. brew services tor), tor échouerait aussitôt
if lsof -nP -iTCP:"$PORT" -sTCP:LISTEN >/dev/null 2>&1; then
    echo "$(tput setaf 160)Le port $PORT est déjà utilisé (brew services stop tor ?).$(tput sgr0)" >&2
    exit 1
fi

# Désactive le proxy à toute sortie : CTRL-C, kill, ou arrêt de tor
trap disable_proxy EXIT
trap 'exit 130' INT TERM

# Let's go dude
sudo networksetup -setsocksfirewallproxy "$INTERFACE" 127.0.0.1 "$PORT" off
sudo networksetup -setsocksfirewallproxystate "$INTERFACE" on

echo "$(tput setaf 64)SOCKS proxy 127.0.0.1:$PORT enabled ($INTERFACE).$(tput sgr0)"
echo "$(tput setaf 136)Starting Tor... (CTRL-C pour stopper)$(tput sgr0)"

tor
