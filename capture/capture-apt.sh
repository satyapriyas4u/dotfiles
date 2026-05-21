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

# Strip packages that don't exist in the default Ubuntu 24.04 archive (so a
# fresh-laptop apt restore doesn't fail on them):
#   - libappindicator1, libdbusmenu-gtk4: removed upstream / renamed
#   - linux-(headers|modules)-X.Y.Z-NNNNNN[-generic]: mainline-PPA kernels,
#     installed by hand from kernel.ubuntu.com — not available via apt
#   - pulseaudio, pulseaudio-utils: 24.04 ships pipewire by default; pulling
#     pulseaudio in removes pipewire-audio (audio will be silently broken)
#   - speedtest: Ookla's apt repo (`packages.ookla.com`), not Ubuntu's
apt-mark showmanual \
    | grep -Ev '^(libappindicator1|libdbusmenu-gtk4|linux-headers-[0-9.]+-[0-9]+(-generic)?|linux-modules-[0-9.]+-[0-9]+-generic|pulseaudio|pulseaudio-utils|speedtest)$' \
    | sort > "$OUT"
echo "  wrote $(wc -l <"$OUT") packages -> ${OUT#"$PWD/"}"
