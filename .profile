# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# add sbin to path if is not there yet
if [ "$PATH" != *sbin* ]; then
    PATH="/usr/local/sbin:/usr/sbin:/sbin:$PATH"
fi
# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi
mkdir -p ~/.local/bin
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

if locale -a | grep -q 'pl_PL.UTF-8'; then
  LANG="pl_PL.UTF-8"
  LC_ALL="pl_PL.UTF-8"
else
  LANG="en_US.UTF-8"
  LC_ALL="en_US.UTF-8"
fi
