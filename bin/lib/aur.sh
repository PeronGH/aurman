# shellcheck shell=bash
# Shared helpers for the aurman applets. Source, do not execute.

# shellcheck disable=SC2034  # AUR_DIR is consumed by the applets that source this file
AUR_DIR="${AURMAN_AUR_DIR:-$HOME/aur}"
AUR_URL="https://aur.archlinux.org"

die() {
    echo "${0##*/}: $*" >&2
    exit 1
}

confirm() {
    local reply
    read -rp "$1 [y/N] " reply
    [[ $reply == [yY] ]]
}

build() {
    (cd "$1" && makepkg -si)
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

# True when the installed packages already match the PKGBUILD in the clone.
installed_matches_pkgbuild() {
    local dir=$1
    local srcinfo="$dir/.SRCINFO"
    [ -f "$srcinfo" ] || die "$(basename "$dir"): missing .SRCINFO in $dir"

    local -a names
    mapfile -t names < <(pkgbuild_names "$srcinfo")
    [ ${#names[@]} -gt 0 ] || die "$srcinfo: no pkgname entries"

    [ "$(installed_version "${names[@]}")" = "$(pkgbuild_version "$srcinfo")" ]
}

# Clone an AUR package base into $2, validating it is a real package base.
clone_validate() {
    local pkg=$1 dir=$2
    git clone "$AUR_URL/$pkg.git" "$dir"
    if [ ! -f "$dir/PKGBUILD" ]; then
        rm -rf "$dir"
        die "'$pkg' is not an AUR package base (split packages must be installed by pkgbase)"
    fi
}

# Page the full PKGBUILD and any install scripts it declares.
review_full() {
    local dir=$1
    local -a review=("$dir/PKGBUILD")
    if [ -f "$dir/.SRCINFO" ]; then
        local script
        while read -r script; do
            review+=("$dir/$script")
        done < <(awk '$1 == "install" { print $3 }' "$dir/.SRCINFO" | sort -u)
    fi
    tail -v -n +1 "${review[@]}" | "${PAGER:-less}"
}

# Page the net content change between two revisions of a clone.
review_diff() {
    local dir=$1 base=$2 target=$3
    git -C "$dir" diff "$base" "$target" | "${PAGER:-less}"
}

# Name of the upstream ref to compare against, or die if there is none.
upstream_ref() {
    local dir=$1
    if git -C "$dir" rev-parse --quiet --verify '@{u}' >/dev/null 2>&1; then
        echo '@{u}'
    elif git -C "$dir" rev-parse --quiet --verify 'origin/HEAD' >/dev/null 2>&1; then
        echo 'origin/HEAD'
    else
        die "$(basename "$dir"): no upstream tracking branch"
    fi
}

# Refuse to proceed if the clone has local modifications to tracked files.
# Untracked makepkg build artifacts (src/, pkg/, *.pkg.tar.*) are ignored.
assert_clean() {
    local dir=$1
    if ! git -C "$dir" diff --quiet || ! git -C "$dir" diff --cached --quiet; then
        die "$(basename "$dir"): clone has local changes; refusing to overwrite"
    fi
}

# Move the clone's worktree to $2, discarding upstream history rewrites.
advance() {
    git -C "$1" reset --hard --quiet "$2"
}

# Advance to $2 and build; if the build fails, roll back to $3 so the clone
# keeps reflecting the last revision that was actually reviewed and built.
update_to() {
    local dir=$1 target=$2 fallback=$3
    advance "$dir" "$target"
    if ! build "$dir"; then
        advance "$dir" "$fallback"
        die "$(basename "$dir"): build failed; clone restored to previous revision"
    fi
}
