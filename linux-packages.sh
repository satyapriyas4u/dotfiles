#!/usr/bin/env bash

# Ubuntu/Debian Linux package installation script
# Installs development tools, CLI utilities, and applications

echo "Starting Ubuntu/Debian package installation..."

# Update package manager
echo "Updating package lists..."
sudo apt-get update

# Define an array of packages to install using apt
packages=(
    "python3"
    "python3-dev"
    "python3-pip"
    "python3-venv"
    "tcl"
    "tk"
    "bash"
    "zsh"
    "coreutils"
    "git"
    "tree"
    "curl"
    "wget"
    "build-essential"
    "imagemagick"
    "ffmpeg"
    "ripgrep"
    "gh"
)

# Loop over the array to install each package
for package in "${packages[@]}"; do
    if dpkg -l | grep -q "^ii  $package "; then
        echo "$package is already installed. Skipping..."
    else
        echo "Installing $package..."
        sudo apt-get install -y "$package"
    fi
done

# Install Node.js via NodeSource repository if not already installed
if ! command -v node &>/dev/null; then
    echo "Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt-get install -y nodejs
else
    echo "Node.js is already installed. Skipping..."
fi

# Install pipx for Python tools
if ! command -v pipx &>/dev/null; then
    echo "Installing pipx..."
    sudo apt-get install -y python3-pip python3-venv
    python3 -m pip install --user pipx
    # Ensure pipx is in PATH
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        export PATH="$HOME/.local/bin:$PATH"
    fi
else
    echo "pipx is already installed. Skipping..."
fi

# Install uv (faster replacement for pip)
if ! command -v uv &>/dev/null; then
    echo "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
else
    echo "uv is already installed. Skipping..."
fi

# Install Prettier globally via npm
if ! npm list -g prettier &>/dev/null; then
    echo "Installing Prettier..."
    npm install --global prettier
else
    echo "Prettier is already installed. Skipping..."
fi

# Install ESLint globally via npm
if ! npm list -g eslint &>/dev/null; then
    echo "Installing ESLint..."
    npm install --global eslint
else
    echo "ESLint is already installed. Skipping..."
fi

# Install DJLint via pipx
if ! command -v djlint &>/dev/null; then
    echo "Installing DJLint..."
    pipx install djlint
else
    echo "DJLint is already installed. Skipping..."
fi

# Install Ruff via uv
if ! command -v ruff &>/dev/null; then
    echo "Installing Ruff..."
    uv tool install ruff
else
    echo "Ruff is already installed. Skipping..."
fi

# Install VS Code (optional - user can do this manually or via snap)
if ! command -v code &>/dev/null; then
    echo ""
    echo "Visual Studio Code is not installed."
    echo "You can install it using one of these methods:"
    echo "1. Via snap: sudo snap install code --classic"
    echo "2. Via apt (Microsoft repository): https://code.visualstudio.com/docs/setup/linux"
    echo ""
else
    echo "Visual Studio Code is already installed."
fi

# Install Sublime Text (optional)
if ! command -v subl &>/dev/null; then
    echo ""
    echo "Sublime Text is not installed."
    echo "You can install it using:"
    echo "sudo snap install sublime-text --classic"
    echo ""
else
    echo "Sublime Text is already installed."
fi

# Clean up
echo "Cleaning up..."
sudo apt-get autoremove -y
sudo apt-get clean

echo "Package installation complete!"
