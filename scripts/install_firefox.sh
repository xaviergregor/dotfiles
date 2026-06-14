#!/bin/bash

# ============================================
# Installation Firefox (dépôt officiel Mozilla)
# Suppression Firefox ESR
# Debian 13
# ============================================

set -e

# Vérification root
if [[ $EUID -ne 0 ]]; then
    echo "❌ Ce script doit être exécuté en root (sudo)"
    exit 1
fi

echo "🦊 Début de l'installation de Firefox via dépôt Mozilla..."

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
    gnupg \
    apt-transport-https

echo "✅ Dépendances installées"

# ============================================
# 3. Ajout de la clé GPG Mozilla
# ============================================
echo ""
echo "🔑 Ajout de la clé GPG Mozilla..."

install -d -m 0755 /etc/apt/keyrings

wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- \
    | tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null

echo "✅ Clé GPG ajoutée"

# ============================================
# 4. Ajout du dépôt Mozilla
# ============================================
echo ""
echo "📋 Ajout du dépôt Mozilla..."

cat > /etc/apt/sources.list.d/mozilla.list << 'EOF'
deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main
EOF

echo "✅ Dépôt Mozilla ajouté"

# ============================================
# 5. Priorité au dépôt Mozilla
# (évite les conflits avec les paquets Debian)
# ============================================
echo ""
echo "⚙️  Configuration des priorités apt..."

cat > /etc/apt/preferences.d/mozilla << 'EOF'
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
EOF

echo "✅ Priorités configurées"

# ============================================
# 6. Mise à jour et installation
# ============================================
echo ""
echo "⬇️  Mise à jour des dépôts et installation de Firefox..."

apt update
apt install -y firefox

echo "✅ Firefox installé"

# ============================================
# 7. Vérification
# ============================================
echo ""
echo "🔍 Vérification de l'installation..."

FIREFOX_VERSION=$(firefox --version 2>/dev/null)
echo "✅ $FIREFOX_VERSION"

echo ""
echo "============================================"
echo "🎉 Installation terminée avec succès !"
echo "============================================"
echo "📌 Mises à jour via : sudo apt update && sudo apt upgrade"
echo "📌 Version : $FIREFOX_VERSION"
echo "============================================"

