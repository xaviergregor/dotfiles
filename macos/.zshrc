# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themesi
precmd() { print "" }
#PROMPT="%B%F{cyan}%T%f%b  %B%F{10}%n%f%b%F{10}@%f%B%F{cyan}%m%f%b: %F{10}%~%f "
PROMPT="%B%F{cyan}%T%f%b 🦖 %B%F{green}%m%f%b %F{cyan}→%f %B%F{green}%~%f%b "

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
#export GOPATH=$HOME/work
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
export PATH="/opt/homebrew/Cellar/john-jumbo/1.9.0_1/share/john/:$PATH"
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

alias c='clear'
alias ansiweather='ansiweather -l "Mauguio,FR" -H true -s true -d true'
alias cheat='cheat -c'
alias grep='grep --color=auto'
alias cat='bat -pp'
alias geoip='/opt/homebrew/bin/geoip.bash'

test -e /Users/xavier/.iterm2_shell_integration.zsh && source /Users/xavier/.iterm2_shell_integration.zsh || true
