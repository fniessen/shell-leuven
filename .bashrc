# Hey Emacs, this is a -*- sh -*- file
## bash_profile --- Bash configuration file (for interactive shells)

# Copyright (C) 2003-2023 Fabrice Niessen

# Author: Fabrice Niessen <(concat "fniessen" at-sign "pirilampo.org")>
# Keywords: bash, dotfile, config

# Code:

# If not running interactively, don't do anything.
# isInteractive=$(echo $- | grep i)
[[ "$-" != *i* ]] && return

# # If running in terminal...
# if test -t 1; then
#     # ... start Zsh
#     echo "Start Zsh..."
#     exec zsh
# fi

# Allow local Shell customizations.
if [ -f "$HOME"/.shellrc_local_before ]; then
    . "$HOME"/.shellrc_local_before
fi

# Allow local Bash customizations.
if [ -f "$HOME"/.bashrc_local_before ]; then
    . "$HOME"/.bashrc_local_before
fi

git_info_msg() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
     # git branch 2> /dev/null | grep '^*' | colrm 1 2
}

# Colors.
BLK="\[$(tput setaf 0; tput bold)\]"
RED="\[$(tput setaf 1; tput bold)\]"
grn="\[$(tput setaf 2)\]"
GRN="\[$(tput setaf 2; tput bold)\]"
yel="\[$(tput setaf 3)\]"
reset_color="\[$(tput sgr0)\]"

# PS1 --- Default interaction prompt

case "$TERM" in
    "dumb")
        # No fancy multi-line prompt for TRAMP (see `tramp-terminal-type').
        # Don't confuse it!
        PS1="\n> "
        ;;
    cygwin|xterm*|rxvt-unicode)
        # `M-x shell' under Cygwin Emacs.
        # `M-x term' under Cygwin Emacs.
        BEL=$(tput bel)
        PS1='\[\033]0;Bash $PWD\007\]\n\
$(st=$?; if [[ $st -eq 0 ]]; then printf "\[\033[01;32m\]"; else printf "\[\033[01;31m\]$BEL\\u00d7 $st "; fi)\
\[\033[0;34m\]\u@\h\
\[\033[1;30m\]:\
\[\033[0;33m\]\w\
\[\033[36m\]`git_info_msg`\
\[\033[1;32m\]>\[\033[0m\] '

# PS1='\[\033]0;$TITLEPREFIX:$PWD\007\]\n\[\033[32m\]\u@\h \[\033[35m\]$MSYSTEM \[\033[33m\]\w\[\033[36m\]`git_info_msg`\[\033[0m\]\n$ '


        ;;
    *) # emacs
        # `M-x shell' under EmacsW32.
        PS1="\n$?\u@\h:\w \$ "
        ;;
esac
# PS1+='$(if test $? -ne 0; then tput bel; fi)'

export PS2="incomplete? continue here-> "

# PS4 --- Used by "set -x" to prefix tracing output

# Get line numbers when you run with `-x'.
PS4='+'$grn'[$0:$LINENO]+ '${reset_color}

# M-h: run-help.
bind '"\eh": "\C-a\eb\ed\C-y\e#man \C-y\C-m\C-p\C-p\C-a\C-d\C-e"'

# Ignore case while completing filenames.
bind "set completion-ignore-case on"

# Treat hypens and underscores as the same if completion-ignore-case is on.
bind "set completion-map-case on"

complete -A helptopic help
complete -A hostname ssh telnet nmap ftp ping host traceroute nslookup

# When entering a directory, push it to the directory stack and list its
# contents.
cd() {
    builtin pushd "$@" > /dev/null      # = setopt auto_pushd, in Zsh.
    dirs_remove_dups                    # = setopt pushd_ignore_dups, in Zsh.
    ls --color=auto -F
}

# Remove dups.
dirs_remove_dups() {
    declare -a new=() copy=("${DIRSTACK[@]:1}")
    declare -A seen
    local v i
    seen[$PWD]=1
    for v in "${copy[@]}"; do
        if [ -z "${seen[$v]}" ]; then
            new+=("$v")
            seen[$v]=1
        fi
    done
    dirs -c
    for ((i=${#new[@]}-1; i>=0; i--)); do
        builtin pushd -n "${new[i]}" > /dev/null
    done
}

# Allow Meta (Alt) key bindings [line added to the top of my `.inputrc'].
bind "set convert-meta on"

# Don't strip characters to 7 bits when reading (permit UTF-8).
bind "set input-meta on"

# Denote symlinks to directories with an appended slash.
bind "set mark-symlinked-directories on"

# Do not autocomplete hidden files unless the pattern begins with a dot.
bind "set match-hidden-files off"

# Display characters with the 8th bit set directly rather than as meta-prefixed
# characters (permit UTF-8).
bind "set output-meta on"

# # Show all autocomplete results at once instead of via the internal pager.
# bind "set page-completions off"

# Make first press of TAB list all matches (in case multiple possible
# completions are possible).
bind "set show-all-if-ambiguous on"

# bind "set menu-complete-display-prefix on"


bind "set show-all-if-unmodified on"

# Color the common prefix
bind "set colored-completion-prefix on"

# Color the common prefix in menu-complete
bind "set menu-complete-display-prefix on"

# Note that this may cause completion text blink in some terminals (e.g. xterm).
bind "set colored-stats on"


# Factor any text after the cursor position into completion matching.
bind "set skip-completed-text on"

# Show extra file information when completing similar to `ls -F`.
bind "set visible-stats off"

# Automatically cd into a  directory without the `cd' in front of it.
shopt -s autocd

# Correct dir spellings.
shopt -s cdspell

# Make sure display get updated when terminal window get resized.
shopt -q -s checkwinsize

# When running two Bash windows, allow both to write to the history.
shopt -s histappend

# Make multi-line commands 1 line in history.
shopt -q -s cmdhist

# Store 10,000 commands in history.
export HISTSIZE=10000
export HISTFILESIZE=$HISTSIZE

# Print full time-date stamps in ISO8601 `yyyy-mm-dd hh:mm' format.
export HISTTIMEFORMAT="%y-%m-%d %H:%M  "

# Blacklist - Avoid recording common commands (like ls, top and clear).
export HISTIGNORE="ls*:top:clear"

# Ignore duplicate commands and commands starting with spaces.
HISTCONTROL=ignoreboth:erasedups

alias h="history"

# Set <C-left/right> to move by whole words.
bind '"\e[1;5C": forward-word'
bind '"\e[1;5D": backward-word'

# Very nice history search.  Type text (as prefix) and hit up <up/down> to
# search witin command history (no C-r required).
bind '"\e[B": history-search-forward'
bind '"\e[A": history-search-backward'

# Set Delete/Insert keys to delete/insert chars on line
bind '"\e[3~": delete-char'
bind '"\e[2~": quoted-insert'

# Make each subsequent press of TAB cycle through matches.
bind '"\t": menu-complete'

bind '"\ep": "\C-e | less\C-m"'

bind '"\es": "\C-asudo \C-e\C-m"'

bind '"\e?": "\C-awhich \C-m"' # TODO: Ré-écire cmd sur la ligne suivante
# See this example: bind '"\eh": "\C-a\eb\ed\C-y\e#man \C-y\C-m\C-p\C-p\C-a\C-d\C-e"'

bind '"\ee": edit-and-execute-command'
bind '"\ev": edit-and-execute-command'
# Same as C-x C-e.

# C-M-u: up-directory
bind '"\e\C-u": "cd ..\n"'

# Common configuration.
if [ -f "$HOME"/.shellrc ]; then
    . "$HOME"/.shellrc
fi

# Allow local Bash customizations.
if [ -f "$HOME"/.bashrc_local_after ]; then
    . "$HOME"/.bashrc_local_after
fi

# Allow local Shell customizations.
if [ -f "$HOME"/.shellrc_local_after ]; then
    . "$HOME"/.shellrc_local_after
fi
