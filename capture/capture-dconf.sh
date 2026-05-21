#!/usr/bin/env bash
# Dump targeted dconf branches (terminal, interface, keybindings, etc.).
# Empty dumps are deleted so the snapshot only reflects keys you've actually
# customized.

set -euo pipefail

DCONF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../snapshots" && pwd)/dconf"
mkdir -p "$DCONF_DIR"

if ! command -v dconf &>/dev/null; then
    echo "dconf not found; skipping."
    exit 0
fi

# path on disk (suffix)             dconf branch
dump() {
    local out="${DCONF_DIR}/$1"
    local path="$2"
    dconf dump "$path" > "$out"
    if [ ! -s "$out" ]; then
        rm -f "$out"
        echo "  (empty)     $path"
    else
        echo "  $(wc -l <"$out" | tr -d ' ')L  $path -> ${out#"$PWD/"}"
    fi
}

dump gnome-terminal.dconf            /org/gnome/terminal/
dump gnome-interface.dconf           /org/gnome/desktop/interface/
dump gnome-input-sources.dconf       /org/gnome/desktop/input-sources/
dump gnome-mutter.dconf              /org/gnome/mutter/
dump gnome-wm-preferences.dconf      /org/gnome/desktop/wm/preferences/
dump gnome-wm-keybindings.dconf      /org/gnome/desktop/wm/keybindings/
dump gnome-shell-app-switcher.dconf  /org/gnome/shell/app-switcher/
dump gnome-shell-window-switcher.dconf /org/gnome/shell/window-switcher/
dump gnome-shell-keybindings.dconf   /org/gnome/shell/keybindings/
dump gnome-media-keys.dconf          /org/gnome/settings-daemon/plugins/media-keys/
