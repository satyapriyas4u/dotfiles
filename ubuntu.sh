#!/usr/bin/env bash

# Ubuntu-specific configurations
# This script handles Ubuntu-specific setup tasks

echo "Running Ubuntu-specific configurations..."

# Update package manager
echo "Updating package lists..."
sudo apt-get update

# Ensure zsh is installed (in case it wasn't installed via packages)
if ! command -v nala &>/dev/null; then
    echo "Installing nala..."
    sudo apt-get install -y nala
fi

# Ensure zsh is installed (in case it wasn't installed via packages)
if ! command -v zsh &>/dev/null; then
    echo "Installing zsh..."
    sudo apt-get install -y zsh
fi

# Set zsh as default shell
echo "Setting zsh as default shell..."
ZSH_PATH=$(which zsh)
if [ "$SHELL" != "$ZSH_PATH" ]; then
    echo "Adding zsh to allowed shells if not already present..."
    if ! grep -Fxq "$ZSH_PATH" /etc/shells; then
        echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
    fi
    chsh -s "$ZSH_PATH"
    echo "Default shell changed to zsh."
else
    echo "zsh is already the default shell. Skipping configuration."
fi

# Git config name
current_name=$(git config --global --get user.name)
if [ -z "$current_name" ]; then
    echo "Please enter your FULL NAME for Git configuration:"
    read -r git_user_name
    git config --global user.name "$git_user_name"
    echo "Git user.name has been set to $git_user_name"
else
    echo "Git user.name is already set to '$current_name'. Skipping configuration."
fi

# Git config email
current_email=$(git config --global --get user.email)
if [ -z "$current_email" ]; then
    echo "Please enter your EMAIL for Git configuration:"
    read -r git_user_email
    git config --global user.email "$git_user_email"
    echo "Git user.email has been set to $git_user_email"
else
    echo "Git user.email is already set to '$current_email'. Skipping configuration."
fi

# Github uses "main" as the default branch name
git config --global init.defaultBranch main

# Check if already authenticated with GitHub to avoid re-authentication prompt
if ! gh auth status &>/dev/null; then
    echo "You will need to authenticate with GitHub. Follow the prompts to login..."
    gh auth login
else
    echo "Already authenticated with GitHub. Skipping login."
fi

# Create the tutorial virtual environment
python3 -m venv "${HOME}/tutorial"
echo "Tutorial virtual environment created at ~/tutorial"

# --------------------------------------------------------------------------
# Snapshot-based restore (apt list, snap, flatpak, vscode extensions,
# gnome extensions, dconf). Skip with SKIP_RESTORE=1 if you only want the
# base setup above.
# --------------------------------------------------------------------------
if [ -z "${SKIP_RESTORE:-}" ] && [ -d "${dotfiledir:-${HOME}/dotfiles}/snapshots" ]; then
    DOTDIR="${dotfiledir:-${HOME}/dotfiles}"
    echo ""
    echo "==> Restoring system state from snapshots/"

    if [ -f "${DOTDIR}/snapshots/THIRD-PARTY-REPOS.md" ]; then
        echo "    NOTE: Some apt packages need third-party repos."
        echo "          See ${DOTDIR}/snapshots/THIRD-PARTY-REPOS.md"
        echo "          and set them up before running this section."
        echo ""
        read -r -p "    Continue with snapshot restore now? [y/N] " ans
        if [[ ! "$ans" =~ ^[Yy]$ ]]; then
            echo "    Skipping snapshot restore. Re-run installs/restore-*.sh manually."
            SKIP_RESTORE=1
        fi
    fi

    if [ -z "${SKIP_RESTORE:-}" ]; then
        "${DOTDIR}/installs/restore-apt-packages.sh"
        "${DOTDIR}/installs/restore-snap-packages.sh"
        "${DOTDIR}/installs/restore-flatpak-apps.sh"
        # VS Code extensions / GNOME extensions / dconf are handled after
        # editor + GNOME tooling are confirmed present; see install.sh.
    fi
fi

echo "Ubuntu-specific configuration complete!"
