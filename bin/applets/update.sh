#!/usr/bin/env bash
set -euo pipefail

AUR_DIR="$HOME/aur"
APPLET_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

die() {
    echo "${0##*/}: $*" >&2
    exit 1
}

if [ $# -gt 0 ]; then
    dirs=()
    for pkg in "$@"; do
        dir="$AUR_DIR/$pkg"
        [ -d "$dir/.git" ] || die "$pkg: no clone in $AUR_DIR"
        dirs+=("$dir")
    done
else
    dirs=("$AUR_DIR"/*/)
fi

for dir in "${dirs[@]}"; do
    [ -d "$dir/.git" ] || continue
    echo "pulling $(basename "$dir")"
    git -C "$dir" pull --ff-only --quiet
done

outdated=$("$APPLET_DIR/list.sh" | awk -v want="$*" '
    BEGIN { n = split(want, w, " "); for (i = 1; i <= n; i++) sel[w[i]] = 1 }
    NR > 1 && NF == 3 && $2 != $3 && (n == 0 || sel[$1]) { print $1 }
')

if [ -z "$outdated" ]; then
    echo "all packages are up to date"
    exit 0
fi

mapfile -t pkgs <<<"$outdated"
exec "$APPLET_DIR/install.sh" "${pkgs[@]}"
