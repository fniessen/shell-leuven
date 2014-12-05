## .zshrc --- Z Shell configuration file (for interactive shells)

# Copyright (C) 2009-2014 Fabrice Niessen

# Author: Fabrice Niessen <(concat "fniessen" at-sign "pirilampo.org")>
# Keywords: zsh, dotfile, config

#* Install:

# For Cygwin users: Create a shortcut for zsh by using the `mkzsh' command.

#* Code:

# extend the PATH var
for MAYBE_PATH in "$HOME/bin" \
                  "$HOME/expect" \
                  "$HOME/winbin";
do
    # `-d' or `-x'?
    if [ -e $MAYBE_PATH ]; then
        PATH=$MAYBE_PATH:$PATH
    fi
done

PATH=$PATH:.

#** 13 (info "(zsh)Prompt Expansion")

# some colors
local BLACK=$'%{\e[1;30m%}'
local RED=$'%{\e[1;31m%}'
local green=$'%{\e[0;32m%}'
local GREEN=$'%{\e[1;32m%}'
local yellow=$'%{\e[0;33m%}'
local reset=$'%{\e[0m%}'

# TODO Insert beep when last command has failed
# custom prompt settings
PROMPT="$green%n@%m$BLACK:$yellow%2. %(?.$GREEN.$RED)%?$reset%(!.#.$) "
    # ? - exit code of the previous command
    # n - user name
    # m - machine name
    # . - abbreviated pwd
    # ! - su?

# # prompt on the right hand side of the screen
# RPROMPT="[%t]"

# git info
. ~/Public/Repositories/git-prompt/zshrc.sh
RPROMPT='$(git_super_status)'

# history
HISTFILE=$HOME/.histfile
HISTSIZE=1000
SAVEHIST=1000

# append new history lines instead of overwriting (important for multiple
# parallel Zsh sessions!)
setopt appendhistory

# don't save command more than once when occuring more often
setopt HIST_IGNORE_DUPS

# Use the same history file for all sessions
setopt SHARE_HISTORY

export TERM=xterm-256color

# some global aliases (expand whatever their position)
alias -g L="| less" #######
alias -g M="| most"
alias -g G='| grep -E' ######
alias -g W='| wc -l' ####
alias -g H='| head' ###
alias -g S='| sort' ###
alias -g T='| tail' ###
alias -g F=' | fmt -' ##
alias -g 21="2>&1"
alias -g DN1='1> /dev/null' #
alias -g DN2='2> /dev/null' #
alias -g VM=/var/log/messages
alias -g A='| awk'
alias -g A1="| awk '{print \$1}'"
alias -g A2="| awk '{print \$2}'"
alias -g A3="| awk '{print \$3}'"
alias -g A4="| awk '{print \$4}'"
alias -g A5="| awk '{print \$5}'"
alias -g A6="| awk '{print \$6}'"
alias -g A7="| awk '{print \$7}'"
alias -g A8="| awk '{print \$8}'"
alias -g A9="| awk '{print \$9}'"
alias -g CA="| cat -A"
alias -g ND='$(ls -d *(/om[1]))' # newest directory
alias -g NF='$(ls *(.om[1]))'    # newest file

alias -g EG='|& egrep'
alias -g EH='|& head'
alias -g EL='|& less'
alias -g ET='|& tail'
alias -g X='| xargs'

alias -- cdwd='cd `pwd`'
alias -- cwd='echo $cwd'
alias h='history 1 | less +G'
alias -- l='ls -lg'
alias find='noglob find'

export LEDGER=ledger
export LEDGER_FILE=/home/fni/Personal/Business/Accounting/LEDGER.dat

# hledger print [REGEXP]... - show entries in Ledger format
    #! `hledger' is better than `ledger' in the sense that it does output
    #! 2 decimals whatever the figure, and that it does not output trailing
    #! spaces. There is no other difference (not even in indentation).

# other problem with ledger: reports onto 81 columns when using other DATEFMT...

alias -g LG="\$LEDGER -f \$LEDGER_FILE"
alias -g DATEFMT='-y %Y/%m/%d'  # for output
alias -g DAILY='--period "daily"'
alias -g DLM='--display "d>=[last month]"'  # display of last month
alias -g CLM='-p "last month"'  # computed total of last month
alias -g D1='--display "l<=1" --depth 1'
alias -g D2='--display "l<=2" --depth 2'
alias -g BALANCE_SHEET='^Assets ^Liabilities'
alias -g PROFIT_LOSS='^Expenses ^Income'

alias lastmonth='LG reg TLM'

# Ledger -f FILE [OPTIONS] [COMMAND [PATTERNS]]
# Ledger using `ledger', `hledger' or `beancount' (see `$LEDGER')
Ledger ()
{
    if [ $# -lt 1 ]; then
        cat << EOF 1>&2
Usage: $(basename $0) -f FILE [OPTIONS] [COMMAND [PATTERNS]]
    or $(basename $0) FILE   (if LEDGER=beancount)
EOF
    fi

    case ${LEDGER} in
        "beancount" )
            ;;

        * )   # default option
            shift;  # for the useless (but expected) `-f'
            ;;
    esac
    local LEDGER_M4_FILE=$1; shift;

    local LEDGER_FILE=sample-ledger.dat;
    case ${LEDGER} in
        "beancount" )
            m4 -D LEDGER=beancount ${LEDGER_M4_FILE} |\
            sed -e 's/\(.*\)(\(.*\)) \(.*\)/\1\3 | \2/g' > ${LEDGER_FILE}
            bean-web ${LEDGER_FILE} $@   # beancount Web interface
            ;;

        * )   # default option
            m4 ${LEDGER_M4_FILE} |\
            sed -e 's/^@/;@/' > ${LEDGER_FILE}
            ${LEDGER} -f ${LEDGER_FILE} $@
            ;;
    esac
    rm ${LEDGER_FILE}
}

# cat file.ledger | sed -e 's/@check/;@check/' | xargs bean-web

# Use wrapper scripts around gpg with armor on (The --armor option means ascii
# versus binary). You'll have to enter a password every time you want to run
# ledger.

#** 9 (info "(zsh)Functions")

# ll ()
# {
#     ls -lag $* | more
# }

term ()
{
    setopt noglob;
    unset TERMCAP;
    eval `tset -s -I -Q - $*`
}

# hgrep PATTERN - print the history lines matching PATTERN
hgrep ()
{
    history 0 | grep $1
}

#** 17 (info "(zsh)Shell Builtin Commands")

# source common aliases
if [ -r $HOME/.commonshrc ]; then
    . $HOME/.commonshrc
fi

#** 18 (info "(zsh)Zsh Line Editor")

# behave like Emacs when editing
bindkey -e

# mappings for `Ctrl-up/down' for matching commands from the history
bindkey ';5A' history-search-backward
bindkey ';5B' history-search-forward

# mappings for `Ctrl-left/right' for word moving
bindkey ';5C' forward-word
bindkey ';5D' backward-word

# beep on errors
setopt beep

# making zsh beep like Bash when backspacing on an empty command line
backward-delete-char-beep ()
{
    if (( CURSOR == 0 )); then
        zle beep
    fi
    zle backward-delete-char
}
zle -N backward-delete-char-beep
bindkey "^?" backward-delete-char-beep

#** 19 (info "(zsh)Completion Widgets")

# load general completion
autoload -Uz compinit && compinit

# display a list of completions when you give an ambiguous choice (like Bash)
setopt autolist

# zsh will attempt to complete wildcards by expanding them in the command line

#** 20 (info "(zsh)Completion System")

# case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

if [ "$TERM" != "dumb" ]; then
    # eval "$(dircolors -b)"
    alias ls='ls --color=always'
else
    alias ls='ls -CF'
fi

## coloring stderr
STDERRRED=$'\e[1;31m'
zmodload zsh/system
color_err () {
    ## sysread & syswrite are part of `zsh/system'
    emulate -LR zsh
    while sysread
    do
        syswrite -o 2 "${STDERRRED}${REPLY}$terminfo[sgr0]"
    done
}

exec 2> >( color_err )

# change directory given just path
setopt autocd

# use additional pattern matching features
setopt extendedglob

# unmatched patterns cause an error
setopt nomatch

# immediately report changes in background job status
setopt notify

#* Local Variables

# This is for the sake of Emacs.
# Local Variables:
# mode: outline-minor
# End:

## .zshrc ends here
