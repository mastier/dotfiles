# not interactive shell, go home
[ -z "$PS1" ] && return

################################################################################
# shell config
################################################################################

#complete -r
#unset command_not_found_handle

# lesspipe - userfull for archive files and not only
[ -x /usr/bin/lesspipe ] && eval "$(lesspipe)"
# autoupdate COLUMNS/LINES
shopt -s checkwinsize
# ignore spaces, duplicates and fgs
export HISTCONTROL=ignoreboth
export HISTIGNORE='fg'

# generate my default ~/.host_colors if nonexistent
if [[ ! -e ~/.host_colors ]]; then
    echo "B_USER=1"  >> ~/.host_colors
    echo "C_USER=32" >> ~/.host_colors
    echo "B_ROOT=1"  >> ~/.host_colors
    echo "C_ROOT=31" >> ~/.host_colors
    echo "B_HOST=1"  >> ~/.host_colors
    echo "C_HOST=33" >> ~/.host_colors
fi
source ~/.host_colors
# set prompt
PS1='\[\e[0;$((UID?B_USER:B_ROOT));$((UID?C_USER:C_ROOT))m\]\u\[\e[0m\]@\[\e[0;$B_HOST;${C_HOST}m\]\h\[\e[0m\]:\w\[\e[0;1;$(($??31:32))m\]\$\[\e[0m\] '
# set screen title
PROMPT_COMMAND='[[ "$TERM" == screen ]] && echo -ne "\\x1bk${PWD##*/}\\x1b\\"'

# set WORKON_HOME for virtualenvwrapper
if type -p virtualenvwrapper_lazy.sh >/dev/null; then
    export WORKON_HOME=~/Envs
    source virtualenvwrapper_lazy.sh
fi

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

# fortune to smile everytime you run the shell. Keeps fortune story  :-)
if type -p fortune >/dev/null; then
	echo
	[[ -e ~/.last-fortune ]] && mv -f ~/.last-fortune ~/.prev-fortune
	fortune -a | tee ~/.last-fortune
	echo
fi

#set PAGER for manpages to most
if type -p most >/dev/null; then
    alias man="PAGER='most' man"
fi

#set GOPATH for Go compiler
if type -p go >/dev/null; then
  export GOPATH=~/.go 
  export PATH="$GOPATH/bin:$PATH"
fi

################################################################################
# aliases
################################################################################

#unset use_color safe_term match_lhs
alias a='sudo aptitude'
alias as='aptitude search'
alias ash='aptitude show'
alias ai='sudo aptitude install'
alias s='screen'
alias rm='rm -I'
alias cp='cp -i'
alias mv='mv -i'
test -e /usr/share/mc/bin/mc.sh && source /usr/share/mc/bin/mc.sh
alias g='geeqie'
alias S='sudo -i'
alias i='ipython'
alias ekg='luit -encoding iso8859-2 ekg'
alias ekg-svn='luit -encoding iso8859-2 ekg-svn'
alias zgas='xset dpms force off'


# cure for differently working tools on MACOS like df or ls
if [[ "$OSTYPE" == darwin* ]]; then
    export DF_OPTIONS='-h'
    export LS_OPTIONS='-FG'
else
    export DF_OPTIONS='-h -xtmpfs -xdevtmpfs -xdebugfs'
    export LS_OPTIONS='-F -T 0 --color=auto'
    # set bash colors for different filetypes
    if [ "$TERM" != "dumb" ]; then 
        eval "`dircolors -b`"
    fi
fi
alias ls='ls $LS_OPTIONS'
alias df='df $DF_OPTIONS'

#disable proxy
function disable_proxy {
    unset $(env | awk -F= '/.*_(proxy|PROXY)/ {print $1}')
}

# play channels
function chan { 
    cvlc --loop http://10.8.1.10:$1 
}
function chanv { 
    vlc --loop http://10.8.1.10:$1 
}

function gituser_switch {
  gituser_current=$(readlink -f ~/.gituser)

  if [ "$(basename "$gituser_current")" == ".gituser-company" ]; then
    ln -sf ~/.gituser-regular ~/.gituser
  elif [ "$(basename "$gituser_current")" == ".gituser-regular" ]; then
    ln -sf ~/.gituser-company ~/.gituser
  else
    echo "ERR: No such file .gituser-company or .gituser-regular"
    exit 1
  fi
  ls -l ~/.gituser
}

edit_image() {
  echo -n "Setting loop device"
  loopdev=$( udisksctl loop-setup -f "$1" | awk '{print $5;}'| tr -d '.' )
  echo -n " ${loopdev}"
  sleep 1
  rootfs=$( mount | grep "$loopdev" | awk '{print $3;}')
  echo " mounted at $rootfs"

  echo "Mounting special devices /{dev,proc,sys}"
  sudo mount -o bind /dev "$rootfs/dev"
  sudo mount -t proc none "$rootfs/proc"
  sudo mount -t sysfs none "$rootfs/sys"
  echo "Running chroot..."

  sudo chroot "$rootfs"
  echo "Leaving chroot..."
  # unmount after leaving chroot
  echo "Unmounting special devices /{dev,proc,sys}"
  sudo umount "$rootfs"/{dev,proc,sys} || echo "Failed to unmount!" && exit 1
  echo "Unmounting ${loopdev}p1"
  udisksctl unmount -b "${loopdev}p1"
  sleep 1
  echo "Deleting loop device ${loopdev}"
  udisksctl loop-delete -b "${loopdev}"
}

source ~/.bashrc.local
