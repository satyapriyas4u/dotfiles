#!/usr/bin/env bash
# Interactive setup for the apt repositories needed by third-party packages
# (Chrome, VS Code, AnyDesk, Grafana, VirtualBox, Warp, Mongo Compass, Zoom,
# FortiClient, EdrawMax). Each block is opt-in — say `y` to add the repo,
# anything else to skip. Run this BEFORE `restore-apt-packages.sh` if you
# want those packages to install.

set -uo pipefail

if [[ "$(id -u)" -eq 0 ]]; then
    echo "Do not run this script as root. It uses sudo internally where needed."
    exit 1
fi

sudo install -d -m 755 /etc/apt/keyrings

ask() {
    local prompt="$1"
    read -r -p "Add repo for ${prompt}? [y/N] " ans
    [[ "$ans" =~ ^[Yy]$ ]]
}

setup_vscode() {
    ask "VS Code (microsoft.com)" || return
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc \
        | sudo gpg --dearmor -o /etc/apt/keyrings/packages.microsoft.gpg
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
        | sudo tee /etc/apt/sources.list.d/vscode.list >/dev/null
}

setup_chrome() {
    ask "Google Chrome (dl.google.com)" || return
    curl -fsSL https://dl.google.com/linux/linux_signing_key.pub \
        | sudo gpg --dearmor -o /etc/apt/keyrings/google-chrome.gpg
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] https://dl.google.com/linux/chrome/deb/ stable main" \
        | sudo tee /etc/apt/sources.list.d/google-chrome.list >/dev/null
}

setup_anydesk() {
    ask "AnyDesk (deb.anydesk.com)" || return
    curl -fsSL https://keys.anydesk.com/repos/DEB-GPG-KEY \
        | sudo gpg --dearmor -o /etc/apt/keyrings/anydesk.gpg
    echo "deb [signed-by=/etc/apt/keyrings/anydesk.gpg] http://deb.anydesk.com/ all main" \
        | sudo tee /etc/apt/sources.list.d/anydesk.list >/dev/null
}

setup_grafana() {
    ask "Grafana (apt.grafana.com)" || return
    curl -fsSL https://apt.grafana.com/gpg.key \
        | sudo gpg --dearmor -o /etc/apt/keyrings/grafana.gpg
    echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" \
        | sudo tee /etc/apt/sources.list.d/grafana.list >/dev/null
}

setup_virtualbox() {
    ask "Oracle VirtualBox" || return
    curl -fsSL https://www.virtualbox.org/download/oracle_vbox_2016.asc \
        | sudo gpg --dearmor -o /etc/apt/keyrings/oracle-virtualbox.gpg
    local codename
    codename="$(. /etc/os-release; echo "$VERSION_CODENAME")"
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/oracle-virtualbox.gpg] https://download.virtualbox.org/virtualbox/debian ${codename} contrib" \
        | sudo tee /etc/apt/sources.list.d/virtualbox.list >/dev/null
}

setup_warp() {
    ask "Warp Terminal (releases.warp.dev)" || return
    curl -fsSL https://releases.warp.dev/linux/keys/warp.asc \
        | sudo gpg --dearmor -o /etc/apt/keyrings/warpdotdev.gpg
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/warpdotdev.gpg] https://releases.warp.dev/linux/deb stable main" \
        | sudo tee /etc/apt/sources.list.d/warpdotdev.list >/dev/null
}

setup_speedtest() {
    ask "Ookla speedtest (packagecloud.io)" || return
    curl -fsSL https://packagecloud.io/ookla/speedtest-cli/gpgkey \
        | sudo gpg --dearmor -o /etc/apt/keyrings/ookla.gpg
    local codename
    codename="$(. /etc/os-release; echo "$VERSION_CODENAME")"
    echo "deb [signed-by=/etc/apt/keyrings/ookla.gpg] https://packagecloud.io/ookla/speedtest-cli/ubuntu/ ${codename} main" \
        | sudo tee /etc/apt/sources.list.d/speedtest.list >/dev/null
}

setup_vscode
setup_chrome
setup_anydesk
setup_grafana
setup_virtualbox
setup_warp
setup_speedtest

echo ""
echo "Running apt-get update..."
sudo apt-get update

cat <<'EOF'

Done. Repos with no apt source (manual .deb download):
  - MongoDB Compass:  https://www.mongodb.com/products/tools/compass
  - Zoom:             https://zoom.us/client/latest/zoom_amd64.deb
  - FortiClient:      https://www.fortinet.com/support/product-downloads (account)
  - EdrawMax:         https://www.edrawsoft.com/edraw-max/
  - OnlyOffice:       https://www.onlyoffice.com/download-desktop.aspx
  - Mattermost desk:  https://mattermost.com/download/#desktop
  - Terraform:        prefer `tenv` or HashiCorp's apt repo (apt.releases.hashicorp.com)

Now run:  ./installs/restore-apt-packages.sh
EOF
