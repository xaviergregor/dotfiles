# ~/.zshrc — commun macOS / Linux

# ---------------------
# Oh My Zsh
# ---------------------
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""   # prompt défini plus bas, pas besoin de charger un thème

plugins=(
  git
  git-prompt   # statut git dans le prompt de droite (RPROMPT)
  grc
  sudo
  web-search
  colored-man-pages
  zsh-autosuggestions
)
[[ $OSTYPE == darwin* ]] && plugins=(brew macos $plugins)
plugins+=(zsh-syntax-highlighting)   # doit rester en dernier

# zsh-completions : ajouté au fpath, Oh My Zsh lance compinit une seule fois
fpath+=(${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-completions/src)

source $ZSH/oh-my-zsh.sh

# ---------------------
# Prompt (hôte en rouge pour root)
# ---------------------
autoload -Uz add-zsh-hook
_blank_line() { print "" }
add-zsh-hook precmd _blank_line
PROMPT=" %B%F{cyan}%T%f%b %B%(!.%F{red}.%F{green})%m%f%b %B%F{cyan}→%f%b %B%F{green}%~%f%b "

# Colorize autosuggest
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=5'

# ---------------------
# PATH
# ---------------------
typeset -U path   # pas de doublons
path=("$HOME/.local/bin" $path)
[[ -d $HOME/go/bin ]]        && path=("$HOME/go/bin" $path)
[[ -d $HOME/.mammouth/bin ]] && path=("$HOME/.mammouth/bin" $path)   # Mammouth Code
if [[ $OSTYPE == darwin* ]]; then
  [[ -d /usr/local/sbin ]] && path=(/usr/local/sbin $path)
else
  path+=(/sbin /usr/sbin)
fi

export EDITOR="vim"

# ---------------------
# Aliases
# ---------------------
if (( $+commands[eza] )); then
  alias ls='eza --icons -lgH --color=auto'
  alias l='eza --icons -lgH --color=auto'
  alias ll='eza --icons -lgH -a --color=auto'
  alias l.='eza -d --icons .* --color=auto'
else
  alias ll='ls -hlF --color=auto'
  alias ls='ls -hlF --color=auto'
  alias l='ls --color=auto'
  alias l.='ls -d .* --color=auto'
fi

# bat s'appelle batcat sur Debian/Ubuntu
if (( $+commands[bat] )); then
  alias cat='bat --theme ansi -pp'
elif (( $+commands[batcat] )); then
  alias cat='batcat --theme ansi -pp'
fi

alias c='clear'
alias grep='grep --color=auto'
alias dot='cd $HOME/dotfiles'
alias ff='fastfetch'
alias gtboo='ghostty +boo'
#alias rm='rm -i'
#alias cp='cp -i'
#alias mv='mv -i'

if [[ $OSTYPE == darwin* ]]; then
  export CLICOLOR=1
  alias ansiweather='ansiweather -l "Mauguio,FR" -H true -s true -d true -a false -i true -w true -h true -p true'
  alias cheat='cheat -c'
  [[ -x /opt/homebrew/bin/geoip.bash ]] && alias geoip='/opt/homebrew/bin/geoip.bash'
  alias scl='cd $HOME/SynologyDrive/Clients'
  alias scl.='open $HOME/SynologyDrive/Clients'
  alias hd='http --download'
fi

# ---------------------
# eza universal Dracula
# ---------------------
export EZA_COLORS="\
uu=36:\
uR=31:\
un=35:\
gu=37:\
da=2;34:\
ur=34:\
uw=95:\
ux=36:\
ue=36:\
gr=34:\
gw=35:\
gx=36:\
tr=34:\
tw=35:\
tx=36:\
xx=95:"
