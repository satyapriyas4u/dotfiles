#!/usr/bin/env bash
# Dump installed VS Code extension IDs (one per line).

set -euo pipefail

OUT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../snapshots" && pwd)/vscode-extensions.txt"

if ! command -v code &>/dev/null; then
    echo "code (VS Code CLI) not found; skipping."
    exit 0
fi

code --list-extensions | sort > "$OUT"
echo "  wrote $(wc -l <"$OUT") extensions -> ${OUT#"$PWD/"}"
