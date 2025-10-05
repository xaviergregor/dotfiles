#!/bin/bash

# ============================================================
# Script de mise à jour automatique d’Ubuntu avec progression
# ============================================================

# Vérifie que l’utilisateur est root
if [[ $EUID -ne 0 ]]; then
   echo "⚠️  Ce script doit être lancé avec sudo ou en root."
   exit 1
fi

# Fichier log
LOGFILE="/var/log/update_ubuntu.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

echo "=============================================" | tee -a $LOGFILE
echo "🚀 Mise à jour lancée le : $DATE" | tee -a $LOGFILE

# Mise à jour des dépôts
echo -e "\n🔄 Mise à jour de la liste des paquets..."
apt update 2>&1 | tee -a $LOGFILE

# Mise à niveau des paquets
echo -e "\n⬆️ Installation des mises à jour..."
apt upgrade -y 2>&1 | tee -a $LOGFILE

# Suppression des paquets obsolètes
echo -e "\n🧹 Suppression des paquets inutiles..."
apt autoremove -y 2>&1 | tee -a $LOGFILE

# Nettoyage du cache
echo -e "\n🗑️ Nettoyage du cache..."
apt clean 2>&1 | tee -a $LOGFILE

echo -e "\n✅ Mise à jour terminée à $DATE" | tee -a $LOGFILE

