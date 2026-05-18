#!/usr/bin/env bash
# Reinstall GNOME Shell extensions from extensions.gnome.org using
# gnome-extensions-cli (`gext`), then apply the captured dconf settings.
#
# This must be run inside a desktop GNOME session (gnome-extensions itself
# talks to the running shell). Some extensions ship as part of
# `gnome-shell-extensions` (apt) or come bundled with Ubuntu and don't need
# a separate install — the script will skip those automatically.

set -uo pipefail

SNAP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../snapshots" && pwd)"
LIST="${SNAP_DIR}/gnome-extensions-enabled.txt"
SETTINGS="${SNAP_DIR}/dconf/gnome-shell-extensions.dconf"

if [ ! -s "$LIST" ]; then
    echo "No gnome extension snapshot — nothing to install."
    exit 0
fi

if ! command -v gnome-extensions &>/dev/null; then
    echo "gnome-extensions CLI not found. Install gnome-shell first."
    exit 1
fi

# gnome-extensions-cli is a separate tool that can install from the website
# (`gext install <uuid>`). Install it via pipx if missing.
if ! command -v gext &>/dev/null; then
    if ! command -v pipx &>/dev/null; then
        echo "pipx not found; installing..."
        sudo apt-get install -y pipx
        pipx ensurepath
        export PATH="${HOME}/.local/bin:${PATH}"
    fi
    echo "Installing gnome-extensions-cli..."
    pipx install gnome-extensions-cli --system-site-packages
    export PATH="${HOME}/.local/bin:${PATH}"
fi

echo "Installing GNOME extensions from $LIST..."
while read -r uuid; do
    [ -z "$uuid" ] && continue
    # Skip extensions that are already installed (e.g. shipped by Ubuntu).
    if gnome-extensions info "$uuid" &>/dev/null; then
        echo "  [skip] $uuid (already installed)"
        gnome-extensions enable "$uuid" 2>/dev/null || true
        continue
    fi
    echo "Installing: $uuid"
    if ! gext install "$uuid"; then
        echo "  [fail] $uuid (not on extensions.gnome.org or incompatible with this GNOME version)"
    fi
done < "$LIST"

# Apply per-extension dconf settings.
if [ -s "$SETTINGS" ]; then
    echo "Loading per-extension dconf settings..."
    dconf load /org/gnome/shell/extensions/ < "$SETTINGS"
fi

# Restore the enabled-extensions array (preserves UUIDs that gext couldn't
# install — they'll just be inactive until installed manually).
if [ -s "${SNAP_DIR}/dconf/gnome-shell-enabled-extensions.txt" ]; then
    dconf write /org/gnome/shell/enabled-extensions "$(cat "${SNAP_DIR}/dconf/gnome-shell-enabled-extensions.txt")"
fi

echo ""
echo "Done. You may need to log out and back in for the shell to pick up new extensions."
