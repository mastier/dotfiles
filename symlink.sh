#!/bin/bash

set -e
# add dotfiles to glob
shopt -s dotglob
# make glob return emptystring on nomatch
shopt -s nullglob

main() {
# for any dotfile except .. and .
echo "Installing dotfiles..."
for dotfile in .[^.]?*; do
  case "$dotfile" in
    .git) continue ;;
    .gitmodules) continue ;;
    *.sw*) continue ;;
  esac

  target="$HOME/$dotfile"
  dotfile="$PWD/$dotfile"
  install_symlink "$dotfile" "$target"
done

# for listed config
echo "Installing configs..."
for conf in config/*; do
  target="$HOME/.config/$(basename "$conf")"
  conf="$PWD/$conf"
  install_symlink "$conf" "$target"
done
}

install_symlink() {
  local src="$1"
  local target="$2"

  if [[ -L "$target" ]] && [[ "$(readlink "$target")" == "$src" ]]; then
    echo "skipping: $src"
	  return
  elif [[ -f "$target" ]] || [[ -d "$target" ]]; then
    echo "move: $src -> ${source}.dist"
    mv "$target" "$target.dist"
  fi

    if ! [[ -e "$target" ]]; then
      echo "install: $src -> $target"
      ln -sf "$src" "$target"
    else
      echo "PROBLEMO: Already exist and ain't symlink, regular file or dir: $target "
      exit 1
    fi
}

main
