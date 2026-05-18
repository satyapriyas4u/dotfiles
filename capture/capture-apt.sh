#!/usr/bin/env bash
# Dump the list of manually-installed apt packages (i.e. not pulled in as
# dependencies). On a fresh Ubuntu install many of these will already be
# present and the installer will simply skip them.

set -euo pipefail

OUT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../snapshots" && pwd)/apt-packages.txt"

if ! command -v apt-mark &>/dev/null; then
    echo "apt-mark not found; skipping apt capture (not a Debian/Ubuntu system?)."
    exit 0
fi

apt-mark showmanual | sort > "$OUT"
echo "  wrote $(wc -l <"$OUT") packages -> ${OUT#"$PWD/"}"
