#!/usr/bin/env bash

# Ubuntu-specific configurations
# This script handles Ubuntu-specific setup tasks

echo "Running Ubuntu-specific configurations..."

# Update package manager
echo "Updating package lists..."
sudo apt-get update

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

echo "Ubuntu-specific configuration complete!"
