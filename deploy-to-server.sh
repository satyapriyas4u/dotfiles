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

# Symlink dotfiles only — skip GNOME/apt/snap/package restore.
# Run twice: oh-my-zsh installer may rewrite ~/.zshrc after the first pass.
chmod +x ~/dotfiles/install.sh
~/dotfiles/install.sh --links-only
~/dotfiles/install.sh --links-only

# Hard-copy .p10k.zsh if the symlink is broken or unreadable (e.g. on first
# deploy before the dotfiles path is fully resolved by the new shell).
if [[ ! -r ~/.p10k.zsh ]]; then
    cp ~/dotfiles/.p10k.zsh ~/.p10k.zsh
    echo "Copied .p10k.zsh directly (symlink was not readable)"
fi

# Clear stale instant prompt cache — if it was created before .p10k.zsh existed
# it replays the wizard warning on every terminal start. Always regenerate.
rm -f ~/.cache/p10k-instant-prompt-*.zsh ~/.cache/p10k-instant-prompt-*.zsh.zwc
echo "Cleared p10k instant prompt cache (will regenerate on next terminal open)."

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
