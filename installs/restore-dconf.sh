#!/usr/bin/env bash
# Load every targeted dconf dump from snapshots/dconf/ into the new system.
# Files that don't exist in the snapshot are simply skipped.
#
# Run this *after* the apps that provide the settings are installed (e.g.
# gnome-terminal, gnome-shell-extension-manager), otherwise some keys will
# be written but ignored at runtime.

set -uo pipefail

DCONF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../snapshots" && pwd)/dconf"

load() {
    local file="${DCONF_DIR}/$1"
    local path="$2"
    if [ ! -s "$file" ]; then
        echo "  (skip)   $path — no snapshot"
        return
    fi
    echo "  loading $path"
    dconf load "$path" < "$file"
}

if ! command -v dconf &>/dev/null; then
    echo "dconf not installed; cannot restore settings."
    exit 1
fi

load gnome-terminal.dconf           /org/gnome/terminal/
load gnome-interface.dconf          /org/gnome/desktop/interface/
load gnome-input-sources.dconf      /org/gnome/desktop/input-sources/
load gnome-mutter.dconf             /org/gnome/mutter/
load gnome-wm-keybindings.dconf     /org/gnome/desktop/wm/keybindings/
load gnome-shell-keybindings.dconf  /org/gnome/shell/keybindings/
load gnome-media-keys.dconf         /org/gnome/settings-daemon/plugins/media-keys/

echo "dconf restore complete."
