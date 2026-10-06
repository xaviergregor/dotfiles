#!/usr/bin/env bash
# sysupdate.sh — Mises à jour courantes et montées de version majeures
# Ubuntu (do-release-upgrade) et Debian (bascule des sources APT)
#
# Usage : sudo ./sysupdate.sh            menu interactif
#         sudo ./sysupdate.sh -u         mises à jour courantes
#         sudo ./sysupdate.sh -u -y      mises à jour courantes sans question (cron)
#         sudo ./sysupdate.sh -m         montée de version majeure
#         sudo ./sysupdate.sh -s         état du système

set -Eeuo pipefail

LOG=/var/log/sysupdate.log
BACKUP_DIR=/var/backups/sysupdate
ASSUME_YES=0
MIN_FREE_ROUTINE=1500   # Mo libres sur /
MIN_FREE_MAJOR=5000
MIN_FREE_BOOT=200

# Debian : version courante -> suivante
declare -A DEB_NEXT=([buster]=bullseye [bullseye]=bookworm [bookworm]=trixie [trixie]=forky)

# ---------- affichage / log ----------
if [[ -t 1 ]]; then
  R=$'\e[31m' G=$'\e[32m' Y=$'\e[33m' B=$'\e[34m' W=$'\e[1m' N=$'\e[0m'
else
  R='' G='' Y='' B='' W='' N=''
fi
log()  { printf '%s %s\n' "$(date '+%F %T')" "$*" >>"$LOG" 2>/dev/null || true; }
info() { printf '%s==>%s %s\n' "$B" "$N" "$*"; log "INFO  $*"; }
ok()   { printf '%s ✔ %s %s\n' "$G" "$N" "$*"; log "OK    $*"; }
warn() { printf '%s ⚠ %s %s\n' "$Y" "$N" "$*"; log "WARN  $*"; }
die()  { printf '%s ✖ %s %s\n' "$R" "$N" "$*" >&2; log "ERROR $*"; exit 1; }
trap 'die "Échec ligne $LINENO : $BASH_COMMAND"' ERR

# ask "question" [o|n]  -> 0 si oui. En mode -y, prend la réponse par défaut.
ask() {
  local q=$1 def=${2:-n} ans hint
  [[ $def == o ]] && hint="[O/n]" || hint="[o/N]"
  if (( ASSUME_YES )); then [[ $def == o ]]; return; fi
  read -rp "$(printf '%s ? %s%s %s ' "$W" "$q" "$N" "$hint")" ans </dev/tty || ans=
  ans=${ans:-$def}
  [[ ${ans,,} == o* || ${ans,,} == y* ]]
}

# ---------- apt ----------
APT_BASE=(-o DPkg::Lock::Timeout=300 -o APT::Color=0 -o Dpkg::Progress-Fancy=0)

# Exécute une commande en journalisant toute sa sortie dans $LOG.
# Interactif : 'script' garde un vrai terminal, donc les questions dpkg/debconf restent possibles.
# Non interactif (-y / cron) : simple tee, avec le code retour de la commande.
run_logged() {
  printf '\n----- %s : %s\n' "$(date '+%F %T')" "$*" >>"$LOG" 2>/dev/null || true
  if (( ! ASSUME_YES )) && [[ -t 0 ]] && command -v script >/dev/null; then
    SHELL=/bin/bash script -qefa -c "$(printf '%q ' "$@")" "$LOG"
  else
    "$@" 2>&1 | tee -a "$LOG"
    return "${PIPESTATUS[0]}"
  fi
}

apt_get() {
  if (( ASSUME_YES )); then
    run_logged env DEBIAN_FRONTEND=noninteractive apt-get -y "${APT_BASE[@]}" \
      -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold "$@"
  else
    run_logged apt-get -y "${APT_BASE[@]}" "$@"   # dpkg pose quand même les questions de conf
  fi
}

# Rotation du log (créée une seule fois)
ensure_logrotate() {
  [[ -d /etc/logrotate.d && ! -f /etc/logrotate.d/sysupdate ]] || return 0
  cat >/etc/logrotate.d/sysupdate <<EOF
$LOG {
    monthly
    rotate 12
    compress
    missingok
    notifempty
}
EOF
}
sim()           { apt-get -s "$@" 2>/dev/null; }
pending_count() { sim full-upgrade | grep -c '^Inst ' || true; }

# ---------- contexte ----------
need_root() { [[ $EUID -eq 0 ]] || die "À lancer en root (sudo)."; }

detect_os() {
  # shellcheck disable=SC1091
  . /etc/os-release
  OS_ID=$ID OS_NAME=$PRETTY_NAME CODENAME=${VERSION_CODENAME:-}
  case $OS_ID in ubuntu|debian) ;; *) die "Distribution non supportée : $OS_ID" ;; esac
}

in_multiplexer() { [[ -n ${TMUX:-} || ${TERM:-} == screen* ]]; }

free_mb() { df -Pm "$1" 2>/dev/null | awk 'NR==2{print $4}'; }

preflight() {
  local need=$1 free
  free=$(free_mb /)
  (( free >= need )) || { warn "Seulement ${free} Mo libres sur / (recommandé : ${need})."; ask "Continuer quand même" n || exit 1; }
  if mountpoint -q /boot; then
    free=$(free_mb /boot)
    (( free >= MIN_FREE_BOOT )) || warn "/boot presque plein (${free} Mo). Pense à 'apt autoremove --purge'."
  fi
  if [[ -n $(dpkg --audit 2>/dev/null) ]]; then
    warn "dpkg signale des paquets mal configurés."
    ask "Lancer 'dpkg --configure -a'" o && dpkg --configure -a
  fi
  local held; held=$(apt-mark showhold)
  [[ -z $held ]] || warn "Paquets bloqués (hold) : $(echo "$held" | tr '\n' ' ')"
}

backup_etc() {
  ask "Sauvegarder /etc et la liste des paquets dans $BACKUP_DIR" o || return 0
  mkdir -p "$BACKUP_DIR"
  local ts; ts=$(date +%F-%H%M%S)
  tar czf "$BACKUP_DIR/etc-$ts.tar.gz" -C / etc 2>/dev/null || warn "tar a signalé des avertissements"
  dpkg --get-selections >"$BACKUP_DIR/selections-$ts.txt"
  apt-mark showmanual >"$BACKUP_DIR/manual-$ts.txt"
  ok "Sauvegarde : $BACKUP_DIR/*-$ts.*"
}

reboot_check() {
  local need=0 newest
  if [[ -f /var/run/reboot-required ]]; then
    need=1
    [[ -f /var/run/reboot-required.pkgs ]] && info "Requis par : $(sort -u /var/run/reboot-required.pkgs | tr '\n' ' ')"
  fi
  newest=$(find /boot -maxdepth 1 -name 'vmlinuz-*' -printf '%f\n' 2>/dev/null | sed 's/^vmlinuz-//' | sort -V | tail -1)
  if [[ -n $newest && $newest != "$(uname -r)" ]]; then
    need=1; info "Noyau actif : $(uname -r) — installé : $newest"
  fi
  if (( need )); then
    warn "Un redémarrage est nécessaire."
    ask "Redémarrer maintenant" n && { log "Reboot"; systemctl reboot; exit 0; }
  else
    ok "Pas de redémarrage nécessaire."
  fi
  return 0
}

# ---------- mises à jour courantes ----------
routine_update() {
  preflight "$MIN_FREE_ROUTINE"
  info "Rafraîchissement des index APT"
  apt_get update

  local list n sec removals
  list=$(sim full-upgrade | awk '/^Inst /{print $2}')
  n=$(grep -c . <<<"$list" || true)
  if (( n == 0 )); then
    ok "Paquets APT à jour."
  else
    sec=$(sim full-upgrade | grep '^Inst ' | grep -ci security || true)
    info "$n paquet(s) à mettre à jour, dont $sec de sécurité :"
    printf '%s\n' "$list" >>"$LOG" 2>/dev/null || true
    column -c "$(tput cols 2>/dev/null || echo 100)" <<<"$list" 2>/dev/null || echo "$list"

    removals=$(sim full-upgrade | awk '/^Remv /{print $2}')
    if [[ -n $removals ]]; then
      warn "full-upgrade va SUPPRIMER : $(echo "$removals" | tr '\n' ' ')"
      if ask "Accepter les suppressions (sinon 'upgrade' simple)" n; then
        apt_get full-upgrade
      else
        apt_get upgrade
      fi
    elif ask "Appliquer les $n mise(s) à jour" o; then
      apt_get full-upgrade
    fi
  fi

  local orphans; orphans=$(sim autoremove | grep -c '^Remv ' || true)
  if (( orphans > 0 )) && ask "Supprimer $orphans paquet(s) orphelin(s) (autoremove --purge)" o; then
    apt_get autoremove --purge
  fi
  apt_get autoclean >/dev/null

  if command -v snap >/dev/null && snap list >/dev/null 2>&1; then
    ask "Rafraîchir les snaps" o && run_logged snap refresh
  fi
  if command -v flatpak >/dev/null; then
    ask "Mettre à jour les flatpaks" o && run_logged flatpak update -y
  fi
  reboot_check
}

# ---------- montée de version : commun ----------
major_prereqs() {
  (( ASSUME_YES )) && die "La montée de version majeure n'est pas disponible en mode -y."
  if [[ -n ${SSH_CONNECTION:-} ]] && ! in_multiplexer; then
    warn "Session SSH hors tmux/screen : une coupure pendant l'upgrade peut casser le système."
    ask "Continuer quand même (déconseillé)" n || { info "Relance dans : tmux new -s upgrade"; exit 0; }
  fi
  ask "As-tu un snapshot / une sauvegarde complète du serveur" n \
    || { warn "Fais un snapshot (VM/Proxmox) ou une sauvegarde avant de continuer."; exit 0; }
  preflight "$MIN_FREE_MAJOR"

  info "Mise à niveau de la version actuelle d'abord"
  apt_get update
  if (( $(pending_count) > 0 )); then
    warn "Des mises à jour sont en attente sur $OS_NAME."
    ask "Les appliquer maintenant (obligatoire)" o || die "Abandon : système pas à jour."
    apt_get full-upgrade
  fi
  if [[ -f /var/run/reboot-required ]]; then
    warn "Redémarrage requis avant la montée de version. Relance le script après."
    ask "Redémarrer maintenant" o && { systemctl reboot; exit 0; }
    die "Abandon : redémarrage requis."
  fi
  ok "$OS_NAME à jour."
}

# ---------- Ubuntu ----------
ubuntu_major() {
  command -v do-release-upgrade >/dev/null || apt_get install update-manager-core
  major_prereqs

  local cfg=/etc/update-manager/release-upgrades prompt
  prompt=$(awk -F= '/^Prompt=/{print $2}' "$cfg" 2>/dev/null || true)
  info "Politique d'upgrade actuelle : Prompt=${prompt:-?}  (lts = LTS→LTS, normal = version suivante)"
  if ! ask "Garder Prompt=${prompt:-?}" o; then
    local choice
    read -rp "Nouvelle valeur [lts/normal] : " choice </dev/tty
    [[ $choice == lts || $choice == normal ]] || die "Valeur invalide."
    sed -i "s/^Prompt=.*/Prompt=$choice/" "$cfg"; ok "Prompt=$choice"
  fi

  info "Recherche d'une nouvelle version"
  local dev=()
  if do-release-upgrade -c; then
    ok "Nouvelle version disponible."
  else
    warn "Aucune montée de version proposée officiellement pour l'instant."
    ask "Forcer avec -d (chemin pas encore ouvert / version de dev)" n || return 0
    dev=(-d)
  fi

  backup_etc

  local ufw_opened=0
  if [[ -n ${SSH_CONNECTION:-} ]] && command -v ufw >/dev/null && ufw status | grep -q '^Status: active'; then
    if ask "Ouvrir le port 1022/tcp dans ufw (sshd de secours pendant l'upgrade)" o; then
      ufw allow 1022/tcp comment 'do-release-upgrade' && ufw_opened=1
    fi
  fi

  ask "Lancer do-release-upgrade ${dev[*]} maintenant" n || return 0
  log "do-release-upgrade ${dev[*]} depuis $OS_NAME"
  do-release-upgrade "${dev[@]}" || warn "do-release-upgrade a retourné une erreur (voir /var/log/dist-upgrade/)."

  if (( ufw_opened )) && ask "Refermer le port 1022 dans ufw" o; then ufw delete allow 1022/tcp; fi
  info "Après reboot : vérifie les dépôts tiers désactivés dans /etc/apt/sources.list.d/"
}

# ---------- Debian ----------
debian_source_files() {
  local f
  [[ -f /etc/apt/sources.list ]] && echo /etc/apt/sources.list
  for f in /etc/apt/sources.list.d/*.list /etc/apt/sources.list.d/*.sources; do
    [[ -f $f ]] && echo "$f"
  done
  return 0
}

debian_major() {
  local next=${DEB_NEXT[$CODENAME]:-}
  [[ -n $next ]] || die "Pas de version suivante connue pour '$CODENAME'."
  info "Montée de version : $CODENAME → $next"

  if command -v curl >/dev/null; then
    local stable
    stable=$(curl -fsS --max-time 10 https://deb.debian.org/debian/dists/stable/Release 2>/dev/null \
             | awk '/^Codename:/{print $2}' || true)
    if [[ -n $stable && $stable == "$CODENAME" ]]; then
      warn "$next n'est pas encore la version stable (c'est actuellement testing)."
      ask "Continuer vers testing (déconseillé sur un serveur)" n || return 0
    fi
  fi

  major_prereqs
  backup_etc

  local ts sdir f
  ts=$(date +%F-%H%M%S); sdir="$BACKUP_DIR/apt-sources-$ts"
  mkdir -p "$sdir"; cp -a /etc/apt/sources.list* "$sdir/" 2>/dev/null || true
  ok "Sources APT sauvegardées dans $sdir"

  # Dépôts tiers : proposer de les désactiver
  while read -r f; do
    [[ $f == /etc/apt/sources.list ]] && continue
    grep -qE 'debian\.org' "$f" && continue
    warn "Dépôt tiers : $f"
    ask "Le désactiver pendant l'upgrade (renommé en .disabled)" o && mv "$f" "$f.disabled"
  done < <(debian_source_files)

  info "Remplacement de '$CODENAME' par '$next' dans les sources Debian"
  while read -r f; do
    grep -qE 'debian\.org' "$f" || continue
    sed -i "s/\b${CODENAME}\b/${next}/g" "$f"
    printf '%s--- %s%s\n' "$W" "$f" "$N"; grep -vE '^\s*(#|$)' "$f" || true
  done < <(debian_source_files)

  restore() {
    warn "Restauration des sources APT d'origine"
    rm -f /etc/apt/sources.list.d/*
    cp -a "$sdir"/. /etc/apt/
    apt_get update || true
  }

  ask "Les sources sont-elles correctes" o || { restore; return 0; }
  apt_get update || { restore; die "apt update a échoué avec les nouvelles sources."; }

  local n rm_count
  n=$(pending_count); rm_count=$(sim full-upgrade | grep -c '^Remv ' || true)
  info "$n paquet(s) à mettre à jour, $rm_count suppression(s) prévue(s)."
  if (( rm_count > 0 )); then
    sim full-upgrade | awk '/^Remv /{print "   - "$2}'
  fi
  ask "Lancer la montée de version vers $next" n || { restore; return 0; }

  log "Debian upgrade $CODENAME -> $next"
  info "Étape 1/2 : upgrade minimal (--without-new-pkgs)"
  apt_get upgrade --without-new-pkgs
  info "Étape 2/2 : full-upgrade"
  apt_get full-upgrade

  ask "Supprimer les paquets obsolètes (autoremove --purge)" o && apt_get autoremove --purge
  ok "Montée de version terminée. Pense à réactiver les dépôts tiers (*.disabled) en adaptant le codename."
  ask "Redémarrer maintenant (fortement recommandé)" o && { systemctl reboot; exit 0; }
  return 0
}

# ---------- état ----------
status() {
  info "Rafraîchissement des index"
  apt-get -qq "${APT_BASE[@]}" update || warn "apt update a échoué"
  local n sec
  n=$(pending_count)
  sec=$(sim full-upgrade | grep '^Inst ' | grep -ci security || true)
  printf '\n%sSystème%s     %s (%s)\n' "$W" "$N" "$OS_NAME" "$CODENAME"
  printf '%sNoyau%s       %s\n' "$W" "$N" "$(uname -r)"
  printf '%sUptime%s      %s\n' "$W" "$N" "$(uptime -p)"
  printf '%sEn attente%s  %s paquet(s), dont %s sécurité\n' "$W" "$N" "$n" "$sec"
  printf '%sDisque /%s    %s Mo libres\n' "$W" "$N" "$(free_mb /)"
  [[ -f /var/run/reboot-required ]] && printf '%sReboot%s      %srequis%s\n' "$W" "$N" "$Y" "$N"
  if [[ $OS_ID == ubuntu ]] && command -v do-release-upgrade >/dev/null; then
    printf '%sNouvelle version%s ' "$W" "$N"
    do-release-upgrade -c 2>/dev/null | grep -i 'new release' || echo "aucune proposée"
  elif [[ $OS_ID == debian ]]; then
    printf '%sVersion suivante%s %s\n' "$W" "$N" "${DEB_NEXT[$CODENAME]:-inconnue}"
  fi
  echo
}

major_upgrade() {
  case $OS_ID in
    ubuntu) ubuntu_major ;;
    debian) debian_major ;;
  esac
}

menu() {
  while true; do
    printf '\n%s%s%s\n' "$W" "$OS_NAME" "$N"
    echo "  1) Mises à jour courantes"
    echo "  2) Montée de version majeure"
    echo "  3) État du système"
    echo "  q) Quitter"
    read -rp "Choix : " c </dev/tty
    case $c in
      1) routine_update ;;
      2) major_upgrade ;;
      3) status ;;
      q|Q) exit 0 ;;
      *) warn "Choix invalide" ;;
    esac
  done
}

usage() { sed -n '2,10p' "$0" | sed 's/^# \{0,1\}//'; exit 0; }

# ---------- main ----------
main() {
  local action=menu
  while (( $# )); do
    case $1 in
      -u|--update) action=routine_update ;;
      -m|--major)  action=major_upgrade ;;
      -s|--status) action=status ;;
      -y|--yes)    ASSUME_YES=1 ;;
      -h|--help)   usage ;;
      *) die "Option inconnue : $1" ;;
    esac
    shift
  done
  need_root
  detect_os
  touch "$LOG" 2>/dev/null || true
  ensure_logrotate
  log "=== $0 $action (yes=$ASSUME_YES) sur $OS_NAME ==="
  "$action"
  log "=== Terminé ==="
}

main "$@"
