# not interactive shell, go home
[ -z "$PS1" ] && return

################################################################################
# shell config
################################################################################

#complete -r
#unset command_not_found_handle

# Additional file with nonpublic envs
[[ -e ~/.env ]] && source ~/.env

# machine checker
uname_output="$(uname -s)"
case "${uname_output}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    CYGWIN*)    machine=Cygwin;;
    MINGW*)     machine=MinGw;;
    *)          machine="UNKNOWN:${unameOut}"
esac

# lesspipe - userfull for archive files and not only
[ -x /usr/bin/lesspipe ] && eval "$(lesspipe)"
# autoupdate COLUMNS/LINES
shopt -s checkwinsize
# ignore spaces, duplicates and fgs
export HISTCONTROL=ignoreboth
export HISTIGNORE='fg'
export HISTFILESIZE=16384000

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
    export VIRTUALENVWRAPPER_PYTHON=python3
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

#set bash completion kubectl
if type -p kubectl >/dev/null; then
  source <(kubectl completion bash)
fi

# Google Cloud SDK
# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/mastier/Downloads/google-cloud-sdk/path.bash.inc' ]; then . '/home/mastier/Downloads/google-cloud-sdk/path.bash.inc'; fi
# The next line enables shell command completion for gcloud.
if [ -f '/home/mastier/Downloads/google-cloud-sdk/completion.bash.inc' ]; then . '/home/mastier/Downloads/google-cloud-sdk/completion.bash.inc'; fi
# load cargo if exists
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

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
alias nvrun='__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME="nvidia" __VK_LAYER_NV_optimus="NVIDIA_only" '

if ip -c addr >/dev/null; then
  alias ip='ip -c'
fi
#exceptions for Mac
if [[ "$machine" == "Mac" ]]; then
  alias rm='rm -i'
  alias grep='grep --color=always'
  if type greadlink>/dev/null; then
    alias readlink=greadlink
  fi
fi

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

#public_ip
function publicip {
   local ip
   local netname
   if [[ -n "$PUBLIC_IP_CHECK_URL" ]]; then
     ip="$(curl -sL "$PUBLIC_IP_CHECK_URL")"
     netname=$(whois $ip|grep 'netname:'|awk '{print $2}')
     echo "Your public IP is: $ip ($netname)"
   else
     echo "Please specify env variable PUBLIC_IP_CHECK_URL!" >&2
     echo "export PUBLIC_IP_CHECK_URL=" >&2
  fi
}

# play channels
function chan {
    cvlc --loop http://10.8.1.10:$1
}
function chanv {
    vlc --loop http://10.8.1.10:$1
}

function mtwake {
    ssh $1 "/tool wol interface=bridge mac=[/ip dhcp-server lease get [find host-name=$2] mac-address]"
}

function openfilesshow {
  sudo lsof | awk '{ print $1 " " $2; }' | sort -rn | uniq -c | sort -rn | head -15
}

function gituser_switch {
  gituser_current=$(readlink -f ~/.gituser)

  if [ "$(basename "$gituser_current")" == ".gituser-company" ]; then
    ln -sf ~/.gituser-regular ~/.gituser
  elif [ "$(basename "$gituser_current")" == ".gituser-regular" ]; then
    ln -sf ~/.gituser-company ~/.gituser
  else
    echo "ERR: No such file .gituser-company or .gituser-regular"
    return 1
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

  echo "Mounting special devices /{dev,proc,sys,dev/pts}"
  sudo mount -o bind /dev "$rootfs/dev"
  sudo mount -t proc none "$rootfs/proc"
  sudo mount -t sysfs none "$rootfs/sys"
  sudo mount -t devpts devpts "$rootfs/dev/pts"
  echo "Running chroot..."

  sudo chroot "$rootfs" /bin/sh
  echo "Leaving chroot..."
  echo "umount" "$rootfs"/{proc,sys,dev/pts,dev}
  # unmount after leaving chroot
  echo "Unmounting special devices {proc,sys,dev/pts,dev}"
  sudo umount "$rootfs"/{proc,sys,dev/pts,dev} || ( echo "Failed to unmount {proc,sys,dev/pts,dev}!" && return 1 )
  echo "Unmounting ${loopdev}p1"
  udisksctl unmount -b "${loopdev}p1" || echo "Failed to udisksctl unmount -b ${loopdev}p1!"
  #sleep 1
  #echo "Deleting loop device ${loopdev}"
  #udisksctl loop-delete -b "${loopdev}" || echo "Failed to udisksctl loop-delete -b ${loopdev}"
}

[[ -e ~/.bashrc.local ]] && source ~/.bashrc.local

if [[ "$OSTYPE" == darwin* ]]; then
  PATH="/Users/mastier/perl5/bin${PATH:+:${PATH}}"; export PATH;
  PERL5LIB="/Users/mastier/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
  PERL_LOCAL_LIB_ROOT="/Users/mastier/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
  PERL_MB_OPT="--install_base \"/Users/mastier/perl5\""; export PERL_MB_OPT;
  PERL_MM_OPT="INSTALL_BASE=/Users/mastier/perl5"; export PERL_MM_OPT;
fi

vfio-unbind-nvidia() {
  sudo bash -c 'echo 0000:01:00.1 > /sys/bus/pci/devices/0000\:01\:00.1/driver/unbind'
  sudo bash -c 'echo 0000:01:00.0 > /sys/bus/pci/devices/0000\:01\:00.0/driver/unbind'
}

# PulseSecure GrID reader
getgrid() {
  if [[ ! -f ~/.grid ]]; then
    echo "Missing .grid in home directory"
    return
  fi
  source ~/.grid
  # GRID_PIN is your GrID PIN (will be added to the string)
  # GRID_PATTERN is the pattern of table, cells start top with 0, then each row: left to right
  # GRID_URL is URL to the GrID picture (check the http request that is sent to fetch it)
  for setting in GRID_PIN GRID_PATTERN GRID_URL; do
    [[ -n "${!setting}" ]] || (echo "$setting not set in ~/.grid ! Please set it" && return)
  done
  GRID_TMP_PICTURE="$(mktemp --suffix .jpg)"
  wget -q -O"$GRID_TMP_PICTURE" "$GRID_URL"
  # We rely on OpenCV Python script to remove lines (might be all Python later implemented)
  remove_lines.py $GRID_TMP_PICTURE
  #echo "GrID pattern: $GRID_PATTERN"
  GRID_RAW="$(gocr -C0-9 ${GRID_TMP_PICTURE})"
  echo -e "Recognised: \n$GRID_RAW"
  echo -n "Token: "
  GRID="$(echo $GRID_RAW |grep -oP '[0-9]'|tr -d '\n')"
  echo -n "$GRID_PIN"
  for char in ${GRID_PATTERN[@]}; do
    echo -n "${GRID:$char:1}"
  done
  echo
  rm "$GRID_TMP_PICTURE"
}

if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    export MOZ_ENABLE_WAYLAND=1
fi

# Switch screens to Windows VM with GPU passthrough
# Attach keyboard and mouse there also
switch_vmhost() {
  if [ "$1" = "win" ]; then
    sudo ddccontrol -r 0x60 dev:/dev/i2c-8 -w 15
    sudo ddccontrol -r 0x60 dev:/dev/i2c-13 -w 17
    sudo virsh attach-device win11 --live --file /dev/stdin <<EOF
<hostdev mode='subsystem' type='usb' managed='yes'>
      <source>
        <vendor id='0x3434'/>
        <product id='0xd033'/>
      </source>
    </hostdev>
EOF
    sudo virsh attach-device win11 --live --file /dev/stdin <<EOF
<hostdev mode='subsystem' type='usb' managed='yes'>
      <source>
        <vendor id='0x05ac'/>
        <product id='0x024f'/>
      </source>
    </hostdev>
EOF
  fi

  if [ "$1" = "host" ]; then
    sudo ddccontrol -r 0x60 dev:/dev/i2c-8 -w 17
    sudo ddccontrol -r 0x60 dev:/dev/i2c-13 -w 15
    sudo virsh detach-device win11 --live --file /dev/stdin <<EOF
<hostdev mode='subsystem' type='usb' managed='yes'>
      <source>
        <vendor id='0x3434'/>
        <product id='0xd033'/>
      </source>
    </hostdev>
EOF
    sudo virsh detach-device win11 --live --file /dev/stdin <<EOF
<hostdev mode='subsystem' type='usb' managed='yes'>
      <source>
        <vendor id='0x05ac'/>
        <product id='0x024f'/>
      </source>
    </hostdev>
EOF
  fi
}
