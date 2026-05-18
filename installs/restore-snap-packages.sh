#!/usr/bin/env bash
# Reinstall snap packages from snapshots/snap-packages.txt.
# Some snaps need --classic confinement; we try the default first and retry
# with --classic on failure.

set -uo pipefail

LIST="$(cd "$(dirname "${BASH_SOURCE[0]}")/../snapshots" && pwd)/snap-packages.txt"

if ! command -v snap &>/dev/null; then
    echo "snap not installed; installing snapd via apt..."
    sudo apt-get update && sudo apt-get install -y snapd
fi

if [ ! -s "$LIST" ]; then
    echo "No snap snapshot — nothing to install."
    exit 0
fi

while read -r pkg; do
    [ -z "$pkg" ] && continue
    if snap list "$pkg" &>/dev/null; then
        echo "  [skip] $pkg already installed"
        continue
    fi
    echo "Installing snap: $pkg"
    if ! sudo snap install "$pkg"; then
        echo "  retrying with --classic..."
        sudo snap install --classic "$pkg" || echo "  [fail] $pkg"
    fi
done < "$LIST"
