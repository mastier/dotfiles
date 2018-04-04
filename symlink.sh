#!/bin/bash

set -e
# add dotfiles to glob
shopt -s dotglob
# make glob return emptystring on nomatch
shopt -s nullglob

# for any dotfile except .. and .
for dotfile in .[^.]?*; do
    case "$dotfile" in
        .git) continue ;;
        .gitmodules) continue ;;
        *.sw*) continue ;;
    esac
    
    target="$HOME/$dotfile"
    dotfile="$PWD/$dotfile"

    if [[ -L "$target" ]] && [[ "$(readlink "$target")" == "$dotfile" ]]; then
        echo "skipping: $dotfile"
	continue
    elif [[ -f "$target" ]] || [[ -d "$target" ]]; then
        echo "move: $dotfile -> ${dotfile}.dist"
        mv "$target" "$target.dist"
    fi

    if ! [[ -e "$target" ]]; then
        echo "install: $dotfile -> $target"
        ln -sf "$dotfile" "$target"
    else
        echo "PROBLEMO: Already exist and ain't symlink, regular file or dir: $dotfile "
        exit 1
    fi
done
