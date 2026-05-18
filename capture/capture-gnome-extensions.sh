#!/usr/bin/env bash
# Capture GNOME Shell extensions:
#   - enabled UUIDs (authoritative list from dconf, includes anything still
#     referenced in /org/gnome/shell/enabled-extensions even if not currently
#     listed by `gnome-extensions list`)
#   - their per-extension dconf settings under /org/gnome/shell/extensions/
#
# Restore reinstalls each UUID fresh from extensions.gnome.org via
# gnome-extensions-cli, then loads the dconf dump.

set -euo pipefail

SNAP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../snapshots" && pwd)"
DCONF_DIR="${SNAP_DIR}/dconf"
mkdir -p "$DCONF_DIR"

if ! command -v gnome-extensions &>/dev/null; then
    echo "gnome-extensions CLI not found; skipping."
    exit 0
fi

# Plain text list (one UUID per line) for human review / scripting.
gnome-extensions list --enabled | sort > "${SNAP_DIR}/gnome-extensions-enabled.txt"
echo "  wrote $(wc -l <"${SNAP_DIR}/gnome-extensions-enabled.txt") enabled extensions"

# Authoritative dconf values (preserve the GVariant arrays as-is).
dconf read /org/gnome/shell/enabled-extensions  > "${DCONF_DIR}/gnome-shell-enabled-extensions.txt"
dconf read /org/gnome/shell/disabled-extensions > "${DCONF_DIR}/gnome-shell-disabled-extensions.txt" || true

# Per-extension settings.
dconf dump /org/gnome/shell/extensions/ > "${DCONF_DIR}/gnome-shell-extensions.dconf"
echo "  wrote dconf settings -> ${DCONF_DIR#"$PWD/"}/gnome-shell-extensions.dconf"
