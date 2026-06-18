# Third-Party APT Repositories

Some packages in [apt-packages.txt](apt-packages.txt) live outside the default
Ubuntu archives. Set up these repositories on the new laptop **before** running
`installs/restore-apt-packages.sh`, otherwise those packages will be reported
as failures (the rest will still install).

**Easiest path:** run the interactive helper instead of pasting from below:

```bash
./installs/setup-third-party-repos.sh
```

It walks you through each repo with a y/N prompt and runs `apt update` at the
end. The manual blocks below are the fallback / reference.

## VS Code (`code`)

```bash
sudo install -D -o root -g root -m 644 \
    <(curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor) \
    /etc/apt/keyrings/packages.microsoft.gpg
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
    | sudo tee /etc/apt/sources.list.d/vscode.list
sudo apt update
```

## Google Chrome (`google-chrome-stable`)

```bash
wget -qO- https://dl.google.com/linux/linux_signing_key.pub \
    | sudo gpg --dearmor -o /etc/apt/keyrings/google-chrome.gpg
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] https://dl.google.com/linux/chrome/deb/ stable main" \
    | sudo tee /etc/apt/sources.list.d/google-chrome.list
sudo apt update
```

## AnyDesk (`anydesk`)

```bash
wget -qO- https://keys.anydesk.com/repos/DEB-GPG-KEY \
    | sudo gpg --dearmor -o /etc/apt/keyrings/anydesk.gpg
echo "deb [signed-by=/etc/apt/keyrings/anydesk.gpg] http://deb.anydesk.com/ all main" \
    | sudo tee /etc/apt/sources.list.d/anydesk.list
sudo apt update
```

## Grafana (`grafana`)

```bash
wget -qO- https://apt.grafana.com/gpg.key \
    | sudo gpg --dearmor -o /etc/apt/keyrings/grafana.gpg
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" \
    | sudo tee /etc/apt/sources.list.d/grafana.list
sudo apt update
```

## VirtualBox (`virtualbox-7.1`)

```bash
wget -qO- https://www.virtualbox.org/download/oracle_vbox_2016.asc \
    | sudo gpg --dearmor -o /etc/apt/keyrings/oracle-virtualbox.gpg
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/oracle-virtualbox.gpg] https://download.virtualbox.org/virtualbox/debian $(. /etc/os-release; echo "$VERSION_CODENAME") contrib" \
    | sudo tee /etc/apt/sources.list.d/virtualbox.list
sudo apt update
```

## MongoDB Compass (`mongodb-compass`)

Direct `.deb` download — no recurring repo:

```bash
wget https://downloads.mongodb.com/compass/mongodb-compass_1.46.4_amd64.deb -O /tmp/compass.deb
sudo apt install -y /tmp/compass.deb
```

## GitHub CLI (`gh`)

```bash
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
sudo apt update
```

## Warp Terminal (`warp-terminal`)

```bash
wget -qO- https://releases.warp.dev/linux/keys/warp.asc \
    | sudo gpg --dearmor -o /etc/apt/keyrings/warpdotdev.gpg
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/warpdotdev.gpg] https://releases.warp.dev/linux/deb stable main" \
    | sudo tee /etc/apt/sources.list.d/warpdotdev.list
sudo apt update
```

## Zoom (`zoom`)

Direct `.deb` download:

```bash
wget https://zoom.us/client/latest/zoom_amd64.deb -O /tmp/zoom.deb
sudo apt install -y /tmp/zoom.deb
```

## FortiClient (`forticlient`)

Fortinet doesn't ship a public apt repo. Download the latest `.deb` from
<https://www.fortinet.com/support/product-downloads> (account required), then:

```bash
sudo apt install -y ./forticlient_<version>_amd64.deb
```

## EdrawMax (`edrawmax`)

No apt repo. Download from <https://www.edrawsoft.com/edraw-max/> and install
the `.deb` manually.

---

After setting up the repos you actually need, run:

```bash
./installs/restore-apt-packages.sh
```
