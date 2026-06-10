#!/usr/bin/env bash
set -euo pipefail

APPLET_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/applets" && pwd)"

usage() {
    echo "usage: ${0##*/} <command> [args...]"
    echo "commands:"
    for applet in "$APPLET_DIR"/*.sh; do
        [ -e "$applet" ] || continue
        name=$(basename "$applet" .sh)
        echo "  $name"
    done
}

if [ $# -eq 0 ]; then
    usage >&2
    exit 1
fi

cmd=$1
shift

applet="$APPLET_DIR/$cmd.sh"
if [ ! -f "$applet" ]; then
    echo "${0##*/}: unknown command '$cmd'" >&2
    usage >&2
    exit 1
fi

exec "$applet" "$@"
