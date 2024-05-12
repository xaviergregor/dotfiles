# -*- mode: sh; -*-
# vim: set ft=sh :
# Dracula Theme v1.2.5
#
# https://github.com/dracula/dracula-theme
#
# Copyright 2019, All rights reserved
#
# Code licensed under the MIT license
# http://zenorocha.mit-license.org
#
# @author Zeno Rocha <hi@zenorocha.com>
# @maintainer Avalon Williams <avalonwilliams@protonmail.com>

# Initialization {{{
autoload -Uz add-zsh-hook
setopt PROMPT_SUBST
PROMPT=''
# }}}

# Options {{{
# Set to 0 to disable the git status
DRACULA_DISPLAY_GIT=${DRACULA_DISPLAY_GIT:-0}

# Set to 1 to show the date
DRACULA_DISPLAY_TIME=${DRACULA_DISPLAY_TIME:-1}

# Set to 1 to show the 'context' segment
DRACULA_DISPLAY_CONTEXT=${DRACULA_DISPLAY_CONTEXT:-1}

# Changes the arrow icon
DRACULA_ARROW_ICON=${DRACULA_ARROW_ICON:-🐧 }

# Set to 1 to use a new line for commands
DRACULA_DISPLAY_NEW_LINE=${DRACULA_DISPLAY_NEW_LINE:-0}

# Set to 1 to show full path of current working directory
DRACULA_DISPLAY_FULL_CWD=${DRACULA_DISPLAY_FULL_CWD:-1}

# time format string
if [[ -z "$DRACULA_TIME_FORMAT" ]]; then
	DRACULA_TIME_FORMAT="%-H:%M"
	# check if locale uses AM and PM
	if locale -ck LC_TIME 2>/dev/null | grep -q '^t_fmt="%r"$'; then
		DRACULA_TIME_FORMAT="%-I:%M%p"
	fi
fi
# }}}

# Status segment {{{
dracula_arrow() {
	if [[ "$1" = "start" ]] && (( ! DRACULA_DISPLAY_NEW_LINE )); then
		print -P "$DRACULA_ARROW_ICON"
	elif [[ "$1" = "end" ]] && (( DRACULA_DISPLAY_NEW_LINE )); then
		print -P "\n$DRACULA_ARROW_ICON"
	fi
}

# arrow is green if last command was successful, red if not, 
# turns yellow in vi command mode
PROMPT+='%(1V:%F{yellow}:%(?:%F{green}:%F{red}))%B$(dracula_arrow start)'
# }}}

# Time segment {{{
dracula_time_segment() {
	if (( DRACULA_DISPLAY_TIME )); then
		print -P "%D{$DRACULA_TIME_FORMAT} "
	fi
}

PROMPT+='%F{green}%B$(dracula_time_segment)'
# }}}

# User context segment {{{
dracula_context() {
	if (( DRACULA_DISPLAY_CONTEXT )); then
		if [[ -n "${SSH_CONNECTION-}${SSH_CLIENT-}${SSH_TTY-}" ]] || (( EUID == 0 )); then
			echo '%m '
		else
			echo '%m '
		fi
	fi
}

PROMPT+='%F{magenta}%B$(dracula_context)'
# }}}

# Directory segment {{{
dracula_directory() {
	if (( DRACULA_DISPLAY_FULL_CWD )); then
		print -P '%~ '
	else
		print -P '%c '
	fi
}

PROMPT+='%F{blue}%B$(dracula_directory)'
# }}}

# Custom variable {{{
custom_variable_prompt() {
	[[ -z "$DRACULA_CUSTOM_VARIABLE" ]] && return
	echo "%F{yellow}$DRACULA_CUSTOM_VARIABLE "
}

PROMPT+='$(custom_variable_prompt)'
# }}}

# Linebreak {{{
PROMPT+='%(1V:%F{yellow}:%(?:%F{green}:%F{red}))%B$(dracula_arrow end)'
# }}}

# define widget without clobbering old definitions
dracula_defwidget() {
	local fname=dracula-wrap-$1
	local prev=($(zle -l -L "$1"))
	local oldfn=${prev[4]:-$1}

	# if no existing zle functions, just define it normally
	if [[ -z "$prev" ]]; then
		zle -N $1 $2
		return
	fi

	# if already defined, return
	[[ "${prev[4]}" = $fname ]] && return
	
	oldfn=${prev[4]:-$1}

	zle -N dracula-old-$oldfn $oldfn

	eval "$fname() { $2 \"\$@\"; zle dracula-old-$oldfn -- \"\$@\"; }"

	zle -N $1 $fname
}

# ensure vi mode is handled by prompt
dracula_zle_update() {
	if [[ $KEYMAP = vicmd ]]; then
		psvar[1]=vicmd
	else
		psvar[1]=''
	fi

	zle reset-prompt
	zle -R
}

dracula_defwidget zle-line-init dracula_zle_update
dracula_defwidget zle-keymap-select dracula_zle_update

# Ensure effects are reset
PROMPT+='%f%b'
