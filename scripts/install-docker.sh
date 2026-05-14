#!/usr/bin/env bash
#
# install-docker.sh
# Installation propre et idempotente de Docker Engine + Compose v2
# sur Debian (11/12/13) et Ubuntu (20.04 / 22.04 / 24.04 / 25.04+).
#
# Détection automatique de la distribution et du codename.
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

if ! command -v apt-get >/dev/null 2>&1; then
    err "apt-get introuvable — ce script vise les distributions Debian/Ubuntu."
    exit 1
fi

# Détection de la distribution
. /etc/os-release
DISTRO_ID="${ID:-}"
CODENAME="${VERSION_CODENAME:-}"

case "$DISTRO_ID" in
    debian)
        DOCKER_URL="https://download.docker.com/linux/debian"
        ;;
    ubuntu)
        DOCKER_URL="https://download.docker.com/linux/ubuntu"
        ;;
    linuxmint|pop|zorin|elementary)
        # Dérivés Ubuntu : on utilise le dépôt Ubuntu avec UBUNTU_CODENAME
        DOCKER_URL="https://download.docker.com/linux/ubuntu"
        CODENAME="${UBUNTU_CODENAME:-$CODENAME}"
        warn "Distribution dérivée détectée ($DISTRO_ID) — utilisation du dépôt Ubuntu (codename: $CODENAME)"
        ;;
    *)
        err "Distribution non supportée : ${PRETTY_NAME:-$DISTRO_ID}. Ce script vise Debian / Ubuntu."
        exit 1
        ;;
esac

if [[ -z "$CODENAME" ]]; then
    err "Impossible de déterminer le codename de la distribution."
    exit 1
fi

log "Distribution : ${PRETTY_NAME:-?}  (codename : $CODENAME)"

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

OLD_PKGS=(docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc)
for pkg in "${OLD_PKGS[@]}"; do
    if dpkg -s "$pkg" >/dev/null 2>&1; then
        log "Suppression : $pkg"
        apt-get remove -y "$pkg" >/dev/null
    fi
done

# --- 2. Dépendances ----------------------------------------------------------
step "Installation des dépendances"
apt-get update -qq
apt-get install -y -qq ca-certificates curl gnupg lsb-release

# --- 3. Clé GPG officielle Docker -------------------------------------------
step "Ajout de la clé GPG Docker"
install -m 0755 -d /etc/apt/keyrings
if [[ ! -f /etc/apt/keyrings/docker.asc ]]; then
    curl -fsSL "${DOCKER_URL}/gpg" -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc
    log "Clé installée dans /etc/apt/keyrings/docker.asc"
else
    log "Clé déjà présente — saut"
fi

# --- 4. Dépôt APT Docker -----------------------------------------------------
step "Ajout du dépôt APT Docker"
ARCH="$(dpkg --print-architecture)"
REPO_LINE="deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.asc] ${DOCKER_URL} ${CODENAME} stable"
echo "$REPO_LINE" > /etc/apt/sources.list.d/docker.list
log "Dépôt configuré : $REPO_LINE"

# --- 5. Installation ---------------------------------------------------------
step "Installation de Docker Engine + Compose v2 + Buildx"
apt-get update -qq
apt-get install -y -qq \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

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
[[ "$TARGET_USER" != "root" ]] && warn "Pense à te reconnecter pour utiliser docker sans sudo."
