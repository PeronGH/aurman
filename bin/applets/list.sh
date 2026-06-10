#!/usr/bin/env bash
set -euo pipefail

AUR_DIR="$HOME/aur"

die() {
    echo "${0##*/}: $*" >&2
    exit 1
}

pkgbuild_version() {
    local srcinfo=$1
    local key _ value pkgver='' pkgrel='' epoch=''

    while read -r key _ value; do
        case $key in
            pkgver) pkgver=$value ;;
            pkgrel) pkgrel=$value ;;
            epoch) epoch=$value ;;
        esac
    done <"$srcinfo"

    if [ -z "$pkgver" ] || [ -z "$pkgrel" ]; then
        die "$srcinfo: missing pkgver or pkgrel"
    fi

    echo "${epoch:+$epoch:}$pkgver-$pkgrel"
}

pkgbuild_names() {
    awk '$1 == "pkgname" { print $3 }' "$1"
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
    srcinfo="$dir/.SRCINFO"

    [ -f "$srcinfo" ] || die "$pkg: missing .SRCINFO in $dir"

    version=$(pkgbuild_version "$srcinfo")
    mapfile -t names < <(pkgbuild_names "$srcinfo")
    [ ${#names[@]} -gt 0 ] || die "$srcinfo: no pkgname entries"

    printf '%-30s %-20s %s\n' "$pkg" "$(installed_version "${names[@]}")" "$version"
done
