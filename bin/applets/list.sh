#!/usr/bin/env bash
set -euo pipefail

AUR_DIR="$HOME/aur"

pkgbuild_version() {
    local srcinfo=$1
    local key _ value pkgver='?' pkgrel='?' epoch=''

    if [ ! -f "$srcinfo" ]; then
        echo "-"
        return
    fi

    while read -r key _ value; do
        case $key in
            pkgver) pkgver=$value ;;
            pkgrel) pkgrel=$value ;;
            epoch)  epoch=$value ;;
        esac
    done <"$srcinfo"

    echo "${epoch:+$epoch:}$pkgver-$pkgrel"
}

installed_version() {
    pacman -Q "$1" 2>/dev/null | awk '{print $2}' || echo "not installed"
}

printf '%-30s %-20s %s\n' "PACKAGE" "INSTALLED" "PKGBUILD"
for dir in "$AUR_DIR"/*/; do
    pkg=$(basename "$dir")
    printf '%-30s %-20s %s\n' "$pkg" "$(installed_version "$pkg")" "$(pkgbuild_version "$dir/.SRCINFO")"
done
