# vim: nowrap foldmethod=marker foldlevel=2
# this is heavily inspired (partly copied) by the grml zsh config
autoload -U compinit
compinit
setopt completealiases
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000

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

# if [[ $TERM == xterm-termite ]]; then
	alias nvim="NVIM_TUI_ENABLE_TRUE_COLOR=1 nvim"
	alias vimwiki="NVIM_TUI_ENABLE_TRUE_COLOR=1 nvim -c 'VimwikiIndex'"
	alias vimjour="NVIM_TUI_ENABLE_TRUE_COLOR=1 nvim -c 'VimwikiDiaryIndex'"
	# In case nvim is started from ranger
	alias ranger="NVIM_TUI_ENABLE_TRUE_COLOR=1 ranger"
# fi

alias scrott='scrot /tmp/shot-$(date +%FT%T).png'
alias rss='newsboat'

alias gb='git worktree prune; git branch'

alias gdb='gdb -q'

alias ssh='TERM=xterm ssh'


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

# edit in $editor
autoload edit-command-line
zle -N edit-command-line
bindkey -M vicmd v edit-command-line

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

# bg and disown if c-z is pressed twice
fancy-ctrl-z () {
	if [[ $#BUFFER -eq 0 ]]; then
		bg
		disown
		zle redisplay
	else
		zle push-input
	fi
}
zle -N fancy-ctrl-z
bindkey '^Z' fancy-ctrl-z

#
# utility functions {{{1
#

alias cntd='countdown'
cntdn () {
	countdown $@
	notify-send 'Time over'
}

# use rsync to copy
function cpy(){
if [[ $# -lt 2 ]]; then
	echo "You have to specify at least one source and the destination."
	echo "Usage: cpy SOURCE... DESTINATION"
	return 1
fi
rsync --archive --human-readable --info=progress2,stats2,flist1 $*
notify-send --urgency=low --app-name=cpy "Copying finished."
}

# Rust
# Enable stack backtraces by default
export RUST_BACKTRACE=1

# Configure fzf
if check_com fzf; then
	export FZF_DEFAULT_OPTS='--extended --cycle --multi'
	if check_com ag; then
		ag_selector='--follow --depth=-1 --all-types --hidden --search-zip -g ""'
		export FZF_DEFAULT_COMMAND="ag --nocolor --files-with-matches $ag_selector 2> /dev/null"
		export FZF_CTRL_T_COMMAND=$FZF_DEFAULT_COMMAND
		# Recreate the meta-c widget because it is not configurable
		fzf-cd-widget() {
			cd "$($FZF_DEFAULT_COMMAND| $(__fzfcmd) +m)"
			zle reset-prompt
		}
		zle     -N    fzf-cd-widget
		bindkey '\ec' fzf-cd-widget
	else
		export FZF_DEFAULT_COMMAND='find -L -type f'
	fi
	fzf_script='/etc/profile.d/fzf.zsh'
	[ -e "$fzf_script" ] && source "$fzf_script"
fi

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
alias ls='BLOCK_SIZE="''1" TIME_STYLE=long-iso ls --color=auto'

#
# prompt {{{1
#
setopt prompt_subst
autoload -Uz vcs_info
zstyle ':vcs_info:*' stagedstr 'M' 
zstyle ':vcs_info:*' unstagedstr 'M' 
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' actionformats '%F{5}[%F{2}%b%F{3}|%F{1}%a%F{5}]%f '
zstyle ':vcs_info:*' formats \
  '%F{5}[%F{2}%b%F{5}] %F{2}%c%F{3}%u%f'
zstyle ':vcs_info:git*+set-message:*' hooks git-untracked
zstyle ':vcs_info:*' enable git
+vi-git-untracked() {
  if [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == 'true' ]] && \
  [[ $(git ls-files --other --directory --exclude-standard | sed q | wc -l | tr -d ' ') == 1 ]] ; then
  hook_com[unstaged]+='%F{1}??%f'
fi
}

# line above prompt
precmd () {
	red="\u001b[31m"
	blue="\u001b[34m"
	reset="\u001b[0m"
	LEFT="$red$(whoami)$reset@$blue$(hostname)$reset $PWD"
	taskc="$( task +READY -backlog count )"
	(( taskc > 0 )) && tasks="$taskc tasks "
	mailc="$( notmuch count tag:unread )"
	(( mailc > 0 )) && mails="$mailc mails "
	RIGHT="$red$tasks$mails$reset$(date +%T) "
	# len without ascii escapes
	LEFTLEN="$(( ${#${(S%%)LEFT//(\%([KF1]|)\{*\}|\%[Bbkf])}} ))"
	RIGHTLEN="$(( ${#${(S%%)RIGHT//(\%([KF1]|)\{*\}|\%[Bbkf])}} ))"
	FILLWIDTH=$(($COLUMNS-$LEFTLEN-$RIGHTLEN+57)) # FIXME len without ascii escapes doesn't work
	print $LEFT${(l:$FILLWIDTH:: :)}$RIGHT
	vcs_info
}
# PROMPT='%F{5}[%F{2}%n%F{5}] %F{3}%3~ ${vcs_info_msg_0_} %f%# '
# RPROMPT=$'$(vcs_info_wrapper)'
# export PS1='→ '
# export PROMPT="$(whoami)@$(hostname) [$(date +%T)] $( task ready | tail -n1 )
# → "
# export RPROMPT="%(?..%B(%?%)%b )%1~"
# git_prompt() {
# 	ref=$(git symbolic-ref HEAD | cut -d'/' -f3)
# 	echo $ref
# }
PROMPT='\$ '
RPROMPT='${vcs_info_msg_0_} [%F{yellow}%?%f]'
autoload -U promptinit
promptinit

#
# aliases {{{1
#
alias rm='rm -Iv --one-file-system'
alias cp='cp -i'
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
# sync mails in background before and after closing mutt
alias mutt='( syncmails >/dev/null 2>&1 & ); neomutt; ( syncmails repeat >/dev/null 2>&1 & )'
check_com rsync && alias smv='rsync -avz --remove-source-files -e ssh'
check_com translate-shell && alias trans='HOME_LANG=de TARGET_LANG=de trans'
check_com translate-shell && alias transb='HOME_LANG=de TARGET_LANG=de trans -brief'
if check_com task ; then
	zstyle ':completion:*:*:task:*' verbose yes
	zstyle ':completion:*:*:task:*:descriptions' format '%U%B%d%b%u'

	zstyle ':completion:*:*:task:*' group-name ''

	alias t=task
	alias ts=tasksh
	compdef _task t=task
fi

############ fasd
if check_com fasd ; then
	eval "$(fasd --init auto)"
	alias v='NVIM_TUI_ENABLE_TRUE_COLOR=1 NVIM_TUI_ENABLE_CURSOR_SHAPE=1 fasd -f -e "nvim"'
	alias m'fasd -f -e mpv'
	# alias o='fasd -f -e "setsid xdg-open"'
	bindkey '^O' fasd-complete
else
	alias v='nvim'
	alias m'setsid mpv'
	alias o='setsid xdg-open'
	alias zat='setsid zathura'
fi

############


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
	if [[ -f "$tempfile" ]] && [[ "$(cat -- "$tempfile")" != "$(echo -n $(pwd))" ]]; then
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

############################### zgen (plugins)
ZGEN_DIR="${HOME}/.zsh/zgen"
if [ ! -f "${ZGEN_DIR}/disabled" ]; then
	if [ ! -f "${ZGEN_DIR}/zgen.zsh" ] ; then
		mkdir -p "$ZGEN_DIR"
		echo "zgen plugin manager is not installed. Do you want to install it?"
		read YnAnswer
		case "$YnAnswer" in
			y*) curl -L 'https://raw.githubusercontent.com/tarjoilija/zgen/master/zgen.zsh' > "${ZGEN_DIR}/zgen.zsh"
				;;
			*)  touch "${ZGEN_DIR}/disabled"
				;;
		esac
	fi
fi

if [ -f "${ZGEN_DIR}/disabled" ]; then
	plugins=false
else
	plugins=true
fi

if $plugins; then
	source "${ZGEN_DIR}/zgen.zsh"
	if ! zgen saved; then
		echo "Creating a zgen save"

		#zgen load jimmijj/zsh-syntax-highlighting

		# autosuggestions should be loaded last
		zgen load tarruda/zsh-autosuggestions

		zgen save
	fi

	# Enable zsh-autosuggestions automatically.
	# zle-line-init() {
	# zle autosuggest-start
	# }
	# zle -N zle-line-init
	# bindkey '^T' autosuggest-toggle
	# bindkey '^L' autosuggest-execute-suggestion
fi;
##############################

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh


#
# enviroment variables {{{1
#
export BROWSER=firefox
if check_com nvim; then
	export EDITOR=nvim
elif check_com vim; then
	export EDITOR=vim
fi
check_com less && export PAGER=less

check_com termite && export TERMCMD=termite
check_com kitty && export TERMCMD=kitty



# This script prints a bell character when a command finishes
# if it has been running for longer than $zbell_duration seconds.
# If there are programs that you know run long that you don't
# want to bell after, then add them to $zbell_ignore.
#
# This script uses only zsh builtins so its fast, there's no needless
# forking, and its only dependency is zsh and its standard modules
#
# Written by Jean-Philippe Ouellet <jpo@vt.edu>
# Made available under the ISC license.

# only do this if we're in an interactive shell
[[ -o interactive ]] || return

# get $EPOCHSECONDS. builtins are faster than date(1)
zmodload zsh/datetime || return

# make sure we can register hooks
autoload -Uz add-zsh-hook || return

# initialize zbell_duration if not set
(( ${+zbell_duration} )) || zbell_duration=5

# initialize zbell_ignore if not set
(( ${+zbell_ignore} )) || zbell_ignore=( $EDITOR $PAGER "vim" "nvim" "ranger" "newsboat" "top" "glances" "htop" "timer" "cntdn" "neomutt" "less" "mpv" "eli")

# initialize it because otherwise we compare a date and an empty string
# the first time we see the prompt. it's fine to have lastcmd empty on the
# initial run because it evaluates to an empty string, and splitting an
# empty string just results in an empty array.
zbell_timestamp=$EPOCHSECONDS

# lists all cmdlines of child processes
recursive_spawned_cmdlines() {
	if [ $# -gt 0 ]; then
		# ps --no-headers $*
		for p in $*; do
			echo -n "$( xargs -0 < /proc/$p/cmdline )\n" 2>/dev/null
			recursive_spawned_cmdlines $(ps -e -o ppid= -o pid= | awk '$1 == '"$p"' { print $2 }') 2>/dev/null
		done
	fi
}

# right before we begin to execute something, store the time it started at
zbell_begin() {
	zbell_timestamp=$EPOCHSECONDS
	zbell_lastcmd=$1
	rm -f /tmp/cmdlines_$$
	(( sleep "$zbell_duration"; recursive_spawned_cmdlines $$ > /tmp/cmdlines_$$ ) & )
}

# when it finishes, if it's been running longer than $zbell_duration,
# and we dont have an ignored command in the line, then print a bell.
zbell_end() {
	ran_long=$(( $EPOCHSECONDS - $zbell_timestamp >= $zbell_duration ))
	if (( ! ran_long )); then
		return
	fi

	if [[ -z "$zbell_lastcmd" ]]; then
		return
	fi
	has_ignored_cmd=0
	while read cmdline; do
		for cmd in ${(s:;:)cmdline//|/;} "$(basename "$cmdline")"; do
			words=(${(z)cmd})
			util=${words[1]}
			if (( ${zbell_ignore[(i)$util]} <= ${#zbell_ignore} )); then
				has_ignored_cmd=1
				break
			fi
		done
	done < /tmp/cmdlines_$$
	rm -f /tmp/cmdlines_$$ >/dev/null

	if (( ! $has_ignored_cmd )) && (( ran_long )); then
		print -n "\a"
		( sound complete & ) # TODO conditionally, only when inactive & at home?
		notify-send "\"$zbell_lastcmd\" finished in $(( EPOCHSECONDS - $zbell_timestamp ))s"
	fi
}

# register the functions as hooks
add-zsh-hook preexec zbell_begin
add-zsh-hook precmd zbell_end


# vi-mode pasting
# https://unix.stackexchange.com/questions/25765/pasting-from-clipboard-to-vi-enabled-zsh-or-bash-shell
function x11-clip-wrap-widgets() {
    # NB: Assume we are the first wrapper and that we only wrap native widgets
    # See zsh-autosuggestions.zsh for a more generic and more robust wrapper
    local copy_or_paste=$1
    shift

    for widget in $@; do
        # Ugh, zsh doesn't have closures
        if [[ $copy_or_paste == "copy" ]]; then
            eval "
            function _x11-clip-wrapped-$widget() {
                zle .$widget
                xclip -in -selection clipboard <<<\$CUTBUFFER
            }
            "
        else
            eval "
            function _x11-clip-wrapped-$widget() {
                CUTBUFFER=\$(xclip -out -selection clipboard)
                zle .$widget
            }
            "
        fi

        zle -N $widget _x11-clip-wrapped-$widget
    done
}


local copy_widgets=(
    vi-yank vi-yank-eol vi-delete vi-backward-kill-word vi-change-whole-line
)
local paste_widgets=(
    vi-put-{before,after}
)

# NB: can atm. only wrap native widgets
x11-clip-wrap-widgets copy $copy_widgets
x11-clip-wrap-widgets paste  $paste_widgets
