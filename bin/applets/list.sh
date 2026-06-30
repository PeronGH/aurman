#!/usr/bin/env bash
set -euo pipefail

# shellcheck source-path=SCRIPTDIR
# shellcheck source=../lib/aur.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/aur.sh"

printf '%-30s %-20s %s\n' "PACKAGE" "INSTALLED" "PKGBUILD"
for dir in "$AUR_DIR"/*/; do
    [ -d "$dir" ] || continue
    pkg=$(basename "$dir")
    srcinfo="$dir/.SRCINFO"

    [ -f "$srcinfo" ] || die "$pkg: missing .SRCINFO in $dir"

    version=$(pkgbuild_version "$srcinfo")
    mapfile -t names < <(pkgbuild_names "$srcinfo")
    [ ${#names[@]} -gt 0 ] || die "$srcinfo: no pkgname entries"

    printf '%-30s %-20s %s\n' "$pkg" "$(installed_version "${names[@]}")" "$version"
done
