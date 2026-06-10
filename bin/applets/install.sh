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
    if [ -d "$dir/.git" ]; then
        git -C "$dir" pull --ff-only
    else
        git clone "$AUR_URL/$pkg.git" "$dir"
    fi
    (cd "$dir" && makepkg -si)
done
