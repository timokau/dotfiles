# vim: nowrap foldmethod=marker foldlevel=2
# this is heavily inspired (partly copied) by the grml zsh config
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
# AUR autocompletion for pacaur is too slow
zstyle ':completion:*:pacaur:*' remote-access false

zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

[[ $TERM == xterm-termite ]] && \
	alias nvim="NVIM_TUI_ENABLE_TRUE_COLOR=1 NVIM_TUI_ENABLE_CURSOR_SHAPE=1 nvim"

#
# enviroment variables {{{1
#
export BROWSER=firefox
export EDITOR=nvim
export PAGER=less

#
# options {{{1
#

# history (append to file, more info, share between sessions)
setopt append_history inc_append_history extended_history share_history 
setopt hist_ignore_space hist_ignore_dups hist_find_no_dups
setopt hist_reduce_blanks
setopt vi
setopt auto_cd
setopt extended_glob
setopt long_list_jobs
setopt notify
setopt hash_list_all
setopt complete_in_word
setopt no_hup
setopt auto_pushd pushd_ignore_dups
setopt no_beep
setopt hist_verify
setopt no_clobber
setopt correct
setopt unset

#
# settings {{{1
#

# report about cpu-/system-/user-time if running long
REPORTTIME=5
# vim-like line editing
bindkey -v

# enable the delete key
bindkey    "^[[3~"          delete-char
bindkey    "^[3;5~"         delete-char

#
# utility functions {{{1
#

# this function checks if a command exists and returns either true or false
check_com() {
    emulate -L zsh
    if   [[ -n ${commands[$1]}    ]] \
      || [[ -n ${functions[$1]}   ]] \
      || [[ -n ${aliases[$1]}     ]] \
      || [[ -n ${reswords[(r)$1]} ]] ; then
        return 0
    fi
    return 1
}

# 
# colors {{{1
# 
# color setup for ls:
check_com dircolors && eval $(dircolors -b)

# support colors in less
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

alias grep='grep --color=auto'
alias ls='ls --color=auto'

#
# prompt {{{1
#
setopt prompt_subst
export PS1='→ '
export RPS1="%(?..%B(%?%)%b )%1~"

#
# aliases {{{1
#
alias rm='rm -Iv --one-file-system'
check_com task && alias t='task'
alias smv='rsync -avz --remove-source-files -e ssh'
alias bell='echo -en "\a"'
alias e="$EDITOR"
alias detach='bg && disown && exit'
alias da='du -sch'
alias l='ls -lF --color=auto'
alias la='ls -lah --color=auto'
alias ll='ls -lh --color=auto'
alias lad='ls -lad .*'
alias lsl='ls -l *(@)'
alias ..='cd ..'
alias ...='cd ../..'

alias -g DN='/dev/null'
alias -g NE='2> /dev/null'
alias -g NUL='> /dev/null 2>&1'

#
# functions {{{1
#
#
# alert via libnotify when the command is finished ('sleep 5s; alert')
alert() {
	err="$?"
	if [[ $err = 0 ]] ; then
		succ='successful'
	else
		succ="error ($err)"
	fi
	zmodload zsh/parameter; # refresh the history parameter
	cmd="${history[$HISTCMD]}"
	notify-send --urgency=low "${succ}: ${cmd}"
}

# cd into the directory in which ranger is quit
rcd () {
	tempfile=$(mktemp /tmp/ranger-dirXXX)
	ranger --choosedir="$tempfile" "${@:-$(pwd)}"
	test -f "$tempfile" &&
	if [[ "$(cat -- "$tempfile")" != "$(echo -n $(pwd))" ]]; then
		echo "$(cat "$tempfile")"
		cd -- "$(cat "$tempfile")"
	fi
	rm -f -- "$tempfile" > /dev/null
}

# Create temporary directory and cd to it
cdt() {
    local t
    t=$(mktemp -d)
    echo "$t"
    builtin cd "$t"
}

# List files which have been accessed within the last n days, n defaults to 1
accessed() {
    emulate -L zsh
    print -l -- *(a-${1:-1})
}

# List files which have been changed within the last n days, n defaults to 1
changed() {
    emulate -L zsh
    print -l -- *(c-${1:-1})
}

# List files which have been modified within the last n days, n defaults to 1
modified() {
    emulate -L zsh
    print -l -- *(m-${1:-1})
}

# cd to directoy and list files
cl() {
    emulate -L zsh
    cd $1 && ls -a
}

# extract intelligently (-d deltes the source files)
xtract() {
    emulate -L zsh
    setopt extended_glob noclobber
    local DELETE_ORIGINAL DECOMP_CMD USES_STDIN USES_STDOUT GZTARGET WGET_CMD
    local RC=0
    zparseopts -D -E "d=DELETE_ORIGINAL"
    for ARCHIVE in "${@}"; do
        case $ARCHIVE in
            *(tar.bz2|tbz2|tbz))
                DECOMP_CMD="tar -xvjf -"
                USES_STDIN=true
                USES_STDOUT=false
                ;;
            *(tar.gz|tgz))
                DECOMP_CMD="tar -xvzf -"
                USES_STDIN=true
                USES_STDOUT=false
                ;;
            *(tar.xz|txz|tar.lzma))
                DECOMP_CMD="tar -xvJf -"
                USES_STDIN=true
                USES_STDOUT=false
                ;;
            *tar)
                DECOMP_CMD="tar -xvf -"
                USES_STDIN=true
                USES_STDOUT=false
                ;;
            *rar)
                DECOMP_CMD="unrar x"
                USES_STDIN=false
                USES_STDOUT=false
                ;;
            *lzh)
                DECOMP_CMD="lha x"
                USES_STDIN=false
                USES_STDOUT=false
                ;;
            *7z)
                DECOMP_CMD="7z x"
                USES_STDIN=false
                USES_STDOUT=false
                ;;
            *(zip|jar))
                DECOMP_CMD="unzip"
                USES_STDIN=false
                USES_STDOUT=false
                ;;
            *deb)
                DECOMP_CMD="ar -x"
                USES_STDIN=false
                USES_STDOUT=false
                ;;
            *bz2)
                DECOMP_CMD="bzip2 -d -c -"
                USES_STDIN=true
                USES_STDOUT=true
                ;;
            *(gz|Z))
                DECOMP_CMD="gzip -d -c -"
                USES_STDIN=true
                USES_STDOUT=true
                ;;
            *(xz|lzma))
                DECOMP_CMD="xz -d -c -"
                USES_STDIN=true
                USES_STDOUT=true
                ;;
            *)
                print "ERROR: '$ARCHIVE' has unrecognized archive type." >&2
                RC=$((RC+1))
                continue
                ;;
        esac

        if ! check_com ${DECOMP_CMD[(w)1]}; then
            echo "ERROR: ${DECOMP_CMD[(w)1]} not installed." >&2
            RC=$((RC+2))
            continue
        fi

        GZTARGET="${ARCHIVE:t:r}"
        if [[ -f $ARCHIVE ]] ; then

            print "Extracting '$ARCHIVE' ..."
            if $USES_STDIN; then
                if $USES_STDOUT; then
                    ${=DECOMP_CMD} < "$ARCHIVE" > $GZTARGET
                else
                    ${=DECOMP_CMD} < "$ARCHIVE"
                fi
            else
                if $USES_STDOUT; then
                    ${=DECOMP_CMD} "$ARCHIVE" > $GZTARGET
                else
                    ${=DECOMP_CMD} "$ARCHIVE"
                fi
            fi
            [[ $? -eq 0 && -n "$DELETE_ORIGINAL" ]] && rm -f "$ARCHIVE"

        elif [[ "$ARCHIVE" == (#s)(https|http|ftp)://* ]] ; then
            if check_com curl; then
                WGET_CMD="curl -L -k -s -o -"
            elif check_com wget; then
                WGET_CMD="wget -q -O - --no-check-certificate"
            else
                print "ERROR: neither wget nor curl is installed" >&2
                RC=$((RC+4))
                continue
            fi
            print "Downloading and Extracting '$ARCHIVE' ..."
            if $USES_STDIN; then
                if $USES_STDOUT; then
                    ${=WGET_CMD} "$ARCHIVE" | ${=DECOMP_CMD} > $GZTARGET
                    RC=$((RC+$?))
                else
                    ${=WGET_CMD} "$ARCHIVE" | ${=DECOMP_CMD}
                    RC=$((RC+$?))
                fi
            else
                if $USES_STDOUT; then
                    ${=DECOMP_CMD} =(${=WGET_CMD} "$ARCHIVE") > $GZTARGET
                else
                    ${=DECOMP_CMD} =(${=WGET_CMD} "$ARCHIVE")
                fi
            fi

        else
            print "ERROR: '$ARCHIVE' is neither a valid file nor a supported URI." >&2
            RC=$((RC+8))
        fi
    done
    return $RC
}
#
# Find history events by search pattern and list them by date.
whatwhen()  {
    emulate -L zsh
    local usage help ident format_l format_s first_char remain first last
    usage='USAGE: whatwhen [options] <searchstring> <search range>'
    help='Use `whatwhen -h'\'' for further explanations.'
    ident=${(l,${#${:-Usage: }},, ,)}
    format_l="${ident}%s\t\t\t%s\n"
    format_s="${format_l//(\\t)##/\\t}"
    # Make the first char of the word to search for case
    # insensitive; e.g. [aA]
    first_char=[${(L)1[1]}${(U)1[1]}]
    remain=${1[2,-1]}
    # Default search range is `-100'.
    first=${2:-\-100}
    # Optional, just used for `<first> <last>' given.
    last=$3
    case $1 in
        ("")
            printf '%s\n\n' 'ERROR: No search string specified. Aborting.'
            printf '%s\n%s\n\n' ${usage} ${help} && return 1
        ;;
        (-h)
            printf '%s\n\n' ${usage}
            print 'OPTIONS:'
            printf $format_l '-h' 'show help text'
            print '\f'
            print 'SEARCH RANGE:'
            printf $format_l "'0'" 'the whole history,'
            printf $format_l '-<n>' 'offset to the current history number; (default: -100)'
            printf $format_s '<[-]first> [<last>]' 'just searching within a give range'
            printf '\n%s\n' 'EXAMPLES:'
            printf ${format_l/(\\t)/} 'whatwhen grml' '# Range is set to -100 by default.'
            printf $format_l 'whatwhen zsh -250'
            printf $format_l 'whatwhen foo 1 99'
        ;;
        (\?)
            printf '%s\n%s\n\n' ${usage} ${help} && return 1
        ;;
        (*)
            # -l list results on stout rather than invoking $EDITOR.
            # -i Print dates as in YYYY-MM-DD.
            # -m Search for a - quoted - pattern within the history.
            fc -li -m "*${first_char}${remain}*" $first $last
        ;;
    esac
}

# maintenence tasks for pacman
pacupdt() {
	BLUE='\033[0;34m'
	NC='\033[0m'
	echo ">>> ${BLUE}Updating packages${NC}"
	pacaur -Syu
	echo ">>> ${BLUE}Removing orphans${NC}"
	pacaur -Rns $(pacaur -Qdtq)
	echo ">>> ${BLUE}Cleaning the package cache${NC}"
	paccache -r; paccache -ruk0
	echo ">>> ${BLUE}Saving package list${NC}"
	rm "$HOME/Documents/pkglist.txt" > /dev/null
	(pacman -Qqen ; echo '\n' ; pacman -Qqem) > "$HOME/Documents/pkglist.txt"
}
