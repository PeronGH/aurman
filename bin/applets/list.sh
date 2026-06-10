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
            epoch) epoch=$value ;;
        esac
    done <"$srcinfo"

    echo "${epoch:+$epoch:}$pkgver-$pkgrel"
}

pkgbuild_names() {
    local srcinfo=$1
    if [ -f "$srcinfo" ]; then
        awk '$1 == "pkgname" { print $3 }' "$srcinfo"
    fi
}

installed_version() {
    local -a versions
    mapfile -t versions < <(pacman -Q "$@" 2>/dev/null | awk '{print $2}' | sort -u)
    case ${#versions[@]} in
        0) echo "not installed" ;;
        1) echo "${versions[0]}" ;;
        *) echo "mixed" ;;
    esac
}

printf '%-30s %-20s %s\n' "PACKAGE" "INSTALLED" "PKGBUILD"
for dir in "$AUR_DIR"/*/; do
    pkg=$(basename "$dir")
    mapfile -t names < <(pkgbuild_names "$dir/.SRCINFO")
    [ ${#names[@]} -gt 0 ] || names=("$pkg")
    printf '%-30s %-20s %s\n' "$pkg" "$(installed_version "${names[@]}")" "$(pkgbuild_version "$dir/.SRCINFO")"
done
