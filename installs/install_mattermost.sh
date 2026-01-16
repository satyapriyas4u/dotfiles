#!/bin/bash

set -e  # Exit on error

echo "=== Mattermost Desktop Installation Script ==="
echo "Updating system and adding Mattermost repository..."

# Add Mattermost repo
curl -fsS -o- https://deb.packages.mattermost.com/setup-repo.sh | sudo bash

echo "=== Installing Mattermost Desktop... ==="
sudo apt install -y mattermost-desktop

echo "=== Upgrading Mattermost Desktop to latest version... ==="
sudo apt upgrade -y mattermost-desktop

echo "=== Installation complete! ==="
