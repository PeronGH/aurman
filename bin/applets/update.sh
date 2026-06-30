#!/usr/bin/env bash
set -euo pipefail

# shellcheck source-path=SCRIPTDIR
# shellcheck source=../lib/aur.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/aur.sh"

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

acted=false
for dir in "${dirs[@]}"; do
    [ -d "$dir/.git" ] || continue
    pkg=$(basename "$dir")

    git -C "$dir" fetch --quiet
    head=$(git -C "$dir" rev-parse HEAD)
    target=$(git -C "$dir" rev-parse "$(upstream_ref "$dir")")

    if [ "$head" != "$target" ]; then
        assert_clean "$dir"
        if git -C "$dir" diff --quiet "$head" "$target"; then
            # History rewritten but tree unchanged: resync without rebuilding.
            advance "$dir" "$target"
        else
            acted=true
            echo "==> $pkg has upstream changes"
            review_diff "$dir" "$head" "$target"
            if confirm "Update and install $pkg?"; then
                update_to "$dir" "$target" "$head"
            else
                echo "skipping $pkg"
            fi
            continue
        fi
    fi

    if ! installed_matches_pkgbuild "$dir"; then
        acted=true
        echo "==> $pkg: installed version differs from PKGBUILD"
        if confirm "Rebuild and install $pkg?"; then
            build "$dir"
        else
            echo "skipping $pkg"
        fi
    fi
done

"$acted" || echo "all packages are up to date"
