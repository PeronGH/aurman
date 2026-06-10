#!/usr/bin/env bash
set -euo pipefail

APPLET_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mapfile -t outdated < <(
    "$APPLET_DIR/list.sh" | awk 'NR > 1 && NF == 3 && $2 != $3 && $3 != "-" { print $1 }'
)

if [ ${#outdated[@]} -eq 0 ]; then
    echo "all packages are up to date"
    exit 0
fi

exec "$APPLET_DIR/install.sh" "${outdated[@]}"
