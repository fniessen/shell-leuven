# Hey Emacs, this is a -*- sh -*- file
## bash_profile --- Bourne Again Shell configuration file (for interactive shells)

# Copyright (C) 2003-2020 Fabrice Niessen

# Author: Fabrice Niessen <(concat "fniessen" at-sign "pirilampo.org")>
# Keywords: bash, dotfile, config

# Code:

# If not running interactively, don't do anything.
# isInteractive=$(echo $- | grep i)
[[ "$-" != *i* ]] && return

# If running in terminal...
if test -t 1; then
    # ... start Zsh
    echo "Zsh"
    exec zsh
fi

# Allow local Shell customizations.
if [ -f "$HOME"/.shell_local_before ]; then
    . "$HOME"/.shell_local_before
fi

# Allow local Bash customizations.
if [ -f "$HOME"/.bashrc_local_before ]; then
    . "$HOME"/.bashrc_local_before
fi

# Colors.
BLK="\[$(tput setaf 0; tput bold)\]"
RED="\[$(tput setaf 1; tput bold)\]"
grn="\[$(tput setaf 2)\]"
GRN="\[$(tput setaf 2; tput bold)\]"
yel="\[$(tput setaf 3)\]"
reset_color="\[$(tput sgr0)\]"

# PROMPT_COMMAND + PS1 --- Default interaction prompt

# + PROMPT='${ret_status}%{$fg_bold[green]%}%p %{$fg[cyan]%}%c %{$fg_bold[blue]%}$(git_prompt_info)$(branch_prompt_info)%{$fg_bold[blue]%} % %{$reset_color%}'


# To be called just before the prompt is printed.
leuven-before-prompt() {
    RET_STATUS=$?

    # Set a color prompt (unless in Emacs).
    case $TERM in
        cygwin|xterm*|rxvt-unicode)
            # `M-x shell' under Cygwin Emacs.
            # `M-x term' under Cygwin Emacs.
            local color_prompt=yes
            ;;
        emacs)
            # `M-x shell' under EmacsW32.
            local color_prompt=no
            ;;
    esac

    # Colorful prompt, based on whether the previous command succeeded or not.
    if [[ $RET_STATUS -eq 0 ]]; then
        HILIT_RET_STATUS=$GRN
    else
        HILIT_RET_STATUS=$RED
    fi

    # Replace the `$HOME' prefix by `~' in the current directory.
    if [[ "$HOME" = "${PWD:0:${#HOME}}" ]]; then
        local myPWD="~${PWD:${#HOME}}"
    else
        local myPWD=$PWD
    fi

    # How many characters of the path should be kept.
    local pwd_max_length=15

    if [[ ${#myPWD} -gt $pwd_max_length ]]; then
        local pwd_offset=$(( ${#myPWD} - pwd_max_length ))
        myPWD="...${myPWD:$pwd_offset:$pwd_max_length}"
    fi

    # Prompt character.
    if [[ $EUID -eq 0 ]]; then
        local PROMPT_CHAR="#"
    else
        local PROMPT_CHAR="$"
    fi

    if [[ "$color_prompt" = "yes" ]]; then
        PS1="$grn\u@\h$BLK:${reset_color}$yel$myPWD${HILIT_RET_STATUS} $RET_STATUS${reset_color}$PROMPT_CHAR "
    else
        PS1="\u@\h:$myPWD $RET_STATUS$PROMPT_CHAR "
    fi
}

# Execute the content of the `PROMPT_COMMAND' just before displaying the `PS1'
# variable.
case "$TERM" in
    "dumb")
        # No fancy multi-line prompt for TRAMP (see `tramp-terminal-type').
        # Don't confuse it!
        PS1="> "
        ;;
    *)
        PROMPT_COMMAND=leuven-before-prompt
        ;;
esac

# PS4 --- Used by "set -x" to prefix tracing output

# Get line numbers when you run with `-x'.
PS4='+'$grn'[$0:$LINENO]+ '${reset_color}

# Automatically cd into a  directory without the `cd' in front of it.
shopt -s autocd

# Correct dir spellings.
shopt -s cdspell

# Make sure display get updated when terminal window get resized.
shopt -q -s checkwinsize

# Append rather than overwrite history.
shopt -s histappend

# Make multi-line commandsline in history.
shopt -q -s cmdhist

# Store 10000 commands in history buffer.
export HISTSIZE=10000

# Store 10000 commands in history FILE.
export HISTFILESIZE=10000

# Avoid recording common commands (like ls, top and clear).
export HISTIGNORE=”ls*:top:clear”

# Ignore duplicate commands and commands starting with space.
export HISTCONTROL=ignoreboth           # Prefix a command with a space to keep it out of the history.

complete -A helptopic help
complete -A hostname ssh telnet nmap ftp ping host traceroute nslookup

bind '"\eh": "\C-a\eb\ed\C-y\e#man \C-y\C-m\C-p\C-p\C-a\C-d\C-e"'

# Allow local Bash customizations.
if [ -f "$HOME"/.bashrc_local_after ]; then
    . "$HOME"/.bashrc_local_after
fi

# Allow local Shell customizations.
if [ -f "$HOME"/.shell_local_after ]; then
    . "$HOME"/.shell_local_after
fi
