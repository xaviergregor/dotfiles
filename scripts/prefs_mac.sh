#!/usr/bin/env bash
# Préférences macOS. À lancer SANS sudo : les réglages utilisateur doivent
# aller dans ton domaine, pas dans celui de root. Le script demande sudo
# uniquement pour les réglages système (/Library/...).

if [[ $EUID -eq 0 ]]; then
  echo "Ne pas lancer en root : make prefs-mac (sans sudo)." >&2
  exit 1
fi

# Valeurs personnelles (non versionnées) : scripts/local.env
ENV_FILE="$(cd "$(dirname "$0")" && pwd)/local.env"
# shellcheck source=/dev/null
[[ -f $ENV_FILE ]] && source "$ENV_FILE"

sudo -v

## ************************* Debut de la configuration ********************************
echo "Configuration des prefs"

# Affichage de la bibliothèque
chflags nohidden ~/Library

# Finder : affichage de la barre latérale / affichage par défaut en mode colonnes / affichage chemin accès / extensions toujours affichées
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "clmv"
defaults write com.apple.finder ShowPathbar -bool true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Afficher le dossier maison par défaut
defaults write com.apple.finder NewWindowTarget -string "PfHm"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

# Recherche dans le dossier en cours par défaut
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Pas de création de fichiers .DS_STORE
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Pas d'organisation des bureaux en fonction des apps ouvertes
defaults write com.apple.dock mru-spaces -bool false

# Masquage automatique du Dock
defaults write com.apple.dock autohide -bool true

# Affichage du Dock plus rapide quand il est masqué
defaults write com.apple.dock autohide-delay -float 0

# Mot de passe demandé immédiatement quand l'économiseur d'écran s'active
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# Répétition touches plus rapide
defaults write NSGlobalDomain KeyRepeat -int 1

# Délai avant répétition des touches
defaults write NSGlobalDomain InitialKeyRepeat -int 10

# Finder: Desactiver l'animation sur Get Info
defaults write com.apple.finder DisableAllAnimations -bool true

# Voir les icones des medias sur le bureau
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

# ---------- Réglages système (sudo) ----------

# Sur la fenetre de login clique sur horloge affiche IP
sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

# Desactiver adresse Wi-Fi privee
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.airport.preferences.plist PrivateMACAddressModeSystemSetting -int 1

# Message a la fenetre de login (défini dans scripts/local.env)
if [[ -n ${LOGIN_MESSAGE:-} ]]; then
  sudo defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText -string "$LOGIN_MESSAGE"
else
  echo "LOGIN_MESSAGE non défini (scripts/local.env) : message de login ignoré"
fi

# Application des changements
killall Dock Finder 2>/dev/null || true

echo "Terminé. Certains réglages (clavier) demandent une reconnexion."
## ************ Fin de la configuration *************
