#!/bin/bash
# install-vscode.sh
# This script installs Visual Studio Code on a Debian/Ubuntu system.
# Save this file and run it with sudo:
#   sudo ./install-vscode.sh

# Exit immediately if any command fails.
set -e

# Check if the script is run as root.
if [[ "$EUID" -ne 0 ]]; then
  echo "This script must be run as root. Please run using sudo."
  exit 1
fi

echo "Updating package lists..."
apt-get update

echo "Installing required dependencies..."
apt-get install -y software-properties-common apt-transport-https wget

echo "Importing the Microsoft GPG key..."
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/packages.microsoft.gpg
install -o root -g root -m 644 /tmp/packages.microsoft.gpg /etc/apt/trusted.gpg.d/
rm /tmp/packages.microsoft.gpg

echo "Adding the Visual Studio Code repository..."
sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

echo "Updating package lists..."
apt-get update

echo "Installing Visual Studio Code..."
apt-get install -y code

echo "Visual Studio Code installation completed successfully!"
