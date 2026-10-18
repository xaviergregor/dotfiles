#!/usr/bin/env bash
# install.sh — installation interactive des dotfiles (macOS / Debian / Ubuntu)
#
# Usage : make install            liste interactive des étapes
#         make install YES=1      tout ce qui manque, sans question
#         make install DRY=1      affiche les commandes sans les exécuter
#         scripts/install.sh --step links   une seule étape
#
# Compatible bash 3.2 (bash par défaut de macOS).

set -o pipefail

DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"
ASSUME_YES=0
DRY=0
ONLY=""
export CHSH=no   # Oh My Zsh ne change pas le shell lui-même, on le propose à la fin

usage() { sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//'; exit 0; }

while [ $# -gt 0 ]; do
  case $1 in
    -y|--yes)     ASSUME_YES=1 ;;
    -n|--dry-run) DRY=1 ;;
    --step)       ONLY=$2; shift ;;
    -h|--help)    usage ;;
    *) echo "Option inconnue : $1" >&2; exit 2 ;;
  esac
  shift
done

# ---------- affichage ----------
if [[ -t 1 ]]; then
  B=$'\e[34m' G=$'\e[32m' Y=$'\e[33m' R=$'\e[31m' D=$'\e[2m' W=$'\e[1m' N=$'\e[0m'
else
  B='' G='' Y='' R='' D='' W='' N=''
fi
info() { printf '\n%s==>%s %s\n' "$B" "$N" "$*"; }
ok()   { printf '%s ✔%s %s\n' "$G" "$N" "$*"; }
warn() { printf '%s ⚠%s %s\n' "$Y" "$N" "$*"; }
err()  { printf '%s ✖%s %s\n' "$R" "$N" "$*" >&2; }
pretty() { local p=$1; [[ $p == "$HOME"* ]] && p="~${p#"$HOME"}"; printf '%s' "$p"; }

# ask "question" [o|n] -> 0 si oui
ask() {
  local a hint="o/N"
  [[ ${2:-n} == o ]] && hint="O/n"
  read -rp "$(printf '%s? %s%s [%s] ' "$W" "$1" "$N" "$hint")" a </dev/tty || a=
  a=${a:-${2:-n}}
  [[ $a == [oOyY]* ]]
}

# Exécute la commande, ou l'affiche seulement en mode DRY
run() {
  if (( DRY )); then printf '   %s$ %s%s\n' "$D" "$*" "$N"; return 0; fi
  "$@"
}
mk()    { run make --no-print-directory -C "$DOTFILES" "$@"; }
mkvar() { make -s --no-print-directory -C "$DOTFILES" "print-$1"; }

# ---------- détection du système ----------
OS="" DISTRO="" OS_LABEL=""
case $(uname -s) in
  Darwin)
    OS=mac
    OS_LABEL="macOS $(sw_vers -productVersion 2>/dev/null) ($(uname -m))"
    ;;
  Linux)
    OS=linux
    OS_LABEL="Linux ($(uname -m))"
    if [[ -r /etc/os-release ]]; then
      # shellcheck disable=SC1091
      . /etc/os-release
      case " ${ID:-} ${ID_LIKE:-} " in
        *" ubuntu "*) DISTRO=ubuntu ;;
        *" debian "*) DISTRO=debian ;;
      esac
      OS_LABEL="${PRETTY_NAME:-Linux} ($(uname -m))"
    fi
    ;;
  *) err "Système non supporté : $(uname -s)"; exit 1 ;;
esac

# Homebrew n'est pas forcément dans le PATH (Apple Silicon, ou juste installé)
load_brew() {
  command -v brew >/dev/null 2>&1 && return 0
  local b
  for b in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    [[ -x $b ]] && { eval "$("$b" shellenv)"; return 0; }
  done
  return 1
}

# ---------- étapes ----------
if [[ $OS == mac ]]; then
  STEPS=(brew brewfile ohmyzsh zshplugins vimplug tpm links prefs)
else
  STEPS=(apt ohmyzsh zshplugins vimplug tpm links)
fi

is_optional() { [[ $1 == prefs ]]; }

label() {
  case $1 in
    brew)       echo "Homebrew" ;;
    brewfile)   echo "Paquets du Brewfile" ;;
    apt)        echo "Paquets apt (${DISTRO:-?})" ;;
    ohmyzsh)    echo "Oh My Zsh" ;;
    zshplugins) echo "Plugins zsh" ;;
    vimplug)    echo "vim-plug" ;;
    tpm)        echo "TPM (tmux)" ;;
    links)      echo "Liens symboliques" ;;
    prefs)      echo "Préférences macOS" ;;
  esac
}

# Liens : source (dans le dépôt) | destination
link_pairs() {
  echo ".zshrc|$HOME/.zshrc"
  echo ".vimrc|$HOME/.vimrc"
  echo ".tmux.conf|$HOME/.tmux.conf"
  echo "config/htop/htoprc|$HOME/.config/htop/htoprc"
  echo "config/ghostty/config|$HOME/.config/ghostty/config"
  if [[ $OS == mac ]]; then echo "Brewfile|$HOME/Brewfile"; fi
}

# check_<étape> : remplit STATUS, retourne 0 si déjà fait
check_brew() {
  if load_brew; then STATUS="déjà installé"; return 0; fi
  STATUS="absent"; return 1
}
check_brewfile() {
  load_brew || { STATUS="nécessite Homebrew"; return 1; }
  if brew bundle check --file="$DOTFILES/Brewfile" --no-upgrade >/dev/null 2>&1; then
    STATUS="tout est installé"; return 0
  fi
  local n
  n=$(brew bundle check --file="$DOTFILES/Brewfile" --no-upgrade --verbose 2>/dev/null | grep -c 'needs to be installed')
  STATUS="${n:-?} manquant(s)"; return 1
}
check_apt() {
  [[ -n $DISTRO ]] || { STATUS="distribution non reconnue (Debian/Ubuntu seulement)"; return 1; }
  local p missing=""
  for p in $(mkvar APT_PKGS); do
    dpkg-query -W -f='${Status}' "$p" 2>/dev/null | grep -q 'ok installed' || missing="$missing $p"
  done
  [[ -z $missing ]] && { STATUS="tout est installé"; return 0; }
  STATUS="manquants :$missing"; return 1
}
check_ohmyzsh() {
  [[ -d $HOME/.oh-my-zsh ]] && { STATUS="déjà installé"; return 0; }
  STATUS="absent"; return 1
}
check_zshplugins() {
  local zc p missing=""
  zc=$(mkvar ZSH_CUSTOM)
  for p in $(mkvar ZSH_PLUGINS); do
    [[ -d $zc/plugins/$p ]] || missing="$missing $p"
  done
  [[ -z $missing ]] && { STATUS="déjà installés"; return 0; }
  STATUS="manquants :$missing"; return 1
}
check_vimplug() {
  [[ -f $HOME/.vim/autoload/plug.vim ]] && { STATUS="déjà installé"; return 0; }
  STATUS="absent"; return 1
}
check_tpm() {
  [[ -d $HOME/.tmux/plugins/tpm ]] && { STATUS="déjà installé"; return 0; }
  STATUS="absent"; return 1
}
check_links() {
  local src dst bad=0 first=""
  while IFS='|' read -r src dst; do
    if [[ -L $dst && $(readlink "$dst") == "$DOTFILES/$src" ]]; then continue; fi
    bad=$((bad + 1))
    if [[ -z $first ]]; then
      if [[ -L $dst ]]; then first="$(pretty "$dst") pointe ailleurs"
      elif [[ -e $dst ]]; then first="$(pretty "$dst") est un fichier (sera sauvegardé)"
      fi
    fi
  done < <(link_pairs)
  (( bad == 0 )) && { STATUS="à jour"; return 0; }
  STATUS="$bad à créer${first:+, $first}"; return 1
}
check_prefs() { STATUS="optionnel, réglages système"; return 1; }

# run_<étape>
run_brew()       { mk brew && { (( DRY )) || load_brew; }; }
run_brewfile() {
  if ! load_brew && (( ! DRY )); then err "Homebrew introuvable"; return 1; fi
  run brew bundle --file="$DOTFILES/Brewfile"
}
run_apt() {
  [[ -n $DISTRO ]] || { err "Distribution non reconnue"; return 1; }
  mk "$DISTRO"
}
run_ohmyzsh() {
  if [[ -d $HOME/.oh-my-zsh ]]; then ok "déjà installé (mise à jour : omz update)"; return 0; fi
  mk shell
}
run_zshplugins() { mk zsh-plugins; }
run_vimplug()    { mk vim; }
run_tpm()        { mk tmux; }
run_prefs()      { mk prefs-mac; }
run_links() {
  local src dst ts rc=0
  ts=$(date +%Y%m%d-%H%M%S)
  while IFS='|' read -r src dst; do
    src="$DOTFILES/$src"
    if [[ -L $dst && $(readlink "$dst") == "$src" ]]; then
      printf '   %s%s déjà lié%s\n' "$D" "$(pretty "$dst")" "$N"; continue
    fi
    [[ -d $(dirname "$dst") ]] || run mkdir -p "$(dirname "$dst")" || { rc=1; continue; }
    if [[ -e $dst && ! -L $dst ]]; then
      run mv "$dst" "$dst.bak-$ts" && warn "$(pretty "$dst") sauvegardé en $(pretty "$dst.bak-$ts")"
    fi
    if run ln -snf "$src" "$dst"; then
      ok "$(pretty "$dst") → dotfiles/${src#"$DOTFILES"/}"
    else
      rc=1
    fi
  done < <(link_pairs)
  return $rc
}

# ---------- après installation ----------
login_shell() {
  local u=${USER:-$(id -un)}
  if [[ $OS == mac ]]; then
    dscl . -read "/Users/$u" UserShell 2>/dev/null | awk '{print $2}'
  else
    getent passwd "$u" | cut -d: -f7
  fi
}

post_install() {
  local selected=" $* "

  if [[ $selected == *" vimplug "* || $selected == *" links "* ]] \
     && [[ -f $HOME/.vim/autoload/plug.vim && -L $HOME/.vimrc ]] && command -v vim >/dev/null; then
    info "Plugins vim"
    # Le 1er lancement échoue forcément (colorscheme pas encore téléchargé) :
    # on juge sur un 2e lancement, une fois les plugins installés.
    run vim -E -s -u "$HOME/.vimrc" +PlugInstall +qall </dev/null
    if (( DRY )) || vim -E -s -u "$HOME/.vimrc" +qall </dev/null; then ok "Plugins vim installés"
    else warn "vim signale encore une erreur : relance :PlugInstall dans vim"; fi
  fi

  if [[ $selected == *" tpm "* || $selected == *" links "* ]] \
     && [[ -x $HOME/.tmux/plugins/tpm/bin/install_plugins && -L $HOME/.tmux.conf ]] && command -v tmux >/dev/null; then
    info "Plugins tmux"
    if run "$HOME/.tmux/plugins/tpm/bin/install_plugins" >/dev/null; then ok "Plugins tmux installés"
    else warn "Échec : dans tmux, fais prefix + I"; fi
  fi

  local cur z
  cur=$(login_shell)
  if [[ ${cur##*/} != zsh ]] && command -v zsh >/dev/null; then
    if [[ $OS == mac ]]; then z=/bin/zsh; else z=$(command -v zsh); fi
    info "Shell par défaut : ${cur:-inconnu}"
    if (( ASSUME_YES )); then
      warn "Pour passer à zsh : chsh -s $z"
    elif ask "Passer à zsh ($z)" o; then
      grep -qx "$z" /etc/shells || run sudo sh -c "echo '$z' >> /etc/shells"
      run chsh -s "$z" && ok "Shell par défaut : $z (effectif à la prochaine connexion)"
    fi
  fi
}

# ---------- exécution d'une liste d'étapes ----------
DONE_OK="" DONE_FAIL=""
run_steps() {
  local s
  for s in "$@"; do
    info "$(label "$s")"
    if "run_$s"; then DONE_OK="$DONE_OK $s"; else DONE_FAIL="$DONE_FAIL $s"; err "$(label "$s") : échec"; fi
  done
}

summary() {
  local s
  info "Résumé"
  for s in $DONE_OK;   do ok "$(label "$s")"; done
  for s in $DONE_FAIL; do err "$(label "$s")"; done
  if [[ " $DONE_OK " == *" links "* || " $DONE_OK " == *" zshplugins "* ]]; then
    echo; echo "Ouvre un nouveau terminal (ou : exec zsh) pour charger la config."
  fi
  (( DRY )) && echo && warn "Mode DRY : rien n'a été exécuté."
  [[ -z $DONE_FAIL ]]
}

# ---------- main ----------

# Une seule étape (utilisé par make link / mac / linux)
if [[ -n $ONLY ]]; then
  declare -F "run_$ONLY" >/dev/null || { err "Étape inconnue : $ONLY"; exit 2; }
  "run_$ONLY"
  exit $?
fi

printf '%s==>%s %s détecté\n' "$B" "$N" "$OS_LABEL"
[[ $OS == linux && -z $DISTRO ]] && warn "Distribution non reconnue : l'étape apt sera indisponible."
(( DRY )) && warn "Mode DRY : les commandes seront affichées, pas exécutées."
echo; printf '%sAnalyse de ce qui est déjà en place…%s\n\n' "$D" "$N"

DEFAULT=""
i=1
for s in "${STEPS[@]}"; do
  if "check_$s"; then
    mark="${G}✓${N}"; st="${D}${STATUS}${N}"
  else
    mark=" "; st=$STATUS
    is_optional "$s" || DEFAULT="$DEFAULT $i"
  fi
  l=$(label "$s")
  printf '  [%s] %d. %s%*s %s\n' "$mark" "$i" "$l" $((22 - ${#l})) "" "$st"
  i=$((i + 1))
done
TOTAL=$((i - 1))
DEFAULT=${DEFAULT# }
echo

if [[ -z $DEFAULT ]] && (( ASSUME_YES )); then
  ok "Tout est déjà en place."; exit 0
fi

if (( ASSUME_YES )); then
  reply=$DEFAULT
else
  while true; do
    read -rp "$(printf '%sÉtapes à lancer ?%s [Entrée = %s | a = tout | q = quitter] : ' \
      "$W" "$N" "${DEFAULT:-rien}")" reply </dev/tty || exit 1
    case $reply in
      q|Q) exit 0 ;;
      a|A) reply=$(seq -s ' ' 1 "$TOTAL"); break ;;
      "")  reply=$DEFAULT; break ;;
    esac
    reply=${reply//,/ }
    valid=1
    for n in $reply; do
      if ! [[ $n =~ ^[0-9]+$ ]] || (( n < 1 || n > TOTAL )); then
        warn "Choix invalide : $n (1 à $TOTAL)"; valid=0
      fi
    done
    (( valid )) && break
  done
fi

[[ -z $reply ]] && { ok "Rien à faire."; exit 0; }

# Étapes choisies, dans l'ordre de la liste (doublons ignorés)
SELECTED=()
i=1
for s in "${STEPS[@]}"; do
  for n in $reply; do
    if (( n == i )); then SELECTED+=("$s"); break; fi
  done
  i=$((i + 1))
done

run_steps "${SELECTED[@]}"
post_install "${SELECTED[@]}"
summary
