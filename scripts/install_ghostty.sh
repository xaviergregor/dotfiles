#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "Ce script doit être exécuté en tant que root (sudo)"
    fi
}

check_os() {
    if [[ ! -f /etc/debian_version ]]; then
        log_error "Ce script est conçu pour Debian uniquement"
    fi
    log_info "Système détecté : $(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '\"')"
}

add_repository() {
    log_info "Ajout de la clé GPG..."
    curl -sS https://debian.griffo.io/EA0F721D231FDD3A0A17B9AC7808B4DD62C41256.asc \
        | gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/debian.griffo.io.gpg

    log_info "Ajout du dépôt..."
    echo "deb https://debian.griffo.io/apt $(lsb_release -sc) main" \
        | tee /etc/apt/sources.list.d/debian.griffo.io.list

    log_info "Mise à jour des paquets..."
    apt update -qq

    log_success "Dépôt ajouté"
}

install_ghostty() {
    log_info "Installation de Ghostty..."
    apt install -y ghostty
    log_success "Ghostty installé"
}

verify_installation() {
    if command -v ghostty &>/dev/null; then
        log_success "Ghostty installé avec succès !"
        echo -e "${GREEN}Version :${NC} $(ghostty --version)"
        echo -e "${GREEN}Binaire :${NC} $(which ghostty)"
    else
        log_error "Installation échouée - ghostty introuvable"
    fi
}

main() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════╗"
    echo "║   Installation de Ghostty - Debian   ║"
    echo "╚══════════════════════════════════════╝"
    echo -e "${NC}"

    check_root
    check_os
    add_repository
    install_ghostty
    verify_installation

    echo ""
    echo -e "${GREEN}✓ Lancez Ghostty avec : ghostty${NC}"
}

main "$@"

