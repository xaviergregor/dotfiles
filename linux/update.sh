#!/bin/bash

# Vérification des droits d'administration
if [[ $EUID -ne 0 ]]; then
   echo "Ce script doit être exécuté avec des droits d'administration (root)."
   exit 1
fi

# Mise à jour des dépôts
apt update

# Mise à jour du système
apt upgrade -y

# Mise à jour des paquets installés
apt full-upgrade -y

# Nettoyage des paquets obsolètes
apt autoremove --purge -y

# Nettoyage du cache apt
apt clean

echo "La mise à jour est terminée."

exit 0
