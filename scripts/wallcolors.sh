#!/bin/bash

# ================================
# Wallpaper Couleur Unie - GNOME
# ================================

# Couleurs prédéfinies
declare -A COULEURS=(
    ["noir"]="#000000"
    ["blanc"]="#FFFFFF"
    ["gris"]="#3C3C3C"
    ["bleu_nuit"]="#2E3440"
    ["bleu"]="#1E90FF"
    ["rouge"]="#C0392B"
    ["vert"]="#1E3A2F"
    ["violet"]="#6C3483"
    ["orange"]="#E67E22"
)

# Affichage du menu
afficher_menu() {
    echo "================================"
    echo "  🎨 Fond d'écran Couleur Unie"
    echo "================================"
    echo ""
    echo "Couleurs disponibles :"
    echo ""
    i=1
    for couleur in "${!COULEURS[@]}"; do
        echo "  $i) $couleur  ${COULEURS[$couleur]}"
        ((i++))
    done
    echo ""
    echo "  c) Entrer un code HEX personnalisé"
    echo "  q) Quitter"
    echo ""
    echo "================================"
}

# Appliquer la couleur
appliquer_couleur() {
    local hex=$1
    echo ""
    echo "⏳ Application de la couleur $hex ..."
    gsettings set org.gnome.desktop.background picture-options 'none'
    gsettings set org.gnome.desktop.background primary-color "$hex"
    gsettings set org.gnome.desktop.background secondary-color "$hex"
    echo "✅ Couleur appliquée avec succès !"
    echo ""
}

# Validation du code HEX
valider_hex() {
    local hex=$1
    if [[ $hex =~ ^#[0-9A-Fa-f]{6}$ ]]; then
        return 0
    else
        return 1
    fi
}

# ---- MAIN ----

afficher_menu

read -p "Votre choix : " choix

case $choix in
    q|Q)
        echo "Au revoir !"
        exit 0
        ;;
    c|C)
        read -p "Entrez votre code HEX (ex: #FF5733) : " hex_custom
        if valider_hex "$hex_custom"; then
            appliquer_couleur "$hex_custom"
        else
            echo "❌ Code HEX invalide ! Format attendu : #RRGGBB"
            exit 1
        fi
        ;;
    *)
        # Sélection par numéro
        i=1
        for couleur in "${!COULEURS[@]}"; do
            if [[ $choix -eq $i ]]; then
                appliquer_couleur "${COULEURS[$couleur]}"
                exit 0
            fi
            ((i++))
        done
        echo "❌ Choix invalide !"
        exit 1
        ;;
esac

