#!/usr/bin/env bash
# Deploy dotfiles to a remote server and replicate your zsh/p10k environment.
# Fonts are NOT installed on the remote — VS Code renders them from your local machine.
#
# Usage:
#   ./deploy-to-server.sh <ssh-host>
#
# Examples:
#   ./deploy-to-server.sh nuvoai-server-jhelum
#   ./deploy-to-server.sh nuvoai-server-saryu

set -e

HOST="${1:?Usage: $0 <ssh-host>  (use any Host name from ssh/config)}"
DOTDIR="${HOME}/dotfiles"

echo "==> Syncing dotfiles to ${HOST}:~/dotfiles/ ..."
rsync -az --progress \
    --exclude '.git' \
    --exclude 'snapshots/' \
    --exclude 'settings/Desktop.png' \
    "${DOTDIR}/" \
    "${HOST}:~/dotfiles/"

echo ""
echo "==> Running remote setup on ${HOST} ..."
ssh "$HOST" 'bash -s' <<'REMOTE'
set -e

# Install dependencies if missing
MISSING=()
command -v zsh  &>/dev/null || MISSING+=(zsh)
command -v git  &>/dev/null || MISSING+=(git)
command -v curl &>/dev/null || MISSING+=(curl)

if [ ${#MISSING[@]} -gt 0 ]; then
    echo "Installing: ${MISSING[*]}"
    sudo apt-get update -qq
    sudo apt-get install -y "${MISSING[@]}"
fi

# Install Oh My Zsh + Powerlevel10k + completion plugins (no fonts on server)
chmod +x ~/dotfiles/installs/install-zsh-p10k.sh
~/dotfiles/installs/install-zsh-p10k.sh --no-fonts

# Symlink dotfiles only — skip GNOME/apt/snap/package restore
chmod +x ~/dotfiles/install.sh
~/dotfiles/install.sh --links-only

# Set zsh as default shell
ZSH_PATH=$(which zsh)
if [ "$SHELL" != "$ZSH_PATH" ]; then
    if ! grep -Fxq "$ZSH_PATH" /etc/shells 2>/dev/null; then
        echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
    fi
    chsh -s "$ZSH_PATH"
    echo "Default shell set to zsh."
else
    echo "zsh is already the default shell."
fi

echo ""
echo "Setup complete on $(hostname)!"
echo "Open VS Code → Remote SSH → connect to this host → open terminal."
REMOTE

echo ""
echo "Done! Connect via VS Code Remote SSH:"
echo "  Host: ${HOST}"
echo "  The integrated terminal will use zsh + p10k + syntax highlighting."
