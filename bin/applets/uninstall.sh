#!/usr/bin/env bash
set -euo pipefail

# shellcheck source-path=SCRIPTDIR
# shellcheck source=../lib/aur.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/aur.sh"

if [ $# -eq 0 ]; then
    echo "usage: ${0##*/} <package>..." >&2
    exit 1
fi

for pkg in "$@"; do
    dir="$AUR_DIR/$pkg"
    srcinfo="$dir/.SRCINFO"

    [ -d "$dir" ] || die "$pkg: no clone in $AUR_DIR"
    [ -f "$srcinfo" ] || die "$pkg: missing .SRCINFO in $dir"

    mapfile -t names < <(pkgbuild_names "$srcinfo")
    [ ${#names[@]} -gt 0 ] || die "$srcinfo: no pkgname entries"

    mapfile -t installed < <(pacman -Q "${names[@]}" 2>/dev/null | awk '{print $1}')
    [ ${#installed[@]} -gt 0 ] || die "$pkg: no packages from this base installed"

    sudo pacman -Rns "${installed[@]}"
    rm -rf "$dir"
done
