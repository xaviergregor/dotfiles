#!/bin/bash

# ============================================
# Installation Firefox dernière version
# Suppression Firefox ESR
# Debian 13
# ============================================

set -e

# Vérification root
if [[ $EUID -ne 0 ]]; then
    echo "❌ Ce script doit être exécuté en root (sudo)"
    exit 1
fi

echo "🦊 Début de l'installation de Firefox (dernière version)..."

# ============================================
# 1. Suppression de Firefox ESR
# ============================================
echo ""
echo "🗑️  Suppression de Firefox ESR..."

apt purge -y firefox-esr
apt autoremove -y
apt autoclean -y

echo "✅ Firefox ESR supprimé"

# ============================================
# 2. Installation des dépendances
# ============================================
echo ""
echo "📦 Installation des dépendances..."

apt install -y \
    wget \
    curl \
    bzip2 \
    libdbus-glib-1-2 \
    libgtk-3-0 \
    libx11-xcb1 \
    libxt6

echo "✅ Dépendances installées"

# ============================================
# 3. Téléchargement de Firefox
# ============================================
echo ""
echo "⬇️  Téléchargement de Firefox..."

FIREFOX_URL="https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64&lang=fr"
FIREFOX_ARCHIVE="/tmp/firefox-latest.tar.bz2"

wget -O "$FIREFOX_ARCHIVE" "$FIREFOX_URL" --progress=bar:force 2>&1

echo "✅ Firefox téléchargé"

# ============================================
# 4. Installation
# ============================================
echo ""
echo "📂 Installation de Firefox dans /opt/firefox..."

# Suppression ancienne installation si existante
if [[ -d /opt/firefox ]]; then
    echo "🔄 Suppression de l'ancienne installation..."
    rm -rf /opt/firefox
fi

tar -xjf "$FIREFOX_ARCHIVE" -C /opt/

echo "✅ Firefox extrait dans /opt/firefox"

# ============================================
# 5. Création du lien symbolique
# ============================================
echo ""
echo "🔗 Création du lien symbolique..."

ln -sf /opt/firefox/firefox /usr/local/bin/firefox

echo "✅ Lien symbolique créé"

# ============================================
# 6. Création du fichier .desktop
# ============================================
echo ""
echo "🖥️  Création du raccourci bureau..."

cat > /usr/share/applications/firefox.desktop << 'EOF'
[Desktop Entry]
Name=Firefox
Comment=Navigateur Web
GenericName=Web Browser
Exec=/opt/firefox/firefox %u
Icon=/opt/firefox/browser/chrome/icons/default/default128.png
Terminal=false
Type=Application
MimeType=text/html;text/xml;application/xhtml+xml;application/vnd.mozilla.xul+xml;text/mml;x-scheme-handler/http;x-scheme-handler/https;
StartupNotify=true
Categories=Network;WebBrowser;
Keywords=web;browser;internet;
StartupWMClass=firefox
EOF

echo "✅ Raccourci bureau créé"

# ============================================
# 7. Définir comme navigateur par défaut
# ============================================
echo ""
echo "🌐 Définition comme navigateur par défaut..."

update-alternatives --install /usr/bin/x-www-browser x-www-browser /opt/firefox/firefox 200
update-alternatives --set x-www-browser /opt/firefox/firefox

echo "✅ Firefox défini comme navigateur par défaut"

# ============================================
# 8. Nettoyage
# ============================================
echo ""
echo "🧹 Nettoyage..."

rm -f "$FIREFOX_ARCHIVE"

echo "✅ Nettoyage effectué"

# ============================================
# 9. Vérification
# ============================================
echo ""
echo "🔍 Vérification de l'installation..."

FIREFOX_VERSION=$(/opt/firefox/firefox --version 2>/dev/null)
echo "✅ $FIREFOX_VERSION"

echo ""
echo "============================================"
echo "🎉 Installation terminée avec succès !"
echo "============================================"
echo "📌 Firefox installé dans : /opt/firefox"
echo "📌 Commande : firefox"
echo "📌 Version : $FIREFOX_VERSION"
echo "============================================"

