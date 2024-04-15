# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themesi
precmd() { print "" }

# Check if the current user is root
if [[ $UID -eq 0 ]]; then
    # Set the prompt color to red for the root user

    PROMPT="%B%F{cyan}%T%f%b  %B%F{red}%n%f%b%F{10}@%f%B%F{cyan}%m%f%b: %F{10}%~%f "
else
    # Set the prompt color to your desired color for non-root users

    PROMPT="%B%F{cyan}%T%f%b  %B%F{10}%n%f%b%F{10}@%f%B%F{cyan}%m%f%b: %F{10}%~%f "
fi

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
git
git-prompt
web-search
zsh-autosuggestions
zsh-completions
zsh-syntax-highlighting
colored-man-pages
)

autoload -U compinit && compinit # reload completions for zsh-completions

source $ZSH/oh-my-zsh.sh

# Colorize autosuggest
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=5'
export CLICOLORS=1

# PATH custom
export PATH="$HOME/go/bin:$PATH"
export PATH="/sbin:$PATH"

# EDITOR ViM

# alias
if $(which eza > /dev/null 2>&1); then
  alias ls='eza --icons -lgH --color=always'
  alias l='eza --icons -lgH --color=always'
  alias ll='eza --icons -lgH -a --color=always'
  alias l.='eza -d --icons .* --color=always'
else
	alias ll='ls -hlF --color=auto'
	alias ls='ls -hlF --color=auto'
	alias l='ls --color=auto'
	alias l.='ls -d .* --color=auto'
fi

alias c='clear'
alias grep='grep --color=auto'
alias cat='bat -pp'
alias ping='grc ping'
alias ip='grc ip'

# alias SSH
alias ssh cyberlab='ssh 100.127.128.43'
alias ssh dhcp='ssh 100.94.187.77'
alias ssh docker='ssh 100.77.157.120'
alias ssh homebridge='100.70.251.40'
alias ssh mqtt='100.97.126.63'
alias nas-xavier='100.73.77.29'
alias ssh partage='ssh 100.76.3.94'
alias ssh pihole='ssh 100.114.146.127'
alias ssh pivpn='ssh 100.97.233.35'
alias ssh pve='ssh root@100.84.18.36'
alias ssh smbshare='ssh 100.82.84.14'
alias ssh ubuntu-oracle='ssh 100.96.164.127'
alias ssh unify='ssh 100.106.4.18'
alias ssh xmini='ssh 100.99.100.87'
alias zerocool='ssh 100.96.227.99'

[[ -s "/etc/grc.zsh" ]] && source /etc/grc.zsh

