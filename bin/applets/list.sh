#!/usr/bin/env bash
set -euo pipefail

AUR_DIR="$HOME/aur"

for dir in "$AUR_DIR"/*/; do
    pkg=$(basename "$dir")
    if version=$(pacman -Q "$pkg" 2>/dev/null | awk '{print $2}'); then
        printf '%-30s %s\n' "$pkg" "$version"
    else
        printf '%-30s %s\n' "$pkg" "not installed"
    fi
done
