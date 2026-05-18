#!/usr/bin/env bash
# Reinstall every apt package recorded in snapshots/apt-packages.txt.
# apt skips packages that are already present, so this is safe to re-run.
#
# Some packages (google-chrome-stable, code, anydesk, grafana, edrawmax,
# forticlient, etc.) live in third-party repos. Set those up FIRST or those
# lines will simply fail and be reported at the end; the rest will still
# install. See snapshots/THIRD-PARTY-REPOS.md for repo-setup instructions.

set -uo pipefail

LIST="$(cd "$(dirname "${BASH_SOURCE[0]}")/../snapshots" && pwd)/apt-packages.txt"

if [ ! -s "$LIST" ]; then
    echo "No apt snapshot at $LIST — run capture/capture-apt.sh first."
    exit 1
fi

echo "Updating package lists..."
sudo apt-get update

echo "Installing $(wc -l <"$LIST") packages from snapshot..."
failed=()
while read -r pkg; do
    [ -z "$pkg" ] && continue
    if dpkg -l 2>/dev/null | awk '{print $2}' | grep -Fxq "$pkg"; then
        echo "  [skip] $pkg already installed"
        continue
    fi
    if ! sudo apt-get install -y "$pkg"; then
        echo "  [fail] $pkg"
        failed+=("$pkg")
    fi
done < "$LIST"

if [ "${#failed[@]}" -gt 0 ]; then
    echo ""
    echo "The following packages failed to install (likely need third-party repos):"
    printf '  - %s\n' "${failed[@]}"
    echo ""
    echo "See snapshots/THIRD-PARTY-REPOS.md for repo-setup instructions, then re-run."
fi
