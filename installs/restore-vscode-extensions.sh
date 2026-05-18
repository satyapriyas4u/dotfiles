#!/usr/bin/env bash
# Install every VS Code extension listed in snapshots/vscode-extensions.txt.

set -uo pipefail

LIST="$(cd "$(dirname "${BASH_SOURCE[0]}")/../snapshots" && pwd)/vscode-extensions.txt"

if ! command -v code &>/dev/null; then
    echo "VS Code CLI ('code') not found. Install VS Code first, then re-run."
    exit 0
fi

if [ ! -s "$LIST" ]; then
    echo "No vscode-extensions snapshot — nothing to install."
    exit 0
fi

installed=$(code --list-extensions)
while read -r ext; do
    [ -z "$ext" ] && continue
    if echo "$installed" | grep -Fxqi "$ext"; then
        echo "  [skip] $ext"
        continue
    fi
    echo "Installing extension: $ext"
    code --install-extension "$ext" || echo "  [fail] $ext"
done < "$LIST"
