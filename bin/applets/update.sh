#!/usr/bin/env bash
set -euo pipefail

AUR_DIR="$HOME/aur"
APPLET_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for dir in "$AUR_DIR"/*/; do
    [ -d "$dir/.git" ] || continue
    echo "pulling $(basename "$dir")"
    git -C "$dir" pull --ff-only --quiet
done

outdated=$("$APPLET_DIR/list.sh" | awk 'NR > 1 && NF == 3 && $2 != $3 { print $1 }')

if [ -z "$outdated" ]; then
    echo "all packages are up to date"
    exit 0
fi

mapfile -t pkgs <<<"$outdated"
exec "$APPLET_DIR/install.sh" "${pkgs[@]}"
