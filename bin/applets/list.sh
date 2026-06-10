#!/usr/bin/env bash
set -euo pipefail

AUR_DIR="$HOME/aur"

pkgbuild_version() {
    local pkgbuild=$1
    [ -f "$pkgbuild" ] || { echo "-"; return; }
    (
        # shellcheck disable=SC1090
        source "$pkgbuild" >/dev/null 2>&1
        echo "${epoch:+$epoch:}${pkgver:-?}-${pkgrel:-?}"
    )
}

printf '%-30s %-20s %s\n' "PACKAGE" "INSTALLED" "PKGBUILD"
for dir in "$AUR_DIR"/*/; do
    pkg=$(basename "$dir")
    installed=$(pacman -Q "$pkg" 2>/dev/null | awk '{print $2}') || installed="not installed"
    printf '%-30s %-20s %s\n' "$pkg" "$installed" "$(pkgbuild_version "$dir/PKGBUILD")"
done
