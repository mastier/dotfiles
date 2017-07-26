# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=/home/woronicz/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="nebirhos"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

export PATH=~/.local/bin:$PATH

if type -p go >/dev/null; then
  export GOPATH=~/.go 
  export PATH="$GOPATH/bin:$PATH"
fi

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

sharescreen2cam() {
  if [[ "x$1" == "x" ]]; then 1=0; fi
  lsmod | grep v4l2loopback >/dev/null || sudo modprobe v4l2loopback
  echo "ffmpeg -f x11grab -r 15 -s 1920x1080 -i :0.0+$1,0 -vcodec rawvideo -pix_fmt yuv420p -threads 0 -f v4l2 /dev/video1"
  ffmpeg -f x11grab -r 15 -s 1920x1080 -i ":0.0+$1,0" -vcodec rawvideo -pix_fmt yuv420p -threads 0 -f v4l2 /dev/video1
}

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

if type -p virtualenvwrapper_lazy.sh >/dev/null; then
    export WORKON_HOME=~/Envs
    source virtualenvwrapper_lazy.sh
fi

if ! type -p pip >/dev/null; then
  echo "NO pip installed! Downloading and installing... in ~/.local"
  python <(curl -sf https://bootstrap.pypa.io/get-pip.py) --user
fi

if type -p most >/dev/null; then
  PAGER=most
fi

