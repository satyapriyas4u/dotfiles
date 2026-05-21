#!/usr/bin/env bash

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS_TYPE="macOS"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS_TYPE="Linux"
fi

# Check if Homebrew's bin exists and if it's not already in the PATH (macOS only)
if [ "$OS_TYPE" = "macOS" ] && [ -x "/opt/homebrew/bin/brew" ] && [[ ":$PATH:" != *":/opt/homebrew/bin:"* ]]; then
    export PATH="/opt/homebrew/bin:$PATH"
fi

# Check if VS Code is installed. On Linux, offer to install from the snap
# store as a fallback (works without the Microsoft apt repo). On macOS we
# don't auto-install — that's brew.sh's job.
if ! command -v code &>/dev/null; then
    if [ "$OS_TYPE" = "Linux" ] && command -v snap &>/dev/null; then
        read -r -p "VS Code is not installed. Install via 'snap install code --classic'? [y/N] " ans
        if [[ "$ans" =~ ^[Yy]$ ]]; then
            sudo snap install code --classic
        fi
    fi
    if ! command -v code &>/dev/null; then
        echo "VS Code still not installed. Skipping VS Code setup..."
        echo "  (Either set up the Microsoft apt repo via installs/setup-third-party-repos.sh,"
        echo "   or install the snap manually: sudo snap install code --classic)"
        exit 0
    fi
fi

# Install VS Code extensions from the captured snapshot. The list is
# refreshed by `./capture/capture-vscode.sh`.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -x "${SCRIPT_DIR}/installs/restore-vscode-extensions.sh" ]; then
    "${SCRIPT_DIR}/installs/restore-vscode-extensions.sh"
else
    echo "restore-vscode-extensions.sh not found; skipping extension install."
fi

# Define the target directory for VS Code user settings based on OS
if [ "$OS_TYPE" = "macOS" ]; then
    VSCODE_USER_SETTINGS_DIR="${HOME}/Library/Application Support/Code/User"
elif [ "$OS_TYPE" = "Linux" ]; then
    VSCODE_USER_SETTINGS_DIR="${HOME}/.config/Code/User"
fi

# Check if VS Code settings directory exists
if [ -d "$VSCODE_USER_SETTINGS_DIR" ]; then
    # Copy your custom settings.json and keybindings.json to the VS Code settings directory
    ln -sf "${HOME}/dotfiles/settings/VSCode-Settings.json" "${VSCODE_USER_SETTINGS_DIR}/settings.json"
    ln -sf "${HOME}/dotfiles/settings/VSCode-Keybindings.json" "${VSCODE_USER_SETTINGS_DIR}/keybindings.json"

    echo "VS Code settings and keybindings have been updated."
else
    echo "VS Code user settings directory does not exist. Please ensure VS Code is installed and has been opened at least once."
fi

# Open VS Code to sign-in to extensions
code .
echo "Login to extensions (Copilot, Grammarly, etc) within VS Code."
echo "Press enter to continue..."
read
