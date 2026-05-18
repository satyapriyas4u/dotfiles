#!/usr/bin/env bash
# Reinstall flatpak applications from snapshots/flatpak-apps.txt (uses
# flathub as the remote; add it if missing).

set -uo pipefail

LIST="$(cd "$(dirname "${BASH_SOURCE[0]}")/../snapshots" && pwd)/flatpak-apps.txt"

if [ ! -s "$LIST" ]; then
    echo "No flatpak snapshot — nothing to install."
    exit 0
fi

if ! command -v flatpak &>/dev/null; then
    sudo apt-get install -y flatpak
fi

# Ensure flathub remote exists.
if ! flatpak remotes | grep -q '^flathub'; then
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
fi

while read -r app; do
    [ -z "$app" ] && continue
    if flatpak list --app --columns=application | grep -Fxq "$app"; then
        echo "  [skip] $app already installed"
        continue
    fi
    echo "Installing flatpak: $app"
    flatpak install -y flathub "$app" || echo "  [fail] $app"
done < "$LIST"
