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

[[ -s "/etc/grc.zsh" ]] && source /etc/grc.zsh

