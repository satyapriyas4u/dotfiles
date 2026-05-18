#!/usr/bin/env bash
# Capture current system state into ../snapshots/ for replication on a new machine.
# Re-run this any time you've installed new apps / extensions / settings you want
# to carry forward, then commit the snapshots/ changes to git.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Capturing apt packages..."
"${SCRIPT_DIR}/capture-apt.sh"

echo "==> Capturing snap packages..."
"${SCRIPT_DIR}/capture-snap.sh"

echo "==> Capturing flatpak apps..."
"${SCRIPT_DIR}/capture-flatpak.sh"

echo "==> Capturing VS Code extensions..."
"${SCRIPT_DIR}/capture-vscode.sh"

echo "==> Capturing GNOME extensions..."
"${SCRIPT_DIR}/capture-gnome-extensions.sh"

echo "==> Capturing dconf settings..."
"${SCRIPT_DIR}/capture-dconf.sh"

echo ""
echo "Capture complete. Review changes with:  git -C \"${SCRIPT_DIR}/..\" status snapshots/"
