#!/bin/bash

# =============================================
# Installation Dash to Dock + System Monitor
# sur Debian
# =============================================

set -e  # Arrêt si erreur

echo "================================================"
echo "   Installation Dash to Dock + System Monitor"
echo "   sur Debian"
echo "================================================"

# --- Étape 1 : Dépendances ---
echo ""
echo "[1/5] Installation des dépendances..."
sudo apt update -q
sudo apt install -y \
    gnome-shell-extensions \
    gnome-browser-connector \
    gnome-shell-extension-manager \
    gnome-shell-extension-system-monitor \
    git \
    make
echo "✅ Dépendances installées"

# --- Étape 2 : Installer Dash to Dock ---
echo ""
echo "[2/5] Installation de Dash to Dock..."
cd /tmp
rm -rf dash-to-dock
git clone https://github.com/micheleg/dash-to-dock.git
cd dash-to-dock
make install
echo "✅ Dash to Dock installé"

# --- Étape 3 : Activer les extensions ---
echo ""
echo "[3/5] Activation des extensions..."
gnome-extensions enable dash-to-dock@micxgx.gmail.com
gnome-extensions enable system-monitor@paradoxxx.zero.gmail.com
echo "✅ Extensions activées"

# --- Étape 4 : Configuration du dock ---
echo ""
echo "[4/5] Configuration du dock..."

# Position en bas
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'

# Dock fixe (désactiver auto-hide)
gsettings set org.gnome.shell.extensions.dash-to-dock autohide false
gsettings set org.gnome.shell.extensions.dash-to-dock intellihide false

# Panel mode (pleine largeur)
gsettings set org.gnome.shell.extensions.dash-to-dock extend-height true

echo "✅ Dock configuré"

# --- Étape 5 : Configuration System Monitor ---
echo ""
echo "[5/5] Configuration de System Monitor..."

# Afficher CPU
gsettings set org.gnome.shell.extensions.system-monitor cpu-display true

# Afficher RAM
gsettings set org.gnome.shell.extensions.system-monitor memory-display true

# Afficher le réseau
gsettings set org.gnome.shell.extensions.system-monitor net-display true

# Afficher les valeurs numériques
gsettings set org.gnome.shell.extensions.system-monitor cpu-show-text true
gsettings set org.gnome.shell.extensions.system-monitor memory-show-text true

echo "✅ System Monitor configuré"

# --- Fin ---
echo ""
echo "================================================"
echo "✅ Installation terminée !"
echo ""
echo "📌 Dash to Dock → fixe en bas de l'écran"
echo "📊 System Monitor → visible dans la barre"
echo ""
echo "⚠️  Déconnectez-vous puis reconnectez-vous"
echo "    pour appliquer les changements."
echo ""
echo "💡 Pour ouvrir Extension Manager :"
echo "    gnome-extensions-app"
echo "================================================"

# Proposer la déconnexion
echo ""
read -p "Voulez-vous vous déconnecter maintenant ? (o/n) : " choix
if [ "$choix" = "o" ] || [ "$choix" = "O" ]; then
    gnome-session-quit --logout --no-prompt
fi

