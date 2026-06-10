#!/usr/bin/env bash
set -euo pipefail

AUR_DIR="$HOME/aur"

pkgbuild_version() {
    local srcinfo=$1 pkgver= pkgrel= epoch= key value
    [ -f "$srcinfo" ] || { echo "-"; return; }
    while IFS= read -r line; do
        key=${line%%=*}; key=${key//[[:space:]]/}
        value=${line#*=}; value=${value#"${value%%[![:space:]]*}"}
        case $key in
            pkgver) pkgver=$value ;;
            pkgrel) pkgrel=$value ;;
            epoch)  epoch=$value ;;
        esac
    done <"$srcinfo"
    echo "${epoch:+$epoch:}${pkgver:-?}-${pkgrel:-?}"
}

printf '%-30s %-20s %s\n' "PACKAGE" "INSTALLED" "PKGBUILD"
for dir in "$AUR_DIR"/*/; do
    pkg=$(basename "$dir")
    installed=$(pacman -Q "$pkg" 2>/dev/null | awk '{print $2}') || installed="not installed"
    printf '%-30s %-20s %s\n' "$pkg" "$installed" "$(pkgbuild_version "$dir/.SRCINFO")"
done
