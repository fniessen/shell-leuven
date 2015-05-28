## .bashrc --- Bourne Again Shell configuration file (for interactive shells)

# Copyright (C) 2003-2015 Fabrice Niessen

# Author: Fabrice Niessen <(concat "fniessen" at-sign "pirilampo.org")>
# Keywords: bash, dotfile, config

#    _               _
#   | |__   __ _ ___| |__  _ __ ___
#   | '_ \ / _` / __| '_ \| '__/ __|
#  _| |_) | (_| \__ \ | | | | | (__
# (_)_.__/ \__,_|___/_| |_|_|  \___|
#

# This file is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of
# the License, or (at your option) any later version.

# This file is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
# PURPOSE.  See the GNU General Public License for more details.

# You should have received a copy of the GNU General Public
# License along with this file; if not, write to the Free
# Software Foundation, Inc., 59 Temple Place - Suite 330, Boston,
# MA 02111-1307, USA.

#* Code:

# modify to taste

# if not running interactively, don't do anything
[[ "$-" != *i* ]] && return

# specify the directories that the shell is to look through to find a
# command. These directories are searched in the order in which they appear.
for MAYBE_PATH in "$HOME/bin" \
                  "$HOME/expect" \
                  "$HOME/winbin"
do
    if [ -d "$MAYBE_PATH" ]; then
        PATH="$MAYBE_PATH:$PATH"
    fi
done

# add the current directory as last component in the search path
# (not to include for root, for security reasons)
if [ ! "$(id -u)" = "0" ]; then
    PATH="$PATH:."
fi

#*** Controlling the Prompt

# regular colors
green="\[\e[0;32m\]"
yellow="\[\e[0;33m\]"

# bold colors
BLACK="\[\e[1;30m\]"
RED="\[\e[1;31m\]"
GREEN="\[\e[1;32m\]"

reset="\[\e[0m\]"

#**** PS1 --- Default interaction prompt

#**** PS2 --- Continuation interactive prompt

#**** PS3 --- Prompt used by "select" inside shell script

#**** PS4 --- Used by "set -x" to prefix tracing output

# get line numbers when you run with `-x'
PS4='+'${green}'[$0:${LINENO}]+ '${reset}
# single quotes (otherwise, this line number is taken)

# If you are looking at performance issues, put `$SECONDS' in the PS4 prompt
# as well

#**** PROMPT_COMMAND

# to be called just before the prompt is printed
precmd ()
{
    RET=$?

    # set a color prompt (unless in Emacs)
    case $TERM in
        cygwin|xterm*|rxvt-unicode)
            local color_prompt=yes
            ;;
        dumb)
            # `M-x shell' under Cygwin Emacs
            # `M-x eshell' under EmacsW32
            # Tramp
            local color_prompt=no
            ;;
        emacs)
            # `M-x shell' under EmacsW32
            local color_prompt=no
            ;;
        eterm-color)
            # `M-x term' under Cygwin Emacs
            local color_prompt=no
            ;;
    esac

    # colorful prompt, based on whether the previous command succeeded or not
    if [ $RET -eq 0 ]; then
        HILIT_RET=${GREEN}
    else
        HILIT_RET=${RED}
    fi

    # replace the `$HOME' prefix by `~' in the current directory
    if [ "$HOME" = "${PWD:0:${#HOME}}" ]; then
        myPWD="~${PWD:${#HOME}}"
    else
        myPWD=$PWD
    fi

    # how many characters of the path should be kept
    local pwd_max_length=15

    if [ ${#myPWD} -gt $pwd_max_length ]; then
        local pwd_offset=$(( ${#myPWD} - $pwd_max_length ))
        myPWD="...${myPWD:$pwd_offset:$pwd_max_length}"
    fi

    # prompt character
    if [ "$USERNAME" = "root" ]; then
        local PROMPTCHAR="#"
    else
        local PROMPTCHAR="$"
    fi

    if [ "$color_prompt" = "yes" ]; then
        PS1="${green}\u@\h${BLACK}:${yellow}${myPWD}${HILIT_RET} ${RET}${reset}${PROMPTCHAR} "
    else
        PS1="\u@\h:${myPWD} ${RET}${PROMPTCHAR} "
    fi
}

# execute the content of the `PROMPT_COMMAND' just before displaying the `PS1'
# variable (but don't confuse Tramp)
[ $TERM = "dumb" ] || PROMPT_COMMAND=precmd

# history
HISTFILE=$HOME/.bash_history # if paranoiac, `/dev/null'
HISTSIZE=1000
HISTFILESIZE=1000
HISTIGNORE="&:[bf]g:exit"
HISTCONTROL=ignoredups

#** Source global rc file (if any)

# source global definitions if the session is interactive (to avoid problems
# like "stdin: is not a tty" when ssh'ing to a remote machine)
if ([ $(expr index "$-" i) -ne 0 ] && [ -f /etc/bashrc ]); then
    . /etc/bashrc
fi

#** Default permissions

# permissions on newly created files
umask 022 # prevent new dirs and files from being group and world writable

if [ "$USERNAME" = "root" ]; then
    umask 077  # stricter
fi

#** Shell options

# correct minor misspellings of cd pathnames
shopt -s cdspell

#** 5 (info "(bashref)Shell Variables")

# set MANPATH so it includes user's private man if it exists
# do the same with MANPATH
#if [ -d $HOME/man ]; then
#    MANPATH=$HOME/man:"${MANPATH}"
#    export MANPATH
#fi

# LANG="en_US.utf8"
# LC_CTYPE="en_US.utf8"
# LC_ALL="C"   # fixes the problem of strange characters in the man page
# XXX These should be set in `/etc/default/locale', via `sudo update-locale'

# XXX Set DISPLAY?

# colon separated list of directories to search for manual pages
#ifnset MANPATH "/usr/man"
    # TODO don't define it like that: does not work under Ubuntu!
    # See `/etc/manpath.config'

# Info readers (standalone + Emacs Info mode)
INFOPATH="/usr/share/info:$INFOPATH"
# include a trailing colon on `INFOPATH' to concatenate the Emacs
# `Info-default-directory-list' when searching for info files
INFOPATH="$HOME/src/emacs-w3m/doc:$INFOPATH"
INFOPATH="$HOME/src/gnus/texi:$INFOPATH"
INFOPATH="$HOME/Downloads/emacs/site-lisp/auctex-11.86/doc:$INFOPATH"
# INFOPATH="$HOME/texlive/2014/texmf/doc/info:$INFOPATH"
INFOPATH="$HOME/Public/Repositories/org-mode/doc:$INFOPATH"

#** 4.2 or 6.6 Aliases

# source common definitions
if [ -r "$HOME/.commonshrc" ]; then
    . $HOME/.commonshrc
fi

# ngrep -i -w 'user|pass' port 110
# ngrep -d eth0 -i 'USER|PASS' tcp port 80
# ngrep google port 80
# ngrep -i 'rcpt to|mail from' tcp port smtp
# ngrep -q -t -wi "login" port 23


#** 8.6 Programmable Completion

complete -A helptopic help
complete -A hostname ssh telnet nmap rlogin ftp ping host traceroute nslookup rexec


#** Misc functions

saneperms ()
{
    find . -type d -print0 | xargs -0 chmod 755
    find . -type f -print0 | xargs -0 chmod ${1:=644}
}


# # search for various types or README file in dir and display them in $PAGER
# readme ()
# {
#     local files
#     files=(./(#i)*(read*me|lue*m(in|)ut)*(ND))
#     if (($#files)); then
#         $PAGER $files
#     else
#         print 'No README files.'
#     fi
# }

# # Get a file's basename, dirname, extension, etc
#
# # get extension; everything after last '.'
# ext=${file##*.}
#
# # basename
# basename=`basename "$file"`
# # everything after last '/'
# basename=${file##*/}
#
# # dirname
# dirname=`dirname "$file"`
# # everything before last '/'
# basename=${file%/*}

# TODO If possible, get the lines colored (exe in green) or suffixed (`*' for
# exe, `/' for dir, etc.)
ff ()
{
    find . -name $@ -print 2>&1 | grep -v "find:"
}

safetmp ()
{
    test -d $HOME || exit 1
    test -d $HOME/tmp || mkdir $HOME/tmp
    echo $HOME/tmp/safetmp.$(hostname).$(date +%s).$$
}

# Copies my public key to the given server
sendkey ()
{
    local HOSTNAME="$*"
    scp $HOME/.ssh/id_rsa.pub $USER@$HOSTNAME:/home/$DOMAIN/$USER/.ssh/authorized_keys
    # The PuTTY developers strongly recommend you use RSA
}

# Copies my `.bashrc' to the given server
sendbash ()
{
    local HOSTNAME="$*"
    scp $HOME/.bashrc $USER@$HOSTNAME:/home/$DOMAIN/$USER/.bashrc
}

# Copies my public key and bashrc to the given server
rsetup ()
{
    local HOSTNAME="$*"
    sendkey $HOSTNAME
    sendbash $HOSTNAME
}

# gpg
searchkey ()
{
    gpg --keyserver pgp.mit.edu --fingerprint --search-key "$@";
}

#*** GPG functions

encrypt ()
{
    # Use ascii armor
    gpg -ac --no-options "$1"
}

bencrypt ()
{
    # No ascii armor
    # Encrypt binary data. jpegs/gifs/vobs/etc.
    gpg -c --no-options "$1"
}

decrypt ()
{
    gpg --no-options "$1"
}

pe ()
{
# Passphrase encryption program
# Created by Dave Crouse 01-13-2006
# Reads input from text editor and encrypts to screen.
    clear
    echo "         Passphrase Encryption Program";
    echo "--------------------------------------------------"; echo "";
    which $EDITOR &>/dev/null
    if [ $? != "0" ]; then
        echo "It appears that you do not have a text editor set in your .bashrc file.";
        echo "What editor would you like to use ? " ;
        read EDITOR ; echo "";
    fi
    echo "Enter the name/comment for this message :"
    read comment
    $EDITOR passphraseencryption
    gpg --armor --comment "$comment" --no-options --output
    passphraseencryption.gpg --symmetric passphraseencryption
    shred -u passphraseencryption ; clear
    echo "Outputting passphrase encrypted message"; echo "" ; echo "" ;
    cat passphraseencryption.gpg ; echo "" ; echo "" ;
    shred -u passphraseencryption.gpg ;
    read -p "Hit enter to exit" temp; clear
}

keys ()
{
    # Opens up kgpg keymanager
    kgpg -k
}

# # have one SSH agent ready at all times
# if [ "$SSH_AUTH_SOCK" = "" ]; then
#     # check to see if there's an ssh-agent running
#     eval $(ssh-agent)
#     ssh-add
# fi

timesync ()
{
    if [ $(id -u) = 0 ]; then
        ntpdate -u swisstime.ethz.ch
    else
        echo "Must be root"
    fi
}

# immediately opens the first match
texman ()
{
    locate $* | grep pdf | grep texlive | head -1 | xargs open;
}

texlist ()
{
    locate $* | grep "\(pdf\|dvi\)" | grep "\ (texlive\|gwTeX\)";
}

#* Local Variables

# This is for the sake of Emacs.
# Local Variables:
# mode: shell-script
# mode: outline-minor
# sh-shell: bash
# End:

## .bashrc ends here
