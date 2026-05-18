#!/usr/bin/env bash
# Dump installed snap package names (one per line). The restore script
# reinstalls each from the default snap store.

set -euo pipefail

OUT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../snapshots" && pwd)/snap-packages.txt"

if ! command -v snap &>/dev/null; then
    echo "snap not found; skipping."
    : > "$OUT"
    exit 0
fi

# Skip the "core*" base snaps and "snapd*" — these are auto-installed as deps
# of other snaps and don't need to be listed explicitly.
snap list 2>/dev/null \
    | awk 'NR>1 {print $1}' \
    | grep -Ev '^(core|core[0-9]+|snapd|snapd-desktop-integration|bare|gnome-[0-9-]+|gtk-common-themes|mesa-[0-9-]+|firmware-updater|cups|ffmpeg-[0-9-]+|canonical-livepatch)$' \
    | sort > "$OUT"

echo "  wrote $(wc -l <"$OUT") snaps -> ${OUT#"$PWD/"}"
