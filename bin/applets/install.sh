#!/usr/bin/env bash
set -euo pipefail

# shellcheck source-path=SCRIPTDIR
# shellcheck source=../lib/aur.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/aur.sh"

if [ $# -eq 0 ]; then
    echo "usage: ${0##*/} <package>..." >&2
    exit 1
fi

mkdir -p "$AUR_DIR"

for pkg in "$@"; do
    dir="$AUR_DIR/$pkg"
    cloned=false
    if [ ! -d "$dir/.git" ]; then
        clone_validate "$pkg" "$dir"
        cloned=true
    fi
    review_full "$dir"
    if confirm "Build and install $pkg?"; then
        build "$dir"
    else
        echo "skipping $pkg"
        "$cloned" && rm -rf "$dir"
    fi
done
