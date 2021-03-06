chpwd() {
    if [[ -x $(which fasd) ]]; then
        [[ "${PWD}" -ef "${HOME}" ]] || fasd -A "${PWD}"
    fi
    hash setup_prompt 2> /dev/null && setup_prompt
}

local readonly use_cope_path=false
if [[ ${use_cope_path} == true  ]]; then
    if [[ -x $(which cope_path 2> /dev/null) ]]; then
        # to prevent slow cope_path evaluation
        local copepath=$(cope_path)
        for i in "${copepath}"/*; alias $(basename ${i})=\"$i\"
        alias df="${copepath}/df -hT"
    else
        alias df="df -hT"
    fi
else
    local copepath=~/bin/scripts/Cope
    for i in "${copepath}"/*; alias $(basename ${i})=\"$i\"
    alias df="${copepath}/df -hT"
fi
unset copepath

zc() {
    autoload -U zrecompile
    for z in ${ZDOTDIR}/*.zsh ${ZDOTDIR}/.zshrc; do
        zrecompile -p ${z}
        print "${z}"
        rm -fv "${z}.zwc.old"
    done
    for f in ${zcompdumpfile};
        zrecompile -p "${f}" && \
        rm -f "${f}.zwc.old"
    source ${ZDOTDIR}/.zshrc
}

# grep for running process, like: 'any vime
any() {
    emulate -L zsh
    unsetopt KSH_ARRAYS
    if [[ -z "$1" ]] ; then
        if [[ -x $(which fzf-tmux) ]]; then
            ps xauwww | fzf-tmux
        fi
    else
        ps xauwww | grep  --color=auto -i "[${1[1]}]${1[2,-1]}"
    fi
}

imv() {
    local src dst
    for src; do
        [[ -e ${src} ]] || { print -u2 "${src} does not exist"; continue }
        dst=${src}
        vared dst
        [[ ${src} != ${dst} ]] && mkdir -p ${dst:h} && mv -n ${src} ${dst}
    done
}

dropcache() { sync && command sudo /bin/zsh -c 'echo 3 > /proc/sys/vm/drop_caches' }

which() {
    if [[ $# > 0 ]]; then
        if [[ -x /usr/bin/ccat ]]; then
            builtin which "$@" | ccat
        else
            builtin which "$@"
        fi
    fi
}

local noglob_list=(
    fc find {,s,l}ftp history locate rake rsync scp
    eix {z,m}mv wget clive{,scan} youtube-{dl,viewer}
    translate links{,2} lynx you-get bower pip task
)

local rlwrap_list=(
    bigloo clisp irb guile bb
)

local sudo_list=({u,}mount ch{mod,own} modprobe i7z aircrack-ng)

local user_commands=(
    list-units is-active status show help list-unit-files
    is-enabled list-jobs show-environment cat
)

local systemctl_sudo_commands=(
    start stop reload restart try-restart isolate kill
    reset-failed enable disable reenable preset mask unmask
    link load cancel set-environment unset-environment
    edit
)

local logind_sudo_list=(
    reboot halt poweroff
)

local nocorrect_commands=(
    ebuild gist heroku hpodder man mkdir mv mysql sudo
)

for c in ${user_commands}; do; alias sc-${c}="systemctl ${c}"; done
for c in ${systemctl_sudo_commands}; do; alias sc-${c}="sudo systemctl ${c}"; done

for i in ${sudo_list[@]}; alias "${i}=sudo ${i}";
for i in ${noglob_list[@]}; alias "${i}=noglob ${i}";
for i in ${rlwrap_list[@]}; alias "${i}=rlwrap ${i}";
for i in ${nocorrect_list[@]}; alias "${i}=nocorrect ${i}";

[[ -x /usr/bin/systemctl ]] && sysctl_pref="systemctl"
for i in ${logind_sudo_list[@]}; alias "${i}=sudo ${sysctl_pref} ${i}"

unset noglob_list rlwrap_list sudo_list sys_sudo_list

alias l=ls
alias ls="ls --color=auto"
alias sort='sort --parallel 8 -S 16M'
alias ping='prettyping'

alias s="sudo"
alias x='xargs'
alias e="mimeo"
alias u='umount'

mp() {
    local args=""
    for arg; do
        if [[ -d ${arg} ]]; then
            {find "${arg}" -maxdepth 1 -type f -print0 | xargs -0n10 -P 10 ~/bin/scripts/vid_info} &
        fi
    done
    {for arg; [[ -f "${arg}" ]] && args+="$(printf '%s\0' "${arg}")";
    xargs -0n10 -P 10 ~/bin/scripts/vid_info <<< "${args}"} &
    mpv --input-ipc-server=/tmp/mpvsocket --vo=gpu "$@" > ${HOME}/tmp/mpv.log
}

alias mpa="mpv --input-ipc-server=/tmp/mpvsocket --vo=gpu "$@" -mute > ${HOME}/tmp/mpv.log"
alias mpA="mpv --input-ipc-server=/tmp/mpvsocket --vo=gpu "$@" -fs -ao null > ${HOME}/tmp/mpv.log"
alias mpi="mpv --input-ipc-server=/tmp/mpvsocket --vo=gpu --interpolation=yes --tscale='oversample' --video-sync='display-resample' "$@" > ${HOME}/tmp/mpv.log"

alias love="mpc sendmessage mpdas love"
alias unlove="mpc sendmessage mpdas unlove"

alias grep="grep --color=auto"
alias rg="rg --colors 'match:fg:magenta' --colors 'line:fg:cyan'"

alias mutt="dtach -A ${HOME}/1st_level/mutt.session neomutt"

alias pstop='ps -eo cmd,fname,pid,pcpu,time --sort=-pcpu | head -n 11 && echo && ps -eo cmd,fname,pid,pmem,rss --sort=-rss | head -n 9'
alias '?=bc -l <<<'

alias mv="mv -i"
alias mk="mkdir -p"
alias rd="rmdir"

alias acpi="acpi -V"
alias url-quote='autoload -U url-quote-magic ; zle -N self-insert url-quote-magic'

alias se="patool extract"
alias pk="patool create"

if hash git 2>/dev/null; then
    alias gs='git status --short -b'
    alias gp='git push'
    alias gc='git commit'

    # http://neurotap.blogspot.com/2012/04/character-level-diff-in-git-gui.html
    intra_line_diff='--word-diff-regex="[^[:space:]]|([[:alnum:]]|UTF_8_GUARD)+"'
    intra_line_less='LESS="-R +/-\]|\{\+"' # jump directly to changes in diffs
    alias gd="${intra_line_less} git diff ${intra_line_diff}"
    alias gd2='git diff -w -U0 --word-diff-regex=[^[:space:]]'
    alias gd3='git diff --word-diff-regex="[A-Za-z0-9. ]|[^[:space:]]" --word-diff=color'

    # commit staged changes with the given message
    alias gcm='git commit -m'

    eval "$(hub alias -s)"
fi

eval 'alias :{x,q,Q}=exit'
alias iostat='iostat -mtx'
alias yt="youtube-dl"
alias ytt='you-get'

yr() {
    ${XDG_CONFIG_HOME}/i3/send bscratch toggle youtube
    sleep 1s
    echo "$@" | xsel -i
    xdotool key shift+Insert
}

alias qe='cd *(/om[1])'
if hash ccat > /dev/null; then
    alias hi='ccat -G String="_default_" -G Plaintext="white" -G Punctuation="blue" -G Literal="fuscia" -G Keyword="fuscia" 2>/dev/null'
fi

alias history='history 0'

alias objdump='objdump -M intel -d'
alias memgrind='valgrind --tool=memcheck "$@" --leak-check=full'

alias cal="task calendar"

urlencode() { python -c "import sys, urllib; print(urllib.quote_plus(sys.argv[1]))" }
urldecode() { python -c "import sys, urllib; print(urllib.unquote_plus(sys.argv[1]))" }

zleiab() {
    declare -A abk
    abk=(
        'G'    '|& rg -i '
        'C'    '| wc -l'
        'H'    '| head'
        'T'    '| tail'
        'N'    '&>/dev/null'
        'S'    '| sort -h '
        'V'    '|& nvim -'
        "jk"   "!-2$"
        "j2"   "!-3$"
        "j3"   "!-4$"
    )

    emulate -L zsh
    setopt extendedglob
    local MATCH

    matched_chars='[.-|_a-zA-Z0-9]#'
    LBUFFER=${LBUFFER%%(#m)[.-|_a-zA-Z0-9]#}
    LBUFFER+=${abk[$MATCH]:-$MATCH}
}
zle -N zleiab

hash journalctl > /dev/null && {
    alias log='journalctl -f | ccze -A' #follow log
}

hash iotop > /dev/null && {
    alias iotop='sudo iotop -oPa'
    alias diskact="sudo iotop -Po"
}

hash nc > /dev/null && alias nyan='nc -v nyancat.dakko.us 23'

alias up="rtv -s unixporn"
alias taco='curl -L git.io/taco'
alias starwars='telnet towel.blinkenlights.nl'

alias -s Dockerfile="docker build - < "

pacnews() { sudo find /etc -name '*.pacnew' | sed -e 's|^/etc/||' -e 's/.pacnew$//' }
alias pkglist="comm -23 <(pacman -Qeq | sort) <(pacman -Qgq base base-devel | sort)"

# upload to imgur with modified zmwangx/imgur
if [[ ${USE_IMGUR_QT} ]]; then
    alias img="imgur-upload $@"
else
    alias img="imgur-screenshot $@"
fi

alias @r=~/bin/scripts/music_rename

v() { ~/bin/v --remote-silent "$@" }
gv() {
    ~/bin/v --remote-silent ./
    ~/bin/v --remote-send ":GV<CR>"
}
[[ -x =nvim ]] && alias vim=nvim
[[ ${DISPLAY} ]] &&  alias nvim=v

alias ip='ip -c'
alias fd='fd -H'

alias куищще='reboot'
alias учше='exit'
alias :й=':q'

mimemap() {
    default=${1}; shift
    for i in $@; do alias -s ${i}=${default}; done
}

alias sp='cdu -idh -s -r -c ":"'

allip() {
    netstat -lantp \
    | grep ESTABLISHED \
    | awk '{print }' \
    | awk -F: '{print }' \
    | sort -u
}

fun::fonts() {
    alias 2023='toilet -f future'
    alias gaym='toilet --gay -f mono9 -t'
    alias gayf='toilet --gay -f future -t'
    alias gayt='toilet --gay -f term -t'
    alias gayp='toilet --gay -f pagga -t'
    alias metm='toilet --metal -f mono9 -t'
    alias metf='toilet --metal -f future -t'
    alias mett='toilet --metal -f term -t'
    alias metp='toilet --metal -f pagga -t'
    alias 3d='figlet -f 3d'
}

+strip_trailing_workspaces() { sed ${1:+-i} 's/\s\+$//' "$@" }

# --------------------------------------------------------------------
# ZLE-related stuff

inplace_mk_dirs() {
    # Press ctrl-xM to create the directory under the cursor or the selected area.
    # To select an area press ctrl-@ or ctrl-space and use the cursor.
    # Use case: you type "mv abc ~/testa/testb/testc/" and remember that the
    # directory does not exist yet -> press ctrl-XM and problem solved
    local PATHTOMKDIR
    if ((REGION_ACTIVE==1)); then
        local F=$MARK T=$CURSOR
        if [[ $F -gt $T ]]; then
            F=${CURSOR}
            T=${MARK}
        fi
        # get marked area from buffer and eliminate whitespace
        PATHTOMKDIR=${BUFFER[F+1,T]%%[[:space:]]##}
        PATHTOMKDIR=${PATHTOMKDIR##[[:space:]]##}
    else
        local bufwords iword
        bufwords=(${(z)LBUFFER})
        iword=${#bufwords}
        bufwords=(${(z)BUFFER})
        PATHTOMKDIR="${(Q)bufwords[iword]}"
    fi
    [[ -z "${PATHTOMKDIR}" ]] && return 1
    PATHTOMKDIR=${~PATHTOMKDIR}
    if [[ -e "${PATHTOMKDIR}" ]]; then
        zle -M " path already exists, doing nothing"
    else
        zle -M "$(mkdir -p -v "${PATHTOMKDIR}")"
        zle end-of-line
    fi
}

# thx to github.com/MitchWeaver/dots
75%() { mogrify -resize '75%X75%' "$@" ; }
50%() { mogrify -resize '50%X50%' "$@" ; }
25%() { mogrify -resize '25%X25%' "$@" ; }

# just type '...' to get '../..'
rationalise-dot() {
    local MATCH
    if [[ $LBUFFER =~ '(^|/| |  |'$'\n''|\||;|&)\.\.$' ]]; then
        LBUFFER+=/
        zle self-insert
        zle self-insert
    else
        zle self-insert
    fi
}
zle -N rationalise-dot

# run command line as user root via sudo:
sudo-command-line() {
    [[ -z $BUFFER ]] && zle up-history
    if [[ ${BUFFER} != sudo\ * ]]; then
        BUFFER="sudo ${BUFFER}"
        CURSOR=$(( CURSOR+5 ))
    fi
}
zle -N sudo-command-line

fg-widget() {
    stty icanon echo -inlcr < /dev/tty
    stty lnext '^V' quit '^\' susp '^Z' < /dev/tty
    zle reset-prompt
    if jobs %- >/dev/null 2>&1; then
        fg %-
    else
        fg
    fi
}
zle -N fg-widget

__expand-alias() {
	zle _expand_alias
	zle self-insert
}

expand_aliases() {
    zle -N __expand-alias
    bindkey -M main ' ' __expand-alias
}

up-one-dir() { pushd .. 2> /dev/null; zle redisplay; zle -M $(pwd);  }
back-one-dir() { popd     2> /dev/null; zle redisplay; zle -M $(pwd);  }
zle -N up-one-dir
zle -N back-one-dir

magic-abbrev-expand() {
    local MATCH
    LBUFFER=${LBUFFER%%(#m)[_a-zA-Z0-9]#}
    LBUFFER+=${abbreviations[$MATCH]:-$MATCH}
    zle self-insert
}

no-magic-abbrev-expand() { LBUFFER+=' ' }

slash-backward-kill-word () {
    local WORDCHARS="${WORDCHARS:s@/@}"
    zle backward-kill-word
}
zle -N slash-backward-kill-word

ap() {
    local inventory="$(pwd)/ansible/hosts"
    local lib="$(pwd)/ansible/library"
    local stdout_opt=""
    local opt1="${1}"
    if [[ "${opt1}" == "-V" ]]; then
        export ANSIBLE_STDOUT_CALLBACK="minimal"
        shift
    fi
    play="${1}"
    shift
    local options=""
    [[ ! -z "${ansible_user}" ]] && options="-u ${ansible_user}"
    export ANSIBLE_CONFIG="${XDG_CONFIG_HOME}/ansible/ansible.cfg"
    ansible-playbook ${options} -i "${inventory}" -M "${lib}" "${play}" "$@"
}
