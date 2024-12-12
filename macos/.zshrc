# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themesi
precmd() { print "" }
PROMPT="%B%F{cyan}%T%f%b %B%F{green}%m%f%b %B%F{cyan}→%f%b %B%F{green}%~%f%b "

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
brew
git
git-prompt
macos 
grc
sudo
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

# PATH custom
export PATH="/usr/local/sbin:$PATH"

#EDITOR ViM
export EDITOR="vim"

#alias
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

if $(which bat > /dev/null 2>&1); then
  alias cat='bat -pp'
fi

alias c='clear'
alias ansiweather='ansiweather -l "Mauguio,FR" -H true -s true -d true'
alias cheat='cheat -c'
alias grep='grep --color=auto'
alias geoip='/opt/homebrew/bin/geoip.bash'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

test -e /Users/xavier/.iterm2_shell_integration.zsh && source /Users/xavier/.iterm2_shell_integration.zsh || true

# Created by `pipx` on 2024-08-19 13:05:35
export PATH="$PATH:/Users/xavier/.local/bin"
