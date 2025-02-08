#!/bin/bash

# Script pour changer le nom d'hôte sur une machine Debian

# Demander le nouveau nom d'hôte
read -p "Entrez le nouveau nom d'hôte: " new_hostname

# Vérifier si le nom d'hôte est non vide
if [ -z "$new_hostname" ]; then
    echo "Le nom d'hôte ne peut pas être vide."
    exit 1
fi

# Vérifier si l'utilisateur est root
if [ "$(id -u)" != "0" ]; then
    echo "Ce script doit être exécuté en tant que root."
    exit 1
fi

# Changer le nom d'hôte actuel
hostnamectl set-hostname $new_hostname

# Modifier le fichier /etc/hostname
echo $new_hostname > /etc/hostname

# Modifier le fichier /etc/hosts
sed -i "s/127.0.1.1\s.*/127.0.1.1\t$new_hostname/" /etc/hosts

# Vérification et fin du script
if [ $? -eq 0 ]; then
    echo "Le nom d'hôte a été changé avec succès en '$new_hostname'."
    echo "Veuillez redémarrer le système pour appliquer les changements."
else
    echo "Une erreur s'est produite lors de la modification du nom d'hôte."
fi

exit 0

