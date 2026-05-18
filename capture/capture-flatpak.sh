#!/usr/bin/env bash
# Dump installed flatpak application IDs (one per line).

set -euo pipefail

OUT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../snapshots" && pwd)/flatpak-apps.txt"

if ! command -v flatpak &>/dev/null; then
    echo "flatpak not found; writing empty list."
    : > "$OUT"
    exit 0
fi

flatpak list --app --columns=application 2>/dev/null | sort > "$OUT"
echo "  wrote $(wc -l <"$OUT") flatpak apps -> ${OUT#"$PWD/"}"
