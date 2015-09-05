# vim: nowrap foldmethod=marker foldlevel=2
# this is heavily inspired (partly copied) by the grml zsh config
autoload -U compinit
compinit
setopt completealiases
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

############ fasd
eval "$(fasd --init auto)"
alias v='f -e vim'
alias m'f -e mpv'
alias o='f -e xdg-open'
bindkey '^O' fasd-complete
############

############################### zgen (plugins)
ZGEN_DIR="${HOME}/.zsh/zgen"
if [ ! -f "${ZGEN_DIR}/zgen.zsh" ] ; then
	echo "Installing zgen"
	mkdir -p "$ZGEN_DIR"
	curl -L 'https://raw.githubusercontent.com/tarjoilija/zgen/master/zgen.zsh' > "${ZGEN_DIR}/zgen.zsh"
fi

source "${ZGEN_DIR}/zgen.zsh"
if ! zgen saved; then
    echo "Creating a zgen save"

    zgen load jimmijj/zsh-syntax-highlighting

    # autosuggestions should be loaded last
    zgen load tarruda/zsh-autosuggestions

    zgen save
fi
###############################

# Enable zsh-autosuggestions automatically.
zle-line-init() {
    zle autosuggest-start
}
zle -N zle-line-init
bindkey '^T' autosuggest-toggle
bindkey '^L' autosuggest-execute-suggestion

############################### Completion
# allow one error for every three characters typed in approximate completer
zstyle ':completion:*:approximate:'    max-errors 'reply=( $((($#PREFIX+$#SUFFIX)/3 )) numeric )'

# don't complete backup files as executables
zstyle ':completion:*:complete:-command-::commands' ignored-patterns '(aptitude-*|*\~)'

# start menu completion only if it could find no unambiguous initial string
zstyle ':completion:*:correct:*'       insert-unambiguous true
zstyle ':completion:*:corrections'     format $'%{\e[0;31m%}%d (errors: %e)%{\e[0m%}'
zstyle ':completion:*:correct:*'       original true

# activate color-completion
zstyle ':completion:*:default'         list-colors ${(s.:.)LS_COLORS}

# format on completion
zstyle ':completion:*:descriptions'    format $'%{\e[0;31m%}completing %B%d%b%{\e[0m%}'

# insert all expansions for expand completer
zstyle ':completion:*:expand:*'        tag-order all-expansions
zstyle ':completion:*:history-words'   list false

# activate menu
zstyle ':completion:*:history-words'   menu yes

# ignore duplicate entries
zstyle ':completion:*:history-words'   remove-all-dups yes
zstyle ':completion:*:history-words'   stop yes

# match uppercase from lowercase
zstyle ':completion:*'                 matcher-list 'm:{a-z}={A-Z}'

# separate matches into groups
zstyle ':completion:*:matches'         group 'yes'
zstyle ':completion:*'                 group-name ''

zstyle ':completion:*'                 menu select=5

zstyle ':completion:*:messages'        format '%d'
zstyle ':completion:*:options'         auto-description '%d'

# describe options in full
zstyle ':completion:*:options'         description 'yes'

# on processes completion complete all user processes
zstyle ':completion:*:processes'       command 'ps -au$USER'

# offer indexes before parameters in subscripts
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

# provide verbose completion information
zstyle ':completion:*'                 verbose true

zstyle ':completion:*:-command-:*:'    verbose false

# set format for warnings
zstyle ':completion:*:warnings'        format $'%{\e[0;31m%}No matches for:%{\e[0m%} %d'

# define files to ignore for zcompile
zstyle ':completion:*:*:zcompile:*'    ignored-patterns '(*~|*.zwc)'
zstyle ':completion:correct:'          prompt 'correct to: %e'

# Ignore completion functions for commands you don't have:
zstyle ':completion::(^approximate*):*:functions' ignored-patterns '_*'

# Provide more processes in completion of programs like killall:
zstyle ':completion:*:processes-names' command 'ps c -u ${USER} -o command | uniq'

# complete manual by their section
zstyle ':completion:*:manuals'    separate-sections true
zstyle ':completion:*:manuals.*'  insert-sections   true
zstyle ':completion:*:man:*'      menu yes select

# Search path for sudo completion
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin \
                                           /usr/local/bin  \
                                           /usr/sbin       \
                                           /usr/bin        \
                                           /sbin           \
                                           /bin            \
                                           /usr/X11R6/bin

# provide .. as a completion
zstyle ':completion:*' special-dirs ..

# run rehash on completion so new installed program are found automatically:
_force_rehash() {
    (( CURRENT == 1 )) && rehash
    return 1
}

## correction
setopt correct
zstyle -e ':completion:*' completer '
    if [[ $_last_try != "$HISTNO$BUFFER$CURSOR" ]] ; then
        _last_try="$HISTNO$BUFFER$CURSOR"
        reply=(_complete _match _ignored _prefix _files)
    else
        if [[ $words[1] == (rm|mv) ]] ; then
            reply=(_complete _files)
        else
            reply=(_oldlist _expand _force_rehash _complete _ignored _correct _approximate _files)
        fi
    fi'

# command for process lists, the local web server details and host completion
zstyle ':completion:*:urls' local 'www' '/var/www/' 'public_html'

# caching
[[ -d $ZSHDIR/cache ]] && zstyle ':completion:*' use-cache yes && \
                        zstyle ':completion::complete:*' cache-path $ZSHDIR/cache/

# host completion
[[ -r ~/.ssh/config ]] && _ssh_config_hosts=(${${(s: :)${(ps:\t:)${${(@M)${(f)"$(<$HOME/.ssh/config)"}:#Host *}#Host }}}:#*[*?]*}) || _ssh_config_hosts=()
[[ -r ~/.ssh/known_hosts ]] && _ssh_hosts=(${${${${(f)"$(<$HOME/.ssh/known_hosts)"}:#[\|]*}%%\ *}%%,*}) || _ssh_hosts=()
[[ -r /etc/hosts ]] && : ${(A)_etc_hosts:=${(s: :)${(ps:\t:)${${(f)~~"$(</etc/hosts)"}%%\#*}##[:blank:]#[^[:blank:]]#}}} || _etc_hosts=()
hosts=(
    $(hostname)
    "$_ssh_config_hosts[@]"
    "$_ssh_hosts[@]"
    "$_etc_hosts[@]"
    localhost
)
zstyle ':completion:*:hosts' hosts $hosts

# pacaur remote completion is too slow 
zstyle ':completion:*:pacaur:*' remote-access false
###############################

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
setopt rc_quotes
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

# history search
bindkey -M vicmd ' k' history-search-backward
bindkey -M vicmd ' j' history-search-forward

# incremental search
bindkey -M viins '^R' history-incremental-search-backward
bindkey -M viins '^S' history-incremental-search-forward

# Accept suggestions without leaving insert mode
bindkey '^f' vi-forward-word
bindkey '^b' vi-backward-word

# no delay after pressing escape (don't use escape as a prefix)
bindkey -rpM viins '\e'

#
# utility functions {{{1
#

# display a countdown (usage similar to sleep)
function countdown(){
    seconds=0
    while [[ $# -ge 1 ]]
    do
        number=${1:0: -1}
        suffix=${1: -1}
        case $suffix in
            s)
                seconds=$(( $seconds + $number ))
                ;;
            m)
                seconds=$(( $seconds + $number * 60 ))
                ;;
            h)
                seconds=$(( $seconds + $number * 60 * 60 ))
                ;;
            *)
                number=${number}${suffix}
                seconds=$(( $seconds + $number ))
                ;;
        esac
        shift
    done
    dateAfter=$((`date +%s` + $seconds)); 
    echo -e "Counting down $seconds seconds until $(date --date @${dateAfter} +'%F %T')..."
    while [[ "$dateAfter" > `date +%s` ]]; do 
        echo -ne "\033[2K" # clear the line
        echo -ne "$(date -u --date @$(($dateAfter - `date +%s`)) +%H:%M:%S)\r";
        sleep 0.1
    done
}
alias cntd='countdown'
cntdn () {
	countdown $@
	notify-send 'Time over'
}

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
alias pastebin='curl -F "sprunge=<-" http://sprunge.us'
alias pastebinc='pastebin | xsel -b'
alias ns='notify-send'
check_com rsync && alias smv='rsync -avz --remove-source-files -e ssh'
check_com translate && alias trans='translate -x en de'
if check_com task ; then
	zstyle ':completion:*:*:task:*' verbose yes
	zstyle ':completion:*:*:task:*:descriptions' format '%U%B%d%b%u'

	zstyle ':completion:*:*:task:*' group-name ''

	alias t=task
	alias in='task add +in'
	compdef _task t=task
	compdef _task in=task
fi

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
sysupgrade() {
	BLUE='\033[0;34m'
	NC='\033[0m'
	snapshot_nbr=$(snapper create --type=pre --cleanup-algorithm=number --print-number --description="${cmd}")
	echo ">>> ${BLUE}New pre snapshot with number ${snapshot_nbr}.${NC}"
	echo ">>> ${BLUE}Updating packages${NC}"
	pacaur -Syu
	echo ">>> ${BLUE}Removing orphans${NC}"
	pacaur -Rns $(pacaur -Qdtq) 2> /dev/null
	echo ">>> ${BLUE}Cleaning the package cache${NC}"
	paccache -r; paccache -ruk0
	echo ">>> ${BLUE}Saving package list${NC}"
	rm "$HOME/Documents/pkglist.txt" > /dev/null
	(pacman -Qqen ; echo '\n' ; pacman -Qqem) > "$HOME/Documents/pkglist.txt"

	snapshot_nbr=$(snapper create --type=post --cleanup-algorithm=number --print-number --pre-number="$snapshot_nbr")
	echo ">>> ${BLUE}New post snapshot with number ${snapshot_nbr}.${NC}"
}
