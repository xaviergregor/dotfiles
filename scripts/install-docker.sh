#!/usr/bin/env bash
#
# install-docker.sh
# Installation propre et idempotente de Docker Engine + Compose v2
# sur Debian (11/12/13), Ubuntu (20.04 / 22.04 / 24.04 / 25.04+) et Fedora.
#
# Détection automatique de la distribution (et du codename pour Debian/Ubuntu).
#
# Usage : sudo ./install-docker.sh
#

set -euo pipefail

# --- Couleurs ----------------------------------------------------------------
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
BLUE=$'\033[0;34m'
NC=$'\033[0m'

log()  { printf "%s[+]%s %s\n" "$GREEN"  "$NC" "$*"; }
warn() { printf "%s[!]%s %s\n" "$YELLOW" "$NC" "$*"; }
err()  { printf "%s[x]%s %s\n" "$RED"    "$NC" "$*" >&2; }
step() { printf "\n%s==>%s %s\n" "$BLUE" "$NC" "$*"; }

# --- Pré-requis --------------------------------------------------------------
if [[ $EUID -ne 0 ]]; then
    err "Ce script doit être exécuté en root (ou avec sudo)."
    exit 1
fi

# Détection de la distribution
. /etc/os-release
DISTRO_ID="${ID:-}"
CODENAME="${VERSION_CODENAME:-}"

case "$DISTRO_ID" in
    debian)
        PKG_FAMILY="apt"
        DOCKER_URL="https://download.docker.com/linux/debian"
        ;;
    ubuntu)
        PKG_FAMILY="apt"
        DOCKER_URL="https://download.docker.com/linux/ubuntu"
        ;;
    linuxmint|pop|zorin|elementary)
        # Dérivés Ubuntu : on utilise le dépôt Ubuntu avec UBUNTU_CODENAME
        PKG_FAMILY="apt"
        DOCKER_URL="https://download.docker.com/linux/ubuntu"
        CODENAME="${UBUNTU_CODENAME:-$CODENAME}"
        warn "Distribution dérivée détectée ($DISTRO_ID) — utilisation du dépôt Ubuntu (codename: $CODENAME)"
        ;;
    fedora)
        PKG_FAMILY="dnf"
        DOCKER_URL="https://download.docker.com/linux/fedora"
        CODENAME="${VERSION_ID:-}"
        ;;
    *)
        err "Distribution non supportée : ${PRETTY_NAME:-$DISTRO_ID}. Ce script vise Debian / Ubuntu / Fedora."
        exit 1
        ;;
esac

if [[ "$PKG_FAMILY" == "apt" ]] && ! command -v apt-get >/dev/null 2>&1; then
    err "apt-get introuvable."
    exit 1
fi
if [[ "$PKG_FAMILY" == "dnf" ]] && ! command -v dnf >/dev/null 2>&1; then
    err "dnf introuvable."
    exit 1
fi

if [[ -z "$CODENAME" ]]; then
    err "Impossible de déterminer la version/codename de la distribution."
    exit 1
fi

log "Distribution : ${PRETTY_NAME:-?}  (version/codename : $CODENAME)"

# Utilisateur cible pour le groupe docker (celui qui a lancé sudo)
TARGET_USER="${SUDO_USER:-$USER}"
if [[ "$TARGET_USER" == "root" ]]; then
    warn "Aucun utilisateur non-root détecté — aucun ajout au groupe docker ne sera fait."
fi

# --- 1. Nettoyage des anciennes versions ------------------------------------
step "Suppression des anciennes versions de Docker (si présentes)"

# Snap docker (fréquent sur Ubuntu) : à virer avant toute chose
if command -v snap >/dev/null 2>&1 && snap list 2>/dev/null | grep -q '^docker '; then
    warn "Paquet snap 'docker' détecté — désinstallation…"
    snap remove --purge docker || warn "Échec de la suppression du snap docker — à vérifier manuellement"
fi

if [[ "$PKG_FAMILY" == "apt" ]]; then
    OLD_PKGS=(docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc)
    for pkg in "${OLD_PKGS[@]}"; do
        if dpkg -s "$pkg" >/dev/null 2>&1; then
            log "Suppression : $pkg"
            apt-get remove -y "$pkg" >/dev/null
        fi
    done
else
    OLD_PKGS=(docker docker-client docker-client-latest docker-common docker-latest
              docker-latest-logrotate docker-logrotate docker-selinux docker-engine-selinux
              docker-engine moby-engine docker-compose podman-docker)
    for pkg in "${OLD_PKGS[@]}"; do
        if rpm -q "$pkg" >/dev/null 2>&1; then
            log "Suppression : $pkg"
            dnf remove -y -q "$pkg" >/dev/null
        fi
    done
fi

if [[ "$PKG_FAMILY" == "apt" ]]; then
    # --- 2. Dépendances ------------------------------------------------------
    step "Installation des dépendances"
    apt-get update -qq
    apt-get install -y -qq ca-certificates curl gnupg lsb-release

    # --- 3. Clé GPG officielle Docker ---------------------------------------
    step "Ajout de la clé GPG Docker"
    install -m 0755 -d /etc/apt/keyrings
    if [[ ! -f /etc/apt/keyrings/docker.asc ]]; then
        curl -fsSL "${DOCKER_URL}/gpg" -o /etc/apt/keyrings/docker.asc
        chmod a+r /etc/apt/keyrings/docker.asc
        log "Clé installée dans /etc/apt/keyrings/docker.asc"
    else
        log "Clé déjà présente — saut"
    fi

    # --- 4. Dépôt APT Docker -------------------------------------------------
    step "Ajout du dépôt APT Docker"
    ARCH="$(dpkg --print-architecture)"
    REPO_LINE="deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.asc] ${DOCKER_URL} ${CODENAME} stable"
    echo "$REPO_LINE" > /etc/apt/sources.list.d/docker.list
    log "Dépôt configuré : $REPO_LINE"
else
    # --- 2. Dépendances ------------------------------------------------------
    step "Installation des dépendances"
    dnf install -y -q ca-certificates curl

    # --- 3/4. Dépôt DNF Docker (la clé GPG est référencée dans le .repo) -----
    step "Ajout du dépôt DNF Docker"
    # Téléchargement direct du .repo : fonctionne avec dnf4 et dnf5
    # (évite les différences de syntaxe de 'dnf config-manager')
    curl -fsSL "${DOCKER_URL}/docker-ce.repo" -o /etc/yum.repos.d/docker-ce.repo
    log "Dépôt configuré : /etc/yum.repos.d/docker-ce.repo"
fi

# --- 5. Installation ---------------------------------------------------------
step "Installation de Docker Engine + Compose v2 + Buildx"
DOCKER_PKGS=(docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin)
if [[ "$PKG_FAMILY" == "apt" ]]; then
    apt-get update -qq
    apt-get install -y -qq "${DOCKER_PKGS[@]}"
else
    # -y accepte aussi l'import de la clé GPG Docker (vérifier l'empreinte :
    # 060A 61C5 1B55 8A7F 742B 77AA C52F EB6B 621E 9F35)
    dnf install -y -q "${DOCKER_PKGS[@]}"
fi

# --- 6. Activation du service -----------------------------------------------
step "Activation du service Docker"
systemctl enable --now docker
systemctl --no-pager --quiet is-active docker \
    && log "Service docker actif" \
    || warn "Service docker non actif — vérifier avec : journalctl -u docker"

# --- 7. Ajout au groupe docker ----------------------------------------------
if [[ "$TARGET_USER" != "root" ]]; then
    step "Ajout de l'utilisateur '$TARGET_USER' au groupe docker"
    if id -nG "$TARGET_USER" | tr ' ' '\n' | grep -qx docker; then
        log "$TARGET_USER est déjà dans le groupe docker"
    else
        usermod -aG docker "$TARGET_USER"
        log "$TARGET_USER ajouté — déconnecte/reconnecte-toi ou exécute : newgrp docker"
    fi
fi

# --- 8. Vérifications --------------------------------------------------------
step "Vérification de l'installation"
docker --version
docker compose version
docker buildx version

echo
log "Test rapide : docker run --rm hello-world"
if docker run --rm hello-world >/dev/null 2>&1; then
    log "Hello-world OK — Docker fonctionne correctement."
else
    warn "Le test hello-world a échoué — vérifier la configuration réseau / daemon."
fi

echo
log "Installation terminée."
if [[ "$TARGET_USER" != "root" ]]; then
    warn "Pense à te reconnecter pour utiliser docker sans sudo."
fi
