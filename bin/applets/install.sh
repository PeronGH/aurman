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
        if [ ! -f "$dir/PKGBUILD" ]; then
            rm -rf "$dir"
            echo "${0##*/}: '$pkg' is not an AUR package base (split packages must be installed by pkgbase)" >&2
            exit 1
        fi
    fi
    review=("$dir/PKGBUILD")
    if [ -f "$dir/.SRCINFO" ]; then
        while read -r script; do
            review+=("$dir/$script")
        done < <(awk '$1 == "install" { print $3 }' "$dir/.SRCINFO" | sort -u)
    fi
    tail -v -n +1 "${review[@]}" | "${PAGER:-less}"
    read -rp "Build and install $pkg? [y/N] " reply
    case $reply in
        [yY]) (cd "$dir" && makepkg -si) ;;
        *) echo "skipping $pkg" ;;
    esac
done
