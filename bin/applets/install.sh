#!/usr/bin/env bash
set -euo pipefail

AUR_DIR="$HOME/aur"
AUR_URL="https://aur.archlinux.org"

if [ $# -eq 0 ]; then
    echo "usage: ${0##*/} <package>..." >&2
    exit 1
fi

mkdir -p "$AUR_DIR"

for pkg in "$@"; do
    dir="$AUR_DIR/$pkg"
    if [ ! -d "$dir/.git" ]; then
        git clone "$AUR_URL/$pkg.git" "$dir"
    fi
    less "$dir/PKGBUILD"
    read -rp "Build and install $pkg? [y/N] " reply
    case $reply in
        [yY]) (cd "$dir" && makepkg -si) ;;
        *) echo "skipping $pkg" ;;
    esac
done
